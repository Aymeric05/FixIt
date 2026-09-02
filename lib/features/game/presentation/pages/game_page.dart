import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/game_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/game_event.dart';
import 'package:fixit/features/game/presentation/bloc/game_state.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_state.dart';
import 'package:fixit/features/home/presentation/widgets/settings_dialog.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';
import 'package:fixit/core/repositories/progression_repository.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:confetti/confetti.dart';
import 'package:fixit/core/widgets/tutorial_dialog.dart';
import 'package:fixit/core/widgets/breaking_heart_animation.dart';

class GamePage extends StatefulWidget {
  final int level;
  final GameDifficulty difficulty;
  final int invPlusTime;
  final int invMoreNumbers;
  final int invRevealPath;

  const GamePage({
    super.key,
    required this.level,
    required this.difficulty,
    this.invPlusTime = 5,
    this.invMoreNumbers = 5,
    this.invRevealPath = 5,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
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
    final playerId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocProvider(
      create: (context) => GameBloc()
        ..add(StartGame(
          level: widget.level,
          difficulty: widget.difficulty,
          playerId: playerId,
          invPlusTime: widget.invPlusTime,
          invMoreNumbers: widget.invMoreNumbers,
          invRevealPath: widget.invRevealPath,
        )),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          final currentLives = context.read<HomeBloc>().state.lives;
          final authStateInner = context.read<AuthBloc>().state;
          final playerIdInner = authStateInner is AuthAuthenticated ? authStateInner.user.id : null;
          _showQuitConfirmationDialog(context, currentLives, playerIdInner);
        },
        child: Scaffold(
          body: BlocListener<GameBloc, GameState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) async {
              if (state.status == GameStatus.playing && widget.level == 1) {
                TutorialDialog.showIfFirstTime(
                  context,
                  tutorialKey: 'snake_tutorial_seen',
                );
              }

              if (state.status == GameStatus.lost) {
                final authStateInner = context.read<AuthBloc>().state;
                final playerIdInner = authStateInner is AuthAuthenticated ? authStateInner.user.id : null;
                final currentLives = context.read<HomeBloc>().state.lives;
                _showGameOverDialog(context, currentLives, playerIdInner);
              } else if (state.status == GameStatus.won) {
                final authStateInner = context.read<AuthBloc>().state;
                String? currentUserId;
                if (authStateInner is AuthAuthenticated) {
                  currentUserId = authStateInner.user.id;
                  final repo = ProgressionRepository();
                  try {
                    await repo.markLevelAsCompleted(
                      playerSupabaseId: currentUserId,
                      worldId: 'world_1',
                      levelNumber: widget.level,
                      timeSeconds: state.initialSeconds - state.remainingSeconds,
                    );
                  } catch (e) {
                    debugPrint('Error saving completion: $e');
                  }
                }
                if (!mounted) return;
                _confettiController.play();
                _showWinDialog(context, state, currentUserId);
              }
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'monde1_background.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 10),
                      _buildItemsRow(context),
                      const Spacer(),
                      _buildGridContainer(context),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final playerId = authState is AuthAuthenticated ? authState.user.id : null;

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => BlocProvider.value(
                            value: BlocProvider.of<HomeBloc>(context),
                            child: const SettingsDialog(),
                          ),
                        );
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
                        width: 180,
                        decoration: BoxDecoration(
                          color: AppColors.candyBlueDark,
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: Container(
                          height: 50,
                          width: 180,
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
                            'LEVEL ${widget.level}',
                            style: const TextStyle(
                              fontSize: 24,
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
                        final currentLives = context.read<HomeBloc>().state.lives;
                        _showQuitConfirmationDialog(context, currentLives, playerId);
                      },
                      child: const Icon(Icons.close, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
      },
    );
  }

  Widget _buildItemsRow(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
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
                icon: Icons.alarm_add,
                color: Colors.orangeAccent,
                count: state.inventoryPlusTime,
                isUsed: state.usedItems.contains('plus_time'),
                onTap: () => context.read<GameBloc>().add(UseItemPlusTime()),
              ),
              const SizedBox(width: 25),
              _buildItemButton(
                context,
                icon: Icons.plus_one,
                color: Colors.lightBlueAccent,
                count: state.inventoryMoreNumbers,
                isUsed: state.usedItems.contains('more_numbers'),
                onTap: () => context.read<GameBloc>().add(UseItemMoreNumbers()),
              ),
              const SizedBox(width: 25),
              _buildItemButton(
                context,
                icon: Icons.flare,
                color: Colors.amber,
                count: state.inventoryRevealPath,
                isUsed: state.usedItems.contains('reveal_path'),
                onTap: () => context.read<GameBloc>().add(UseItemRevealPath()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required int count,
    required bool isUsed,
    required VoidCallback onTap,
  }) {
    final bool canUse = count > 0 && !isUsed;

    return GestureDetector(
      onTap: canUse ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ColorFiltered(
            colorFilter: isUsed
                ? const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0, 0, 0, 1, 0,
                  ])
                : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withValues(alpha: 0.8), color],
                  center: const Alignment(-0.3, -0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
          // Inventory Badge
          Positioned(
            right: -8,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.candyPurple,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              constraints: const BoxConstraints(minWidth: 22),
              child: Text(
                "$count",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          if (isUsed)
            const Positioned(
              top: -5,
              left: -5,
              child: Icon(Icons.block, color: Colors.redAccent, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildGridContainer(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state.hints.isEmpty) return const SizedBox.shrink();

        return AspectRatio(
          aspectRatio: 1,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Transform.scale(
                  scale: 1.08,
                  child: Image.asset(
                    'jeu_serpent_contour_pas_ouf.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cellSize = constraints.maxWidth / 6;

                    return GestureDetector(
                      onPanStart: (details) => _handleDrag(context, details.localPosition, cellSize),
                      onPanUpdate: (details) => _handleDrag(context, details.localPosition, cellSize),
                      child: Container(
                        width: constraints.maxWidth,
                        height: constraints.maxWidth,
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            _buildGridLines(state, cellSize),
                            ..._buildWalls(state, cellSize),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                              ),
                              itemCount: 36,
                              itemBuilder: (context, index) {
                                final row = index ~/ 6;
                                final col = index % 6;
                                final pos = GridOffset(row, col);
                                final value = state.hints[row][col];
                                final isHighlighted = state.highlightedCells.contains(pos);

                                return Container(
                                  alignment: Alignment.center,
                                  decoration: isHighlighted
                                      ? BoxDecoration(
                                          color: Colors.yellow.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(10),
                                        )
                                      : null,
                                  child: value != null
                                      ? Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Text(
                                              '$value',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900,
                                                foreground: Paint()
                                                  ..style = PaintingStyle.stroke
                                                  ..strokeWidth = 3
                                                  ..color = Colors.white,
                                              ),
                                            ),
                                            Text(
                                              '$value',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900,
                                                color: value == 1 ? Colors.red.shade700 : const Color(0xFF3E2723),
                                              ),
                                            ),
                                          ],
                                        )
                                      : null,
                                );
                              },
                            ),
                            _buildSerpentHead(state, cellSize),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildWalls(GameState state, double cellSize) {
    final List<Widget> wallWidgets = [];
    final thickness = cellSize * 0.75;
    final length = cellSize * 1.2;
    final offset = (length - cellSize) / 2;

    for (var wall in state.walls) {
      final parts = wall.split('-');
      final a = parts[0].split(',');
      final b = parts[1].split(',');
      final r1 = int.parse(a[0]);
      final c1 = int.parse(a[1]);
      final r2 = int.parse(b[0]);
      final c2 = int.parse(b[1]);

      if (r1 == r2) {
        final x = max(c1, c2) * cellSize;
        wallWidgets.add(
          Positioned(
            left: x - thickness / 2,
            top: r1 * cellSize - offset,
            width: thickness,
            height: length,
            child: RotatedBox(
              quarterTurns: 1,
              child: Image.asset(
                'buisson.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        );
      } else {
        final y = max(r1, r2) * cellSize;
        wallWidgets.add(
          Positioned(
            left: c1 * cellSize - offset,
            top: y - thickness / 2,
            width: length,
            height: thickness,
            child: Image.asset(
              'buisson.png',
              fit: BoxFit.fill,
            ),
          ),
        );
      }
    }
    return wallWidgets;
  }

  Widget _buildSerpentHead(GameState state, double cellSize) {
    if (state.currentPath.isEmpty) return const SizedBox.shrink();

    final headPos = state.currentPath.last;
    return Positioned(
      left: headPos.col * cellSize,
      top: headPos.row * cellSize,
      width: cellSize,
      height: cellSize,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _HeadPainter(isAngry: state.isAngry, cellSize: cellSize),
        ),
      ),
    );
  }

  void _handleDrag(BuildContext context, Offset localPos, double cellSize) {
    final row = (localPos.dy / cellSize).floor();
    final col = (localPos.dx / cellSize).floor();

    if (row >= 0 && row < 6 && col >= 0 && col < 6) {
      context.read<GameBloc>().add(SelectCell(row, col));
    }
  }

  Widget _buildGridLines(GameState state, double cellSize) {
    return IgnorePointer(
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: PathLinePainter(
            path: state.currentPath,
            cellSize: cellSize,
            color: state.pathColor,
            isAngry: state.isAngry,
          ),
        ),
      ),
    );
  }

  void _showQuitConfirmationDialog(BuildContext context, int currentLives, String? playerId) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.candyPurple,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "YOU WILL LOSE A LIFE!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CandyButton(
                  width: 130,
                  height: 60,
                  color: AppColors.candyGreen,
                  darkColor: AppColors.candyGreenDark,
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'STAY',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
                CandyButton(
                  width: 130,
                  height: 60,
                  color: AppColors.candyPink,
                  darkColor: AppColors.candyPinkDark,
                  onPressed: () {
                    context.read<HomeBloc>().add(LoseLife(playerId: playerId));
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'QUIT',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, int currentLives, String? playerId) {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => CandyDialog(
          title: 'GAME OVER',
          content: Column(
            children: [
              BreakingHeartAnimation(
                initialLives: currentLives,
                onAnimationComplete: () {},
              ),
              const SizedBox(height: 20),
              const Text(
                "IT'S SO SAD... YOU DIDN'T SUCCEED!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.candyPurple,
                ),
              ),
              const SizedBox(height: 30),
              CandyButton(
                width: 240,
                height: 60,
                color: AppColors.candyBlue,
                darkColor: AppColors.candyBlueDark,
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<GameBloc>().add(ContinueGameWithVideo());
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'CONTINUE (+3 MIN)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CandyButton(
                width: 240,
                height: 60,
                color: AppColors.candyPink,
                darkColor: AppColors.candyPinkDark,
                onPressed: () {
                  context.read<HomeBloc>().add(LoseLife(playerId: playerId));
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: const Text(
                  'RETURN HOME',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showWinDialog(BuildContext context, GameState state, String? playerId) {
    final timeTaken = state.initialSeconds - state.remainingSeconds;
    final timeStr = "${(timeTaken / 60).floor()}:${(timeTaken % 60).toString().padLeft(2, '0')}";

    final String averageTimeStr = state.averageTimeSeconds > 0
        ? "${(state.averageTimeSeconds / 60).floor()}:${(state.averageTimeSeconds % 60).toString().padLeft(2, '0')}"
        : "--:--";

    final String bestTimeStr = (state.bestTimeSeconds > 0 && state.bestTimeSeconds < 999999)
        ? "${(state.bestTimeSeconds / 60).floor()}:${(state.bestTimeSeconds % 60).toString().padLeft(2, '0')}"
        : "--:--";

    final isNewRecord = (state.bestTimeSeconds == 0 || state.bestTimeSeconds >= 999999) || (timeTaken <= state.bestTimeSeconds);
    final isFasterThanAverage = (state.averageTimeSeconds > 0) && (timeTaken < state.averageTimeSeconds);

    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Stack(
          alignment: Alignment.center,
          children: [
            CandyDialog(
              title: 'VICTORY!',
              onClose: () {
                context.read<HomeBloc>().add(CompleteLevel(playerId: playerId));
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              content: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "YOUR TIME",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.candyGreenDark),
                        ),
                        Text(
                          timeStr,
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.candyGreenDark),
                        ),
                        const Divider(color: Colors.white, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Average Time:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text(averageTimeStr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Best Time:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text(bestTimeStr, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blue, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (isNewRecord)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                            child: const Text("NEW WORLD RECORD!", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12)),
                          )
                        else if (isFasterThanAverage)
                          const Text(
                            "You are faster than average!",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.candyGreenDark),
                          )
                        else if (state.averageTimeSeconds > 0)
                          Text(
                            "Average is ${timeTaken - state.averageTimeSeconds}s faster than you",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "GREAT JOB! YOU SOLVED THE PUZZLE!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.candyGreenDark,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CandyButton(
                        width: 140,
                        height: 60,
                        color: AppColors.candyPink,
                        darkColor: AppColors.candyPinkDark,
                        onPressed: () {
                          context.read<HomeBloc>().add(CompleteLevel(playerId: playerId));
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'HOME',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                      CandyButton(
                        width: 140,
                        height: 60,
                        color: AppColors.candyGreen,
                        darkColor: AppColors.candyGreenDark,
                        onPressed: () async {
                          context.read<HomeBloc>().add(CompleteLevel(playerId: playerId));

                          Navigator.pop(dialogContext);
                          final nextLevel = widget.level + 1;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GamePage(
                                level: nextLevel,
                                difficulty: widget.difficulty,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'NEXT LEVEL',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                createParticlePath: drawFireworkSparkle,
                colors: const [
                  Colors.yellow,
                  Colors.white,
                  Colors.amber,
                  Colors.orangeAccent,
                ],
                numberOfParticles: 8,
                gravity: 0.1,
                minBlastForce: 15,
                maxBlastForce: 30,
                blastDirection: 3.14 * 1.5,
              ),
            ),
            Positioned(
              left: 30,
              top: 150,
              child: IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  createParticlePath: drawFireworkSparkle,
                  numberOfParticles: 5,
                  gravity: 0.1,
                  minBlastForce: 10,
                  maxBlastForce: 25,
                  colors: const [Colors.lightBlueAccent, Colors.white],
                ),
              ),
            ),
            Positioned(
              right: 30,
              top: 150,
              child: IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  createParticlePath: drawFireworkSparkle,
                  numberOfParticles: 5,
                  gravity: 0.1,
                  minBlastForce: 10,
                  maxBlastForce: 25,
                  colors: const [Colors.pinkAccent, Colors.white],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _HeadPainter extends CustomPainter {
  final bool isAngry;
  final double cellSize;

  _HeadPainter({required this.isAngry, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    _paintHead(canvas, size, isAngry, cellSize);
  }

  @override
  bool shouldRepaint(covariant _HeadPainter oldDelegate) => oldDelegate.isAngry != isAngry || oldDelegate.cellSize != cellSize;
}

void _paintHead(Canvas canvas, Size size, bool isAngry, double cellSize) {
  final center = Offset(size.width / 2, size.height / 2);
  final eyePaint = Paint()..color = Colors.white;
  final pupilPaint = Paint()..color = Colors.black;
  final eyeSize = cellSize * 0.15;

  canvas.drawCircle(center + Offset(-eyeSize, -eyeSize / 2), eyeSize, eyePaint);
  canvas.drawCircle(center + Offset(eyeSize, -eyeSize / 2), eyeSize, eyePaint);
  canvas.drawCircle(center + Offset(-eyeSize, -eyeSize / 2), eyeSize / 2, pupilPaint);
  canvas.drawCircle(center + Offset(eyeSize, -eyeSize / 2), eyeSize / 2, pupilPaint);

  if (isAngry) {
    final angryPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center + Offset(-eyeSize * 2, -eyeSize * 2), center + Offset(-eyeSize * 0.5, -eyeSize), angryPaint);
    canvas.drawLine(center + Offset(eyeSize * 2, -eyeSize * 2), center + Offset(eyeSize * 0.5, -eyeSize), angryPaint);
    final mouthPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final mouthPath = Path();
    mouthPath.moveTo(center.dx - eyeSize, center.dy + eyeSize);
    mouthPath.quadraticBezierTo(center.dx, center.dy, center.dx + eyeSize, center.dy + eyeSize);
    canvas.drawPath(mouthPath, mouthPaint);
  } else {
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final mouthPath = Path();
    mouthPath.moveTo(center.dx - eyeSize, center.dy + eyeSize);
    mouthPath.quadraticBezierTo(center.dx, center.dy + eyeSize * 2, center.dx + eyeSize, center.dy + eyeSize);
    canvas.drawPath(mouthPath, mouthPaint);
  }
}

class PathLinePainter extends CustomPainter {
  final List<GridOffset> path;
  final double cellSize;
  final Color color;
  final bool isAngry;

  PathLinePainter({required this.path, required this.cellSize, required this.color, required this.isAngry});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 1.0)
      ..strokeWidth = cellSize * 0.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = cellSize * 0.75
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final uiPath = Path();
    final startOffset = Offset((path[0].col * cellSize) + (cellSize / 2), (path[0].row * cellSize) + (cellSize / 2));
    uiPath.moveTo(startOffset.dx, startOffset.dy);
    for (int i = 1; i < path.length; i++) {
      final pos = path[i];
      final nextOffset = Offset((pos.col * cellSize) + (cellSize / 2), (pos.row * cellSize) + (cellSize / 2));
      uiPath.lineTo(nextOffset.dx, nextOffset.dy);
    }
    canvas.drawPath(uiPath, shadowPaint);
    canvas.drawPath(uiPath, paint);
  }

  @override
  bool shouldRepaint(covariant PathLinePainter oldDelegate) => oldDelegate.path != path || oldDelegate.cellSize != cellSize || oldDelegate.color != color || oldDelegate.isAngry != isAngry;
}

class _WallPainter extends CustomPainter {
  final Set<String> walls;
  final double cellSize;

  _WallPainter({required this.walls, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (var wall in walls) {
      final parts = wall.split('-');
      final a = parts[0].split(',');
      final b = parts[1].split(',');
      final r1 = int.parse(a[0]);
      final c1 = int.parse(a[1]);
      final r2 = int.parse(b[0]);
      final c2 = int.parse(b[1]);

      if (r1 == r2) {
        final x = max(c1, c2) * cellSize;
        canvas.drawLine(
          Offset(x, r1 * cellSize),
          Offset(x, (r1 + 1) * cellSize),
          paint,
        );
      } else {
        final y = max(r1, r2) * cellSize;
        canvas.drawLine(
          Offset(c1 * cellSize, y),
          Offset((c1 + 1) * cellSize, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WallPainter oldDelegate) => oldDelegate.walls != walls;
}

Path drawFireworkSparkle(Size size) {
  final path = Path();
  final double halfWidth = size.width / 2;
  final double halfHeight = size.height / 2;
  path.moveTo(halfWidth, 0);
  path.lineTo(halfWidth + size.width * 0.05, halfHeight - size.height * 0.05);
  path.lineTo(size.width, halfHeight);
  path.lineTo(halfWidth + size.width * 0.05, halfHeight + size.height * 0.05);
  path.lineTo(halfWidth, size.height);
  path.lineTo(halfWidth - size.width * 0.05, halfHeight + size.height * 0.05);
  path.lineTo(0, halfHeight);
  path.lineTo(halfWidth - size.width * 0.05, halfHeight - size.height * 0.05);
  path.close();
  return path;
}
