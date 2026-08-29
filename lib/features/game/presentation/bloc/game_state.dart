import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/core/models/daily_mode.dart';

import 'package:fixit/core/models/level_win_summary.dart';

enum GameStatus { initial, playing, won, lost }

class GameState extends Equatable {
  final List<List<int?>> hints; // The pre-filled numbers (1 to N)
  final List<GridOffset> currentPath; // The user's current progress
  final int remainingSeconds;
  final int initialSeconds; // Added to calculate time taken
  final GameStatus status;
  final List<GridOffset> solutionPath; // The generated 1-36 path
  final Map<GridOffset, int> hintSteps; // Map grid position to step index (0-35)
  final Set<String> walls; // "r1,c1-r2,c2" formatted strings for walls between adjacent cells
  final Color pathColor;
  final bool isAngry;
  final int averageTimeSeconds;
  final int bestTimeSeconds;
  final int levelNumber;
  final LevelWinSummary? winSummary;
  final List<FriendRankEntry> friendsLeaderboard;
  final GameMode mode;
  final int seriesAccumulatedTime;

  const GameState({
    this.hints = const [],
    this.currentPath = const [],
    this.remainingSeconds = 0,
    this.initialSeconds = 0,
    this.status = GameStatus.initial,
    this.solutionPath = const [],
    this.hintSteps = const {},
    this.walls = const {},
    this.pathColor = Colors.orange,
    this.isAngry = false,
    this.averageTimeSeconds = 0,
    this.bestTimeSeconds = 0,
    this.levelNumber = 1,
    this.winSummary,
    this.friendsLeaderboard = const [],
    this.mode = GameMode.story,
    this.seriesAccumulatedTime = 0,
  });

  GameState copyWith({
    List<List<int?>>? hints,
    List<GridOffset>? currentPath,
    int? remainingSeconds,
    int? initialSeconds,
    GameStatus? status,
    List<GridOffset>? solutionPath,
    Map<GridOffset, int>? hintSteps,
    Set<String>? walls,
    Color? pathColor,
    bool? isAngry,
    int? averageTimeSeconds,
    int? bestTimeSeconds,
    int? levelNumber,
    LevelWinSummary? winSummary,
    List<FriendRankEntry>? friendsLeaderboard,
    GameMode? mode,
    int? seriesAccumulatedTime,
  }) {
    return GameState(
      hints: hints ?? this.hints,
      currentPath: currentPath ?? this.currentPath,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      initialSeconds: initialSeconds ?? this.initialSeconds,
      status: status ?? this.status,
      solutionPath: solutionPath ?? this.solutionPath,
      hintSteps: hintSteps ?? this.hintSteps,
      walls: walls ?? this.walls,
      pathColor: pathColor ?? this.pathColor,
      isAngry: isAngry ?? this.isAngry,
      averageTimeSeconds: averageTimeSeconds ?? this.averageTimeSeconds,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      levelNumber: levelNumber ?? this.levelNumber,
      winSummary: winSummary ?? this.winSummary,
      friendsLeaderboard: friendsLeaderboard ?? this.friendsLeaderboard,
      mode: mode ?? this.mode,
      seriesAccumulatedTime: seriesAccumulatedTime ?? this.seriesAccumulatedTime,
    );
  }

  @override
  List<Object?> get props => [
    hints, currentPath, remainingSeconds, initialSeconds, 
    status, solutionPath, hintSteps, walls, pathColor, isAngry,
    averageTimeSeconds, bestTimeSeconds, levelNumber, winSummary,
    friendsLeaderboard, mode, seriesAccumulatedTime,
  ];
}
