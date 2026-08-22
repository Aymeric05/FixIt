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

  const StartGame({required this.level, required this.difficulty});

  @override
  List<Object> get props => [level, difficulty];
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
