import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_event.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_state.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_state.dart';
import 'package:fixit/features/friends/presentation/widgets/add_friend_dialog.dart';
import 'package:fixit/features/friends/presentation/widgets/friend_requests_dialog.dart';

class SocialDialog extends StatelessWidget {
  const SocialDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final String playerId = authState is AuthAuthenticated ? authState.user.id : '';

    if (playerId.isEmpty) {
      return const CandyDialog(
        title: 'SOCIAL',
        content: Center(child: Text('Please log in to see friends.')),
      );
    }

    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        return CandyDialog(
          title: 'SOCIAL',
          content: SizedBox(
            height: 400,
            width: 300,
            child: Column(
              children: [
                // Action Buttons Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.person_add,
                      label: 'Add',
                      color: AppColors.candyGreen,
                      darkColor: AppColors.candyGreenDark,
                      onTap: () => _openAddFriend(context, playerId),
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.mail,
                      label: 'Requests',
                      color: AppColors.candyOrange,
                      darkColor: AppColors.candyOrangeDark,
                      badgeCount: state.incomingRequests.length,
                      onTap: () => _openRequests(context, playerId),
                    ),
                  ],
                ),
                const Divider(height: 30, color: Colors.black12, thickness: 2),
                const Text(
                  'MY FRIENDS',
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.candyPurple, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: state.isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : state.friends.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: state.friends.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final friend = state.friends[index];
                            return _buildFriendRow(context, friend, playerId);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color darkColor,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CandyButton(
              width: 60,
              height: 60,
              borderRadius: 30,
              color: color,
              darkColor: darkColor,
              onPressed: onTap,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            if (badgeCount > 0)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildFriendRow(BuildContext context, dynamic friend, String playerId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: AppColors.candyBlue, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.friendUsername,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: () => _confirmRemove(context, friend, playerId),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied, size: 50, color: Colors.black26),
          SizedBox(height: 10),
          Text('No friends yet.', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _openAddFriend(BuildContext context, String playerId) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<FriendsBloc>(),
        child: AddFriendDialog(currentUserId: playerId),
      ),
    );
  }

  void _openRequests(BuildContext context, String playerId) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<FriendsBloc>(),
        child: FriendRequestsDialog(playerId: playerId),
      ),
    );
  }

  void _confirmRemove(BuildContext context, dynamic friend, String playerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Friend?'),
        content: Text('Are you sure you want to remove ${friend.friendUsername}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<FriendsBloc>().add(RemoveFriend(playerId: playerId, friendId: friend.friendId));
    }
  }
}
