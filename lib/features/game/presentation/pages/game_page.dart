import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/game_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/game_event.dart';
import 'package:fixit/features/game/presentation/bloc/game_state.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_bloc.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_event.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_state.dart';
import 'package:fixit/core/repositories/progression_repository.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:confetti/confetti.dart';
import 'package:fixit/core/widgets/tutorial_dialog.dart';
import 'package:fixit/core/utils/app_notifications.dart';
import 'package:fixit/features/game/presentation/widgets/friends_leaderboard_dialog.dart';
import 'package:fixit/core/models/level_win_summary.dart';
import 'package:fixit/core/models/daily_mode.dart';

class GamePage extends StatefulWidget {
  final int level;
  final GameDifficulty difficulty;
  final GameMode mode;

  const GamePage({
    super.key,
    required this.level,
    required this.difficulty,
    this.mode = GameMode.story,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialDialog.showIfFirstTime(
        context,
        title: 'HOW TO PLAY',
        description: 'Connect all numbers in order (1, 2, 3...) to fill the entire grid!',
        tutorialKey: 'snake_tutorial_seen',
      );
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final playerId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocProvider(
      create: (context) => GameBloc()..add(StartGame(
        level: widget.level,
        difficulty: widget.difficulty,
        playerId: playerId,
        mode: widget.mode,
      )),
      child: Scaffold(
        body: BlocListener<GameBloc, GameState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) async {
            if (state.status == GameStatus.lost) {
              if (widget.mode == GameMode.story) {
                context.read<LivesBloc>().add(DecrementLife());
              }
              _showGameOverDialog(context);
            } else if (state.status == GameStatus.won) {
              final authState = context.read<AuthBloc>().state;
              String? currentUserId;
              
              if (authState is AuthAuthenticated) {
                currentUserId = authState.user.id;
                if (widget.mode == GameMode.story) {
                  final repo = ProgressionRepository();
                  try {
                    await repo.markLevelAsCompleted(
                      playerSupabaseId: currentUserId,
                      worldId: 'world_1',
                      levelNumber: widget.level,
                      timeSeconds: state.initialSeconds - state.remainingSeconds,
                    );
                  } catch (e) {
                    print('Error saving completion: $e');
                  }
                }
              }
              
              if (!mounted) return;
              _confettiController.play();
              _showWinDialog(context, state, currentUserId);
            }
          },
          child: Stack(
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
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: CandyButton(
                  width: 60,
                  height: 60,
                  borderRadius: 30,
                  color: AppColors.candyYellow,
                  darkColor: AppColors.candyYellowDark,
                  onPressed: () {
                    AppNotifications.show(context, 'Follow the numbers in order!');
                  },
                  child: const Icon(Icons.lightbulb, color: Colors.white, size: 30),
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
        final totalSeconds = state.mode == GameMode.dailySeries 
            ? state.seriesAccumulatedTime + (state.initialSeconds - state.remainingSeconds)
            : state.remainingSeconds;
        
        final minutes = (totalSeconds / 60).floor();
        final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
        
        final isCountingUp = state.mode != GameMode.story;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 240,
                    decoration: BoxDecoration(
                      color: AppColors.candyBlueDark,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -5),
                    child: Container(
                      height: 55,
                      width: 240,
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [AppColors.candyBlue, AppColors.candyBlueDark],
                          center: Alignment(-0.3, -0.3),
                          radius: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        state.mode == GameMode.dailySeries 
                            ? 'SERIES ${widget.level}/3' 
                            : state.mode == GameMode.dailySingle 
                                ? 'DAILY LEVEL' 
                                : 'LEVEL ${widget.level}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isCountingUp ? Icons.timer_outlined : Icons.timer, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '$minutes:$seconds',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
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

        return AspectRatio(
          aspectRatio: 1,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Transform.scale(
                  scale: 1.08,
                  child: Image.asset(
                    'jeu_serpent_contour_pas_ouf.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cellSize = constraints.maxWidth / 6;

                    return GestureDetector(
                      onPanStart: (details) => _handleDrag(context, details.localPosition, cellSize),
                      onPanUpdate: (details) => _handleDrag(context, details.localPosition, cellSize),
                      child: Container(
                        width: constraints.maxWidth,
                        height: constraints.maxWidth,
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            _buildGridLines(state, cellSize),
                            CustomPaint(
                              size: Size(constraints.maxWidth, constraints.maxWidth),
                              painter: _WallPainter(walls: state.walls, cellSize: cellSize),
                            ),
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
                                return Container(
                                  alignment: Alignment.center,
                                  child: value != null
                                      ? Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Text(
                                              '$value',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900,
                                                foreground: Paint()
                                                  ..style = PaintingStyle.stroke
                                                  ..strokeWidth = 3
                                                  ..color = Colors.white,
                                              ),
                                            ),
                                            Text(
                                              '$value',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900,
                                                color: value == 1 ? Colors.red.shade700 : const Color(0xFF3E2723),
                                              ),
                                            ),
                                          ],
                                        )
                                      : null,
                                );
                              },
                            ),
                            _buildSerpentHead(state, cellSize),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSerpentHead(GameState state, double cellSize) {
    if (state.currentPath.isEmpty) return const SizedBox.shrink();

    final headPos = state.currentPath.last;
    return Positioned(
      left: headPos.col * cellSize,
      top: headPos.row * cellSize,
      width: cellSize,
      height: cellSize,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _HeadPainter(isAngry: state.isAngry, cellSize: cellSize),
        ),
      ),
    );
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
          painter: PathLinePainter(
            path: state.currentPath,
            cellSize: cellSize,
            color: state.pathColor,
            isAngry: state.isAngry,
          ),
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => CandyDialog(
          title: 'GAME OVER',
          content: Column(
            children: [
              const Icon(Icons.heart_broken, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              const Text(
                "IT'S SO SAD... YOU DIDN'T SUCCEED!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.candyPurple,
                ),
              ),
              const SizedBox(height: 30),
              CandyButton(
                width: 200,
                height: 60,
                color: AppColors.candyPink,
                darkColor: AppColors.candyPinkDark,
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: const Text(
                  'RETURN HOME',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showWinDialog(BuildContext context, GameState state, String? playerId) {
    final summary = state.winSummary;
    if (summary == null) return;

    final int currentTimeTaken = state.initialSeconds - state.remainingSeconds;
    final int displayTime = state.mode == GameMode.dailySeries 
        ? (state.status == GameStatus.won && state.currentPath.length == 36 && state.remainingSeconds == state.initialSeconds)
            ? state.seriesAccumulatedTime // Resumption case: accumulated time is the total
            : state.seriesAccumulatedTime + currentTimeTaken 
        : currentTimeTaken;
    final timeStr = "${(displayTime / 60).floor()}:${(displayTime % 60).toString().padLeft(2, '0')}";
    
    final avgSeconds = summary.globalAverageSeconds;
    final avgTimeStr = avgSeconds > 0 
      ? "${(avgSeconds / 60).floor()}:${(avgSeconds % 60).toString().padLeft(2, '0')}" 
      : "--:--";
      
    final wrSeconds = summary.worldRecordSeconds;
    final wrTimeStr = wrSeconds > 0 
      ? "${(wrSeconds / 60).floor()}:${(wrSeconds % 60).toString().padLeft(2, '0')}" 
      : "--:--";

    final bool isFirstGlobal = summary.globalCompletionCount <= 1; // It includes current player
    final isNewRecord = wrSeconds == 0 || displayTime < wrSeconds || isFirstGlobal;
    
    final int fasterBy = avgSeconds - displayTime;
    final bool isFaster = fasterBy > 0;
    
    String? diffStr;
    if (!isFirstGlobal && avgSeconds > 0 && fasterBy != 0) {
      diffStr = isFaster 
        ? "${fasterBy}s faster than average!" 
        : "${fasterBy.abs()}s slower than average!";
    }

    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Stack(
          alignment: Alignment.center,
          children: [
            CandyDialog(
              title: 'VICTORY!',
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // PERSONAL TIME BLOCK
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              state.mode == GameMode.dailySeries ? "TOTAL SERIES TIME" : "YOUR TIME", 
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.candyGreenDark)
                            ),
                            Text(timeStr, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.candyGreenDark)),
                            
                            if (isNewRecord)
                              const Text("NEW WORLD RECORD!", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.orangeAccent))
                            else if (diffStr != null)
                              Text(
                                diffStr,
                                style: TextStyle(
                                  fontSize: 12, 
                                  fontWeight: FontWeight.bold, 
                                  color: isFaster ? Colors.green : Colors.redAccent
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // STATS BLOCK - Only show if not intermediate series level
                      if (state.mode != GameMode.dailySeries || widget.level == 3) ...[
                        // GLOBAL STATS BLOCK
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _buildStatBadge("GLOBAL AVG", avgTimeStr, Icons.public, Colors.blue)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatBadge("BEST TIME", "$wrTimeStr by ${summary.worldRecordHolder}", Icons.emoji_events, Colors.amber)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${summary.globalCompletionCount} players finished", style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                            if (summary.globalPercentile != null && summary.globalPercentile! <= 0.5 && summary.globalCompletionCount > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  "TOP ${max(1, (summary.globalPercentile! * 100).round())}%", 
                                  style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w900, fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 25),

                        // FRIENDS MINI LEADERBOARD
                        const Text("FRIENDS RANKING", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.candyPurple, fontSize: 14)),
                        const SizedBox(height: 8),
                        
                        if (summary.friendsMiniLeaderboard.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("You are the first of your friends!", style: TextStyle(fontSize: 12, color: Colors.black45, fontStyle: FontStyle.italic)),
                          )
                        else
                          ...summary.friendsMiniLeaderboard.map((e) => _buildFriendRankRow(e, playerId == e.playerId)),
                        
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => _showFullLeaderboard(context, playerId ?? ''),
                          child: const Text("VIEW FULL RANKINGS", style: TextStyle(color: AppColors.candyBlue, fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                      ],

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CandyButton(
                            width: 130, height: 55, color: AppColors.candyPink, darkColor: AppColors.candyPinkDark,
                            onPressed: () {
                              context.read<HomeBloc>().add(CompleteLevel(playerId: playerId));
                              Navigator.pop(dialogContext);
                              Navigator.pop(context);
                            },
                            child: const Text('HOME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                          ),
                          CandyButton(
                            width: 130, height: 55, color: AppColors.candyGreen, darkColor: AppColors.candyGreenDark,
                            onPressed: () {
                              if (widget.mode == GameMode.story) {
                                context.read<HomeBloc>().add(CompleteLevel(playerId: playerId));
                              }
                              Navigator.pop(dialogContext);
                              
                              if (widget.mode == GameMode.dailySeries && widget.level < 3) {
                                final nextLevel = widget.level + 1;
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GamePage(level: nextLevel, difficulty: widget.difficulty, mode: GameMode.dailySeries)));
                              } else if (widget.mode == GameMode.story) {
                                final nextLevel = widget.level + 1;
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GamePage(level: nextLevel, difficulty: widget.difficulty)));
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              (widget.mode == GameMode.dailySeries && widget.level < 3) || widget.mode == GameMode.story 
                                ? 'NEXT' 
                                : 'CLOSE', 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Confetti
            IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                createParticlePath: drawFireworkSparkle, 
                colors: const [Colors.yellow, Colors.white, Colors.amber, Colors.orangeAccent],
                numberOfParticles: 12,
                gravity: 0.1,
                minBlastForce: 15,
                maxBlastForce: 30,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatBadge(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildFriendRankRow(FriendRankEntry entry, bool isMe) {
    final minutes = (entry.timeSeconds / 60).floor();
    final seconds = (entry.timeSeconds % 60).toString().padLeft(2, '0');
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isMe ? AppColors.candyBlue.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isMe ? AppColors.candyBlue : Colors.black12),
      ),
      child: Row(
        children: [
          Text("#${entry.rank}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: entry.rank == 1 ? Colors.amber : Colors.grey)),
          const SizedBox(width: 10),
          Expanded(child: Text(entry.username, style: TextStyle(fontWeight: isMe ? FontWeight.w900 : FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis)),
          Text("$minutes:$seconds", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }

  void _showFullLeaderboard(BuildContext context, String playerId) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => BlocProvider.value(
        value: context.read<GameBloc>(),
        child: FriendsLeaderboardDialog(playerId: playerId),
      ),
    );
  }
}

class _HeadPainter extends CustomPainter {
  final bool isAngry;
  final double cellSize;

  _HeadPainter({required this.isAngry, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    final eyeSize = cellSize * 0.15;

    canvas.drawCircle(center + Offset(-eyeSize, -eyeSize / 2), eyeSize, eyePaint);
    canvas.drawCircle(center + Offset(eyeSize, -eyeSize / 2), eyeSize, eyePaint);
    canvas.drawCircle(center + Offset(-eyeSize, -eyeSize / 2), eyeSize / 2, pupilPaint);
    canvas.drawCircle(center + Offset(eyeSize, -eyeSize / 2), eyeSize / 2, pupilPaint);

    if (isAngry) {
      final angryPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center + Offset(-eyeSize * 2, -eyeSize * 2), center + Offset(-eyeSize * 0.5, -eyeSize), angryPaint);
      canvas.drawLine(center + Offset(eyeSize * 2, -eyeSize * 2), center + Offset(eyeSize * 0.5, -eyeSize), angryPaint);
      final mouthPaint = Paint()..color = Colors.red..style = PaintingStyle.stroke..strokeWidth = 3;
      final mouthPath = Path();
      mouthPath.moveTo(center.dx - eyeSize, center.dy + eyeSize);
      mouthPath.quadraticBezierTo(center.dx, center.dy, center.dx + eyeSize, center.dy + eyeSize);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      final mouthPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
      final mouthPath = Path();
      mouthPath.moveTo(center.dx - eyeSize, center.dy + eyeSize);
      mouthPath.quadraticBezierTo(center.dx, center.dy + eyeSize * 2, center.dx + eyeSize, center.dy + eyeSize);
      canvas.drawPath(mouthPath, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeadPainter oldDelegate) => oldDelegate.isAngry != isAngry || oldDelegate.cellSize != cellSize;
}

class PathLinePainter extends CustomPainter {
  final List<GridOffset> path;
  final double cellSize;
  final Color color;
  final bool isAngry;

  PathLinePainter({required this.path, required this.cellSize, required this.color, required this.isAngry});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;
    final paint = Paint()..color = color.withValues(alpha: 1.0)..strokeWidth = cellSize * 0.7..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
    final shadowPaint = Paint()..color = Colors.black26..strokeWidth = cellSize * 0.75..strokeCap = StrokeCap.round..style = PaintingStyle.stroke..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final uiPath = Path();
    final startOffset = Offset((path[0].col * cellSize) + (cellSize / 2), (path[0].row * cellSize) + (cellSize / 2));
    uiPath.moveTo(startOffset.dx, startOffset.dy);
    for (int i = 1; i < path.length; i++) {
      final pos = path[i];
      final nextOffset = Offset((pos.col * cellSize) + (cellSize / 2), (pos.row * cellSize) + (cellSize / 2));
      uiPath.lineTo(nextOffset.dx, nextOffset.dy);
    }
    canvas.drawPath(uiPath, shadowPaint);
    canvas.drawPath(uiPath, paint);
  }

  @override
  bool shouldRepaint(covariant PathLinePainter oldDelegate) => oldDelegate.path != path || oldDelegate.cellSize != cellSize || oldDelegate.color != color || oldDelegate.isAngry != isAngry;
}

class _WallPainter extends CustomPainter {
  final Set<String> walls;
  final double cellSize;

  _WallPainter({required this.walls, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (var wall in walls) {
      final parts = wall.split('-');
      final a = parts[0].split(',');
      final b = parts[1].split(',');
      final r1 = int.parse(a[0]);
      final c1 = int.parse(a[1]);
      final r2 = int.parse(b[0]);
      final c2 = int.parse(b[1]);

      if (r1 == r2) {
        final x = max(c1, c2) * cellSize;
        canvas.drawLine(
          Offset(x, r1 * cellSize),
          Offset(x, (r1 + 1) * cellSize),
          paint,
        );
      } else {
        final y = max(r1, r2) * cellSize;
        canvas.drawLine(
          Offset(c1 * cellSize, y),
          Offset((c1 + 1) * cellSize, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WallPainter oldDelegate) => oldDelegate.walls != walls;
}

Path drawFireworkSparkle(Size size) {
  final path = Path();
  final double halfWidth = size.width / 2;
  final double halfHeight = size.height / 2;
  path.moveTo(halfWidth, 0); 
  path.lineTo(halfWidth + size.width * 0.05, halfHeight - size.height * 0.05);
  path.lineTo(size.width, halfHeight); 
  path.lineTo(halfWidth + size.width * 0.05, halfHeight + size.height * 0.05);
  path.lineTo(halfWidth, size.height); 
  path.lineTo(halfWidth - size.width * 0.05, halfHeight + size.height * 0.05);
  path.lineTo(0, halfHeight); 
  path.lineTo(halfWidth - size.width * 0.05, halfHeight - size.height * 0.05);
  path.close();
  return path;
}
