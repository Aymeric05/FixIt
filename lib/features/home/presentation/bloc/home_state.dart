part of 'home_bloc.dart';

enum GameDifficulty { facile, medium, difficile }

class HomeState extends Equatable {
  final int currentLevel;
  final int lives;
  final int maxLives;
  final GameDifficulty difficulty;
  final bool isLoading;

  const HomeState({
    this.currentLevel = 1,
    this.lives = 3,
    this.maxLives = 5,
    this.difficulty = GameDifficulty.facile,
    this.isLoading = false,
  });

  HomeState copyWith({
    int? currentLevel,
    int? lives,
    int? maxLives,
    GameDifficulty? difficulty,
    bool? isLoading,
  }) {
    return HomeState(
      currentLevel: currentLevel ?? this.currentLevel,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      difficulty: difficulty ?? this.difficulty,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [currentLevel, lives, maxLives, difficulty, isLoading];
}
