import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/main_play_button.dart';
import '../widgets/lives_store_dialog.dart';
import '../../../game/presentation/pages/game_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/candy_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeData()),
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image with slight blur
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

            // Main UI
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Stack(
                  children: [
                    Column(
                      children: [
                        TopNavBar(
                          lives: state.lives,
                          maxLives: state.maxLives,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              // Middle Section
                              const Center(
                                // Place for world elements
                              ),
                              
                              // Bottom Section
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(width: 80), // Balanced width
                                          MainPlayButton(
                                            level: state.currentLevel,
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => const GamePage(),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 20),
                                          _FloatingBuyButton(),
                                        ],
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
        color: Colors.blue.withOpacity(0.3), // Transparent blue background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress Fill (Solid Yellow)
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow, // Solid yellow fill
                    boxShadow: [BoxShadow(color: Colors.yellow.withOpacity(0.5), blurRadius: 6)],
                  ),
                ),
              ),
            ),
            // Text inside the bar
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
        width: 80,
        height: 80,
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
            Icon(Icons.favorite, color: Colors.white, size: 40),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.candyGreen,
                child: Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
