import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/game_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/game_event.dart';
import 'package:fixit/features/game/presentation/bloc/game_state.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_bloc.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_event.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/theme/app_colors.dart';

class GamePage extends StatelessWidget {
  final int level;
  final GameDifficulty difficulty;

  const GamePage({super.key, required this.level, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(StartGame(level: level, difficulty: difficulty)),
      child: BlocListener<GameBloc, GameState>(
        listener: (context, state) {
          if (state.status == GameStatus.lost) {
            context.read<LivesBloc>().add(DecrementLife());
            _showGameOverDialog(context);
          } else if (state.status == GameStatus.won) {
            context.read<HomeBloc>().add(CompleteLevel());
            _showWinDialog(context);
          }
        },
        child: Scaffold(
          body: Stack(
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
                        'LEVEL $level',
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

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 15)],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = constraints.maxWidth / 6;

              return GestureDetector(
                onPanStart: (details) => _handleDrag(context, details.localPosition, cellSize),
                onPanUpdate: (details) => _handleDrag(context, details.localPosition, cellSize),
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                      image: AssetImage('jeu_serpent_contour_pas_ouf.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: [
                      _buildGridLines(state, cellSize),
                      CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxWidth),
                        painter: _BushWallPainter(walls: state.walls, cellSize: cellSize),
                      ),
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
        );
      },
    );
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _GameOverDialog(),
    );
  }

  void _showWinDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.green, width: 10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GREAT JOB!',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.green),
              ),
              const SizedBox(height: 16),
              const Text(
                "YOU SOLVED THE PUZZLE!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              const SizedBox(height: 32),
              const Icon(Icons.star, color: Colors.amber, size: 100),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.candyGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
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

class _BushWallPainter extends CustomPainter {
  final Set<String> walls;
  final double cellSize;

  _BushWallPainter({required this.walls, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green.shade900..style = PaintingStyle.fill;
    final random = Random(42);
    for (var wall in walls) {
      final parts = wall.split('-');
      final a = parts[0].split(',');
      final b = parts[1].split(',');
      final r1 = int.parse(a[0]);
      final c1 = int.parse(a[1]);
      final r2 = int.parse(b[0]);
      final c2 = int.parse(b[1]);
      double x, y, w, h;
      if (r1 == r2) {
        x = max(c1, c2) * cellSize - 4;
        y = r1 * cellSize;
        w = 8; h = cellSize;
      } else {
        x = c1 * cellSize;
        y = max(r1, r2) * cellSize - 4;
        w = cellSize; h = 8;
      }
      int count = 12;
      for (int i = 0; i < count; i++) {
        double px = x + (w == 8 ? (random.nextDouble() - 0.5) * 15 : (i / count) * w);
        double py = y + (h == 8 ? (random.nextDouble() - 0.5) * 15 : (i / count) * h);
        canvas.drawCircle(Offset(px, py), 6 + random.nextDouble() * 4, paint);
        if (random.nextDouble() < 0.3) canvas.drawCircle(Offset(px, py), 3, Paint()..color = Colors.green.shade400);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BushWallPainter oldDelegate) => oldDelegate.walls != walls;
}

class _GameOverDialog extends StatefulWidget {
  const _GameOverDialog();

  @override
  State<_GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<_GameOverDialog> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _showFinal = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) setState(() => _showFinal = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.candyPink, width: 10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('OH NO!', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.brown)),
            const SizedBox(height: 16),
            const Text("IT'S SO SAD... YOU DIDN'T SUCCEED!", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
            const SizedBox(height: 32),
            SizedBox(
              height: 140,
              width: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_showFinal)
                    ScaleTransition(
                      scale: TweenSequence([
                        TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 30),
                        TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 20),
                        TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 50),
                      ]).animate(_controller),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.favorite, color: Colors.red, size: 120),
                          const Text('5', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              if (_controller.value > 0.5) return const Icon(Icons.heart_broken, color: Colors.black38, size: 130);
                              return const SizedBox();
                            },
                          ),
                        ],
                      ),
                    ),
                  if (_showFinal)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.favorite, color: Colors.red, size: 100),
                              const Text('4', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.candyGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('RETURN HOME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
