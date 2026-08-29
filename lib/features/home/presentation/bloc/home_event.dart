part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeData extends HomeEvent {
  final String? playerId;
  const LoadHomeData({this.playerId});
  @override
  List<Object> get props => [playerId ?? ''];
}

class ToggleMusic extends HomeEvent {}

class ToggleSound extends HomeEvent {}

class WatchVideoForLife extends HomeEvent {}

class BuyLives extends HomeEvent {
  final int count;
  const BuyLives(this.count);
  @override
  List<Object> get props => [count];
}

class BuyUnlimitedLives extends HomeEvent {}

class BuyNoAds extends HomeEvent {}

class TickLifeRecharge extends HomeEvent {}

class CompleteLevel extends HomeEvent {
  final String? playerId;
  const CompleteLevel({this.playerId});
  @override
  List<Object> get props => [playerId ?? ''];
}

class LoseLife extends HomeEvent {
  final String? playerId;
  const LoseLife({this.playerId});
  @override
  List<Object> get props => [playerId ?? ''];
}

class ChangeWorld extends HomeEvent {
  final int worldIndex;
  final String worldId;
  const ChangeWorld(this.worldIndex, this.worldId);
  @override
  List<Object> get props => [worldIndex, worldId];
}

class FinishWorldLoading extends HomeEvent {}
