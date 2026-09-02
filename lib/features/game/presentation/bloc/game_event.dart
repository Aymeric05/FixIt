import 'package:equatable/equatable.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class StartGame extends GameEvent {
  final int level;
  final GameDifficulty difficulty;
  final String playerId;
  final int invPlusTime;
  final int invMoreNumbers;
  final int invRevealPath;

  const StartGame({
    required this.level, 
    required this.difficulty, 
    required this.playerId,
    this.invPlusTime = 5,
    this.invMoreNumbers = 5,
    this.invRevealPath = 5,
  });

  @override
  List<Object> get props => [level, difficulty, playerId, invPlusTime, invMoreNumbers, invRevealPath];
}

class SelectCell extends GameEvent {
  final int row;
  final int col;

  const SelectCell(this.row, this.col);

  @override
  List<Object> get props => [row, col];
}

class TimerTick extends GameEvent {
  final int remainingSeconds;

  const TimerTick(this.remainingSeconds);

  @override
  List<Object> get props => [remainingSeconds];
}

class PauseTimer extends GameEvent {}
class ResumeTimer extends GameEvent {}

class ContinueGameWithVideo extends GameEvent {}

class UseItemPlusTime extends GameEvent {}
class UseItemMoreNumbers extends GameEvent {}
class UseItemRevealPath extends GameEvent {}
