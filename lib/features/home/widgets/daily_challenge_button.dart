import 'package:flutter/material.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/widgets/scintillating_wrapper.dart';

class DailyChallengeButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDailyCompleted;
  final bool isSeriesCompleted;

  const DailyChallengeButton({
    super.key,
    required this.onTap,
    this.isDailyCompleted = false,
    this.isSeriesCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color color = AppColors.candyYellow;
    const Color darkColor = AppColors.candyYellowDark;
    bool showBadge = !isDailyCompleted || !isSeriesCompleted;
    bool isAllCompleted = isDailyCompleted && isSeriesCompleted;

    return ScintillatingWrapper(
      isEnabled: !isAllCompleted,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
            CandyButton(
              width: 75,
              height: 75,
              borderRadius: 20,
              borderWidth: 5,
              color: color,
              darkColor: darkColor,
              onPressed: onTap,
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 40,
              ),
            ),
            if (showBadge)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
                    ],
                  ),
                ),
              ),
          ],
        ),
    );
  }
}
