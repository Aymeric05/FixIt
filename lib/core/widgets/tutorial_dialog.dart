import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'candy_button.dart';
import '../theme/app_colors.dart';
import '../../features/game/presentation/pages/game_page.dart';
import '../../features/game/presentation/bloc/game_state.dart';

class TutorialDialog extends StatefulWidget {
  final String title;
  final String description;
  final String tutorialKey;

  const TutorialDialog({
    super.key,
    required this.title,
    required this.description,
    required this.tutorialKey,
  });

  static Future<void> showIfFirstTime(
    BuildContext context, {
    required String title,
    required String description,
    required String tutorialKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(tutorialKey) ?? false;

    if (!hasSeen && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TutorialDialog(
          title: title,
          description: description,
          tutorialKey: tutorialKey,
        ),
      );
      await prefs.setBool(tutorialKey, true);
    }
  }

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  List<GridOffset> _botPath = [];
  Timer? _botTimer;
  int _currentStep = 0;

  // A simple 4x4 snake path for demonstration
  final List<GridOffset> _demoPath = [
    const GridOffset(0, 0), const GridOffset(0, 1), const GridOffset(0, 2), const GridOffset(0, 3),
    const GridOffset(1, 3), const GridOffset(1, 2), const GridOffset(1, 1), const GridOffset(1, 0),
    const GridOffset(2, 0), const GridOffset(2, 1), const GridOffset(2, 2), const GridOffset(2, 3),
    const GridOffset(3, 3), const GridOffset(3, 2), const GridOffset(3, 1), const GridOffset(3, 0),
  ];

  final List<List<int?>> _demoHints = [
    [1, null, null, null],
    [null, null, null, null],
    [null, null, null, null],
    [null, null, null, 16],
  ];

  @override
  void initState() {
    super.initState();
    _startBot();
  }

  void _startBot() {
    _botTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentStep < _demoPath.length) {
          _botPath.add(_demoPath[_currentStep]);
          _currentStep++;
        } else {
          // Pause at the end then restart
          _botTimer?.cancel();
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _botPath = [];
                _currentStep = 0;
                _startBot();
              });
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.candyBlueDark,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // Live Demo Grid
            Container(
              height: 220,
              width: 220,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellSize = constraints.maxWidth / 4;
                  return Stack(
                    children: [
                      // Numbers
                      GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                        itemCount: 16,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final r = index ~/ 4;
                          final c = index % 4;
                          final val = _demoHints[r][c];
                          if (val == null) return const SizedBox.shrink();
                          return Center(
                            child: Text(
                              '$val',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          );
                        },
                      ),
                      // Path
                      CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxWidth),
                        painter: PathLinePainter(
                          path: _botPath,
                          cellSize: cellSize,
                          color: AppColors.candyGreen,
                          isAngry: false,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.description,
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
    );
  }
}
