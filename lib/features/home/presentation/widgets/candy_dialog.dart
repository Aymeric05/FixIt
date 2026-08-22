import 'package:flutter/material.dart';
import '../../../../core/widgets/candy_button.dart';
import '../../../../core/theme/app_colors.dart';

class CandyDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const CandyDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Body
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.dialogBackground,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.candyPink, width: 8),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3D Style Title (like a button but not clickable)
                Stack(
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
                          title,
                          style: const TextStyle(
                            fontSize: 24,
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
                const SizedBox(height: 30),
                content,
                if (actions != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
          // Close Button
          Positioned(
            right: -10,
            top: -10,
            child: CandyButton(
              width: 50,
              height: 50,
              borderRadius: 25,
              depth: 4,
              color: Colors.redAccent,
              darkColor: Colors.red.shade900,
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
