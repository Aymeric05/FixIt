import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/features/game/meadow/bloc/meadow_game_bloc.dart';
import 'package:fixit/features/game/meadow/bloc/meadow_game_event.dart';
import 'package:fixit/features/game/meadow/bloc/meadow_game_state.dart';
import 'package:fixit/features/home/widgets/candy_dialog.dart';

class FriendsLeaderboardDialog extends StatelessWidget {
  final String playerId;
  const FriendsLeaderboardDialog({super.key, required this.playerId});

  @override
  Widget build(BuildContext context) {
    // Trigger load if not already loaded
    context.read<MeadowGameBloc>().add(LoadFriendsLeaderboard(playerId: playerId));

    return CandyDialog(
      title: 'RANKINGS',
      content: SizedBox(
        height: 350,
        width: 300,
        child: BlocBuilder<MeadowGameBloc, MeadowGameState>(
          builder: (context, state) {
            final list = state.friendsLeaderboard;
            if (list.isEmpty) {
              return const Center(child: Text('No friends ranked yet.'));
            }

            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = list[index];
                final isMe = entry.playerId == playerId;
                final minutes = (entry.timeSeconds / 60).floor();
                final seconds = (entry.timeSeconds % 60).toString().padLeft(2, '0');

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.candyBlue.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isMe ? AppColors.candyBlue : Colors.black12,
                      width: isMe ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text(
                          '#${entry.rank}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: entry.rank <= 3 ? Colors.amber : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.username,
                          style: TextStyle(
                            fontWeight: isMe ? FontWeight.w900 : FontWeight.bold,
                            color: isMe ? AppColors.candyBlue : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '$minutes:$seconds',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
