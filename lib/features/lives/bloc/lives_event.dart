import 'package:equatable/equatable.dart';

abstract class LivesEvent extends Equatable {
  const LivesEvent();

  @override
  List<Object> get props => [];
}

class LoadLives extends LivesEvent {}

class DecrementLife extends LivesEvent {}

class IncrementLife extends LivesEvent {}
