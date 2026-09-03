import 'package:flutter/material.dart';
import 'package:fixit/core/theme/app_colors.dart';

class CandyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color darkColor;
  final double width;
  final double height;
  final double borderRadius;
  final double depth;

  const CandyButton({
    super.key,
    required this.child,
    this.onPressed,
    required this.color,
    required this.darkColor,
    this.width = 85,
    this.height = 85,
    double? borderRadius,
    this.depth = 8,
  }) : borderRadius = borderRadius ?? (width / 2);

  @override
  State<CandyButton> createState() => _CandyButtonState();
}

class _CandyButtonState extends State<CandyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;
    final Color buttonColor = isDisabled ? Colors.grey : widget.color;
    final Color shadowColor = isDisabled ? Colors.grey.shade700 : widget.darkColor;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: SizedBox(
        width: widget.width,
        height: widget.height + widget.depth,
        child: Stack(
          children: [
            // Bottom "Base" (Shadow/Depth)
            Positioned(
              bottom: 0,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
              ),
            ),
            // Top "Face"
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              top: _isPressed ? widget.depth : 0,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [buttonColor.withValues(alpha: 0.8), buttonColor],
                    center: const Alignment(-0.3, -0.3),
                    radius: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Gloss reflection
                    Positioned(
                      top: widget.height * 0.1,
                      left: widget.width * 0.2,
                      child: Container(
                        width: widget.width * 0.4,
                        height: widget.height * 0.15,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                        ),
                      ),
                    ),
                    widget.child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
