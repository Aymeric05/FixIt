import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart' hide Column;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/core/repositories/progression_repository.dart';
import 'package:fixit/core/repositories/daily_repository.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/core/utils/level_generator.dart';
import 'package:fixit/features/game/presentation/bloc/game_event.dart';
import 'package:fixit/features/game/presentation/bloc/game_state.dart';
import 'package:fixit/core/models/daily_mode.dart';
import 'package:fixit/core/models/level_win_summary.dart';
import 'package:fixit/core/utils/app_logger.dart';
import 'package:fixit/core/repositories/game_session_repository.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Timer? _timer;
  Timer? _dizzyTimer;
  late final ProgressionRepository _progressionRepo;
  late final DailyRepository _dailyRepo;
  late final GameSessionRepository _sessionRepo;
  String? _playerId;

  GameBloc({
    ProgressionRepository? progressionRepo,
    DailyRepository? dailyRepo,
    GameSessionRepository? sessionRepo,
  }) : super(const GameState()) {
    _progressionRepo = progressionRepo ?? ProgressionRepository();
    _dailyRepo = dailyRepo ?? DailyRepository();
    _sessionRepo = sessionRepo ?? GameSessionRepository();
    on<StartGame>(_onStartGame);
    on<SelectCell>(_onSelectCell);
    on<TimerTick>(_onTimerTick);
    on<LoadFriendsLeaderboard>(_onLoadFriendsLeaderboard);
    on<PauseTimer>(_onPauseTimer);
    on<ResumeTimer>(_onResumeTimer);
    on<ContinueGameWithVideo>(_onContinueGameWithVideo);
    on<UseItemPlusTime>(_onUseItemPlusTime);
    on<UseItemMoreNumbers>(_onUseItemMoreNumbers);
    on<UseItemRevealPath>(_onUseItemRevealPath);
    on<RecoverFromDizzy>(_onRecoverFromDizzy);
  }

  Future<void> _onStartGame(StartGame event, Emitter<GameState> emit) async {
    _timer?.cancel();
    _playerId = event.playerId;

    int initialSeconds = 300;
    int hintsCount = 12;

    if (event.mode == GameMode.dailySingle) {
      initialSeconds = 3600; // 1 hour (effectively no limit)
      hintsCount = 12;
    } else if (event.mode == GameMode.dailySeries) {
      initialSeconds = 3600; 
      hintsCount = 10 + event.level; // Slightly harder per level in series
    } else {
      if (event.difficulty == GameDifficulty.medium) {
        initialSeconds = 240;
        hintsCount = 8;
      } else if (event.difficulty == GameDifficulty.hard) {
        initialSeconds = 180;
        hintsCount = 7;
      }
    }

    // Initial state setup
    emit(state.copyWith(
      status: GameStatus.initial,
      remainingSeconds: initialSeconds,
      initialSeconds: initialSeconds,
      levelNumber: event.level,
      hints: [],
      mode: event.mode,
      seriesAccumulatedTime: 0, 
      wonTime: null,
      inventoryPlusTime: event.invPlusTime,
      inventoryMoreNumbers: event.invMoreNumbers,
      inventoryRevealPath: event.invRevealPath,
      usedItems: {},
    ));

    List<List<int?>> hints;
    List<GridOffset> solution;
    Set<String> walls;
    Map<GridOffset, int> hintSteps = {};

    final String worldId = event.mode == GameMode.story 
        ? 'world_1' 
        : event.mode == GameMode.dailySeries 
            ? _dailyRepo.getTodaySeriesWorldId() 
            : _dailyRepo.getTodayWorldId();

    // Check for existing session
    ActiveGameState? savedSession;
    if (event.playerId.isNotEmpty) {
      savedSession = await _sessionRepo.loadSession(
        playerId: event.playerId,
        worldId: worldId,
        levelNumber: event.level,
        mode: event.mode,
      );
    }

    if (event.mode != GameMode.story) {
      final daily = _dailyRepo.generateDailyLevel(
        worldLevel: event.level,
        isSeries: event.mode == GameMode.dailySeries,
      );
      hints = daily.hints;
      solution = daily.solution;
      walls = daily.walls;

      for (int r = 0; r < 6; r++) {
        for (int c = 0; c < 6; c++) {
          if (hints[r][c] != null) {
            final pos = GridOffset(r, c);
            hintSteps[pos] = solution.indexOf(pos);
          }
        }
      }
    } else {
      final worldId = 'world_1';
      try {
        final globalLevel = await _progressionRepo.getGlobalLevel(worldId, event.level)
            .timeout(const Duration(seconds: 3));
        
        if (globalLevel != null) {
          hints = (jsonDecode(globalLevel.hintsJson) as List)
              .map((row) => (row as List).map((e) => e as int?).toList())
              .toList();
          walls = (jsonDecode(globalLevel.wallsJson) as List).cast<String>().toSet();
          solution = (jsonDecode(globalLevel.solutionJson) as List)
              .map((e) => GridOffset(e['r'], e['c']))
              .toList();
          
          for (int r = 0; r < 6; r++) {
            for (int c = 0; c < 6; c++) {
              if (hints[r][c] != null) {
                final pos = GridOffset(r, c);
                hintSteps[pos] = solution.indexOf(pos);
              }
            }
          }
        } else {
          throw Exception('Not found');
        }
      } catch (e) {
        final result = LevelGenerator.generate(hintsCount);
        hints = result.hints;
        solution = result.solution;
        walls = result.walls;
        hintSteps = result.hintSteps;

        unawaited(_progressionRepo.saveGlobalLevel(
          worldId: worldId,
          levelNumber: event.level,
          hints: hints,
          walls: walls,
          solution: solution,
        ).catchError((err) => AppLogger.error('Background save failed', err)));
      }
    }

    final colors = [
      Colors.orange, Colors.pink, Colors.purple, Colors.blue,
      Colors.green, Colors.red, Colors.teal, Colors.indigo,
    ];
    final randomColor = colors[Random().nextInt(colors.length)];

    // Final level data and playing state
    List<GridOffset> restoredPath = [];
    int finalRemainingSeconds = initialSeconds;

    if (savedSession != null) {
      AppLogger.log('Restoring saved session for level ${event.level}');
      finalRemainingSeconds = savedSession.remainingSeconds;
      final List<dynamic> decodedPath = jsonDecode(savedSession.currentPathJson);
      restoredPath = decodedPath.map((e) => GridOffset(e['r'], e['c'])).toList();
    }

    emit(state.copyWith(
      hints: hints,
      solutionPath: solution,
      hintSteps: hintSteps,
      walls: walls,
      status: GameStatus.playing,
      currentPath: restoredPath,
      remainingSeconds: finalRemainingSeconds,
      pathColor: randomColor,
      isAngry: _checkIfAngry(restoredPath, hints),
    ));

    if (event.playerId.isNotEmpty) {
      final status = await _dailyRepo.getDailyStatus(event.playerId);
      if (status != null) {
        if (event.mode == GameMode.dailySingle && status.isDailyLevelCompleted) {
          final summary = await _progressionRepo.getLevelWinSummary(
            worldId: _dailyRepo.getTodayWorldId(),
            levelNumber: event.level,
            playerId: event.playerId,
            playerTime: status.dailyLevelTime,
          );
          
          await Future.delayed(Duration.zero);
          if (!isClosed) {
            await _sessionRepo.deleteSession(playerId: event.playerId, worldId: worldId, levelNumber: event.level, mode: event.mode);
            
            emit(state.copyWith(
              status: GameStatus.won,
              winSummary: summary,
              wonTime: status.dailyLevelTime,
              currentPath: solution,
            ));
          }
          return;
        } else if (event.mode == GameMode.dailySeries) {
          if (event.level <= status.seriesCurrentLevel) {
            final summary = await _progressionRepo.getLevelWinSummary(
              worldId: _dailyRepo.getTodaySeriesWorldId(),
              levelNumber: event.level,
              playerId: event.playerId,
              playerTime: status.seriesAccumulatedTime,
            );
            
            await Future.delayed(Duration.zero);
            if (!isClosed) {
              await _sessionRepo.deleteSession(playerId: event.playerId, worldId: worldId, levelNumber: event.level, mode: event.mode);

              emit(state.copyWith(
                status: GameStatus.won,
                winSummary: summary,
                seriesAccumulatedTime: status.seriesAccumulatedTime,
                wonTime: status.seriesAccumulatedTime,
                currentPath: solution,
              ));
            }
            return;
          } else {
            emit(state.copyWith(seriesAccumulatedTime: status.seriesAccumulatedTime));
          }
        }
      }
    }

    if (event.mode == GameMode.story && event.level == 1 && event.playerId.isNotEmpty) {
      unawaited(_progressionRepo.grantLevel1Reward(event.playerId).catchError((e) => AppLogger.error('Reward error', e)));
    }

    if (!state.isPaused) {
      _startTimer(finalRemainingSeconds);
    }
    
    if (event.mode == GameMode.story) {
      unawaited(_progressionRepo.ensureNextLevelsExist('world_1', event.level));
    }
  }

  Future<void> _onSelectCell(SelectCell event, Emitter<GameState> emit) async {
    if (state.status != GameStatus.playing) return;
    final tapped = GridOffset(event.row, event.col);
    final currentPath = List<GridOffset>.from(state.currentPath);
    
    if (currentPath.isEmpty) {
      if (state.hints[event.row][event.col] == 1) {
        emit(state.copyWith(currentPath: [tapped]));
        unawaited(_saveCurrentSession());
      }
      return;
    }

    final last = currentPath.last;
    final existingIndex = currentPath.indexOf(tapped);

    // FAST BACKTRACKING (Teleport on Tap)
    if (!event.isDrag && existingIndex != -1) {
      final newPath = currentPath.sublist(0, existingIndex + 1);
      _dizzyTimer?.cancel();
      emit(state.copyWith(
        currentPath: newPath,
        isAngry: _checkIfAngry(newPath),
        isDizzy: false,
        collisionOffset: null,
      ));
      unawaited(_saveCurrentSession());
      return;
    }

    if (last == tapped) return;

    final isAdjacent = (last.row - tapped.row).abs() + (last.col - tapped.col).abs() == 1;

    bool isValidMove = false;
    bool isBacktrackingMove = false;

    if (isAdjacent) {
      if (existingIndex != -1) {
        if (existingIndex == currentPath.length - 2) {
          isValidMove = true;
          isBacktrackingMove = true;
        }
      } else if (!state.walls.contains(_getWallKey(last, tapped))) {
        isValidMove = true;
      }
    }

    if (state.isDizzy) {
      if (isValidMove) {
        _dizzyTimer?.cancel();
        emit(state.copyWith(isDizzy: false, collisionOffset: null));
      } else {
        return;
      }
    }

    if (isAdjacent) {
      if (isValidMove) {
        if (isBacktrackingMove) {
          final newPath = currentPath.sublist(0, currentPath.length - 1);
          emit(state.copyWith(
            currentPath: newPath, 
            isAngry: _checkIfAngry(newPath),
          ));
          unawaited(_saveCurrentSession());
        } else {
          final newPath = [...currentPath, tapped];
          
          if (newPath.length == 36) {
            if (_validatePath(newPath)) {
              _timer?.cancel();
              emit(state.copyWith(currentPath: newPath, isAngry: false));

              final timeTaken = state.initialSeconds - state.remainingSeconds;
              final worldId = state.mode == GameMode.story ? 'world_1' : _dailyRepo.getTodayWorldId();

              int displayTime = timeTaken;
              if (state.mode == GameMode.dailySingle && _playerId != null) {
                await _dailyRepo.updateDailyStatus(playerId: _playerId!, isDailyLevelCompleted: true, dailyLevelTime: timeTaken);
                await _progressionRepo.markLevelAsCompleted(playerSupabaseId: _playerId!, worldId: worldId, levelNumber: state.levelNumber, timeSeconds: timeTaken, updateProgression: false);
              } else if (state.mode == GameMode.dailySeries && _playerId != null) {
                displayTime = state.seriesAccumulatedTime + timeTaken;
                await _dailyRepo.updateDailyStatus(playerId: _playerId!, seriesCurrentLevel: state.levelNumber, seriesAccumulatedTime: displayTime, isSeriesCompleted: state.levelNumber >= 3);
                await _progressionRepo.markLevelAsCompleted(playerSupabaseId: _playerId!, worldId: _dailyRepo.getTodaySeriesWorldId(), levelNumber: state.levelNumber, timeSeconds: displayTime, updateProgression: false);
              }

              LevelWinSummary? summary;
              if (state.mode == GameMode.story) {
                 summary = await _progressionRepo.getLevelWinSummary(worldId: 'world_1', levelNumber: state.levelNumber, playerId: _playerId ?? '', playerTime: timeTaken);
              } else if (state.mode == GameMode.dailySingle) {
                 summary = await _progressionRepo.getLevelWinSummary(worldId: _dailyRepo.getTodayWorldId(), levelNumber: state.levelNumber, playerId: _playerId ?? '', playerTime: timeTaken);
              } else if (state.mode == GameMode.dailySeries) {
                 summary = await _progressionRepo.getLevelWinSummary(worldId: _dailyRepo.getTodaySeriesWorldId(), levelNumber: state.levelNumber, playerId: _playerId ?? '', playerTime: displayTime);
              }

              emit(state.copyWith(status: GameStatus.won, winSummary: summary, wonTime: displayTime));
              unawaited(_deleteCurrentSession());
              return;
            }
          }
          emit(state.copyWith(currentPath: newPath, isAngry: _checkIfAngry(newPath)));
          unawaited(_saveCurrentSession());
        }
      } else {
        _triggerCollision(emit, tapped.row - last.row, tapped.col - last.col);
      }
    } else {
      // NOT ADJACENT (Too far)
      // Just make the snake angry as requested, no dizziness/shake
      emit(state.copyWith(isAngry: true));
    }
  }

  void _triggerCollision(Emitter<GameState> emit, int dr, int dc) {
    if (state.isDizzy) return;
    
    emit(state.copyWith(
      isDizzy: true, 
      collisionOffset: GridOffset(dr, dc),
    ));

    _dizzyTimer?.cancel();
    _dizzyTimer = Timer(const Duration(milliseconds: 500), () {
      add(RecoverFromDizzy());
    });
  }

  void _onRecoverFromDizzy(RecoverFromDizzy event, Emitter<GameState> emit) {
    if (state.isDizzy) {
      emit(state.copyWith(
        isDizzy: false, 
        collisionOffset: null,
      ));
    }
  }

  Future<void> _onLoadFriendsLeaderboard(LoadFriendsLeaderboard event, Emitter<GameState> emit) async {
    final worldId = state.mode == GameMode.story 
        ? 'world_1' 
        : state.mode == GameMode.dailySeries 
            ? _dailyRepo.getTodaySeriesWorldId() 
            : _dailyRepo.getTodayWorldId();
            
    final list = await _progressionRepo.getFriendsLeaderboard(
      worldId: worldId,
      levelNumber: state.levelNumber,
      playerId: event.playerId,
    );
    emit(state.copyWith(friendsLeaderboard: list));
  }

  String _getWallKey(GridOffset a, GridOffset b) {
    final list = [a.toString(), b.toString()]..sort();
    return '${list[0]}-${list[1]}';
  }

  bool _checkIfAngry(List<GridOffset> path, [List<List<int?>>? customHints]) {
    final hintsToUse = customHints ?? state.hints;
    if (hintsToUse.isEmpty) return false;

    int maxHintSeen = 0;
    int hintsCounted = 0;
    for (var pos in path) {
      final val = hintsToUse[pos.row][pos.col];
      if (val != null) {
        hintsCounted++;
        if (val > maxHintSeen) maxHintSeen = val;
        if (maxHintSeen > hintsCounted) return true;
      }
    }
    return false;
  }

  bool _validatePath(List<GridOffset> path) {
    final List<({int value, int index})> hintOrder = [];
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        final hintValue = state.hints[r][c];
        if (hintValue != null) {
          final pos = GridOffset(r, c);
          final userIndex = path.indexOf(pos);
          if (userIndex == -1) return false;
          hintOrder.add((value: hintValue, index: userIndex));
        }
      }
    }
    hintOrder.sort((a, b) => a.value.compareTo(b.value));
    for (int i = 0; i < hintOrder.length - 1; i++) {
      if (hintOrder[i].index > hintOrder[i+1].index) return false;
    }

    if (hintOrder.isNotEmpty && hintOrder.last.index != path.length - 1) {
      return false;
    }

    return true;
  }

  void _startTimer(int seconds) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = seconds - timer.tick;
      if (remaining <= 0) {
        _timer?.cancel();
        add(const TimerTick(0));
      } else {
        add(TimerTick(remaining));
      }
    });
  }

  void _onTimerTick(TimerTick event, Emitter<GameState> emit) {
    if (event.remainingSeconds == 0) {
      emit(state.copyWith(remainingSeconds: 0, status: GameStatus.lost));
      unawaited(_deleteCurrentSession());
    } else {
      emit(state.copyWith(remainingSeconds: event.remainingSeconds));
      if (event.remainingSeconds % 5 == 0) {
        unawaited(_saveCurrentSession());
      }
    }
  }

  void _onPauseTimer(PauseTimer event, Emitter<GameState> emit) {
    _timer?.cancel();
    emit(state.copyWith(isPaused: true));
    unawaited(_saveCurrentSession());
  }

  void _onResumeTimer(ResumeTimer event, Emitter<GameState> emit) {
    _timer?.cancel();
    emit(state.copyWith(isPaused: false));
    _startTimer(state.remainingSeconds);
  }

  void _onContinueGameWithVideo(ContinueGameWithVideo event, Emitter<GameState> emit) {
    _timer?.cancel();
    final newTime = state.remainingSeconds + 180;
    emit(state.copyWith(
      remainingSeconds: newTime,
      status: GameStatus.playing,
    ));
    _startTimer(newTime);
  }

  Future<void> _onUseItemPlusTime(UseItemPlusTime event, Emitter<GameState> emit) async {
    if (state.inventoryPlusTime <= 0 || state.status != GameStatus.playing || state.usedItems.contains('plus_time')) return;
    
    _timer?.cancel();
    final newTime = state.remainingSeconds + 120;
    final newInv = state.inventoryPlusTime - 1;
    
    emit(state.copyWith(
      remainingSeconds: newTime, 
      inventoryPlusTime: newInv,
      usedItems: {...state.usedItems, 'plus_time'},
    ));
    _startTimer(newTime);
    _updateLocalInventory('item_plus_time', newInv);
  }

  Future<void> _onUseItemMoreNumbers(UseItemMoreNumbers event, Emitter<GameState> emit) async {
    if (state.inventoryMoreNumbers <= 0 || state.status != GameStatus.playing || state.usedItems.contains('more_numbers')) return;
    
    final solution = state.solutionPath;
    final Map<GridOffset, int> newHintSteps = {};
    final List<List<int?>> newHints = List.generate(6, (_) => List.filled(6, null));
    
    for (int i = 0; i < 4; i++) {
      int stepIndex = (i * 3).round();
      final pos = solution[stepIndex];
      newHintSteps[pos] = stepIndex;
      newHints[pos.row][pos.col] = i + 1;
    }

    for (int i = 0; i < 11; i++) {
      int stepIndex = 12 + (i * (23 / 10)).round();
      final pos = solution[stepIndex];
      if (newHintSteps.containsKey(pos)) continue;
      newHintSteps[pos] = stepIndex;
      newHints[pos.row][pos.col] = 5 + i;
    }

    final newInv = state.inventoryMoreNumbers - 1;
    emit(state.copyWith(
      hints: newHints,
      hintSteps: newHintSteps,
      inventoryMoreNumbers: newInv,
      usedItems: {...state.usedItems, 'more_numbers'},
    ));
    _updateLocalInventory('item_more_numbers', newInv);
    unawaited(_saveCurrentSession());
  }

  Future<void> _onUseItemRevealPath(UseItemRevealPath event, Emitter<GameState> emit) async {
    if (state.inventoryRevealPath <= 0 || state.status != GameStatus.playing || state.usedItems.contains('reveal_path')) return;

    int lastStepIndex = -1;
    if (state.currentPath.isNotEmpty) {
      lastStepIndex = state.solutionPath.indexOf(state.currentPath.last);
    }
    
    final nextCells = <GridOffset>[];
    for (int i = 1; i <= 4; i++) {
      int nextIdx = lastStepIndex + i;
      if (nextIdx < 36) {
        nextCells.add(state.solutionPath[nextIdx]);
      }
    }

    if (nextCells.isEmpty) return;

    final newInv = state.inventoryRevealPath - 1;
    _updateLocalInventory('item_reveal_path', newInv);
    
    emit(state.copyWith(
      inventoryRevealPath: newInv,
      usedItems: {...state.usedItems, 'reveal_path'},
    ));

    final revealedSoFar = <GridOffset>[];
    for (var cell in nextCells) {
      if (state.status != GameStatus.playing) break;
      revealedSoFar.add(cell);
      emit(state.copyWith(highlightedCells: List.from(revealedSoFar)));
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    if (state.status == GameStatus.playing) {
      await Future.delayed(const Duration(seconds: 2));
    }
    
    emit(state.copyWith(highlightedCells: []));
  }

  Future<void> _updateLocalInventory(String field, int newValue) async {
    final db = DatabaseService().db;
    if (field == 'item_plus_time') {
      await (db.update(db.players)..where((t) => t.id.isNotNull())).write(PlayersCompanion(itemPlusTime: drift.Value(newValue)));
    } else if (field == 'item_more_numbers') {
      await (db.update(db.players)..where((t) => t.id.isNotNull())).write(PlayersCompanion(itemMoreNumbers: drift.Value(newValue)));
    } else if (field == 'item_reveal_path') {
      await (db.update(db.players)..where((t) => t.id.isNotNull())).write(PlayersCompanion(itemRevealPath: drift.Value(newValue)));
    }
  }

  Future<void> _saveCurrentSession() async {
    if (_playerId == null || _playerId!.isEmpty || state.status != GameStatus.playing) return;

    final String worldId = state.mode == GameMode.story 
        ? 'world_1' 
        : state.mode == GameMode.dailySeries 
            ? _dailyRepo.getTodaySeriesWorldId() 
            : _dailyRepo.getTodayWorldId();

    await _sessionRepo.saveSession(
      playerId: _playerId!,
      worldId: worldId,
      levelNumber: state.levelNumber,
      mode: state.mode,
      remainingSeconds: state.remainingSeconds,
      currentPath: state.currentPath,
    );
  }

  Future<void> _deleteCurrentSession() async {
    if (_playerId == null || _playerId!.isEmpty) return;

    final String worldId = state.mode == GameMode.story 
        ? 'world_1' 
        : state.mode == GameMode.dailySeries 
            ? _dailyRepo.getTodaySeriesWorldId() 
            : _dailyRepo.getTodayWorldId();

    await _sessionRepo.deleteSession(
      playerId: _playerId!,
      worldId: worldId,
      levelNumber: state.levelNumber,
      mode: state.mode,
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _dizzyTimer?.cancel();
    return super.close();
  }
}
