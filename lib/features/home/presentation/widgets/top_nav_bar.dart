import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TopNavBar extends StatelessWidget {
  final int lives;
  final int maxLives;

  const TopNavBar({
    super.key,
    required this.lives,
    required this.maxLives,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Left: Profile Icon
          _buildIconButton(
            icon: Icons.person,
            color: Colors.blue.shade400,
            onPressed: () {
              // TODO: Open Profile Modal
            },
          ),

          // Top Center: Lives Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.overlayDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 24),
                const SizedBox(width: 6),
                Text(
                  '$lives/$maxLives',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                // TODO: Add countdown timer if lives < maxLives
              ],
            ),
          ),

          // Top Right: Settings Button
          _buildIconButton(
            icon: Icons.settings,
            color: Colors.grey.shade600,
            onPressed: () {
              // TODO: Open Settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textWhite, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Icon(icon, color: AppColors.textWhite, size: 28),
      ),
    );
  }
}
