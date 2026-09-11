import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fixit/features/home/bloc/home_bloc.dart';
import 'package:fixit/features/home/widgets/experience_bar.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fixit/features/home/widgets/candy_dialog.dart';

class WorldUnlockOverlay extends StatefulWidget {
  final int worldIndex; 
  final GlobalKey barKey;
  final HomeState state;
  final ValueChanged<int> onTransition;

  const WorldUnlockOverlay({
    super.key,
    required this.worldIndex,
    required this.barKey,
    required this.state,
    required this.onTransition,
  });

  @override
  State<WorldUnlockOverlay> createState() => _WorldUnlockOverlayState();
}

class _WorldUnlockOverlayState extends State<WorldUnlockOverlay> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _moveController;
  late AnimationController _revealController;
  late AnimationController _handController;

  late Animation<Offset> _barPositionAnimation;
  late Animation<double> _barScaleAnimation;

  bool _isExploded = false;
  Offset _startPos = Offset.zero;
  
  int _selectedWorldIndex = 0;
  
  final List<({String name, String asset, Color color, int index, String id, String previewText})> _availableWorlds = [
    (
      name: 'DESERT', 
      asset: 'assets/images/world2.png', 
      color: Colors.orange, 
      index: 2, 
      id: 'desert',
      previewText: "Rotate the pipes to guide the water and restore the oasis!",
    ),
    (
      name: 'ICE', 
      asset: 'assets/images/world3.png', 
      color: Colors.blueAccent, 
      index: 3, 
      id: 'ice',
      previewText: "Slide through the frozen kingdom and solve icy puzzles!",
    ),
    (
      name: 'VOLCANO', 
      asset: 'assets/images/world4.png', 
      color: Colors.red, 
      index: 4, 
      id: 'volcano',
      previewText: "Navigate dangerous lava flows in the heart of the volcano!",
    ),
    (
      name: 'CITY', 
      asset: 'assets/images/world5.png', 
      color: Colors.purple, 
      index: 5, 
      id: 'city',
      previewText: "Restore power to the urban jungle and fix the city grid!",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _moveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _revealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _handController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePositions();
      _startSequence();
    });
  }

  void _calculatePositions() {
    final RenderBox? box = widget.barKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      _startPos = box.localToGlobal(Offset.zero);
    }
    
    const double targetScale = 1.2;
    const double barWidth = 320 * targetScale;
    const double barHeight = 40 * targetScale;

    final screenCenter = Offset(
      MediaQuery.of(context).size.width / 2 - (barWidth / (2 * targetScale)), 
      MediaQuery.of(context).size.height / 2 - (barHeight / (2 * targetScale)),
    );

    _barPositionAnimation = Tween<Offset>(
      begin: _startPos,
      end: screenCenter,
    ).animate(CurvedAnimation(parent: _moveController, curve: Curves.easeInOutCubic));

    _barScaleAnimation = Tween<double>(
      begin: 1.0,
      end: targetScale,
    ).animate(CurvedAnimation(parent: _moveController, curve: Curves.easeInOutCubic));
  }

  void _startSequence() async {
    await _bgController.forward();
    await _moveController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isExploded = true);
    await _revealController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _moveController.dispose();
    _revealController.dispose();
    _handController.dispose();
    super.dispose();
  }
  
  void _cycleWorld() {
    setState(() {
      _selectedWorldIndex = (_selectedWorldIndex + 1) % _getFilteredWorlds().length;
    });
  }

  List<({String name, String asset, Color color, int index, String id, String previewText})> _getFilteredWorlds() {
    // We only filter worlds that were unlocked PERMANENTLY in a PREVIOUS session
    // Actually, in the HomeBloc, when we reach level 11, 'desert' is ALREADY in unlockedWorlds.
    // So we should only filter worlds that are NOT the current suggested one if it's new.
    
    // A better logic: Filter worlds that have been in the unlockedWorldIds for more than 1 second?
    // No, let's just check if it's the one we are CURRENTLY unlocking.
    return _availableWorlds.where((w) {
      // If it's the suggested world for this transition, don't filter it out
      if (w.index == widget.worldIndex) return true;
      // Otherwise, filter if already unlocked
      return !widget.state.unlockedWorlds.contains(w.id);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredWorlds();
    if (filtered.isEmpty) return const SizedBox.shrink();
    
    final currentChoice = filtered[_selectedWorldIndex % filtered.length];

    return Stack(
      children: [
        FadeTransition(
          opacity: _bgController,
          child: Container(color: Colors.black.withValues(alpha: 0.9)),
        ),

        if (!_isExploded)
          AnimatedBuilder(
            animation: _moveController,
            builder: (context, child) {
              return Positioned(
                left: _barPositionAnimation.value.dx,
                top: _barPositionAnimation.value.dy,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: _barScaleAnimation.value,
                      child: Container(
                        width: 320,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withValues(alpha: 0.4 * _moveController.value),
                              blurRadius: 30,
                              spreadRadius: 10 * _moveController.value,
                            )
                          ],
                        ),
                      ),
                    ),

                    Transform.scale(
                      scale: _barScaleAnimation.value,
                      child: ExperienceBar(state: widget.state, forceFull: true),
                    ),
                  ],
                ),
              );
            },
          ),

        if (_isExploded)
          Center(
            child: FadeTransition(
              opacity: _revealController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NEW WORLD UNLOCKED!',
                    style: GoogleFonts.luckiestGuy(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [const Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => widget.onTransition(currentChoice.index),
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: currentChoice.color.withValues(alpha: 0.4), blurRadius: 60, spreadRadius: 10)
                            ],
                          ),
                          child: Image.asset(currentChoice.asset, fit: BoxFit.contain),
                        ),
                      ),
                      
                      // Choice Cycle Button
                      Positioned(
                        bottom: 0,
                        right: -10,
                        child: CandyButton(
                          width: 44,
                          height: 44,
                          borderRadius: 22,
                          color: AppColors.candyBlue,
                          darkColor: AppColors.candyBlueDark,
                          onPressed: _cycleWorld,
                          child: const Icon(Icons.sync, color: Colors.white, size: 24),
                        ),
                      ),
                      
                      // Preview Button
                      Positioned(
                        top: 0,
                        right: -10,
                        child: CandyButton(
                          width: 44,
                          height: 44,
                          borderRadius: 22,
                          color: AppColors.candyBlue,
                          darkColor: AppColors.candyBlueDark,
                          onPressed: () => _showPreview(context, currentChoice.name, currentChoice.asset, currentChoice.previewText),
                          child: Text(
                            "?",
                            style: GoogleFonts.luckiestGuy(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      
                      Positioned(
                        bottom: -40,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                          ),
                          child: Text(
                            currentChoice.name,
                            style: GoogleFonts.luckiestGuy(
                              color: Colors.white, 
                              fontSize: 28, 
                              fontWeight: FontWeight.w900
                            ),
                          ),
                        ),
                      ),
                      
                      AnimatedBuilder(
                        animation: _handController,
                        builder: (context, child) {
                          return Positioned(
                            left: 0,
                            bottom: 20 + (_handController.value * 25),
                            child: const Icon(
                              Icons.touch_app, 
                              color: Colors.white, 
                              size: 70,
                              shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showPreview(BuildContext context, String name, String asset, String text) {
    showDialog(
      context: context,
      builder: (ctx) => CandyDialog(
        title: name.toUpperCase(),
        content: Column(
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          CandyButton(
            width: 150,
            height: 50,
            color: AppColors.candyGreen,
            darkColor: AppColors.candyGreenDark,
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "GOT IT!",
              style: GoogleFonts.luckiestGuy(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
