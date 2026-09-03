import 'package:flutter/material.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';

class DailyChallengeButton extends StatelessWidget {
  final VoidCallback onTap;

  const DailyChallengeButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CandyButton(
      width: 70,
      height: 70,
      color: AppColors.candyYellow,
      darkColor: AppColors.candyYellowDark,
      onPressed: onTap,
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.calendar_month, color: Colors.white, size: 35),
          Positioned(
            top: 5,
            right: 5,
            child: CircleAvatar(
              radius: 6,
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
