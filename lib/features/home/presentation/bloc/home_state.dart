part of 'home_bloc.dart';

enum GameDifficulty { easy, medium, hard }

class HomeState extends Equatable {
  final int currentLevel;
  final int lives;
  final int maxLives;
  final GameDifficulty difficulty;
  final bool isLoading;
  
  // New Fields
  final String username;
  final bool isMusicEnabled;
  final bool isSoundEnabled;
  final bool isNoAdsActive;
  final int videosWatched;
  final DateTime? nextLifeTime;
  
  // Progression Fields
  final int levelsCompletedInWorld;
  final int maxLevelsInWorld;
  final int currentWorldIndex;

  const HomeState({
    this.currentLevel = 1,
    this.lives = 5,
    this.maxLives = 5,
    this.difficulty = GameDifficulty.easy,
    this.isLoading = false,
    this.username = 'Player123',
    this.isMusicEnabled = true,
    this.isSoundEnabled = true,
    this.isNoAdsActive = false,
    this.videosWatched = 0,
    this.nextLifeTime,
    this.levelsCompletedInWorld = 0,
    this.maxLevelsInWorld = 10,
    this.currentWorldIndex = 1,
  });

  HomeState copyWith({
    int? currentLevel,
    int? lives,
    int? maxLives,
    GameDifficulty? difficulty,
    bool? isLoading,
    String? username,
    bool? isMusicEnabled,
    bool? isSoundEnabled,
    bool? isNoAdsActive,
    int? videosWatched,
    DateTime? nextLifeTime,
    int? levelsCompletedInWorld,
    int? maxLevelsInWorld,
    int? currentWorldIndex,
  }) {
    return HomeState(
      currentLevel: currentLevel ?? this.currentLevel,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      difficulty: difficulty ?? this.difficulty,
      isLoading: isLoading ?? this.isLoading,
      username: username ?? this.username,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isNoAdsActive: isNoAdsActive ?? this.isNoAdsActive,
      videosWatched: videosWatched ?? this.videosWatched,
      nextLifeTime: nextLifeTime ?? this.nextLifeTime,
      levelsCompletedInWorld: levelsCompletedInWorld ?? this.levelsCompletedInWorld,
      maxLevelsInWorld: maxLevelsInWorld ?? this.maxLevelsInWorld,
      currentWorldIndex: currentWorldIndex ?? this.currentWorldIndex,
    );
  }

  @override
  List<Object?> get props => [
        currentLevel,
        lives,
        maxLives,
        difficulty,
        isLoading,
        username,
        isMusicEnabled,
        isSoundEnabled,
        isNoAdsActive,
        videosWatched,
        nextLifeTime,
        levelsCompletedInWorld,
        maxLevelsInWorld,
        currentWorldIndex,
      ];
}
