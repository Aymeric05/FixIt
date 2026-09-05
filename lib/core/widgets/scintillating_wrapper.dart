import 'package:flutter/material.dart';

class ScintillatingWrapper extends StatefulWidget {
  final Widget child;
  final bool isEnabled;

  const ScintillatingWrapper({
    super.key,
    required this.child,
    this.isEnabled = true,
  });

  @override
  State<ScintillatingWrapper> createState() => _ScintillatingWrapperState();
}

class _ScintillatingWrapperState extends State<ScintillatingWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    if (widget.isEnabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ScintillatingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isEnabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.4),
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              transform: _SlidingGradientTransform(offset: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double offset;
  const _SlidingGradientTransform({required this.offset});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (offset * 2 - 1), 0, 0);
  }
}
