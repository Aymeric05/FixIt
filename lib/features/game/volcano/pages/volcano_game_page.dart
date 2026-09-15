import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/features/game/widgets/game_header.dart';
import 'package:fixit/core/models/daily_mode.dart';
import 'package:fixit/features/home/bloc/home_bloc.dart';

class VolcanoGamePage extends StatelessWidget {
  final int level;
  final GameDifficulty difficulty;

  const VolcanoGamePage({
    super.key,
    required this.level,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Monde_4.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                GameHeader(
                  level: level,
                  mode: FixItGameMode.story,
                  remainingSeconds: 120,
                  onPause: () {},
                  onResume: () {},
                  onClose: () => Navigator.pop(context),
                  titleOverride: "VOLCANO WORLD (WIP)",
                ),
                const Spacer(),
                const Icon(Icons.whatshot, size: 100, color: Colors.orange),
                const Text("STAY TUNED!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
