import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_event.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_state.dart';

import 'package:fixit/core/utils/app_notifications.dart';

class FriendRequestsDialog extends StatelessWidget {
  final String playerId;
  const FriendRequestsDialog({super.key, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FriendsBloc, FriendsState>(
      listenWhen: (prev, curr) => (prev.successMessage != curr.successMessage && curr.successMessage != null) ||
                                (prev.error != curr.error && curr.error != null),
      listener: (context, state) {
        if (state.successMessage != null) {
          AppNotifications.show(context, state.successMessage!);
          context.read<FriendsBloc>().add(ClearSocialMessages());
        }
        if (state.error != null) {
          AppNotifications.show(context, state.error!, isError: true);
          context.read<FriendsBloc>().add(ClearSocialMessages());
        }
      },
      child: CandyDialog(
        title: 'REQUESTS',
        content: SizedBox(
          height: 400,
          width: 300,
          child: BlocBuilder<FriendsBloc, FriendsState>(
            builder: (context, state) {
              if (state.isLoading) return const Center(child: CircularProgressIndicator());
              if (state.incomingRequests.isEmpty) {
                return const Center(child: Text('No pending requests.', style: TextStyle(color: Colors.black45)));
              }
              return ListView.separated(
                itemCount: state.incomingRequests.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final request = state.incomingRequests[index];
                  return _buildRequestRow(context, request);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequestRow(BuildContext context, dynamic request) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: AppColors.candyOrange, child: Icon(Icons.mail, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Text(request.senderUsername, style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
            onPressed: () {
              context.read<FriendsBloc>().add(HandleRequest(
                requestId: request.id,
                playerId: playerId,
                accept: true,
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
            onPressed: () {
              context.read<FriendsBloc>().add(HandleRequest(
                requestId: request.id,
                playerId: playerId,
                accept: false,
              ));
            },
          ),
        ],
      ),
    );
  }
}
