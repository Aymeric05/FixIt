import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/game/desert/bloc/desert_game_bloc.dart';
import 'package:fixit/features/game/desert/bloc/desert_game_event.dart';
import 'package:fixit/features/game/desert/bloc/desert_game_state.dart';
import 'package:fixit/features/home/bloc/home_bloc.dart';
import 'package:fixit/features/game/widgets/game_header.dart';
import 'package:fixit/features/game/widgets/game_inventory.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/models/daily_mode.dart';
import 'package:fixit/features/auth/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/bloc/auth_state.dart';
import 'package:fixit/core/widgets/tutorial_dialog.dart';
import 'package:fixit/core/widgets/breaking_heart_animation.dart';
import 'package:fixit/features/home/widgets/candy_dialog.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:confetti/confetti.dart';

class DesertGamePage extends StatefulWidget {
  final int level;
  final GameDifficulty difficulty;
  final FixItGameMode mode;
  final int invWaterBucket;
  final int invGoldenWrench;
  final int invSandShovel;

  const DesertGamePage({
    super.key,
    required this.level,
    required this.difficulty,
    this.mode = FixItGameMode.story,
    required this.invWaterBucket,
    required this.invGoldenWrench,
    required this.invSandShovel,
  });

  @override
  State<DesertGamePage> createState() => _DesertGamePageState();
}

