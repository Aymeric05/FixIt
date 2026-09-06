import 'package:flutter/material.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';

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
    double progress = forceFull ? 1.0 : (state.levelsCompletedInWorld / state.maxLevelsInWorld);
    int levelsLeft = forceFull ? 0 : (state.maxLevelsInWorld - state.levelsCompletedInWorld);
    
    return Container(
      key: barKey,
      width: 320,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.3),
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
                    color: Colors.yellow,
                    boxShadow: [BoxShadow(color: Colors.yellow.withValues(alpha: 0.5), blurRadius: 6)],
                  ),
                ),
              ),
            ),
            Text(
              'NEXT WORLD IN $levelsLeft LEVELS',
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
