import 'dart:async';
import 'dart:math';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/repositories/progression_repository.dart';
import 'package:fixit/core/repositories/daily_repository.dart';
import 'package:fixit/core/utils/app_logger.dart';
import 'package:fixit/core/models/daily_mode.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  Timer? _rechargeTimer;
  Timer? _midnightTimer;
  AppDatabase get _db => DatabaseService().db;
  final _progressionRepo = ProgressionRepository();
  final _dailyRepo = DailyRepository();

  HomeBloc() : super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<ToggleMusic>(_onToggleMusic);
    on<ToggleSound>(_onToggleSound);
    on<WatchVideoForLife>(_onWatchVideoForLife);
    on<BuyLives>(_onBuyLives);
    on<BuyItem>(_onBuyItem);
    on<BuyPuzzlePack>(_onBuyPuzzlePack);
    on<ClaimDailyPuzzle>(_onClaimDailyPuzzle);
    on<BuyNoAds>(_onBuyNoAds);
    on<TickLifeRecharge>(_onTickLifeRecharge);
    on<CompleteLevel>(_onCompleteLevel);
    on<LoseLife>(_onLoseLife);
    on<ChangeWorld>(_onChangeWorld);
    on<MidnightReached>(_onMidnightReached);
    on<FinishWorldLoading>(_onFinishWorldLoading);
    on<AppResumed>(_onAppResumed);
    on<DebugSetLevel>(_onDebugSetLevel);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    AppLogger.log('HomeBloc: Loading data for player: ${event.playerId}');
    emit(state.copyWith(isLoading: true));
    try {
      await _refreshProgression(emit, event.playerId);
      _startRechargeTimer();
      _startMidnightTimer();
      AppLogger.log('HomeBloc: Data loaded successfully');
    } catch (e) {
      AppLogger.error('HomeBloc: Error loading data', e);
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onMidnightReached(MidnightReached event, Emitter<HomeState> emit) async {
    AppLogger.log('Midnight UTC reached. Refreshing home data...');
    final user = DatabaseService().supabase.auth.currentUser;
    await _refreshProgression(emit, user?.id);
    _startMidnightTimer(); // Schedule next midnight
  }

  void _startMidnightTimer() {
    _midnightTimer?.cancel();
    final secondsUntilMidnight = _dailyRepo.getSecondsUntilMidnight();
    AppLogger.log('Scheduling midnight refresh in $secondsUntilMidnight seconds.');
    
    _midnightTimer = Timer(Duration(seconds: secondsUntilMidnight + 1), () {
      add(MidnightReached());
    });
  }

  Future<void> _savePlayerLives(int lives, DateTime? lastLifeLostAt, String? playerId) async {
    try {
      final companion = PlayersCompanion(
        lives: drift.Value(lives),
        lastLifeLostAt: drift.Value(lastLifeLostAt),
      );

      final query = _db.update(_db.players);
      if (playerId != null && playerId.isNotEmpty) {
        query.where((t) => t.supabaseId.equals(playerId));
      } else {
        query.where((t) => t.id.isNotNull());
      }
      await query.write(companion);

      if (playerId != null && playerId.isNotEmpty) {
        try {
          await DatabaseService().supabase.from('profiles').update({
            'lives': lives,
            'last_life_lost_at': lastLifeLostAt?.toIso8601String(),
          }).eq('id', playerId);
        } catch (e) {
          AppLogger.error('Error syncing lives to Supabase', e);
        }
      }
    } catch (e) {
      AppLogger.error('Error saving player lives', e);
    }
  }

  Future<void> _refreshProgression(Emitter<HomeState> emit, String? playerId) async {
    AppLogger.log('HomeBloc: Refreshing progression...');
    // 1. Fetch player data
    List<Player> players = [];
    try {
      final query = _db.select(_db.players);
      if (playerId != null && playerId.isNotEmpty) {
        query.where((t) => t.supabaseId.equals(playerId));
      } else {
        query.where((t) => t.id.isNotNull());
      }
      query.limit(1);

      players = await query.get();
    } catch (e) {
      AppLogger.error('HomeBloc: Error reading local players', e);
    }
    
    if (players.isNotEmpty) {
      final player = players.first;
      AppLogger.log('HomeBloc: Found local player: ${player.username}');
      
      // 2. Fetch progression for THIS specific player
      final playerSupabaseId = player.supabaseId ?? '';
      final progs = await (_db.select(_db.progressions)
            ..where((t) => t.playerSupabaseId.equals(playerSupabaseId))
            ..limit(1))
          .get();
      
      final progression = progs.isNotEmpty ? progs.first : null;
      AppLogger.log('HomeBloc: Progression level: ${progression?.currentLevel ?? 1}');

      // 3. Persistent Life Recovery Calculation
      int lives = player.lives;
      DateTime? lastLifeLostAt = player.lastLifeLostAt;
      DateTime? nextLifeTime;
      final now = DateTime.now();

      if (lives < state.maxLives) {
        if (lastLifeLostAt == null) {
          lastLifeLostAt = now;
          await _savePlayerLives(lives, lastLifeLostAt, player.supabaseId);
        }

        final elapsedMinutes = now.difference(lastLifeLostAt).inMinutes;
        final livesGained = elapsedMinutes ~/ 60;

        if (livesGained > 0) {
          lives = min(state.maxLives, lives + livesGained);
          if (lives == state.maxLives) {
            lastLifeLostAt = null;
            nextLifeTime = null;
          } else {
            lastLifeLostAt = lastLifeLostAt.add(Duration(minutes: livesGained * 60));
            nextLifeTime = lastLifeLostAt.add(const Duration(minutes: 60));
          }
          await _savePlayerLives(lives, lastLifeLostAt, player.supabaseId);
        } else {
          nextLifeTime = lastLifeLostAt.add(const Duration(minutes: 60));
        }
      } else {
        if (lastLifeLostAt != null) {
          lastLifeLostAt = null;
          await _savePlayerLives(lives, null, player.supabaseId);
        }
        nextLifeTime = null;
      }

      unawaited(_progressionRepo.ensureNextLevelsExist('world_1', progression?.currentLevel ?? 1));

      // Fetch Daily Status
      final dailyStatus = await _dailyRepo.getDailyStatus(playerSupabaseId);

      // Determine unlocked worlds
      final Set<String> unlocked = {'meadow'};
      if (progression != null) {
        if (progression.currentLevel > 10) unlocked.add('desert');
        if (progression.currentLevel > 20) unlocked.add('ice');
      }

      // Progression calculation logic:
      // World 1 (Meadow): Levels 1-10
      // World 2 (Desert): Levels 1-10 (offset from global 11)
      // We use currentWorldIndex to filter logic in the UI
      
      int levelsInWorld = 0;
      if (progression != null) {
        if (state.currentWorldIndex == 1) {
          levelsInWorld = min(10, progression.currentLevel - 1);
        } else if (state.currentWorldIndex == 2) {
          levelsInWorld = progression.currentLevel > 10 ? (progression.currentLevel - 11) : 0;
        } else if (state.currentWorldIndex == 3) {
          levelsInWorld = progression.currentLevel > 20 ? (progression.currentLevel - 21) : 0;
        }
      }

      emit(state.copyWith(
        lives: lives,
        nextLifeTime: nextLifeTime,
        puzzlePieces: player.puzzlePieces,
        itemPlusTime: player.itemPlusTime,
        itemMoreNumbers: player.itemMoreNumbers,
        itemRevealPath: player.itemRevealPath,
        currentLevel: progression?.currentLevel ?? 1,
        levelsCompletedInWorld: levelsInWorld,
        isLoading: false,
        currentDate: _dailyRepo.getTodayWorldId(), 
        isDailyCompleted: dailyStatus?.isDailyLevelCompleted ?? false,
        isSeriesCompleted: dailyStatus?.isSeriesCompleted ?? false,
        unlockedWorlds: unlocked,
      ));
    } else {
      AppLogger.log('HomeBloc: No local player found yet. Resetting to initial state.');
      emit(const HomeState());
    }
  }

  void _onToggleMusic(ToggleMusic event, Emitter<HomeState> emit) {
    emit(state.copyWith(isMusicEnabled: !state.isMusicEnabled));
  }

  void _onToggleSound(ToggleSound event, Emitter<HomeState> emit) {
    emit(state.copyWith(isSoundEnabled: !state.isSoundEnabled));
  }

  Future<void> _onWatchVideoForLife(WatchVideoForLife event, Emitter<HomeState> emit) async {
    if (state.videosWatched < 3 && state.lives < state.maxLives) {
      final newLives = state.lives + 1;
      final user = DatabaseService().supabase.auth.currentUser;
      DateTime? newLastLifeLostAt;
      DateTime? nextTime;

      if (newLives < state.maxLives) {
        final players = await (_db.select(_db.players)..limit(1)).get();
        final currentLastAt = players.isNotEmpty ? players.first.lastLifeLostAt : null;
        if (currentLastAt != null) {
          newLastLifeLostAt = currentLastAt.add(const Duration(minutes: 60));
          nextTime = newLastLifeLostAt.add(const Duration(minutes: 60));
        }
      }

      await _savePlayerLives(newLives, newLastLifeLostAt, user?.id);

      emit(state.copyWith(
        lives: newLives,
        nextLifeTime: nextTime,
        videosWatched: state.videosWatched + 1,
      ));
    }
  }

  Future<void> _onBuyLives(BuyLives event, Emitter<HomeState> emit) async {
    int newLives = state.lives + event.count;
    if (newLives > state.maxLives) newLives = state.maxLives;
    final user = DatabaseService().supabase.auth.currentUser;

    DateTime? newLastLifeLostAt;
    DateTime? nextTime;
    if (newLives < state.maxLives) {
      final players = await (_db.select(_db.players)..limit(1)).get();
      final currentLastAt = players.isNotEmpty ? players.first.lastLifeLostAt : null;
      if (currentLastAt != null) {
        newLastLifeLostAt = currentLastAt.add(Duration(minutes: event.count * 60));
        nextTime = newLastLifeLostAt.add(const Duration(minutes: 60));
      }
    }

    await _savePlayerLives(newLives, newLastLifeLostAt, user?.id);
    emit(state.copyWith(lives: newLives, nextLifeTime: nextTime));
  }

  Future<void> _onBuyItem(BuyItem event, Emitter<HomeState> emit) async {
    int newPuzzles = state.puzzlePieces;
    if (!event.isRealMoney) {
      if (state.puzzlePieces < event.cost) return;
      newPuzzles = state.puzzlePieces - event.cost;
    }

    int plusTime = state.itemPlusTime;
    int moreNums = state.itemMoreNumbers;
    int revealPath = state.itemRevealPath;

    if (event.itemKey == 'plus_time') plusTime++;
    if (event.itemKey == 'more_numbers') moreNums++;
    if (event.itemKey == 'reveal_path') revealPath++;

    await (_db.update(_db.players)..where((t) => t.id.isNotNull())).write(
      PlayersCompanion(
        puzzlePieces: drift.Value(newPuzzles),
        itemPlusTime: drift.Value(plusTime),
        itemMoreNumbers: drift.Value(moreNums),
        itemRevealPath: drift.Value(revealPath),
      ),
    );

    emit(state.copyWith(
      puzzlePieces: newPuzzles,
      itemPlusTime: plusTime,
      itemMoreNumbers: moreNums,
      itemRevealPath: revealPath,
    ));
  }

  Future<void> _onBuyPuzzlePack(BuyPuzzlePack event, Emitter<HomeState> emit) async {
    final newPuzzles = state.puzzlePieces + event.count;
    await (_db.update(_db.players)..where((t) => t.id.isNotNull())).write(
      PlayersCompanion(puzzlePieces: drift.Value(newPuzzles)),
    );
    emit(state.copyWith(puzzlePieces: newPuzzles));
  }

  Future<void> _onClaimDailyPuzzle(ClaimDailyPuzzle event, Emitter<HomeState> emit) async {
    final now = DateTime.now();
    if (state.lastDailyPuzzleAt != null &&
        now.difference(state.lastDailyPuzzleAt!).inHours < 24) {
      return;
    }

    final newPuzzles = state.puzzlePieces + 10;
    emit(state.copyWith(
      puzzlePieces: newPuzzles,
      lastDailyPuzzleAt: now,
    ));
    await (_db.update(_db.players)..where((t) => t.id.isNotNull())).write(
      PlayersCompanion(puzzlePieces: drift.Value(newPuzzles)),
    );
  }

  void _onBuyNoAds(BuyNoAds event, Emitter<HomeState> emit) {
    emit(state.copyWith(isNoAdsActive: true));
  }

  Future<void> _onTickLifeRecharge(TickLifeRecharge event, Emitter<HomeState> emit) async {
    if (state.lives < state.maxLives) {
      final now = DateTime.now();
      if (state.nextLifeTime == null) {
        final lastAt = now;
        final nextTime = now.add(const Duration(minutes: 60));
        final user = DatabaseService().supabase.auth.currentUser;
        await _savePlayerLives(state.lives, lastAt, user?.id);
        emit(state.copyWith(nextLifeTime: nextTime, timerTick: state.timerTick + 1));
      } else if (now.isAfter(state.nextLifeTime!)) {
        final currentLastAt = state.nextLifeTime!.subtract(const Duration(minutes: 60));
        final elapsedMinutes = now.difference(currentLastAt).inMinutes;
        final livesGained = max(1, elapsedMinutes ~/ 60);
        final newLives = min(state.maxLives, state.lives + livesGained);

        final user = DatabaseService().supabase.auth.currentUser;
        DateTime? newLastLifeLostAt;
        DateTime? newNextLifeTime;

        if (newLives < state.maxLives) {
          newLastLifeLostAt = currentLastAt.add(Duration(minutes: livesGained * 60));
          newNextLifeTime = newLastLifeLostAt.add(const Duration(minutes: 60));
        }

        await _savePlayerLives(newLives, newLastLifeLostAt, user?.id);

        emit(state.copyWith(
          lives: newLives,
          nextLifeTime: newNextLifeTime,
          lastAction: HomeLastAction.lifeRegained,
          timerTick: state.timerTick + 1,
        ));
      } else {
        emit(state.copyWith(timerTick: state.timerTick + 1));
      }
    } else {
      if (state.nextLifeTime != null) {
        emit(state.copyWith(nextLifeTime: null, timerTick: state.timerTick + 1));
      }
    }
  }

  Future<void> _onCompleteLevel(CompleteLevel event, Emitter<HomeState> emit) async {
    // Increment puzzle pieces for completing a level
    // 20 for Daily/Series End, 5 for Story
    final bool isSeriesEnd = event.mode == GameMode.dailySeries && event.level >= 3;
    final bool isSingleDaily = event.mode == GameMode.dailySingle;
    final bool isStory = event.mode == GameMode.story;

    final int reward = (isSingleDaily || isSeriesEnd) ? 20 : (isStory ? 5 : 0);
    
    if (reward > 0) {
      try {
        final player = await (_db.select(_db.players)
              ..where((t) => event.playerId != null && event.playerId!.isNotEmpty 
                  ? t.supabaseId.equals(event.playerId!) 
                  : t.id.isNotNull()))
            .getSingle();
        
        final newPuzzles = player.puzzlePieces + reward;
        
        await (_db.update(_db.players)
              ..where((t) => event.playerId != null && event.playerId!.isNotEmpty 
                  ? t.supabaseId.equals(event.playerId!) 
                  : t.id.isNotNull()))
            .write(PlayersCompanion(puzzlePieces: drift.Value(newPuzzles)));
            
        if (event.playerId != null && event.playerId!.isNotEmpty) {
          unawaited(DatabaseService().supabase.from('profiles').update({'puzzle_pieces': newPuzzles}).eq('id', event.playerId!));
        }
      } catch (e) {
        AppLogger.error('Error incrementing puzzles on complete level', e);
      }
    }

    // IMPORTANT: World logic
    // If you are in World 1 and you finish level 10, the NEXT refresh will see currentLevel 11.
    // The UI listener will trigger the WorldUnlockOverlay.
    
    // Emit win state with specific gained pieces for celebration
    emit(state.copyWith(
      lastAction: reward > 0 ? HomeLastAction.win : HomeLastAction.none, 
      gainedPuzzlePieces: reward,
    ));

    // Hard refresh from DB for the specific player
    await _refreshProgression(emit, event.playerId);
    
    // IMPORTANT: Reset gained pieces so listener only triggers once
    emit(state.copyWith(gainedPuzzlePieces: 0, lastAction: HomeLastAction.none));
  }

  Future<void> _onLoseLife(LoseLife event, Emitter<HomeState> emit) async {
    // Safety check: Never lose life in daily modes (logic usually in GamePage, but added here too)
    // Actually LoseLife doesn't know about the mode.
    // I will rely on GamePage not sending it.
    
    if (state.lives > 0) {
      final newLives = state.lives - 1;
      final now = DateTime.now();

      DateTime? newLastLifeLostAt;
      if (state.lives == state.maxLives) {
        newLastLifeLostAt = now;
      } else {
        final players = await (_db.select(_db.players)..limit(1)).get();
        newLastLifeLostAt = (players.isNotEmpty ? players.first.lastLifeLostAt : null) ?? now;
      }

      final nextTime = newLastLifeLostAt.add(const Duration(minutes: 60));

      await _savePlayerLives(newLives, newLastLifeLostAt, event.playerId);

      emit(state.copyWith(
        lives: newLives,
        nextLifeTime: nextTime,
        lastAction: HomeLastAction.loss,
      ));
    }
  }

  Future<void> _onAppResumed(AppResumed event, Emitter<HomeState> emit) async {
    AppLogger.log('HomeBloc: App resumed from background. Recalculating lives...');
    final user = DatabaseService().supabase.auth.currentUser;
    await _refreshProgression(emit, user?.id);
  }

  void _onChangeWorld(ChangeWorld event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      currentWorldIndex: event.worldIndex,
      isWorldLoading: true,
    ));
  }

  void _onFinishWorldLoading(FinishWorldLoading event, Emitter<HomeState> emit) {
    emit(state.copyWith(isWorldLoading: false));
  }

  Future<void> _onDebugSetLevel(DebugSetLevel event, Emitter<HomeState> emit) async {
    final user = DatabaseService().supabase.auth.currentUser;
    if (user != null) {
      if (event.isActive) {
        // Force update the DB locally so the refresh sees it
        await _progressionRepo.markLevelAsCompleted(
          playerSupabaseId: user.id,
          worldId: 'world_1',
          levelNumber: event.level - 1,
          timeSeconds: 0,
        );
      } else {
        // When deactivating, we just reload the real data from DB
      }
      
      emit(state.copyWith(isDebugLevelActive: event.isActive));
      
      // Crucial: await the refresh so the state is updated before the dialog closes
      await _refreshProgression(emit, user.id);
    }
  }

  void _startRechargeTimer() {
    _rechargeTimer?.cancel();
    _rechargeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TickLifeRecharge());
    });
  }

  @override
  Future<void> close() {
    _rechargeTimer?.cancel();
    _midnightTimer?.cancel();
    return super.close();
  }
}
