import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/repositories/progression_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  Timer? _rechargeTimer;
  final _db = DatabaseService().db;
  final _progressionRepo = ProgressionRepository();

  HomeBloc() : super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<ToggleMusic>(_onToggleMusic);
    on<ToggleSound>(_onToggleSound);
    on<WatchVideoForLife>(_onWatchVideoForLife);
    on<BuyLives>(_onBuyLives);
    on<BuyNoAds>(_onBuyNoAds);
    on<TickLifeRecharge>(_onTickLifeRecharge);
    on<CompleteLevel>(_onCompleteLevel);
    on<LoseLife>(_onLoseLife);
    on<ChangeWorld>(_onChangeWorld);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    // Force a data refresh for the specific player
    await _refreshProgression(emit, event.playerId);
    _startRechargeTimer();
  }

  Future<void> _refreshProgression(Emitter<HomeState> emit, String? playerId) async {
    // 1. Fetch player data
    final players = await (_db.select(_db.players)
          ..where((t) => playerId != null 
              ? t.supabaseId.equals(playerId) 
              : t.id.isNotNull())
          ..limit(1))
        .get();
    
    if (players.isNotEmpty) {
      final player = players.first;
      
      // 2. Fetch progression for THIS specific player
      final progs = await (_db.select(_db.progressions)
            ..where((t) => t.playerSupabaseId.equals(player.supabaseId ?? ''))
            ..limit(1))
          .get();
      
      final progression = progs.isNotEmpty ? progs.first : null;

      emit(state.copyWith(
        lives: player.lives,
        hints: player.hints,
        currentLevel: progression?.currentLevel ?? 1,
        levelsCompletedInWorld: (progression?.currentLevel ?? 1) - 1,
        isLoading: false,
      ));

      unawaited(_progressionRepo.ensureNextLevelsExist('world_1', progression?.currentLevel ?? 1));
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
      await (_db.update(_db.players)..where((t) => t.id.isNotNull())).write(PlayersCompanion(lives: Value(newLives)));
      emit(state.copyWith(
        lives: newLives,
        videosWatched: state.videosWatched + 1,
      ));
    }
  }

  Future<void> _onBuyLives(BuyLives event, Emitter<HomeState> emit) async {
    int newLives = state.lives + event.count;
    if (newLives > state.maxLives) newLives = state.maxLives;
    await (_db.update(_db.players)..where((t) => t.id.isNotNull())).write(PlayersCompanion(lives: Value(newLives)));
    emit(state.copyWith(lives: newLives));
  }

  void _onBuyNoAds(BuyNoAds event, Emitter<HomeState> emit) {
    emit(state.copyWith(isNoAdsActive: true));
  }

  Future<void> _onTickLifeRecharge(TickLifeRecharge event, Emitter<HomeState> emit) async {
    if (state.lives < state.maxLives) {
      final now = DateTime.now();
      if (state.nextLifeTime == null) {
        emit(state.copyWith(
          nextLifeTime: now.add(const Duration(minutes: 60)),
          timerTick: state.timerTick + 1,
        ));
      } else if (now.isAfter(state.nextLifeTime!)) {
        final newLives = state.lives + 1;
        final nextTime = newLives < state.maxLives 
            ? now.add(const Duration(minutes: 60)) 
            : null;
        
        await _db.update(_db.players).write(PlayersCompanion(lives: Value(newLives)));
        
        emit(state.copyWith(
          lives: newLives, 
          nextLifeTime: nextTime,
          lastAction: HomeLastAction.lifeRegained,
          timerTick: state.timerTick + 1,
        ));
      } else {
        // Just increment tick to force UI refresh
        emit(state.copyWith(timerTick: state.timerTick + 1));
      }
    } else {
      if (state.nextLifeTime != null) {
        emit(state.copyWith(nextLifeTime: null, timerTick: state.timerTick + 1));
      }
    }
  }

  Future<void> _onCompleteLevel(CompleteLevel event, Emitter<HomeState> emit) async {
    emit(state.copyWith(lastAction: HomeLastAction.win));
    // Hard refresh from DB for the specific player
    await _refreshProgression(emit, event.playerId);
  }

  Future<void> _onLoseLife(LoseLife event, Emitter<HomeState> emit) async {
    if (state.lives > 0) {
      final newLives = state.lives - 1;
      
      final query = _db.update(_db.players);
      if (event.playerId != null) {
        query.where((t) => t.supabaseId.equals(event.playerId!));
      } else {
        query.where((t) => t.id.isNotNull());
      }
      await query.write(PlayersCompanion(lives: Value(newLives)));
      
      emit(state.copyWith(
        lives: newLives,
        lastAction: HomeLastAction.loss,
      ));
      
      // If we were at max, start the timer
      if (state.lives == state.maxLives) {
        emit(state.copyWith(nextLifeTime: DateTime.now().add(const Duration(minutes: 60))));
      }
    }
  }

  void _onChangeWorld(ChangeWorld event, Emitter<HomeState> emit) {
    emit(state.copyWith(currentWorldIndex: event.worldIndex));
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
    return super.close();
  }
}
