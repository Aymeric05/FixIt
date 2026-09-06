import 'package:flutter/material.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/features/home/presentation/widgets/experience_bar.dart';

class WorldUnlockOverlay extends StatefulWidget {
  final int worldIndex; 
  final GlobalKey barKey;
  final HomeState state;
  final VoidCallback onTransition;

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

  @override
  void initState() {
    super.initState();
    // bgController: darken screen
    _bgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    // moveController: slower move (2.5s)
    _moveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    // revealController: reveal new world
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
    
    // Less zoomed (1.2 instead of 1.5)
    final double targetScale = 1.2;
    // Calculate centered position for a 320x40 bar scaled by 1.2
    final double barWidth = 320 * targetScale;
    final double barHeight = 40 * targetScale;

    final screenCenter = Offset(
      MediaQuery.of(context).size.width / 2 - (barWidth / (2 * targetScale)), 
      MediaQuery.of(context).size.height / 2 - (barHeight / (2 * targetScale)),
    );

    // Using a more gentle curve (easeInOutCubic instead of Expo)
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
    // Stay centered for a bit
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

  @override
  Widget build(BuildContext context) {
    final String worldName = widget.worldIndex == 2 ? 'DESERT' : 'ICE';
    final String worldAsset = widget.worldIndex == 2 ? 'assets/images/world2.png' : 'assets/images/world3.png';

    return Stack(
      children: [
        // Darken background
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
                child: Transform.scale(
                  scale: _barScaleAnimation.value,
                  // forceFull: true ensures the bar is completely yellow
                  child: ExperienceBar(state: widget.state, forceFull: true),
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
                  const Text(
                    'NOUVEAU MONDE DÉBLOQUÉ !',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: widget.onTransition,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.yellow.withValues(alpha: 0.4), blurRadius: 60, spreadRadius: 10)
                            ],
                          ),
                          child: Image.asset(worldAsset, fit: BoxFit.contain),
                        ),
                        // Title below image
                        Positioned(
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                            ),
                            child: Text(
                              worldName,
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        // Animated hand
                        AnimatedBuilder(
                          animation: _handController,
                          builder: (context, child) {
                            return Positioned(
                              right: 20,
                              bottom: 40 + (_handController.value * 25),
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
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
