import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkedin_games/features/game/presentation/bloc/game_bloc.dart';
import 'package:linkedin_games/features/game/presentation/bloc/game_event.dart';
import 'package:linkedin_games/features/game/presentation/bloc/game_state.dart';
import 'package:linkedin_games/features/home/presentation/bloc/home_bloc.dart';
import 'package:linkedin_games/features/lives/presentation/bloc/lives_bloc.dart';
import 'package:linkedin_games/features/lives/presentation/bloc/lives_event.dart';

class GamePage extends StatelessWidget {
  final int level;
  final GameDifficulty difficulty;

  const GamePage({super.key, required this.level, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(StartGame(level: level, difficulty: difficulty)),
      child: BlocListener<GameBloc, GameState>(
        listener: (context, state) {
          if (state.status == GameStatus.lost) {
            context.read<LivesBloc>().add(DecrementLife());
            _showGameOverDialog(context);
          } else if (state.status == GameStatus.won) {
            _showWinDialog(context);
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'monde1_background.png',
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context),
                    const Spacer(),
                    _buildGridContainer(context),
                    const Spacer(),
                  ],
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final minutes = (state.remainingSeconds / 60).floor();
        final seconds = (state.remainingSeconds % 60).toString().padLeft(2, '0');

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Text(
                'Level $level',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(2, 2))],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '$minutes:$seconds',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridContainer(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state.hints.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = constraints.maxWidth / 6;

              return GestureDetector(
                onPanStart: (details) => _handleDrag(context, details.localPosition, cellSize),
                onPanUpdate: (details) => _handleDrag(context, details.localPosition, cellSize),
                child: Stack(
                  children: [
                    _buildGridLines(state, cellSize),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                      ),
                      itemCount: 36,
                      itemBuilder: (context, index) {
                        final row = index ~/ 6;
                        final col = index % 6;
                        final value = state.hints[row][col];
                        final pos = GridOffset(row, col);

                        return Container(
                          decoration: BoxDecoration(
                            border: _buildCellBorder(state, pos),
                          ),
                          child: Center(
                            child: value != null
                                ? Text(
                                    '$value',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: value == 1 ? Colors.red.shade800 : Colors.black87,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Border _buildCellBorder(GameState state, GridOffset pos) {
    const defaultSide = BorderSide(color: Colors.black12, width: 0.5);
    const wallSide = BorderSide(color: Colors.black87, width: 4);

    return Border(
      top: _hasWall(state, pos, GridOffset(pos.row - 1, pos.col)) ? wallSide : defaultSide,
      bottom: _hasWall(state, pos, GridOffset(pos.row + 1, pos.col)) ? wallSide : defaultSide,
      left: _hasWall(state, pos, GridOffset(pos.row, pos.col - 1)) ? wallSide : defaultSide,
      right: _hasWall(state, pos, GridOffset(pos.row, pos.col + 1)) ? wallSide : defaultSide,
    );
  }

  bool _hasWall(GameState state, GridOffset a, GridOffset b) {
    if (b.row < 0 || b.row >= 6 || b.col < 0 || b.col >= 6) return false;
    final list = [a.toString(), b.toString()]..sort();
    final key = '${list[0]}-${list[1]}';
    return state.walls.contains(key);
  }

  void _handleDrag(BuildContext context, Offset localPos, double cellSize) {
    final row = (localPos.dy / cellSize).floor();
    final col = (localPos.dx / cellSize).floor();

    if (row >= 0 && row < 6 && col >= 0 && col < 6) {
      context.read<GameBloc>().add(SelectCell(row, col));
    }
  }

  Widget _buildGridLines(GameState state, double cellSize) {
    return IgnorePointer(
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: PathLinePainter(path: state.currentPath, cellSize: cellSize),
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: const Text('Time is up. You lost a life.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
  }

  void _showWinDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('You solved the puzzle!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class PathLinePainter extends CustomPainter {
  final List<GridOffset> path;
  final double cellSize;

  PathLinePainter({required this.path, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;

    final paint = Paint()
      ..color = Colors.orange.shade800
      ..strokeWidth = cellSize * 0.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final shadowPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = cellSize * 0.65
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final uiPath = Path();
    final startOffset = Offset(
      (path[0].col * cellSize) + (cellSize / 2),
      (path[0].row * cellSize) + (cellSize / 2),
    );
    uiPath.moveTo(startOffset.dx, startOffset.dy);

    for (int i = 1; i < path.length; i++) {
      final pos = path[i];
      final nextOffset = Offset(
        (pos.col * cellSize) + (cellSize / 2),
        (pos.row * cellSize) + (cellSize / 2),
      );
      uiPath.lineTo(nextOffset.dx, nextOffset.dy);
    }

    canvas.drawPath(uiPath, shadowPaint);
    canvas.drawPath(uiPath, paint);
  }

  @override
  bool shouldRepaint(covariant PathLinePainter oldDelegate) => 
      oldDelegate.path != path || oldDelegate.cellSize != cellSize;
}
