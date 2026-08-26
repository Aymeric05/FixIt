import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Timer? _timer;

  GameBloc() : super(const GameState()) {
    on<StartGame>(_onStartGame);
    on<SelectCell>(_onSelectCell);
    on<TimerTick>(_onTimerTick);
  }

  void _onStartGame(StartGame event, Emitter<GameState> emit) {
    _timer?.cancel();

    int seconds = 300;
    int hintsCount = 12;
    if (event.difficulty == GameDifficulty.medium) {
      seconds = 240;
      hintsCount = 8;
    } else if (event.difficulty == GameDifficulty.hard) {
      seconds = 180;
      hintsCount = 7;
    }

    final result = _generatePuzzle(hintsCount);

    final colors = [
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];
    final randomColor = colors[Random().nextInt(colors.length)];

    emit(state.copyWith(
      hints: result.hints,
      solutionPath: result.solution,
      hintSteps: result.hintSteps,
      walls: result.walls,
      remainingSeconds: seconds,
      status: GameStatus.playing,
      currentPath: [],
      pathColor: randomColor,
      isAngry: false,
    ));

    _startTimer(seconds);
  }

  ({List<List<int?>> hints, List<GridOffset> solution, Map<GridOffset, int> hintSteps, Set<String> walls}) 
  _generatePuzzle(int hintsCount) {
    final List<GridOffset>? solution = _generateHamiltonianPath();
    final finalSolution = solution ?? _generateSnakePath();

    final hints = List.generate(6, (_) => List<int?>.generate(6, (_) => null));
    final Map<GridOffset, int> hintSteps = {};
    
    final random = Random();
    final Set<int> indices = {0, 35}; 
    
    while (indices.length < hintsCount) {
      indices.add(random.nextInt(36));
    }

    final sortedIndices = indices.toList()..sort();
    for (int i = 0; i < sortedIndices.length; i++) {
      final stepIndex = sortedIndices[i];
      final pos = finalSolution[stepIndex];
      hints[pos.row][pos.col] = i + 1;
      hintSteps[pos] = stepIndex;
    }

    // Generate walls
    final Set<String> walls = {};
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        final current = GridOffset(r, c);
        final neighbors = [
          GridOffset(r + 1, c),
          GridOffset(r, c + 1),
        ];

        for (var neighbor in neighbors) {
          if (neighbor.row < 6 && neighbor.col < 6) {
            // Check if they are NOT consecutive in the solution path
            if (!_areConsecutive(current, neighbor, finalSolution)) {
              // Randomly place a wall with some probability to guide the user
              if (random.nextDouble() < 0.2) { 
                walls.add(_getWallKey(current, neighbor));
              }
            }
          }
        }
      }
    }

    return (hints: hints, solution: finalSolution, hintSteps: hintSteps, walls: walls);
  }

  bool _areConsecutive(GridOffset a, GridOffset b, List<GridOffset> path) {
    final idxA = path.indexOf(a);
    final idxB = path.indexOf(b);
    return (idxA - idxB).abs() == 1;
  }

  String _getWallKey(GridOffset a, GridOffset b) {
    final list = [a.toString(), b.toString()]..sort();
    return '${list[0]}-${list[1]}';
  }

  List<GridOffset> _generateSnakePath() {
    final List<GridOffset> path = [];
    for (int r = 0; r < 6; r++) {
      if (r % 2 == 0) {
        for (int c = 0; c < 6; c++) path.add(GridOffset(r, c));
      } else {
        for (int c = 5; c >= 0; c--) path.add(GridOffset(r, c));
      }
    }
    return path;
  }

  List<GridOffset>? _generateHamiltonianPath() {
    final random = Random();
    final startRow = random.nextInt(6);
    final startCol = random.nextInt(6);
    final path = [GridOffset(startRow, startCol)];
    final visited = List.generate(6, (_) => List<bool>.generate(6, (_) => false));
    visited[startRow][startCol] = true;

    if (_solvePath(path, visited, random)) {
      return path;
    }
    return null;
  }

  bool _solvePath(List<GridOffset> path, List<List<bool>> visited, Random random) {
    if (path.length == 36) return true;

    final last = path.last;
    final neighbors = [
      GridOffset(last.row + 1, last.col),
      GridOffset(last.row - 1, last.col),
      GridOffset(last.row, last.col + 1),
      GridOffset(last.row, last.col - 1),
    ];
    neighbors.shuffle(random);

    for (var neighbor in neighbors) {
      if (neighbor.row >= 0 && neighbor.row < 6 && 
          neighbor.col >= 0 && neighbor.col < 6 && 
          !visited[neighbor.row][neighbor.col]) {
        
        visited[neighbor.row][neighbor.col] = true;
        path.add(neighbor);
        
        if (_solvePath(path, visited, random)) return true;
        
        path.removeLast();
        visited[neighbor.row][neighbor.col] = false;
      }
    }
    return false;
  }

  void _onSelectCell(SelectCell event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing) return;

    final tapped = GridOffset(event.row, event.col);
    final currentPath = List<GridOffset>.from(state.currentPath);

    if (currentPath.isNotEmpty && currentPath.last == tapped) return;

    if (currentPath.isEmpty) {
      if (state.hints[event.row][event.col] == 1) {
        emit(state.copyWith(currentPath: [tapped]));
      }
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
      // Check for walls
      if (state.walls.contains(_getWallKey(last, tapped))) {
        return;
      }

      final newPath = [...currentPath, tapped];
      emit(state.copyWith(currentPath: newPath, isAngry: _checkIfAngry(newPath)));

      if (newPath.length == 36) {
        if (_validatePath(newPath)) {
          emit(state.copyWith(status: GameStatus.won, isAngry: false));
          _timer?.cancel();
        }
      }
    }
  }

  bool _checkIfAngry(List<GridOffset> path) {
    int maxHintSeen = 0;
    int hintsCounted = 0;
    
    for (var pos in path) {
      final val = state.hints[pos.row][pos.col];
      if (val != null) {
        hintsCounted++;
        if (val > maxHintSeen) maxHintSeen = val;
        
        // If we seen hint 3 but we only have 1 hint total in path, we skipped one.
        if (maxHintSeen > hintsCounted) return true;
      }
    }
    return false;
  }

  bool _validatePath(List<GridOffset> path) {
    // Collect all hints and their user-provided indices
    final List<({int value, int index})> hintOrder = [];
    
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        final hintValue = state.hints[r][c];
        if (hintValue != null) {
          final pos = GridOffset(r, c);
          final userIndex = path.indexOf(pos);
          if (userIndex == -1) return false; // Should not happen if path.length == 36
          hintOrder.add((value: hintValue, index: userIndex));
        }
      }
    }

    // Sort by hint value (1, 2, 3...)
    hintOrder.sort((a, b) => a.value.compareTo(b.value));

    // Ensure indices are strictly increasing
    for (int i = 0; i < hintOrder.length - 1; i++) {
      if (hintOrder[i].index > hintOrder[i+1].index) {
        return false;
      }
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
