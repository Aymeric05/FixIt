import 'package:equatable/equatable.dart';

class LivesState extends Equatable {
  final int currentLives;
  final int maxLives;
  final DateTime? lastLifeLost;

  const LivesState({
    this.currentLives = 5,
    this.maxLives = 5,
    this.lastLifeLost,
  });

  LivesState copyWith({
    int? currentLives,
    int? maxLives,
    DateTime? lastLifeLost,
  }) {
    return LivesState(
      currentLives: currentLives ?? this.currentLives,
      maxLives: maxLives ?? this.maxLives,
      lastLifeLost: lastLifeLost ?? this.lastLifeLost,
    );
  }

  @override
  List<Object?> get props => [currentLives, maxLives, lastLifeLost];
}
