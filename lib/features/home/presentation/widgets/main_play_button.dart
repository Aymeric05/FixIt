import 'package:flutter/material.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/features/game/presentation/pages/game_page.dart';

class MainPlayButton extends StatefulWidget {
  final int level;
  final VoidCallback onTap;

  const MainPlayButton({
    super.key,
    required this.level,
    required this.onTap,
  });

  @override
  State<MainPlayButton> createState() => _MainPlayButtonState();
}

class _MainPlayButtonState extends State<MainPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: (_) => _controller.stop(),
            onTapUp: (_) => _controller.repeat(reverse: true),
            onTapCancel: () => _controller.repeat(reverse: true),
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [AppColors.secondaryOrange, Colors.deepOrange],
                  center: Alignment(-0.2, -0.3),
                  radius: 1.2,
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: AppColors.textWhite, width: 6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    offset: Offset(0, 8),
                    blurRadius: 15,
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Gloss effect
                  Positioned(
                    top: 2,
                    left: 15,
                    child: Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Text(
                    'PLAY LEVEL ${widget.level}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textWhite,
                      letterSpacing: 1.2,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 6, offset: Offset(3, 3))],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
