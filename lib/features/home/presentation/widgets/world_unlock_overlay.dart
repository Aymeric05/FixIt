import 'package:flutter/material.dart';
import 'package:fixit/core/theme/app_colors.dart';

class WorldUnlockOverlay extends StatefulWidget {
  final int worldIndex; // 2 or 3
  final VoidCallback onTransition;

  const WorldUnlockOverlay({
    super.key,
    required this.worldIndex,
    required this.onTransition,
  });

  @override
  State<WorldUnlockOverlay> createState() => _WorldUnlockOverlayState();
}

class _WorldUnlockOverlayState extends State<WorldUnlockOverlay> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _explosionController;
  late AnimationController _revealController;
  late AnimationController _handController;

  bool _isExploded = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _explosionController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _revealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _handController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);

    _startSequence();
  }

  void _startSequence() async {
    await _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    await _explosionController.forward();
    setState(() => _isExploded = true);
    await _revealController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _explosionController.dispose();
    _revealController.dispose();
    _handController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String worldName = widget.worldIndex == 2 ? 'DESERT' : 'ICE';
    final String worldAsset = widget.worldIndex == 2 ? 'assets/images/world2.png' : 'assets/images/world3.png';

    return Stack(
      children: [
        // Darken background
        FadeTransition(
          opacity: _bgController,
          child: Container(color: Colors.black.withValues(alpha: 0.8)),
        ),

        if (!_isExploded)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'WORLD COMPLETE!',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 50),
                // Glowing progress bar placeholder
                Container(
                  width: 320,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.yellow.withValues(alpha: 0.8), blurRadius: 30, spreadRadius: 10)
                    ],
                  ),
                ),
              ],
            ),
          ),

        if (_isExploded)
          Center(
            child: FadeTransition(
              opacity: _revealController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'NOUVEAU MONDE DÉBLOQUÉ !',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: widget.onTransition,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 50)
                            ],
                          ),
                          child: Image.asset(worldAsset, fit: BoxFit.contain),
                        ),
                        // Title below image
                        Positioned(
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              worldName,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        // Animated hand
                        AnimatedBuilder(
                          animation: _handController,
                          builder: (context, child) {
                            return Positioned(
                              right: 20,
                              bottom: 50 + (_handController.value * 20),
                              child: const Icon(Icons.touch_app, color: Colors.white, size: 60),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
