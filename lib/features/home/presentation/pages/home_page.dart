import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/features/home/presentation/widgets/top_nav_bar.dart';
import 'package:fixit/features/home/presentation/widgets/main_play_button.dart';
import 'package:fixit/features/home/presentation/widgets/lives_store_dialog.dart';
import 'package:fixit/features/home/presentation/pages/loading_screen.dart';
import 'package:fixit/features/game/presentation/pages/game_page.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_state.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_event.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:confetti/confetti.dart';

import 'package:fixit/features/home/presentation/widgets/daily_popup.dart';
import 'package:fixit/core/models/daily_mode.dart';
import 'package:fixit/core/repositories/daily_repository.dart';
import 'package:fixit/core/database/app_database.dart';

import 'package:fixit/core/utils/app_notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late ConfettiController _confettiController;
  bool _isDailyPopupShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 800));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyChallenge();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeBloc>().add(AppResumed());
    }
  }

  Future<void> _checkDailyChallenge() async {
    if (_isDailyPopupShowing) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final repo = DailyRepository();
      final status = await repo.getDailyStatus(authState.user.id);
      
      bool alreadyCompleted = status != null && status.isDailyLevelCompleted && status.isSeriesCompleted;
      
      if (!alreadyCompleted && mounted) {
        _showDailyPopup(
          isDailyCompleted: status?.isDailyLevelCompleted ?? false,
          isSeriesCompleted: status?.isSeriesCompleted ?? false,
          status: status,
        );
      }
    }
  }

  void _showDailyPopup({
    required bool isDailyCompleted,
    required bool isSeriesCompleted,
    DailyChallenge? status,
  }) {
    if (_isDailyPopupShowing) return;
    _isDailyPopupShowing = true;

    showDialog(
      context: context,
      builder: (dialogContext) => DailyPopup(
        isDailyCompleted: isDailyCompleted,
        isSeriesCompleted: isSeriesCompleted,
        onPlayDaily: () {
          Navigator.pop(dialogContext);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GamePage(
                level: 1,
                difficulty: GameDifficulty.easy,
                mode: GameMode.dailySingle,
              ),
            ),
          ).then((_) {
            if (mounted) {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<HomeBloc>().add(LoadHomeData(playerId: authState.user.id));
              }
            }
          });
        },
        onPlaySeries: () {
          Navigator.pop(dialogContext);
          
          int startLevel = 1;
          if (status != null) {
            if (status.isSeriesCompleted) {
              startLevel = 3; // Show recap of last level
            } else if (status.seriesCurrentLevel > 0) {
              startLevel = status.seriesCurrentLevel; // Show recap of last finished level
            }
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GamePage(
                level: startLevel,
                difficulty: GameDifficulty.easy,
                mode: GameMode.dailySeries,
              ),
            ),
          ).then((_) {
            if (mounted) {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<HomeBloc>().add(LoadHomeData(playerId: authState.user.id));
              }
            }
          });
        },
      ),
    ).then((_) {
      _isDailyPopupShowing = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              AppNotifications.show(context, 'Auth Error: ${state.message}', isError: true);
            } else if (state is AuthAuthenticated) {
              // Reload home data and friends when authenticated
              context.read<HomeBloc>().add(LoadHomeData(playerId: state.user.id));
              context.read<FriendsBloc>().add(LoadFriends(state.user.id));
              context.read<FriendsBloc>().add(StartSocialSubscription(state.user.id));
              _checkDailyChallenge();
            }
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (previous, current) =>
              (previous.levelsCompletedInWorld != current.levelsCompletedInWorld && current.lastAction == HomeLastAction.win),
          listener: (context, state) {
            _confettiController.play();
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (previous, current) => previous.currentDate != current.currentDate,
          listener: (context, state) {
            if (state.currentDate != null) {
              _checkDailyChallenge();
            }
          },
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (prev, curr) => prev.currentWorldIndex != curr.currentWorldIndex,
                builder: (context, state) {
                  String bg = 'monde1_background.png';
                  // Add logic for other worlds if assets exist
                  return Image.asset(
                    bg,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.lightBlue, Colors.green],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: Container(color: Colors.transparent),
              ),
            ),
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        TopNavBar(
                          onDailyPressed: () async {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthAuthenticated) {
                              final repo = DailyRepository();
                              final status = await repo.getDailyStatus(authState.user.id);
                              if (mounted) {
                                _showDailyPopup(
                                  isDailyCompleted: context.read<HomeBloc>().state.isDailyCompleted,
                                  isSeriesCompleted: context.read<HomeBloc>().state.isSeriesCompleted,
                                  status: status,
                                );
                              }
                            }
                          },
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              const Center(),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        height: 100,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            MainPlayButton(
                                              level: state.currentLevel,
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => GamePage(
                                                      level: state.currentLevel,
                                                      difficulty: state.difficulty,
                                                      invPlusTime: state.itemPlusTime,
                                                      invMoreNumbers: state.itemMoreNumbers,
                                                      invRevealPath: state.itemRevealPath,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Positioned(
                                              right: 20,
                                              child: _FloatingBuyButton(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      _buildExperienceBar(state),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (state.isWorldLoading)
                      Positioned.fill(
                        child: LoadingScreen(
                          isDataLoading: false,
                          onComplete: () {
                            context.read<HomeBloc>().add(FinishWorldLoading());
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                  Colors.red,
                ],
                numberOfParticles: 60,
                gravity: 0.1,
              ),
            ),
            Align(
              alignment: const Alignment(-0.8, -1.0),
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 20,
                gravity: 0.1,
              ),
            ),
            Align(
              alignment: const Alignment(0.8, -1.0),
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 20,
                gravity: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceBar(HomeState state) {
    double progress = state.levelsCompletedInWorld / state.maxLevelsInWorld;
    int levelsLeft = state.maxLevelsInWorld - state.levelsCompletedInWorld;
    return Container(
      width: 320,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    boxShadow: [BoxShadow(color: Colors.yellow.withValues(alpha: 0.5), blurRadius: 6)],
                  ),
                ),
              ),
            ),
            Text(
              'NEXT WORLD IN $levelsLeft LEVELS',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBuyButton extends StatefulWidget {
  @override
  State<_FloatingBuyButton> createState() => _FloatingBuyButtonState();
}

class _FloatingBuyButtonState extends State<_FloatingBuyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: child,
        );
      },
      child: CandyButton(
        width: 60,
        height: 60,
        color: AppColors.candyPink,
        darkColor: AppColors.candyPinkDark,
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => BlocProvider.value(
              value: BlocProvider.of<HomeBloc>(context),
              child: const LivesStoreDialog(),
            ),
          );
        },
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 30),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.candyGreen,
                child: Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
