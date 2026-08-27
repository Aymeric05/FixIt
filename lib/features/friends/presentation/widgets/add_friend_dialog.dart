import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_event.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_state.dart';

class AddFriendDialog extends StatefulWidget {
  final String currentUserId;
  const AddFriendDialog({super.key, required this.currentUserId});

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FriendsBloc, FriendsState>(
      listenWhen: (prev, curr) => prev.successMessage != curr.successMessage && curr.successMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.candyGreen),
        );
      },
      child: CandyDialog(
        title: 'ADD FRIEND',
        content: SizedBox(
          height: 400,
          width: 300,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) => context.read<FriendsBloc>().add(SearchPlayers(val, widget.currentUserId)),
                decoration: InputDecoration(
                  hintText: 'Search pseudo...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<FriendsBloc, FriendsState>(
                  builder: (context, state) {
                    if (state.isLoading) return const Center(child: CircularProgressIndicator());
                    if (state.searchResults.isEmpty) {
                      return const Center(child: Text('Search for a player by pseudo', style: TextStyle(color: Colors.black45)));
                    }
                    return ListView.separated(
                      itemCount: state.searchResults.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final player = state.searchResults[index];
                        return _buildResultRow(context, player);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, Map<String, dynamic> player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(child: Text(player['username'], style: const TextStyle(fontWeight: FontWeight.bold))),
          CandyButton(
            width: 80,
            height: 40,
            borderRadius: 10,
            color: AppColors.candyBlue,
            darkColor: AppColors.candyBlueDark,
            onPressed: () {
              context.read<FriendsBloc>().add(SendRequest(
                senderId: widget.currentUserId,
                receiverId: player['id'],
              ));
            },
            child: const Text('ADD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
