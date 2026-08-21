import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_bloc.dart';

class MainPlayButton extends StatelessWidget {
  final int level;
  final GameDifficulty difficulty;

  const MainPlayButton({
    super.key,
    required this.level,
    required this.difficulty,
  });

  String get _difficultyText {
    switch (difficulty) {
      case GameDifficulty.facile:
        return 'Facile';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.difficile:
        return 'Difficile';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            // TODO: Start game
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondaryOrange, Colors.deepOrange],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.textWhite, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 6),
                  blurRadius: 12,
                )
              ],
            ),
            child: const Text(
              'JOUER',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Niveau $level',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textWhite,
            shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(2, 2))],
          ),
        ),
        Text(
          'Difficulté : $_difficultyText',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textWhite.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
