import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_bloc.dart';
import '../../../game/presentation/pages/game_page.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [AppColors.secondaryOrange, Colors.deepOrange],
                  center: Alignment(-0.2, -0.3),
                  radius: 1.2,
                ),
                borderRadius: BorderRadius.circular(45),
                border: Border.all(color: AppColors.textWhite, width: 8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    offset: Offset(0, 10),
                    blurRadius: 18,
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Gloss effect
                  Positioned(
                    top: 2,
                    left: 20,
                    child: Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Text(
                    'PLAY LEVEL ${widget.level}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textWhite,
                      letterSpacing: 1.5,
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
