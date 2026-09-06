import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/features/home/presentation/widgets/shiny_puzzle_icon.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';

class PuzzleRewardAnimation extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final int incrementAmount; // How much this piece adds to the total on impact
  final int? badgeValue; // If non-null, shows "+badgeValue" on this piece only
  final VoidCallback onComplete;

  const PuzzleRewardAnimation({
    super.key,
    required this.startOffset,
    required this.endOffset,
    required this.incrementAmount,
    this.badgeValue,
    required this.onComplete,
  });

  @override
  State<PuzzleRewardAnimation> createState() => _PuzzleRewardAnimationState();
}

class _PuzzleRewardAnimationState extends State<PuzzleRewardAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _moveAnimation;
  late Animation<double> _opacityAnimation;
  bool _hasImpacted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _moveAnimation = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInQuad));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.addListener(() {
      // Impact detection (trigger pulse and increment when close to target)
      if (_controller.value >= 0.85 && !_hasImpacted) {
        _hasImpacted = true;
        context.read<HomeBloc>().add(IncrementAnimatedPuzzles(widget.incrementAmount));
      }
    });

    _controller.forward();
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
        if (_controller.value == 0 && _controller.status != AnimationStatus.forward) return const SizedBox.shrink();

        final position = _moveAnimation.value;
        final opacity = _opacityAnimation.value;

        return Positioned(
          left: position.dx - 27,
          top: position.dy - 27,
          child: Opacity(
            opacity: opacity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const ShinyPuzzleIcon(size: 55),
                if (widget.badgeValue != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Stack(
                      children: [
                        Text(
                          "+${widget.badgeValue}",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 4
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          "+${widget.badgeValue}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}