class _DesertGamePageState extends State<DesertGamePage> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  bool _tutorialShown = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final String playerId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocProvider(
      create: (context) => DesertGameBloc()
        ..add(StartDesertGame(
          level: widget.level,
          difficulty: widget.difficulty,
          playerId: playerId,
          mode: widget.mode,
          invWaterBucket: widget.invWaterBucket,
          invGoldenWrench: widget.invGoldenWrench,
          invSandShovel: widget.invSandShovel,
        )),
      child: Builder(builder: (providerContext) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBackPress(providerContext, playerId);
          },
          child: Scaffold(
            body: BlocConsumer<DesertGameBloc, DesertGameState>(
              listener: (context, state) {
                if (state.status == DesertGameStatus.playing && widget.level == 1 && !_tutorialShown) {
                  _tutorialShown = true;
                  TutorialDialog.showIfFirstTime(
                    context,
                    tutorialKey: 'desert_tutorial_seen',
                    worldIndex: 2,
                  );
                }
                if (state.status == DesertGameStatus.won) {
                  _confettiController.play();
                  _showWinDialog(context, state, playerId);
                } else if (state.status == DesertGameStatus.lost) {
                  _showGameOverDialog(context);
                }
              },
              builder: (context, state) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/Monde_2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          GameHeader(
                            level: widget.level,
                            mode: widget.mode,
                            remainingSeconds: state.remainingSeconds,
                            titleOverride: widget.mode == FixItGameMode.dailySingle ? 'DAILY OASIS' : '',
                            onPause: () => context.read<DesertGameBloc>().add(PauseDesertTimer()),
                            onResume: () => context.read<DesertGameBloc>().add(ResumeDesertTimer()),
                            onClose: () => _handleBackPress(context, playerId),
                          ),
                          const SizedBox(height: 10),
                          GameInventory(
                            items: [
                              GameItemData(
                                icon: Icons.opacity,
                                color: Colors.blueAccent,
                                count: state.invWaterBucket,
                                onTap: () => context.read<DesertGameBloc>().add(UseWaterBucket()),
                              ),
                              GameItemData(
                                icon: Icons.build,
                                color: Colors.amber,
                                count: state.invGoldenWrench,
                                onTap: () => context.read<DesertGameBloc>().add(UseGoldenWrench()),
                              ),
                              GameItemData(
                                icon: Icons.handyman,
                                color: Colors.orangeAccent,
                                count: state.invSandShovel,
                                onTap: () => context.read<DesertGameBloc>().add(UseSandShovel()),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _buildGridContainer(context, state),
                          const Spacer(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: IgnorePointer(
                        child: ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          shouldLoop: false,
                          colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.yellow],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }),
    );
  }

  void _handleBackPress(BuildContext context, String playerId) {
     final state = context.read<DesertGameBloc>().state;
     if (state.status == DesertGameStatus.won) {
        _navigateBackAndComplete(context, state);
     } else {
        _showQuitConfirmationDialog(context, playerId);
     }
  }

  Widget _buildGridContainer(BuildContext context, DesertGameState state) {
    if (state.grid.isEmpty) return const CircularProgressIndicator();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white38, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(6, (r) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(6, (c) {
              return _buildTile(context, r, c, state.grid[r][c]);
            }),
          );
        }),
      ),
    );
  }

  Widget _buildTile(BuildContext context, int r, int c, DesertTile tile) {
    return GestureDetector(
      onTap: () => context.read<DesertGameBloc>().add(RotateTile(r, c)),
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: tile.isWatered ? Colors.blue.withValues(alpha: 0.4) : Colors.brown.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: tile.hasSandStorm ? Colors.orange : Colors.white24, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: tile.rotation * pi / 2,
              child: _getTileIcon(tile),
            ),
            if (tile.hasSandStorm)
              const Icon(Icons.waves, color: Colors.orange, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _getTileIcon(DesertTile tile) {
    final color = tile.isWatered ? Colors.blue : Colors.grey.shade300;
    switch (tile.type) {
      case DesertTileType.source:
        return const Icon(Icons.waves, color: Colors.blue, size: 35);
      case DesertTileType.sink:
        return Icon(Icons.wb_sunny, color: tile.isWatered ? Colors.green : Colors.red, size: 35);
      case DesertTileType.straight:
        return Icon(Icons.remove, color: color, size: 40);
      case DesertTileType.elbow:
        return Icon(Icons.subdirectory_arrow_right, color: color, size: 30);
      case DesertTileType.cross:
        return Icon(Icons.add, color: color, size: 40);
      default:
        return const SizedBox.shrink();
    }
  }

  void _showWinDialog(BuildContext context, DesertGameState state, String playerId) {
     showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CandyDialog(
        title: 'WELL DONE!',
        content: Column(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
            const SizedBox(height: 20),
            const Text(
              "OASIS RESTORED!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.candyPurple),
            ),
            const SizedBox(height: 10),
            Text(
              "You completed Level ${state.levelNumber}!",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          CandyButton(
            width: 200,
            height: 60,
            color: AppColors.candyGreen,
            darkColor: AppColors.candyGreenDark,
            onPressed: () {
              Navigator.pop(ctx);
              _navigateBackAndComplete(context, state);
            },
            child: const Text("CONTINUE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void _navigateBackAndComplete(BuildContext context, DesertGameState state) {
    final authState = context.read<AuthBloc>().state;
    final String? pId = authState is AuthAuthenticated ? authState.user.id : null;

    context.read<HomeBloc>().add(CompleteLevel(
      mode: state.mode, 
      level: state.levelNumber + 10, 
      playerId: pId,
    ));
    Navigator.pop(context);
  }

  void _showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CandyDialog(
        title: 'GAME OVER',
        content: const Column(
          children: [
            Icon(Icons.sentiment_very_dissatisfied, color: Colors.redAccent, size: 80),
            SizedBox(height: 20),
            Text(
              "THE OASIS DRIED UP...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.candyPurple),
            ),
          ],
        ),
        actions: [
          CandyButton(
            width: 150,
            height: 50,
            color: Colors.redAccent,
            darkColor: Colors.red.shade900,
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("EXIT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showQuitConfirmationDialog(BuildContext context, String playerId) async {
    context.read<DesertGameBloc>().add(PauseDesertTimer());
    final currentLives = context.read<HomeBloc>().state.lives;
    
    await showDialog(
      context: context,
      builder: (dialogContext) => CandyDialog(
        title: 'QUIT?',
        content: Column(
          children: [
            BreakingHeartAnimation(
              initialLives: currentLives,
              onAnimationComplete: () {},
            ),
            const SizedBox(height: 20),
            const Text(
              "ARE YOU SURE YOU WANT TO QUIT?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.candyPurple),
            ),
            if (widget.mode == FixItGameMode.story) ...[
              const SizedBox(height: 8),
              const Text(
                "YOU WILL LOSE A LIFE!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CandyButton(
                  width: 120,
                  height: 55,
                  color: AppColors.candyGreen,
                  darkColor: AppColors.candyGreenDark,
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('STAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                CandyButton(
                  width: 120,
                  height: 55,
                  color: AppColors.candyPink,
                  darkColor: AppColors.candyPinkDark,
                  onPressed: () {
                    if (widget.mode == FixItGameMode.story) {
                      context.read<HomeBloc>().add(LoseLife(playerId: playerId));
                    }
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  child: const Text('QUIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (context.mounted) {
      context.read<DesertGameBloc>().add(ResumeDesertTimer());
    }
  }
}
