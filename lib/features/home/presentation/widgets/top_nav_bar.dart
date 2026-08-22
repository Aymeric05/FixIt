import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../lives/presentation/bloc/lives_bloc.dart';
import '../../../lives/presentation/bloc/lives_state.dart';
import '../bloc/home_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/candy_button.dart';
import '../../../../core/widgets/candy_icons.dart';
import 'settings_dialog.dart';
import 'social_dialog.dart';
import 'no_ads_dialog.dart';
import 'lives_store_dialog.dart';
import 'leaderboard_dialog.dart';
import 'map_dialog.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.fromLTRB(15, topPadding + 10, 15, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Leaderboard, Map, Social
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavButton(
                    context,
                    icon: Icons.people,
                    label: 'Social',
                    color: AppColors.candyPink,
                    darkColor: AppColors.candyPinkDark,
                    onPressed: () => _showCandyDialog(context, const SocialDialog()),
                  ),
                  const SizedBox(height: 12),
                  _buildNavButton(
                    context,
                    icon: Icons.airplanemode_active,
                    label: 'Map',
                    color: AppColors.candyGreen,
                    darkColor: AppColors.candyGreenDark,
                    onPressed: () => _showCandyDialog(context, const MapDialog()),
                  ),
                  const SizedBox(height: 12),
                  _buildNavButton(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Rank',
                    color: AppColors.candyBlue,
                    darkColor: AppColors.candyBlueDark,
                    onPressed: () => _showCandyDialog(context, const LeaderboardDialog()),
                  ),
                ],
              ),

              // Center: Juicy Heart
              _buildJuicyHeart(context, state),

              // Right side: No Ads & Settings
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavButton(
                    context,
                    customIcon: const NoAdsIcon(size: 40),
                    label: 'No Ads',
                    color: AppColors.candyOrange,
                    darkColor: AppColors.candyOrangeDark,
                    onPressed: () => _showCandyDialog(context, const NoAdsDialog()),
                  ),
                  const SizedBox(height: 15),
                  _buildNavButton(
                    context,
                    icon: Icons.settings,
                    label: 'Settings',
                    color: AppColors.candyBlue,
                    darkColor: AppColors.candyBlueDark,
                    onPressed: () => _showCandyDialog(context, const SettingsDialog()),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCandyDialog(BuildContext context, Widget dialog) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: BlocProvider.of<HomeBloc>(context),
        child: dialog,
      ),
    );
  }

  Widget _buildJuicyHeart(BuildContext context, HomeState state) {
    String timeText = '';
    if (state.lives < state.maxLives && state.nextLifeTime != null) {
      final diff = state.nextLifeTime!.difference(DateTime.now());
      if (diff.isNegative) {
        timeText = '00:00';
      } else {
        timeText = '${diff.inMinutes.toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _showCandyDialog(context, const LivesStoreDialog()),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Shadow for heart
              const Icon(Icons.favorite, color: Colors.black26, size: 94),
              // Main Heart
              ShaderMask(
                shaderCallback: (bounds) => const RadialGradient(
                  center: Alignment(-0.3, -0.3),
                  colors: [Colors.white, Colors.red, Color(0xFF8B0000)],
                  radius: 0.8,
                ).createShader(bounds),
                child: const Icon(Icons.favorite, color: Colors.white, size: 90),
              ),
              // Glossy highlight
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  width: 30,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Lives Count
              Text(
                '${state.lives}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
                ),
              ),
              // Plus Button
              Positioned(
                right: 5,
                bottom: 0,
                child: CandyButton(
                  width: 30,
                  height: 30,
                  borderRadius: 15,
                  depth: 3,
                  color: AppColors.candyGreen,
                  darkColor: AppColors.candyGreenDark,
                  onPressed: () => _showCandyDialog(context, const LivesStoreDialog()),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        if (timeText.isNotEmpty) ...[
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              timeText,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    IconData? icon,
    Widget? customIcon,
    required String label,
    required Color color,
    required Color darkColor,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CandyButton(
          width: 75,
          height: 75,
          borderRadius: 20,
          depth: 6,
          color: color,
          darkColor: darkColor,
          onPressed: onPressed,
          child: customIcon ?? Icon(icon, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 1))],
          ),
        ),
      ],
    );
  }
}

class _StripedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // No longer used, but kept to avoid compilation errors if referenced
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
