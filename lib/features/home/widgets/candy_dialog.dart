import 'package:flutter/material.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/scintillating_wrapper.dart';

class CandyDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final VoidCallback? onClose;
  final Color? borderColor;
  final bool isScintillating;

  const CandyDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.onClose,
    this.borderColor,
    this.isScintillating = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget dialogBody = Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.dialogBackground,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: borderColor ?? AppColors.candyPink,
          width: 8,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3D Style Title (like a button but not clickable)
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 60,
                width: 320,
                decoration: BoxDecoration(
                  color: AppColors.candyBlueDark,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -5),
                child: Container(
                  height: 55,
                  width: 320,
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [AppColors.candyBlue, AppColors.candyBlueDark],
                      center: Alignment(-0.3, -0.3),
                      radius: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
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
    );

    if (isScintillating) {
      dialogBody = ScintillatingWrapper(child: dialogBody);
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Body
          dialogBody,

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
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
