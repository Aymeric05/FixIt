import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/core/repositories/progression_repository.dart';
import 'package:fixit/core/repositories/daily_repository.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/core/utils/level_generator.dart';
import 'package:fixit/features/game/presentation/bloc/game_event.dart';
import 'package:fixit/features/game/presentation/bloc/game_state.dart';
import 'package:fixit/core/models/daily_mode.dart';
import 'package:fixit/core/models/level_win_summary.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Timer? _timer;
  final _progressionRepo = ProgressionRepository();
  final _dailyRepo = DailyRepository();
  String? _playerId;

  GameBloc() : super(const GameState()) {
    on<StartGame>(_onStartGame);
    on<SelectCell>(_onSelectCell);
    on<TimerTick>(_onTimerTick);
    on<LoadFriendsLeaderboard>(_onLoadFriendsLeaderboard);
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
      seriesAccumulatedTime: 0, // Default, will be updated below
    ));

    List<List<int?>> hints;
    List<GridOffset> solution;
    Set<String> walls;
    Map<GridOffset, int> hintSteps = {};

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
        ).catchError((err) => print('Background save failed: $err')));
      }
    }

    final colors = [
      Colors.orange, Colors.pink, Colors.purple, Colors.blue,
      Colors.green, Colors.red, Colors.teal, Colors.indigo,
    ];
    final randomColor = colors[Random().nextInt(colors.length)];

    // Final level data and playing state
    emit(state.copyWith(
      hints: hints,
      solutionPath: solution,
      hintSteps: hintSteps,
      walls: walls,
      status: GameStatus.playing,
      currentPath: [],
      pathColor: randomColor,
      isAngry: false,
    ));

    // Check completion and handle resumption
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
            emit(state.copyWith(
              status: GameStatus.won,
              winSummary: summary,
              remainingSeconds: initialSeconds - status.dailyLevelTime,
              currentPath: solution,
            ));
          }
          return;
        } else if (event.mode == GameMode.dailySeries) {
          // Update series accumulated time (time from levels BEFORE this one)
          // We need to calculate it properly. seriesAccumulatedTime in DB is the TOTAL so far.
          // For resumption, if we are at level N, and it's already finished, we show the recap.
          
          if (event.level <= status.seriesCurrentLevel) {
            final summary = await _progressionRepo.getLevelWinSummary(
              worldId: _dailyRepo.getTodaySeriesWorldId(),
              levelNumber: event.level,
              playerId: event.playerId,
              playerTime: status.seriesAccumulatedTime,
            );
            
            await Future.delayed(Duration.zero);
            if (!isClosed) {
              emit(state.copyWith(
                status: GameStatus.won,
                winSummary: summary,
                // Trick to make GamePage display the total time correctly
                seriesAccumulatedTime: status.seriesAccumulatedTime,
                remainingSeconds: initialSeconds, 
                currentPath: solution,
              ));
            }
            return;
          } else {
            // Normal play for Level N, accumulated time is the total from Level N-1
            emit(state.copyWith(seriesAccumulatedTime: status.seriesAccumulatedTime));
          }
        }
      }
    }

    if (event.mode == GameMode.story && event.level == 1 && event.playerId.isNotEmpty) {
      unawaited(_progressionRepo.grantLevel1Reward(event.playerId).catchError((e) => print('Reward error: $e')));
    }

    _startTimer(initialSeconds);
    if (event.mode == GameMode.story) {
      unawaited(_progressionRepo.ensureNextLevelsExist('world_1', event.level));
    }
  }

  Future<void> _onSelectCell(SelectCell event, Emitter<GameState> emit) async {
    if (state.status != GameStatus.playing) return;
    final tapped = GridOffset(event.row, event.col);
    final currentPath = List<GridOffset>.from(state.currentPath);
    if (currentPath.isNotEmpty && currentPath.last == tapped) return;
    if (currentPath.isEmpty) {
      if (state.hints[event.row][event.col] == 1) emit(state.copyWith(currentPath: [tapped]));
      return;
    }
    final existingIndex = currentPath.indexOf(tapped);
    if (existingIndex != -1) {
      final newPath = currentPath.sublist(0, existingIndex + 1);
      emit(state.copyWith(currentPath: newPath, isAngry: _checkIfAngry(newPath)));
      return;
    }
    final last = currentPath.last;
    final isAdjacent = (last.row - event.row).abs() + (last.col - event.col).abs() == 1;
    if (isAdjacent) {
      if (state.walls.contains(_getWallKey(last, tapped))) return;
      final newPath = [...currentPath, tapped];
      
      if (newPath.length == 36) {
        if (_validatePath(newPath)) {
          _timer?.cancel();
          
          // Emit intermediate state so UI knows it's won
          emit(state.copyWith(currentPath: newPath, isAngry: false));

          final timeTaken = state.initialSeconds - state.remainingSeconds;
          final worldId = state.mode == GameMode.story ? 'world_1' : _dailyRepo.getTodayWorldId();

          if (state.mode == GameMode.dailySingle && _playerId != null) {
            await _dailyRepo.updateDailyStatus(
              playerId: _playerId!, 
              isDailyLevelCompleted: true,
              dailyLevelTime: timeTaken,
            );
            // Also record in global completions
            await _progressionRepo.markLevelAsCompleted(
              playerSupabaseId: _playerId!,
              worldId: worldId,
              levelNumber: state.levelNumber,
              timeSeconds: timeTaken,
              updateProgression: false,
            );
          } else if (state.mode == GameMode.dailySeries && _playerId != null) {
            final newAccumulated = state.seriesAccumulatedTime + timeTaken;
            final isFinished = state.levelNumber >= 3;
            
            await _dailyRepo.updateDailyStatus(
              playerId: _playerId!,
              seriesCurrentLevel: state.levelNumber,
              seriesAccumulatedTime: newAccumulated,
              isSeriesCompleted: isFinished,
            );

            // Record in global completions for the series stage
            await _progressionRepo.markLevelAsCompleted(
              playerSupabaseId: _playerId!,
              worldId: _dailyRepo.getTodaySeriesWorldId(),
              levelNumber: state.levelNumber,
              timeSeconds: newAccumulated,
              updateProgression: false,
            );
          }

          // Fetch Rich Win Summary
          LevelWinSummary? summary;
          if (state.mode == GameMode.story) {
             summary = await _progressionRepo.getLevelWinSummary(
              worldId: 'world_1',
              levelNumber: state.levelNumber,
              playerId: _playerId ?? '',
              playerTime: timeTaken,
            );
          } else if (state.mode == GameMode.dailySingle) {
             summary = await _progressionRepo.getLevelWinSummary(
              worldId: _dailyRepo.getTodayWorldId(),
              levelNumber: state.levelNumber,
              playerId: _playerId ?? '',
              playerTime: timeTaken,
            );
          } else if (state.mode == GameMode.dailySeries) {
             summary = await _progressionRepo.getLevelWinSummary(
              worldId: _dailyRepo.getTodaySeriesWorldId(),
              levelNumber: state.levelNumber,
              playerId: _playerId ?? '',
              playerTime: state.seriesAccumulatedTime + timeTaken,
            );
          }

          emit(state.copyWith(
            status: GameStatus.won,
            winSummary: summary,
          ));
          return;
        }
      }
      
      emit(state.copyWith(currentPath: newPath, isAngry: _checkIfAngry(newPath)));
    }
  }

  Future<void> _onLoadFriendsLeaderboard(LoadFriendsLeaderboard event, Emitter<GameState> emit) async {
    final worldId = state.mode == GameMode.story ? 'world_1' : _dailyRepo.getTodayWorldId();
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

  bool _checkIfAngry(List<GridOffset> path) {
    int maxHintSeen = 0;
    int hintsCounted = 0;
    for (var pos in path) {
      final val = state.hints[pos.row][pos.col];
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
    } else {
      emit(state.copyWith(remainingSeconds: event.remainingSeconds));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
