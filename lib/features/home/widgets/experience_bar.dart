import 'package:flutter/material.dart';
import 'package:fixit/features/home/bloc/home_bloc.dart';

class ExperienceBar extends StatefulWidget {
  final HomeState state;
  final GlobalKey? barKey;
  final bool forceFull;

  const ExperienceBar({
    super.key, 
    required this.state, 
    this.barKey,
    this.forceFull = false,
  });

  @override
  State<ExperienceBar> createState() => _ExperienceBarState();
}

class _ExperienceBarState extends State<ExperienceBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A transition is occurring if we just unlocked a world and are at the milestone level.
    final bool isTransitioning = widget.state.justUnlockedWorldIndex != null;

    double progress = (widget.forceFull || isTransitioning) ? 1.0 : (widget.state.levelsCompletedInWorld / widget.state.maxLevelsInWorld);
    int levelsLeft = (widget.forceFull || isTransitioning) ? 0 : (widget.state.maxLevelsInWorld - widget.state.levelsCompletedInWorld);
    
    // The color follows the world progression:
    // Meadow (10 levels) = Yellow
    // Desert (20 levels) = Blue
    // Ice (30 levels) = Green (new)
    // Volcano (40 levels) = Orange (new)
    Color barColor = Colors.yellow;
    if (widget.state.maxLevelsInWorld == 20) barColor = Colors.blue;
    if (widget.state.maxLevelsInWorld == 30) barColor = Colors.green;
    if (widget.state.maxLevelsInWorld == 40) barColor = Colors.orange;

    return Container(
      key: widget.barKey,
      width: 320,
      height: 40,
      decoration: BoxDecoration(
        color: barColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: 314 * progress.clamp(0.0, 1.0), // Total inner content width budget (~320 minus borders)
                height: 40,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: barColor,
                        boxShadow: [BoxShadow(color: barColor.withValues(alpha: 0.5), blurRadius: 6)],
                      ),
                      child: CustomPaint(
                        painter: _CandyBarPainter(
                          barColor: barColor,
                          animationValue: _controller.value,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            IgnorePointer(
              child: Text(
                (levelsLeft <= 0 || isTransitioning) ? 'NEXT WORLD UNLOCKED!' : 'NEXT WORLD IN $levelsLeft LEVELS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandyBarPainter extends CustomPainter {
  final Color barColor;
  final double animationValue;

  _CandyBarPainter({required this.barColor, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    double stripeWidth = 14;
    double gap = 16;
    double total = stripeWidth + gap;
    
    double shift = animationValue * total;

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    
    for (double x = -size.height * 2; x < size.width + size.height; x += total) {
      final currentX = x + shift;
      final path = Path()
        ..moveTo(currentX, 0)
        ..lineTo(currentX + stripeWidth, 0)
        ..lineTo(currentX + stripeWidth - size.height, size.height)
        ..lineTo(currentX - size.height, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
    
    // Animated glossy highlight/sheen passing across the bar
    final sheenPaint = Paint();
    final sheenLeft = (animationValue * (size.width * 2)) - size.width;
    sheenPaint.shader = LinearGradient(
      colors: [
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.45),
        Colors.white.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(sheenLeft, 0, 70, size.height));
    
    canvas.drawRect(Rect.fromLTWH(sheenLeft, 0, 70, size.height), sheenPaint);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CandyBarPainter oldDelegate) =>
      oldDelegate.barColor != barColor || oldDelegate.animationValue != animationValue;
}
