import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/core/repositories/progression_repository.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/core/utils/level_generator.dart';
import 'package:fixit/features/game/presentation/bloc/game_event.dart';
import 'package:fixit/features/game/presentation/bloc/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Timer? _timer;
  final _progressionRepo = ProgressionRepository();

  GameBloc() : super(const GameState()) {
    on<StartGame>(_onStartGame);
    on<SelectCell>(_onSelectCell);
    on<TimerTick>(_onTimerTick);
  }

  Future<void> _onStartGame(StartGame event, Emitter<GameState> emit) async {
    _timer?.cancel();

    int initialSeconds = 300;
    int hintsCount = 12;
    if (event.difficulty == GameDifficulty.medium) {
      initialSeconds = 240;
      hintsCount = 8;
    } else if (event.difficulty == GameDifficulty.hard) {
      initialSeconds = 180;
      hintsCount = 7;
    }

    emit(state.copyWith(
      status: GameStatus.initial,
      remainingSeconds: initialSeconds,
      initialSeconds: initialSeconds,
      levelNumber: event.level,
      hints: [],
    ));

    if (event.level == 1 && event.playerId.isNotEmpty) {
      unawaited(_progressionRepo.grantLevel1Reward(event.playerId).catchError((e) => print('Reward error: $e')));
    }

    final worldId = 'world_1';
    List<List<int?>> hints;
    List<GridOffset> solution;
    Set<String> walls;
    Map<GridOffset, int> hintSteps = {};

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

    final colors = [
      Colors.orange, Colors.pink, Colors.purple, Colors.blue,
      Colors.green, Colors.red, Colors.teal, Colors.indigo,
    ];
    final randomColor = colors[Random().nextInt(colors.length)];

    emit(state.copyWith(
      hints: hints,
      solutionPath: solution,
      hintSteps: hintSteps,
      walls: walls,
      remainingSeconds: initialSeconds,
      status: GameStatus.playing,
      currentPath: [],
      pathColor: randomColor,
      isAngry: false,
    ));

    _startTimer(initialSeconds);
    unawaited(_progressionRepo.ensureNextLevelsExist(worldId, event.level));
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

          // Fetch Real Stats before final emission
          try {
            final stats = await _progressionRepo.getLevelStatistics('world_1', state.levelNumber);
            emit(state.copyWith(
              status: GameStatus.won,
              averageTimeSeconds: stats.averageSeconds,
              bestTimeSeconds: stats.bestSeconds,
            ));
          } catch (e) {
            print('Error fetching stats on win: $e');
            emit(state.copyWith(status: GameStatus.won));
          }
          return;
        }
      }
      
      emit(state.copyWith(currentPath: newPath, isAngry: _checkIfAngry(newPath)));
    }
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
