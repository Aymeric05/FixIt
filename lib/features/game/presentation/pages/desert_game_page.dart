import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/desert_game_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/desert_game_event.dart';
import 'package:fixit/features/game/presentation/bloc/desert_game_state.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';
import 'package:fixit/core/models/daily_mode.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_state.dart';
import 'package:fixit/features/home/presentation/widgets/settings_dialog.dart';
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
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          
          // Context is local to build, but we need BlocProvider.of to get state
          // Actually, we'll use a Builder or a key to handle this if needed, 
          // but for Desert we can just show confirmation.
          _showQuitConfirmationDialog(context, playerId);
        },
        child: Scaffold(
          body: BlocConsumer<DesertGameBloc, DesertGameState>(
            listener: (context, state) {
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
                        _buildHeader(context, state),
                        const SizedBox(height: 10),
                        _buildItemsRow(context, state),
                        const Spacer(),
                        _buildGridContainer(context, state),
                        const Spacer(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.yellow],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DesertGameState state) {
    final minutes = (state.remainingSeconds / 60).floor();
    final seconds = (state.remainingSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Settings Button
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: CandyButton(
                  width: 52,
                  height: 52,
                  borderRadius: 12,
                  depth: 4,
                  color: Colors.grey,
                  darkColor: Colors.grey.shade700,
                  onPressed: () async {
                    context.read<DesertGameBloc>().add(PauseDesertTimer());
                    await showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: BlocProvider.of<HomeBloc>(context),
                        child: const SettingsDialog(),
                      ),
                    );
                    if (context.mounted) {
                      context.read<DesertGameBloc>().add(ResumeDesertTimer());
                    }
                  },
                  child: const Icon(Icons.settings, color: Colors.white, size: 28),
                ),
              ),

              // Level Banner
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 55,
                    width: 220,
                    decoration: BoxDecoration(
                      color: AppColors.candyBlueDark,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -4),
                    child: Container(
                      height: 50,
                      width: 220,
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [AppColors.candyBlue, AppColors.candyBlueDark],
                          center: Alignment(-0.3, -0.3),
                          radius: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.mode == FixItGameMode.dailySeries 
                            ? 'SERIES ${widget.level}/3' 
                            : widget.mode == FixItGameMode.dailySingle 
                                ? 'DAILY OASIS' 
                                : 'LEVEL ${widget.level}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Close Button
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: CandyButton(
                  width: 52,
                  height: 52,
                  borderRadius: 26,
                  depth: 4,
                  color: Colors.redAccent,
                  darkColor: Colors.red.shade900,
                  onPressed: () {
                    if (state.status == DesertGameStatus.won) {
                      _navigateBackAndComplete(context, state);
                    } else {
                      _showQuitConfirmationDialog(context, context.read<AuthBloc>().state is AuthAuthenticated ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id : '');
                    }
                  },
                  child: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Timer Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsRow(BuildContext context, DesertGameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildItemButton(
            context,
            icon: Icons.opacity,
            color: Colors.blueAccent,
            count: state.invWaterBucket,
            onTap: () => context.read<DesertGameBloc>().add(UseWaterBucket()),
          ),
          const SizedBox(width: 25),
          _buildItemButton(
            context,
            icon: Icons.build,
            color: Colors.amber,
            count: state.invGoldenWrench,
            onTap: () => context.read<DesertGameBloc>().add(UseGoldenWrench()),
          ),
          const SizedBox(width: 25),
          _buildItemButton(
            context,
            icon: Icons.handyman,
            color: Colors.orangeAccent,
            count: state.invSandShovel,
            onTap: () => context.read<DesertGameBloc>().add(UseSandShovel()),
          ),
        ],
      ),
    );
  }

  Widget _buildItemButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: count > 0 ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: count > 0 ? 1.0 : 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          Positioned(
            right: -5,
            bottom: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.candyPurple, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
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
    await showDialog(
      context: context,
      builder: (dialogContext) => CandyDialog(
        title: 'QUIT?',
        content: Column(
          children: [
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
