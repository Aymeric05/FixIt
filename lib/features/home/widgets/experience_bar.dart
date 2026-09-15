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
    // A transition is occurring if we just unlocked a world and are at the milestone level.
    final bool isTransitioning = state.justUnlockedWorldIndex != null;

    double progress = (forceFull || isTransitioning) ? 1.0 : (state.levelsCompletedInWorld / state.maxLevelsInWorld);
    int levelsLeft = (forceFull || isTransitioning) ? 0 : (state.maxLevelsInWorld - state.levelsCompletedInWorld);
    
    // The color follows the world progression:
    // Meadow (10 levels) = Yellow
    // Desert (20 levels) = Blue
    // Ice (30 levels) = Green (new)
    // Volcano (40 levels) = Orange (new)
    Color barColor = Colors.yellow;
    if (state.maxLevelsInWorld == 20) barColor = Colors.blue;
    if (state.maxLevelsInWorld == 30) barColor = Colors.green;
    if (state.maxLevelsInWorld == 40) barColor = Colors.orange;

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
