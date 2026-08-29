import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/features/home/presentation/widgets/top_nav_bar.dart';
import 'package:fixit/features/home/presentation/widgets/main_play_button.dart';
import 'package:fixit/features/home/presentation/widgets/lives_store_dialog.dart';
import 'package:fixit/features/game/presentation/pages/game_page.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_state.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_event.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:confetti/confetti.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Auth Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AuthAuthenticated) {
              // Reload home data and friends when authenticated
              context.read<HomeBloc>().add(LoadHomeData(playerId: state.user.id));
              context.read<FriendsBloc>().add(LoadFriends(state.user.id));
            }
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (previous, current) =>
              previous.levelsCompletedInWorld != current.levelsCompletedInWorld && current.lastAction == HomeLastAction.win,
          listener: (context, state) {
            _confettiController.play();
          },
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'monde1_background.png',
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
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Stack(
                  children: [
                    Column(
                      children: [
                        const TopNavBar(),
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
                                            Positioned(
                                              left: 20,
                                              child: _buildHintIndicator(context, state),
                                            ),
                                            MainPlayButton(
                                              level: state.currentLevel,
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => GamePage(
                                                      level: state.currentLevel,
                                                      difficulty: state.difficulty,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Positioned(
                                              right: 25,
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

  Widget _buildHintIndicator(BuildContext context, HomeState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.lightbulb, color: Colors.black26, size: 54),
            ShaderMask(
              shaderCallback: (bounds) => const RadialGradient(
                center: Alignment(-0.3, -0.3),
                colors: [Colors.white, Colors.amber, Color(0xFFB8860B)],
                radius: 0.8,
              ).createShader(bounds),
              child: const Icon(Icons.lightbulb, color: Colors.white, size: 50),
            ),
            Text(
              '${state.hints}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'HINTS',
          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
        ),
      ],
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
