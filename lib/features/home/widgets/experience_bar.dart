import 'package:flutter/material.dart';
import 'package:fixit/features/home/bloc/home_bloc.dart';

class ExperienceBar extends StatelessWidget {
  final HomeState state;
  final GlobalKey? barKey;
  final bool forceFull;

  const ExperienceBar({
    super.key, 
    required this.state, 
    this.barKey,
    this.forceFull = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWorld1Transition = state.currentLevel == 11 && state.justUnlockedWorldIndex == 2;
    final bool isWorld2Transition = state.currentLevel == 31 && state.justUnlockedWorldIndex == 3;
    final bool isTransitioning = isWorld1Transition || isWorld2Transition;

    double progress = (forceFull || isTransitioning) ? 1.0 : (state.levelsCompletedInWorld / state.maxLevelsInWorld);
    int levelsLeft = (forceFull || isTransitioning) ? 0 : (state.maxLevelsInWorld - state.levelsCompletedInWorld);
    
    // The color strictly follows the maxLevelsInWorld logic:
    // 10 levels target (Meadow completion) = Yellow
    // 20 levels target (Desert completion) = Blue
    final Color barColor = (state.maxLevelsInWorld == 10) ? Colors.yellow : Colors.blue;

    return Container(
      key: barKey,
      width: 320,
      height: 40,
      decoration: BoxDecoration(
        color: barColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    boxShadow: [BoxShadow(color: barColor.withValues(alpha: 0.5), blurRadius: 6)],
                  ),
                ),
              ),
            ),
            Text(
              (levelsLeft <= 0 || isTransitioning) ? 'NEXT WORLD UNLOCKED!' : 'NEXT WORLD IN $levelsLeft LEVELS',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
