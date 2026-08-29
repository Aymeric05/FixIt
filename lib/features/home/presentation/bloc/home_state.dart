part of 'home_bloc.dart';

enum GameDifficulty { easy, medium, hard }
enum HomeLastAction { none, win, loss, lifeRegained }

class HomeState extends Equatable {
  final int currentLevel;
  final int lives;
  final int maxLives;
  final int hints;
  final GameDifficulty difficulty;
  final bool isLoading;
  
  // New Fields
  final bool isMusicEnabled;
  final bool isSoundEnabled;
  final bool isNoAdsActive;
  final int videosWatched;
  final DateTime? nextLifeTime;
  
  // Progression Fields
  final int levelsCompletedInWorld;
  final int maxLevelsInWorld;
  final int currentWorldIndex;
  final HomeLastAction lastAction;
  final int timerTick; 
  final bool isWorldLoading;

  const HomeState({
    this.currentLevel = 1,
    this.lives = 5,
    this.maxLives = 5,
    this.hints = 10,
    this.difficulty = GameDifficulty.easy,
    this.isLoading = false,
    this.isMusicEnabled = true,
    this.isSoundEnabled = true,
    this.isNoAdsActive = false,
    this.videosWatched = 0,
    this.nextLifeTime,
    this.levelsCompletedInWorld = 0,
    this.maxLevelsInWorld = 10,
    this.currentWorldIndex = 1,
    this.lastAction = HomeLastAction.none,
    this.timerTick = 0,
    this.isWorldLoading = false,
  });

  HomeState copyWith({
    int? currentLevel,
    int? lives,
    int? maxLives,
    int? hints,
    GameDifficulty? difficulty,
    bool? isLoading,
    bool? isMusicEnabled,
    bool? isSoundEnabled,
    bool? isNoAdsActive,
    int? videosWatched,
    DateTime? nextLifeTime,
    int? levelsCompletedInWorld,
    int? maxLevelsInWorld,
    int? currentWorldIndex,
    HomeLastAction? lastAction,
    int? timerTick,
    bool? isWorldLoading,
  }) {
    return HomeState(
      currentLevel: currentLevel ?? this.currentLevel,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      hints: hints ?? this.hints,
      difficulty: difficulty ?? this.difficulty,
      isLoading: isLoading ?? this.isLoading,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isNoAdsActive: isNoAdsActive ?? this.isNoAdsActive,
      videosWatched: videosWatched ?? this.videosWatched,
      nextLifeTime: nextLifeTime ?? this.nextLifeTime,
      levelsCompletedInWorld: levelsCompletedInWorld ?? this.levelsCompletedInWorld,
      maxLevelsInWorld: maxLevelsInWorld ?? this.maxLevelsInWorld,
      currentWorldIndex: currentWorldIndex ?? this.currentWorldIndex,
      lastAction: lastAction ?? this.lastAction,
      timerTick: timerTick ?? this.timerTick,
      isWorldLoading: isWorldLoading ?? this.isWorldLoading,
    );
  }

  @override
  List<Object?> get props => [
        currentLevel,
        lives,
        maxLives,
        hints,
        difficulty,
        isLoading,
        isMusicEnabled,
        isSoundEnabled,
        isNoAdsActive,
        videosWatched,
        nextLifeTime,
        levelsCompletedInWorld,
        maxLevelsInWorld,
        currentWorldIndex,
        lastAction,
        timerTick,
        isWorldLoading,
      ];
}
