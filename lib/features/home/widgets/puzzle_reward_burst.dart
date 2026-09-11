import 'dart:async';
import 'package:flutter/material.dart';
import 'puzzle_reward_animation.dart';

class PuzzleRewardBurst extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final int totalReward; 
  final int visualPieceCount; 
  final VoidCallback onComplete;

  const PuzzleRewardBurst({
    super.key,
    required this.startOffset,
    required this.endOffset,
    required this.totalReward,
    required this.visualPieceCount,
    required this.onComplete,
  });

  @override
  State<PuzzleRewardBurst> createState() => _PuzzleRewardBurstState();
}

class _PuzzleRewardBurstState extends State<PuzzleRewardBurst> {
  static const Duration _stagger = Duration(milliseconds: 90);
  static const double _maxStackSpread = 36.0;

  late final List<bool> _started;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _started = List.filled(widget.visualPieceCount, false);

    for (int i = 0; i < widget.visualPieceCount; i++) {
      Future.delayed(_stagger * i, () {
        if (!mounted) return;
        setState(() => _started[i] = true);
      });
    }
  }

  void _onPieceComplete() {
    _completedCount++;
    if (_completedCount >= widget.visualPieceCount) {
      widget.onComplete();
    }
  }

  double get _stackStep {
    final int pieceCount = widget.visualPieceCount;
    if (pieceCount <= 1) return 0;
    return _maxStackSpread / (pieceCount - 1);
  }

  Offset _stackedEnd(int index) {
    final step = _stackStep;
    return Offset(
      widget.endOffset.dx + index * step,
      widget.endOffset.dy + index * step,
    );
  }

  Offset _stackedStart(int index) {
    final step = _stackStep;
    return Offset(
      widget.startOffset.dx + index * step,
      widget.startOffset.dy + index * step,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int pieceCount = widget.visualPieceCount;
    final int incrementPerPiece = (widget.totalReward / pieceCount).round();

    final List<Widget> pieces = [];
    for (int i = pieceCount - 1; i >= 0; i--) {
      if (!_started[i]) continue;
      pieces.add(
        PuzzleRewardAnimation(
          key: ValueKey('puzzle_piece_$i'),
          startOffset: _stackedStart(i),
          endOffset: _stackedEnd(i),
          incrementAmount: incrementPerPiece,
          badgeValue: i == 0 ? widget.totalReward : null,
          onComplete: _onPieceComplete,
        ),
      );
    }

    // Wrap in fill to ensure it takes whole screen space for absolute positioning of children
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: pieces,
      ),
    );
  }
}
