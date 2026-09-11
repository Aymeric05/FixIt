import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/home/bloc/home_bloc.dart';
import 'package:fixit/features/home/widgets/settings_dialog.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/models/daily_mode.dart';

class GameHeader extends StatelessWidget {
  final int level;
  final FixItGameMode mode;
  final int remainingSeconds;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onClose;
  final String titleOverride;

  const GameHeader({
    super.key,
    required this.level,
    required this.mode,
    required this.remainingSeconds,
    required this.onPause,
    required this.onResume,
    required this.onClose,
    this.titleOverride = '',
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds / 60).floor();
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Settings Button
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: CandyButton(
                  width: 52,
                  height: 52,
                  borderRadius: 12,
                  depth: 4,
                  color: Colors.grey,
                  darkColor: Colors.grey.shade700,
                  onPressed: () async {
                    onPause();
                    await showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: BlocProvider.of<HomeBloc>(context),
                        child: const SettingsDialog(),
                      ),
                    );
                    onResume();
                  },
                  child: const Icon(Icons.settings, color: Colors.white, size: 28),
                ),
              ),

              // Level Banner
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 55,
                    width: 220,
                    decoration: BoxDecoration(
                      color: AppColors.candyBlueDark,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -4),
                    child: Container(
                      height: 50,
                      width: 220,
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [AppColors.candyBlue, AppColors.candyBlueDark],
                          center: Alignment(-0.3, -0.3),
                          radius: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        titleOverride.isNotEmpty 
                          ? titleOverride 
                          : (mode == FixItGameMode.dailySeries 
                              ? 'SERIES $level/3' 
                              : mode == FixItGameMode.dailySingle 
                                  ? 'DAILY LEVEL' 
                                  : 'LEVEL $level'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Close Button
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: CandyButton(
                  width: 52,
                  height: 52,
                  borderRadius: 26,
                  depth: 4,
                  color: Colors.redAccent,
                  darkColor: Colors.red.shade900,
                  onPressed: onClose,
                  child: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Timer Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
