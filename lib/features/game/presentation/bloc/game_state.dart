import 'package:equatable/equatable.dart';

enum GameStatus { initial, playing, won, lost }

class GameState extends Equatable {
  final List<List<int?>> hints; // The pre-filled numbers (1 to N)
  final List<GridOffset> currentPath; // The user's current progress
  final int remainingSeconds;
  final GameStatus status;
  final List<GridOffset> solutionPath; // The generated 1-36 path
  final Map<GridOffset, int> hintSteps; // Map grid position to step index (0-35)
  final Set<String> walls; // "r1,c1-r2,c2" formatted strings for walls between adjacent cells

  const GameState({
    this.hints = const [],
    this.currentPath = const [],
    this.remainingSeconds = 0,
    this.status = GameStatus.initial,
    this.solutionPath = const [],
    this.hintSteps = const {},
    this.walls = const {},
  });

  GameState copyWith({
    List<List<int?>>? hints,
    List<GridOffset>? currentPath,
    int? remainingSeconds,
    GameStatus? status,
    List<GridOffset>? solutionPath,
    Map<GridOffset, int>? hintSteps,
    Set<String>? walls,
  }) {
    return GameState(
      hints: hints ?? this.hints,
      currentPath: currentPath ?? this.currentPath,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      solutionPath: solutionPath ?? this.solutionPath,
      hintSteps: hintSteps ?? this.hintSteps,
      walls: walls ?? this.walls,
    );
  }

  @override
  List<Object> get props => [hints, currentPath, remainingSeconds, status, solutionPath, hintSteps, walls];
}

class GridOffset extends Equatable {
  final int row;
  final int col;

  const GridOffset(this.row, this.col);

  @override
  List<Object> get props => [row, col];

  @override
  String toString() => '$row,$col';
}
