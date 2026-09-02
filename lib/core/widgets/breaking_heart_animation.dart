import 'package:flutter/material.dart';
import 'package:fixit/core/theme/app_colors.dart';

class BreakingHeartAnimation extends StatefulWidget {
  final int initialLives;
  final VoidCallback onAnimationComplete;

  const BreakingHeartAnimation({
    super.key,
    required this.initialLives,
    required this.onAnimationComplete,
  });

  @override
  State<BreakingHeartAnimation> createState() => _BreakingHeartAnimationState();
}

class _BreakingHeartAnimationState extends State<BreakingHeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breakAnimation;
  late Animation<double> _fadeAnimation;
  bool _isBroken = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _breakAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.elasticIn),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      setState(() => _isBroken = true);
      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_fadeAnimation.value == 0) {
          return _buildHeart(widget.initialLives - 1, isBroken: false);
        }

        return Opacity(
          opacity: _fadeAnimation.value,
          child: _buildHeart(
            _isBroken ? widget.initialLives - 1 : widget.initialLives,
            isBroken: _breakAnimation.value > 0.5,
            breakProgress: _breakAnimation.value,
          ),
        );
      },
    );
  }

  Widget _buildHeart(int count, {bool isBroken = false, double breakProgress = 0}) {
    return SizedBox(
      height: 150,
      width: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!isBroken)
            Icon(Icons.favorite, color: Colors.red.shade700, size: 120)
          else
            // Split halves logic using simple transforms
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(-10 * breakProgress, 0),
                  child: Transform.rotate(
                    angle: -0.1 * breakProgress,
                    child: ClipRect(
                      clipper: _HalfClipper(left: true),
                      child: Icon(Icons.favorite, color: Colors.red.shade700, size: 120),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(10 * breakProgress, 0),
                  child: Transform.rotate(
                    angle: 0.1 * breakProgress,
                    child: ClipRect(
                      clipper: _HalfClipper(left: false),
                      child: Icon(Icons.favorite, color: Colors.red.shade700, size: 120),
                    ),
                  ),
                ),
              ],
            ),
          if (!isBroken)
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 40,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
            ),
        ],
      ),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  final bool left;
  _HalfClipper({required this.left});

  @override
  Rect getClip(Size size) {
    if (left) {
      return Rect.fromLTWH(0, 0, size.width / 2, size.height);
    } else {
      return Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);
    }
  }

  @override
  bool shouldReclip(_HalfClipper oldClipper) => oldClipper.left != left;
}
