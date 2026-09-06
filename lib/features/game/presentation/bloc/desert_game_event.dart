import 'package:equatable/equatable.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/core/models/daily_mode.dart';

abstract class DesertGameEvent extends Equatable {
  const DesertGameEvent();
  @override
  List<Object> get props => [];
}

class StartDesertGame extends DesertGameEvent {
  final int level;
  final GameDifficulty difficulty;
  final String playerId;
  final FixItGameMode mode;
  final int invWaterBucket;
  final int invGoldenWrench;
  final int invSandShovel;

  const StartDesertGame({
    required this.level,
    required this.difficulty,
    required this.playerId,
    this.mode = FixItGameMode.story,
    required this.invWaterBucket,
    required this.invGoldenWrench,
    required this.invSandShovel,
  });

  @override
  List<Object> get props => [level, difficulty, playerId, mode, invWaterBucket, invGoldenWrench, invSandShovel];
}

class RotateTile extends DesertGameEvent {
  final int row;
  final int col;
  const RotateTile(this.row, this.col);
}

class DesertTimerTick extends DesertGameEvent {
  final int remainingSeconds;
  const DesertTimerTick(this.remainingSeconds);
}

class UseWaterBucket extends DesertGameEvent {}
class UseGoldenWrench extends DesertGameEvent {}
class UseSandShovel extends DesertGameEvent {}
