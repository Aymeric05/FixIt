import 'package:flutter/material.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';

class DailyPopup extends StatelessWidget {
  final VoidCallback onPlayDaily;
  final VoidCallback onPlaySeries;
  final bool isDailyCompleted;
  final bool isSeriesCompleted;

  const DailyPopup({
    super.key,
    required this.onPlayDaily,
    required this.onPlaySeries,
    this.isDailyCompleted = false,
    this.isSeriesCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAllCompleted = isDailyCompleted && isSeriesCompleted;

    return CandyDialog(
      title: "DAILY CHALLENGES",
      borderColor: AppColors.candyYellow,
      isScintillating: !isAllCompleted,
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Daily challenges are available once per day with no time limit.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.candyPurple,
              ),
            ),
            const SizedBox(height: 30),
            _buildChallengeOption(
              context,
              title: "PLAY DAILY",
              subtitle: "",
              icon: null,
              color: isDailyCompleted ? Colors.grey.shade500 : AppColors.candyYellow,
              darkColor: isDailyCompleted ? Colors.grey.shade700 : AppColors.candyYellowDark,
              isCompleted: isDailyCompleted,
              onTap: onPlayDaily,
            ),
            if (isDailyCompleted) ...[
              const SizedBox(height: 15),
              _buildChallengeOption(
                context,
                title: "PLAY DAILY SERIES",
                subtitle: "",
                icon: null,
                color: isSeriesCompleted ? Colors.grey.shade500 : AppColors.candyOrange,
                darkColor: isSeriesCompleted ? Colors.grey.shade700 : AppColors.candyOrangeDark,
                isCompleted: isSeriesCompleted,
                onTap: onPlaySeries,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    IconData? icon,
    required Color color,
    required Color darkColor,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return CandyButton(
      width: 280,
      height: 80,
      borderRadius: 40,
      borderWidth: 6,
      color: color,
      darkColor: darkColor,
      onPressed: onTap,
      child: Opacity(
        opacity: isCompleted ? 0.7 : 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 30),
                  const SizedBox(width: 15),
                ],
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 1.2,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isCompleted ? Colors.white.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (isCompleted)
              const Positioned(
                right: 20,
                child: Icon(Icons.check_circle, color: Colors.white, size: 30),
              ),
          ],
        ),
      ),
    );
  }
}
