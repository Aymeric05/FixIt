import 'package:equatable/equatable.dart';
import 'package:fixit/core/models/level_win_summary.dart';
import 'package:fixit/core/models/daily_mode.dart';

enum DesertGameStatus { initial, playing, won, lost }

enum DesertTileType { empty, straight, elbow, cross, source, sink }

class DesertTile {
  final DesertTileType type;
  final int rotation; // 0: 0°, 1: 90°, 2: 180°, 3: 270°
  final bool isWatered;
  final bool isFixed;
  final bool hasSandStorm;

  const DesertTile({
    required this.type,
    this.rotation = 0,
    this.isWatered = false,
    this.isFixed = false,
    this.hasSandStorm = false,
  });

  DesertTile copyWith({
    DesertTileType? type,
    int? rotation,
    bool? isWatered,
    bool? isFixed,
    bool? hasSandStorm,
  }) {
    return DesertTile(
      type: type ?? this.type,
      rotation: rotation ?? this.rotation,
      isWatered: isWatered ?? this.isWatered,
      isFixed: isFixed ?? this.isFixed,
      hasSandStorm: hasSandStorm ?? this.hasSandStorm,
    );
  }
}

class DesertGameState extends Equatable {
  final DesertGameStatus status;
  final List<List<DesertTile>> grid;
  final int remainingSeconds;
  final int initialSeconds;
  final int levelNumber;
  final FixItGameMode mode;
  final LevelWinSummary? winSummary;
  
  // Inventory
  final int invWaterBucket;
  final int invGoldenWrench;
  final int invSandShovel;

  const DesertGameState({
    this.status = DesertGameStatus.initial,
    this.grid = const [],
    this.remainingSeconds = 0,
    this.initialSeconds = 0,
    this.levelNumber = 1,
    this.mode = FixItGameMode.story,
    this.winSummary,
    this.invWaterBucket = 0,
    this.invGoldenWrench = 0,
    this.invSandShovel = 0,
  });

  DesertGameState copyWith({
    DesertGameStatus? status,
    List<List<DesertTile>>? grid,
    int? remainingSeconds,
    int? initialSeconds,
    int? levelNumber,
    FixItGameMode? mode,
    LevelWinSummary? winSummary,
    int? invWaterBucket,
    int? invGoldenWrench,
    int? invSandShovel,
  }) {
    return DesertGameState(
      status: status ?? this.status,
      grid: grid ?? this.grid,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      initialSeconds: initialSeconds ?? this.initialSeconds,
      levelNumber: levelNumber ?? this.levelNumber,
      mode: mode ?? this.mode,
      winSummary: winSummary ?? this.winSummary,
      invWaterBucket: invWaterBucket ?? this.invWaterBucket,
      invGoldenWrench: invGoldenWrench ?? this.invGoldenWrench,
      invSandShovel: invSandShovel ?? this.invSandShovel,
    );
  }

  @override
  List<Object?> get props => [status, grid, remainingSeconds, levelNumber, invWaterBucket, invGoldenWrench, invSandShovel];
}
