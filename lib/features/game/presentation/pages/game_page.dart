import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/game_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/game_event.dart';
import 'package:fixit/features/game/presentation/bloc/game_state.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_bloc.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_event.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/theme/app_colors.dart';

import 'package:fixit/core/theme/app_colors.dart';
import 'package:confetti/confetti.dart';
import 'package:fixit/core/widgets/tutorial_dialog.dart';

class GamePage extends StatefulWidget {
  final int level;
  final GameDifficulty difficulty;

  const GamePage({super.key, required this.level, required this.difficulty});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Show tutorial if it's the first time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialDialog.showIfFirstTime(
        context,
        title: 'HOW TO PLAY',
        description: 'Connect all numbers in order (1, 2, 3...) to fill the entire grid!',
        tutorialKey: 'snake_tutorial_seen',
      );
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(StartGame(level: widget.level, difficulty: widget.difficulty)),
      child: Scaffold(
        body: BlocListener<GameBloc, GameState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == GameStatus.lost) {
              context.read<LivesBloc>().add(DecrementLife());
              _showGameOverDialog(context);
            } else if (state.status == GameStatus.won) {
              _confettiController.play();
              _showWinDialog(context, state);
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
                    const Spacer(),
                    _buildGridContainer(context),
                    const Spacer(),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Help Button (Lightbulb)
              Positioned(
                top: 20,
                right: 20,
                child: CandyButton(
                  width: 60,
                  height: 60,
                  borderRadius: 30,
                  color: AppColors.candyYellow,
                  darkColor: AppColors.candyYellowDark,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Follow the numbers in order!'),
                        backgroundColor: AppColors.candyBlue,
                      ),
                    );
                  },
                  child: const Icon(Icons.lightbulb, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final minutes = (state.remainingSeconds / 60).floor();
        final seconds = (state.remainingSeconds % 60).toString().padLeft(2, '0');

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              // 3D Style Title (exactly like WORLD MAP)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 240,
                    decoration: BoxDecoration(
                      color: AppColors.candyBlueDark,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -5),
                    child: Container(
                      height: 55,
                      width: 240,
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [AppColors.candyBlue, AppColors.candyBlueDark],
                          center: Alignment(-0.3, -0.3),
                          radius: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'LEVEL ${widget.level}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '$minutes:$seconds',
                      style: const TextStyle(
                        fontSize: 28,
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

  Widget _buildGridContainer(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state.hints.isEmpty) return const SizedBox.shrink();

        return AspectRatio(
          aspectRatio: 1,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // The frame image - enlarged to touch screen edges
              Positioned.fill(
                child: Transform.scale(
                  scale: 1.08,
                  child: Image.asset(
                    'jeu_serpent_contour_pas_ouf.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              // The Grid itself - slightly inset so it doesn't overlap the lianes
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
                                final value = state.hints[row][col];
                                return Container(
                                  alignment: Alignment.center,
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
    final thickness = cellSize * 0.75; // Much thicker
    final length = cellSize * 1.2; // Slightly longer to overlap and look continuous
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
        // Vertical wall between columns
        final x = max(c1, c2) * cellSize;
        wallWidgets.add(
          Positioned(
            left: x - thickness / 2,
            top: r1 * cellSize - offset,
            width: thickness,
            height: length,
            child: RotatedBox(
              quarterTurns: 1, // 90 degrees rotation
              child: Image.asset(
                'buisson.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        );
      } else {
        // Horizontal wall between rows
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

  void _showGameOverDialog(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => CandyDialog(
          title: 'GAME OVER',
          content: Column(
            children: [
              const Icon(Icons.heart_broken, color: Colors.red, size: 80),
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
                width: 200,
                height: 60,
                color: AppColors.candyPink,
                darkColor: AppColors.candyPinkDark,
                onPressed: () {
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

  void _showWinDialog(BuildContext context, GameState state) {
    final timeTaken = state.initialSeconds - state.remainingSeconds;
    final timeStr = "${(timeTaken / 60).floor()}:${(timeTaken % 60).toString().padLeft(2, '0')}";
    
    // Mock statistics data
    const averageTimeSeconds = 65; 
    const averageTimeStr = "1:05";
    const bestTimeSeconds = 42; 
    const bestTimeStr = "0:42";
    
    final isNewRecord = timeTaken < bestTimeSeconds;
    final isFasterThanAverage = timeTaken < averageTimeSeconds;

    Future.delayed(Duration.zero, () {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Stack(
          alignment: Alignment.center,
          children: [
            CandyDialog(
              title: 'VICTORY!',
              onClose: () {
                context.read<HomeBloc>().add(CompleteLevel());
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              content: Column(
                children: [
                  // Replacing the star with stats
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
                            const Text("Average Time:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(averageTimeStr, style: const TextStyle(fontWeight: FontWeight.w900)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Best Time:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(bestTimeStr, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blue)),
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
                        else
                          Text(
                            "Average is ${timeTaken - averageTimeSeconds}s faster than you",
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
                          context.read<HomeBloc>().add(CompleteLevel());
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
                        onPressed: () {
                          context.read<HomeBloc>().add(CompleteLevel());
                          Navigator.pop(dialogContext);
                          // We push a new game page for the next level
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
            // Main Firework Burst (Center)
            IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                createParticlePath: drawFireworkSparkle, // Sparkle shape
                colors: const [
                  Colors.yellow,
                  Colors.white,
                  Colors.amber,
                  Colors.orangeAccent,
                ],
                numberOfParticles: 8, // Very few particles
                gravity: 0.1,
                minBlastForce: 15, // High spread
                maxBlastForce: 30,
                blastDirection: 3.14 * 1.5,
              ),
            ),
            // Spread-out burst Left
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
            // Spread-out burst Right
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
      final mouthPaint = Paint()..color = Colors.red..style = PaintingStyle.stroke..strokeWidth = 3;
      final mouthPath = Path();
      mouthPath.moveTo(center.dx - eyeSize, center.dy + eyeSize);
      mouthPath.quadraticBezierTo(center.dx, center.dy, center.dx + eyeSize, center.dy + eyeSize);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      final mouthPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
      final mouthPath = Path();
      mouthPath.moveTo(center.dx - eyeSize, center.dy + eyeSize);
      mouthPath.quadraticBezierTo(center.dx, center.dy + eyeSize * 2, center.dx + eyeSize, center.dy + eyeSize);
      canvas.drawPath(mouthPath, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeadPainter oldDelegate) => oldDelegate.isAngry != isAngry || oldDelegate.cellSize != cellSize;
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
    final paint = Paint()..color = color.withOpacity(1.0)..strokeWidth = cellSize * 0.7..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
    final shadowPaint = Paint()..color = Colors.black26..strokeWidth = cellSize * 0.75..strokeCap = StrokeCap.round..style = PaintingStyle.stroke..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
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

/// A thin sparkle path for firework sparks
Path drawFireworkSparkle(Size size) {
  final path = Path();
  final double halfWidth = size.width / 2;
  final double halfHeight = size.height / 2;
  
  // A very thin 4-pointed sparkle
  path.moveTo(halfWidth, 0); // Top
  path.lineTo(halfWidth + size.width * 0.05, halfHeight - size.height * 0.05);
  path.lineTo(size.width, halfHeight); // Right
  path.lineTo(halfWidth + size.width * 0.05, halfHeight + size.height * 0.05);
  path.lineTo(halfWidth, size.height); // Bottom
  path.lineTo(halfWidth - size.width * 0.05, halfHeight + size.height * 0.05);
  path.lineTo(0, halfHeight); // Left
  path.lineTo(halfWidth - size.width * 0.05, halfHeight - size.height * 0.05);
  path.close();
  return path;
}

