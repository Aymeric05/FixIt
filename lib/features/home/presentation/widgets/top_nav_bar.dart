import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_state.dart';
import 'package:fixit/features/profile/presentation/widgets/profile_modal.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_state.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/widgets/candy_icons.dart';
import 'package:fixit/features/home/presentation/widgets/settings_dialog.dart';
import 'package:fixit/features/home/presentation/widgets/no_ads_dialog.dart';
import 'package:fixit/features/home/presentation/widgets/lives_store_dialog.dart';
import 'package:fixit/features/home/presentation/widgets/leaderboard_dialog.dart';
import 'package:fixit/features/home/presentation/widgets/map_dialog.dart';
import 'package:fixit/features/home/presentation/widgets/shop_dialog.dart';
import 'package:fixit/features/home/presentation/widgets/shiny_puzzle_icon.dart';
import 'package:fixit/features/home/presentation/widgets/daily_challenge_button.dart';

import 'package:fixit/core/utils/app_notifications.dart';

class TopNavBar extends StatelessWidget {
  static final GlobalKey puzzleKey = GlobalKey();
  final VoidCallback? onDailyPressed;

  const TopNavBar({super.key, this.onDailyPressed});

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
              // Left side: Profil, Shop, Map, Daily
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(context),
                    const SizedBox(height: 12),
                    _buildNavButton(
                      context,
                      icon: Icons.shopping_cart,
                      label: 'Shop',
                      color: AppColors.candyPurple,
                      darkColor: AppColors.candyPurpleDark,
                      onPressed: () => _showCandyDialog(context, const ShopDialog()),
                    ),
                    const SizedBox(height: 12),
                    _buildNavButton(
                      context,
                      icon: Icons.airplanemode_active,
                      label: 'Map',
                      color: AppColors.candyGreen,
                      darkColor: AppColors.candyGreenDark,
                      onPressed: () => _showCandyDialog(
                        context,
                        MapDialog(
                          onWorldSelected: (worldId) {
                            int index = 0;
                            switch (worldId) {
                              case 'meadow':
                                index = 1;
                                break;
                              case 'desert':
                                index = 2;
                                break;
                              case 'ice':
                                index = 3;
                                break;
                              case 'volcano':
                                index = 4;
                                break;
                              case 'city':
                                index = 5;
                                break;
                            }
                            context.read<HomeBloc>().add(ChangeWorld(index, worldId));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (onDailyPressed != null)
                      DailyChallengeButton(
                        isDailyCompleted: state.isDailyCompleted,
                        isSeriesCompleted: state.isSeriesCompleted,
                        onTap: onDailyPressed!,
                      ),
                  ],
                ),
              ),

              // Center: Juicy Heart & Puzzles
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  JuicyHeartIndicator(state: state),
                  const SizedBox(height: 15),
                  _buildPuzzleIndicator(context, state),
                ],
              ),

              // Right side: No Ads, Settings, Rank
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildNavButton(
                      context,
                      icon: Icons.settings,
                      label: 'Settings',
                      color: Colors.grey,
                      darkColor: Colors.grey.shade700,
                      onPressed: () => _showCandyDialog(context, const SettingsDialog()),
                    ),
                    const SizedBox(height: 12),
                    _buildNavButton(
                      context,
                      customIcon: const NoAdsIcon(size: 40),
                      label: 'No Ads',
                      color: AppColors.candyOrange,
                      darkColor: AppColors.candyOrangeDark,
                      onPressed: () => _showCandyDialog(context, const NoAdsDialog()),
                    ),
                    const SizedBox(height: 12),
                    _buildNavButton(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Rank',
                      color: Colors.red,
                      darkColor: Colors.red.shade900,
                      onPressed: () => _showCandyDialog(context, const LeaderboardDialog()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPuzzleIndicator(BuildContext context, HomeState state) {
    return PuzzleIndicator(state: state);
  }

  Widget _buildProfileSection(BuildContext context) {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, friendsState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final bool isAuthenticated = state is AuthAuthenticated;
            final avatarUrl = isAuthenticated ? state.profile.avatarUrl : null;

            return _buildNavButton(
              context,
              icon: avatarUrl == null || !File(avatarUrl).existsSync() ? Icons.person : null,
              customIcon: avatarUrl != null && File(avatarUrl).existsSync()
                  ? ClipOval(
                      child: Image.file(
                        File(avatarUrl),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        key: ValueKey(avatarUrl + DateTime.now().millisecondsSinceEpoch.toString()),
                      ),
                    )
                  : null,
              label: 'Social',
              color: AppColors.candyBlue,
              darkColor: AppColors.candyBlueDark,
              badgeCount: friendsState.incomingRequests.length,
              onPressed: isAuthenticated
                  ? () => showDialog(
                        context: context,
                        builder: (dialogContext) => ProfileModal(player: state.profile),
                      )
                  : () {
                      AppNotifications.show(context, 'Connecting to server...');
                    },
            );
          },
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

  Widget _buildNavButton(
    BuildContext context, {
    IconData? icon,
    Widget? customIcon,
    required String label,
    required Color color,
    required Color darkColor,
    required VoidCallback onPressed,
    int badgeCount = 0,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
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
            if (badgeCount > 0)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.candyPurple,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
                  ),
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
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

class PuzzleIndicator extends StatefulWidget {
  final HomeState state;
  const PuzzleIndicator({super.key, required this.state});

  @override
  State<PuzzleIndicator> createState() => _PuzzleIndicatorState();
}

class _PuzzleIndicatorState extends State<PuzzleIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(PuzzleIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pulse only on win action to avoid random pulses on data reload
    if (widget.state.lastAction == HomeLastAction.win && 
        widget.state.puzzlePieces > oldWidget.state.puzzlePieces) {
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (mounted) _controller.forward(from: 0.0);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        key: TopNavBar.puzzleKey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: _controller.isAnimating 
              ? [BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)] 
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ShinyPuzzleIcon(size: 24),
            const SizedBox(width: 8),
            Text(
              '${widget.state.puzzlePieces}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JuicyHeartIndicator extends StatefulWidget {
  final HomeState state;
  const JuicyHeartIndicator({super.key, required this.state});

  @override
  State<JuicyHeartIndicator> createState() => _JuicyHeartIndicatorState();
}

class _JuicyHeartIndicatorState extends State<JuicyHeartIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _glowAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(JuicyHeartIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.lastAction == HomeLastAction.lifeRegained &&
        oldWidget.state.lastAction != HomeLastAction.lifeRegained) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
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
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (_controller.isAnimating)
                    Transform.scale(
                      scale: _glowAnimation.value,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.yellow.withValues(alpha: 0.5),
                        size: 100,
                      ),
                    ),
                  const Icon(Icons.favorite, color: Colors.black26, size: 94),
                  ShaderMask(
                    shaderCallback: (bounds) => const RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      colors: [Colors.white, Colors.red, Color(0xFF8B0000)],
                      radius: 0.8,
                    ).createShader(bounds),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 90),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      width: 30,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    '${state.lives}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
                    ),
                  ),
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
              );
            },
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
}
