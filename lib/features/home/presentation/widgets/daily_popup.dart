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
    return CandyDialog(
      title: "DAILY CHALLENGES",
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Complete today's challenges to earn rewards and compete with friends!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.candyPurple,
              ),
            ),
            const SizedBox(height: 30),
            _buildChallengeOption(
              context,
              title: "DAILY LEVEL",
              subtitle: isDailyCompleted ? "COMPLETED!" : "One unique level, no time limit",
              icon: Icons.calendar_today,
              color: AppColors.candyBlue,
              darkColor: AppColors.candyBlueDark,
              isCompleted: isDailyCompleted,
              onTap: onPlayDaily,
            ),
            const SizedBox(height: 15),
            _buildChallengeOption(
              context,
              title: "DAILY SERIES",
              subtitle: isSeriesCompleted ? "COMPLETED!" : "3 levels in a row, cumulative time",
              icon: Icons.format_list_numbered,
              color: AppColors.candyGreen,
              darkColor: AppColors.candyGreenDark,
              isCompleted: isSeriesCompleted,
              onTap: onPlaySeries,
            ),
            const SizedBox(height: 30),
            CandyButton(
              width: 180,
              height: 50,
              borderRadius: 25,
              color: Colors.grey.shade400,
              darkColor: Colors.grey.shade600,
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "MAYBE LATER",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color darkColor,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return CandyButton(
      width: 280,
      height: 80,
      borderRadius: 20,
      color: color,
      darkColor: darkColor,
      onPressed: onTap,
      child: Row(
        children: [
          const SizedBox(width: 15),
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.check_circle, color: Colors.white, size: 25),
            ),
        ],
      ),
    );
  }
}
