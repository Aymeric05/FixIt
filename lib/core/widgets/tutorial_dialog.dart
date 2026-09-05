import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/features/game/presentation/pages/game_page.dart';
import 'package:fixit/features/game/presentation/bloc/game_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/game_event.dart';

class TutorialDialog extends StatefulWidget {
  final String tutorialKey;

  const TutorialDialog({
    super.key,
    required this.tutorialKey,
  });

  static Future<void> showIfFirstTime(
    BuildContext context, {
    required String tutorialKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(tutorialKey) ?? false;

    if (!hasSeen && context.mounted) {
      context.read<GameBloc>().add(PauseTimer());

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => TutorialDialog(
          tutorialKey: tutorialKey,
        ),
      );
      
      await prefs.setBool(tutorialKey, true);
      
      if (context.mounted) {
        context.read<GameBloc>().add(ResumeTimer());
      }
    }
  }

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> with SingleTickerProviderStateMixin {
  int _currentStep = 1; // 1: Error Demo, 2: Success Demo
  int _animSubStep = 0;
  Timer? _timer;
  late AnimationController _flashController;
  
  // Paths for tutorial
  final List<GridOffset> _fullPath = [
    GridOffset(0, 0), GridOffset(0, 1), GridOffset(0, 2),
    GridOffset(1, 2), GridOffset(1, 1), GridOffset(1, 0),
    GridOffset(2, 0), GridOffset(2, 1), GridOffset(2, 2),
  ];

  // Path for error demo: reaches 3 but misses (1,1) and (2,1) etc.
  // Actually let's just make it jump to numbers but skip intermediate cells
  final List<GridOffset> _errorPath = [
    GridOffset(0, 0), // 1
    GridOffset(0, 1),
    GridOffset(0, 2),
    GridOffset(1, 2),
    GridOffset(1, 1), // 2
    GridOffset(2, 1),
    GridOffset(2, 2), // 3
  ];

  final List<List<int?>> _hints = [
    [1, null, null],
    [null, 2, null],
    [null, null, 3],
  ];

  List<GridOffset> _currentDrawingPath = [];
  bool _showRedAlert = false;
  bool _showYellowSuccess = false;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
    _startAnimation();
  }

  void _startAnimation() {
    _timer?.cancel();
    _animSubStep = 0;
    _currentDrawingPath = [];
    _showRedAlert = false;
    _showYellowSuccess = false;

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentStep == 1) {
          _handleStep1();
        } else {
          _handleStep2();
        }
      });
    });
  }



  void _handleStep1() {
    if (_animSubStep < _errorPath.length) {
      _currentDrawingPath.add(_errorPath[_animSubStep]);
      _animSubStep++;
    } else {
      _showRedAlert = true;
      _timer?.cancel();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _currentStep = 2;
            _startAnimation();
          });
        }
      });
    }
  }

  void _handleStep2() {
    if (_animSubStep < _fullPath.length) {
      _currentDrawingPath.add(_fullPath[_animSubStep]);
      _animSubStep++;
    } else {
      _showYellowSuccess = true;
      _timer?.cancel();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _currentStep = 1;
            _startAnimation();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String titleText;
    String description;
    Color pathColor;
    String badgeText;
    Color badgeColor;

    if (_currentStep == 1) {
      titleText = "DON'T MISS ANY!";
      description = "Skipping cells causes failure!";
      pathColor = Colors.red;
      badgeText = "WRONG";
      badgeColor = Colors.red;
    } else {
      titleText = "FILL EVERYTHING!";
      description = "Complete the grid to win!";
      pathColor = AppColors.candyGreen;
      badgeText = "CORRECT";
      badgeColor = AppColors.candyGreen;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 320,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.dialogBackground,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.candyBlue, width: 8),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 200,
                  width: 200,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _showYellowSuccess ? Colors.yellow.withValues(alpha: 0.3) : Colors.white24,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: _showRedAlert ? Colors.red : Colors.white, 
                      width: 4
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellSize = constraints.maxWidth / 3;
                      return AnimatedBuilder(
                        animation: _flashController,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                itemCount: 9,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final r = index ~/ 3;
                                  final c = index % 3;
                                  final pos = GridOffset(r, c);
                                  final val = _hints[r][c];
                                  
                                  final isVisited = _currentDrawingPath.contains(pos);
                                  Color cellColor = Colors.transparent;
                                  if (_showYellowSuccess) {
                                    cellColor = Colors.yellow.withValues(alpha: 0.6);
                                  } else if (_showRedAlert && !isVisited) {
                                    cellColor = Colors.red.withValues(alpha: _flashController.value * 0.6);
                                  }

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: cellColor,
                                      border: Border.all(color: Colors.white10, width: 0.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: val == null ? null : Text(
                                      '$val',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                                    ),
                                  );
                                },
                              ),
                              CustomPaint(
                                size: Size(constraints.maxWidth, constraints.maxWidth),
                                painter: PathLinePainter(
                                  path: _currentDrawingPath,
                                  cellSize: cellSize,
                                  color: pathColor,
                                  isAngry: _showRedAlert,
                                ),
                              ),
                              if (_currentDrawingPath.isNotEmpty)
                                Positioned(
                                  left: _currentDrawingPath.last.col * cellSize,
                                  top: _currentDrawingPath.last.row * cellSize,
                                  width: cellSize,
                                  height: cellSize,
                                  child: CustomPaint(
                                    painter: HeadPainter(isAngry: _showRedAlert, cellSize: cellSize),
                                  ),
                                ),
                              // BAD/GOOD Badge overlay
                              Center(
                                child: Transform.rotate(
                                  angle: -0.2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Text(
                                      badgeText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 24,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                CandyButton(
                  width: 200,
                  height: 60,
                  color: AppColors.candyGreen,
                  darkColor: AppColors.candyGreenDark,
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'START PLAYING',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildTitleBanner(titleText),
        ],
      ),
    );
  }

  Widget _buildTitleBanner(String text) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 55,
          width: 220,
          decoration: BoxDecoration(
            color: AppColors.candyBlueDark,
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -5),
          child: Container(
            height: 50,
            width: 220,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [AppColors.candyBlue, AppColors.candyBlueDark],
                center: Alignment(-0.3, -0.3),
                radius: 0.8,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white, width: 3),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HeadPainter extends CustomPainter {
  final bool isAngry;
  final double cellSize;

  HeadPainter({required this.isAngry, required this.cellSize});

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

  @override
  bool shouldRepaint(covariant HeadPainter oldDelegate) => 
      oldDelegate.isAngry != isAngry || oldDelegate.cellSize != cellSize;
}
