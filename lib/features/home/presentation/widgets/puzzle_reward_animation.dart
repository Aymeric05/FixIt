import 'package:flutter/material.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/features/home/presentation/widgets/shiny_puzzle_icon.dart';

class PuzzleRewardAnimation extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final int pieceCount;
  final VoidCallback onComplete;

  const PuzzleRewardAnimation({
    super.key,
    required this.startOffset,
    required this.endOffset,
    this.pieceCount = 5,
    required this.onComplete,
  });

  @override
  State<PuzzleRewardAnimation> createState() => _PuzzleRewardAnimationState();
}

class _PuzzleRewardAnimationState extends State<PuzzleRewardAnimation> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<Offset>> _moveAnimations;
  late List<Animation<double>> _opacityAnimations;
  
  late List<bool> _showBadge;
  int _completedCount = 0;
  late int _totalGained;

  @override
  void initState() {
    super.initState();
    _totalGained = (widget.pieceCount == 10) ? 20 : 5;
    _showBadge = List.filled(widget.pieceCount, false);
    _controllers = List.generate(widget.pieceCount, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2500),
      );
    });

    _scaleAnimations = [];
    _moveAnimations = [];
    _opacityAnimations = [];

    for (int i = 0; i < widget.pieceCount; i++) {
      final double startDelay = i * 0.05; // Tight staggered launch
      
      _scaleAnimations.add(TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1).chain(CurveTween(curve: Curves.easeOutBack)), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 70),
      ]).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Interval(startDelay, (startDelay + 0.3).clamp(0.0, 1.0), curve: Curves.linear),
      )));

      _moveAnimations.add(Tween<Offset>(
        begin: widget.startOffset,
        end: widget.endOffset,
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Interval((startDelay + 0.5).clamp(0.0, 1.0), (startDelay + 0.9).clamp(0.0, 1.0), curve: Curves.easeInBack),
      )));

      _opacityAnimations.add(TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
        TweenSequenceItem(tween: ConstantTween(1.0), weight: 80),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
      ]).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Interval(startDelay, 1.0, curve: Curves.linear),
      )));

      _controllers[i].addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _completedCount++;
          if (_completedCount == widget.pieceCount) {
            widget.onComplete();
          }
        }
      });

      _controllers[i].addListener(() {
        if (_controllers[i].value > (startDelay + 0.1) && !_showBadge[i]) {
          setState(() => _showBadge[i] = true);
        }
      });
      
      _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.pieceCount, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, child) {
            final position = _moveAnimations[i].value;
            final scale = _scaleAnimations[i].value;
            final opacity = _opacityAnimations[i].value;

            if (opacity <= 0) return const SizedBox.shrink();

            return Positioned(
              left: position.dx - 27,
              top: position.dy - 27, // Use exact center
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const ShinyPuzzleIcon(size: 55), // Increased size from 40 to 55
                      if (_showBadge[i])
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Stack(
                                  children: [
                                    // Big Text with heavy black outline
                                    Text(
                                      '+$_totalGained',
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
                                      '+$_totalGained',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
