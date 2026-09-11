import 'package:flutter/material.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/features/game/widgets/game_header.dart';
import 'package:fixit/core/models/daily_mode.dart';
import 'package:fixit/features/home/bloc/home_bloc.dart';

class IceGamePage extends StatelessWidget {
  final int level;
  final GameDifficulty difficulty;
  const IceGamePage({super.key, required this.level, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.lightBlue.shade100)),
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
                  titleOverride: "ICE WORLD (WIP)",
                ),
                const Spacer(),
                const Icon(Icons.ac_unit, size: 100, color: Colors.white),
                const Text("STAY TUNED!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
