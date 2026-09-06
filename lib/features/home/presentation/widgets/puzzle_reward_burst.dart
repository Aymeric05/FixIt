import 'package:flutter/material.dart';

import 'puzzle_reward_animation.dart';

/// Orchestrates a burst of duplicated [PuzzleRewardAnimation] pieces.
///
/// Example: totalReward=20, visualPieceCount=10 -> each piece impact adds +2
/// to the total, but only the first piece displays the "+20" badge.
///
/// The pieces land in a neat stack: the first piece (badge) lands right on
/// the target and stays visually on top; every following piece lands
/// slightly offset toward the bottom-right and sits underneath it, like a
/// small pile of puzzle pieces forming.
///
/// The total diagonal spread of the pile is kept constant regardless of how
/// many pieces are in it (5 for a normal win, 10 for daily/series), so a
/// bigger piece count results in a tighter per-piece offset instead of the
/// whole pile stretching further away from the landing point.
class PuzzleRewardBurst extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final int totalReward; // e.g. 5 or 20
  final int visualPieceCount; // e.g. 5 or 10
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

  // Total diagonal spread (in px) of the whole pile, from the first piece
  // (unshifted, on top) to the very last one at the back. This stays fixed
  // regardless of visualPieceCount, so more pieces means a tighter stack
  // rather than a pile that stretches further to the bottom-right.
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

  /// Per-piece stacking step, recalculated so the pile's total spread stays
  /// at [_maxStackSpread] no matter how many pieces there are.
  double get _stackStep {
    final int pieceCount = widget.visualPieceCount;
    if (pieceCount <= 1) return 0;
    return _maxStackSpread / (pieceCount - 1);
  }

  /// Landing position for piece [index]: the first piece (index 0, the one
  /// carrying the total badge) lands exactly on the target. Every following
  /// piece lands a bit further down-right, so they visually stack under it.
  Offset _stackedEnd(int index) {
    final step = _stackStep;
    return Offset(
      widget.endOffset.dx + index * step,
      widget.endOffset.dy + index * step,
    );
  }

  /// Start position mirrors the same stacking offset so each piece flies in
  /// on its own parallel path instead of converging messily.
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
    // Split the total reward evenly across the visual pieces so the sum
    // still lands exactly on totalReward (e.g. 20 over 10 pieces = +2 each).
    final int incrementPerPiece = (widget.totalReward / pieceCount).round();

    // Build children so the badge piece (index 0) is added LAST, which in a
    // Stack means it's painted on top of every other piece — keeping it
    // visually "above" the little pile formed by the rest.
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

    return Stack(children: pieces);
  }
}