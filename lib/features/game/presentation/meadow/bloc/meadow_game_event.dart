import 'package:equatable/equatable.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/core/models/daily_mode.dart';

abstract class MeadowGameEvent extends Equatable {
  const MeadowGameEvent();

  @override
  List<Object> get props => [];
}

class StartGame extends MeadowGameEvent {
  final int level;
  final GameDifficulty difficulty;
  final String playerId;
  final FixItGameMode mode;
  final int invPlusTime;
  final int invMoreNumbers;
  final int invRevealPath;

  const StartGame({
    required this.level,
    required this.difficulty,
    required this.playerId,
    this.mode = FixItGameMode.story,
    this.invPlusTime = 5,
    this.invMoreNumbers = 5,
    this.invRevealPath = 5,
  });

  @override
  List<Object> get props => [level, difficulty, playerId, mode, invPlusTime, invMoreNumbers, invRevealPath];
}

class SelectCell extends MeadowGameEvent {
  final int row;
  final int col;
  final bool isDrag;

  const SelectCell(this.row, this.col, {this.isDrag = false});

  @override
  List<Object> get props => [row, col, isDrag];
}

class TimerTick extends MeadowGameEvent {
  final int remainingSeconds;

  const TimerTick(this.remainingSeconds);

  @override
  List<Object> get props => [remainingSeconds];
}

class LoadFriendsLeaderboard extends MeadowGameEvent {
  final String playerId;
  const LoadFriendsLeaderboard({required this.playerId});

  @override
  List<Object> get props => [playerId];
}

class PauseTimer extends MeadowGameEvent {}
class ResumeTimer extends MeadowGameEvent {}

class ContinueGameWithVideo extends MeadowGameEvent {}

class UseItemPlusTime extends MeadowGameEvent {}
class UseItemMoreNumbers extends MeadowGameEvent {}
class UseItemRevealPath extends MeadowGameEvent {}

class RecoverFromDizzy extends MeadowGameEvent {}

class ResetAngryFace extends MeadowGameEvent {}

class AbandonGame extends MeadowGameEvent {}
