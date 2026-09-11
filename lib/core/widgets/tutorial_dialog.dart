import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/features/game/meadow/pages/meadow_game_page.dart';
import 'package:fixit/features/game/meadow/bloc/meadow_game_bloc.dart';
import 'package:fixit/features/game/meadow/bloc/meadow_game_event.dart';
import 'package:fixit/features/game/desert/bloc/desert_game_bloc.dart';
import 'package:fixit/features/game/desert/bloc/desert_game_event.dart';

class TutorialDialog extends StatefulWidget {
  final String tutorialKey;
  final int worldIndex;

  const TutorialDialog({
    super.key,
    required this.tutorialKey,
    required this.worldIndex,
  });

  static Future<void> showIfFirstTime(
    BuildContext context, {
    required String tutorialKey,
    required int worldIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(tutorialKey) ?? false;

    if (!hasSeen && context.mounted) {
      if (worldIndex == 1) {
        context.read<MeadowGameBloc>().add(PauseTimer());
      } else if (worldIndex == 2) {
        context.read<DesertGameBloc>().add(PauseDesertTimer());
      }

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => TutorialDialog(
          tutorialKey: tutorialKey,
          worldIndex: worldIndex,
        ),
      );
      
      await prefs.setBool(tutorialKey, true);
      
      if (context.mounted) {
        if (worldIndex == 1) {
          context.read<MeadowGameBloc>().add(ResumeTimer());
        } else if (worldIndex == 2) {
          context.read<DesertGameBloc>().add(ResumeDesertTimer());
        }
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
        if (widget.worldIndex == 1) {
          if (_currentStep == 1) {
            _handleMeadowStep1();
          } else {
            _handleMeadowStep2();
          }
        } else if (widget.worldIndex == 2) {
          _handleDesertStep();
        }
      });
    });
  }

  void _handleMeadowStep1() {
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

  void _handleMeadowStep2() {
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

  int _desertRotation = 0;
  void _handleDesertStep() {
    if (_animSubStep < 4) {
      _animSubStep++;
    } else {
      _animSubStep = 0;
      _desertRotation = (_desertRotation + 1) % 4;
      if (_desertRotation == 1) { // 90 deg is correct for this demo
         _showYellowSuccess = true;
         _timer?.cancel();
         Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showYellowSuccess = false;
                _desertRotation = 0;
                _startAnimation();
              });
            }
         });
      }
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

    if (widget.worldIndex == 1) {
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
    } else {
      titleText = "RESTORE THE OASIS!";
      description = "Rotate pipes to water all cacti!";
      pathColor = Colors.blue;
      badgeText = _showYellowSuccess ? "CONNECTED" : "TAP TO ROTATE";
      badgeColor = _showYellowSuccess ? AppColors.candyGreen : AppColors.candyBlue;
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
                      if (widget.worldIndex == 1) {
                        return _buildMeadowTutorial(constraints, pathColor, badgeColor, badgeText);
                      } else {
                        return _buildDesertTutorial(constraints, badgeColor, badgeText);
                      }
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

extension on _TutorialDialogState {
  Widget _buildMeadowTutorial(BoxConstraints constraints, Color pathColor, Color badgeColor, String badgeText) {
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
                  child: val == null
                      ? null
                      : Text(
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
            _buildTutorialBadge(badgeColor, badgeText),
          ],
        );
      },
    );
  }

  Widget _buildDesertTutorial(BoxConstraints constraints, Color badgeColor, String badgeText) {
    final cellSize = constraints.maxWidth / 2;
    return AnimatedBuilder(
      animation: _flashController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Source
                Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(border: Border.all(color: Colors.white10)),
                  child: const Icon(Icons.waves, color: Colors.blue, size: 50),
                ),
                // Pipe
                Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: _showYellowSuccess ? Colors.blue.withValues(alpha: 0.3) : Colors.transparent,
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Transform.rotate(
                    angle: _desertRotation * pi / 2,
                    child: Icon(Icons.remove, color: _showYellowSuccess ? Colors.blue : Colors.grey, size: 60),
                  ),
                ),
              ],
            ),
            if (!_showYellowSuccess)
              Positioned(
                right: cellSize / 4,
                top: cellSize / 2,
                child: Icon(Icons.touch_app, color: Colors.white, size: 40 + (_flashController.value * 10)),
              ),
            _buildTutorialBadge(badgeColor, badgeText),
          ],
        );
      },
    );
  }

  Widget _buildTutorialBadge(Color color, String text) {
    return Center(
      child: Transform.rotate(
        angle: -0.2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
