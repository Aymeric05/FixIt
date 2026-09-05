import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_state.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_event.dart';
import 'package:fixit/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fixit/features/profile/presentation/bloc/profile_event.dart';
import 'package:fixit/features/profile/presentation/bloc/profile_state.dart';
import 'package:fixit/core/utils/app_notifications.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_event.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_state.dart';
import 'package:fixit/features/friends/presentation/widgets/add_friend_dialog.dart';
import 'package:fixit/features/friends/presentation/widgets/friend_requests_dialog.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';

class ProfileModal extends StatefulWidget {
  final Player player;

  const ProfileModal({super.key, required this.player});

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  late TextEditingController _nicknameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.player.username);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null && mounted) {
      context.read<ProfileBloc>().add(UpdateAvatarRequested(pickedFile.path));
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdated) {
              setState(() => _isEditing = false);
              context.read<AuthBloc>().add(RefreshProfileRequested());
              if (state.newName != null) {
                AppNotifications.show(context, 'Nickname updated!');
              } else {
                AppNotifications.show(context, 'Avatar updated!');
              }
            } else if (state is ProfileError) {
              AppNotifications.show(context, state.message, isError: true);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 320,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
                decoration: BoxDecoration(
                  color: AppColors.dialogBackground,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: AppColors.candyPink, width: 6),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAvatarAndNickname(context),
                    const Divider(height: 30, color: Colors.black12, thickness: 2),
                    const Text(
                      'SOCIAL',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.candyPurple, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    _buildSocialSection(context),
                  ],
                ),
              ),
              _buildTitleBanner(),
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarAndNickname(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatarSection(context),
        const SizedBox(width: 15),
        Expanded(child: _buildNicknameSection()),
      ],
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final avatarUrl = (authState is AuthAuthenticated) ? authState.profile.avatarUrl : null;
        
        return GestureDetector(
          onTap: () => _showImageSourceActionSheet(context),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 80, // Reduced from 110
                height: 80, // Reduced from 110
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.candyBlue, width: 3),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, spreadRadius: 2)
                  ],
                ),
                child: ClipOval(
                  child: avatarUrl != null && File(avatarUrl).existsSync()
                      ? Image.file(
                          File(avatarUrl), 
                          fit: BoxFit.cover,
                          key: ValueKey(avatarUrl + DateTime.now().millisecondsSinceEpoch.toString()), // Force reload
                        )
                      : const Icon(Icons.person, size: 50, color: AppColors.candyBlue),
                ),
              ),
              // Pencil edit icon
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.candyGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNicknameSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String currentUsername = widget.player.username;
        if (authState is AuthAuthenticated) {
          currentUsername = authState.profile.username;
        }

        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: _isEditing ? const EdgeInsets.fromLTRB(16, 12, 16, 10) : const EdgeInsets.fromLTRB(16, 12, 16, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
                ],
                border: Border.all(
                  color: _isEditing ? AppColors.candyBlue : AppColors.candyBlue.withValues(alpha: 0.3), 
                  width: _isEditing ? 3 : 2
                ),
              ),
              child: _isEditing
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nicknameController,
                            autofocus: true,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(right: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            context.read<ProfileBloc>().add(
                                  UpdateNicknameRequested(_nicknameController.text),
                                );
                          },
                          child: const Icon(Icons.check, color: Colors.green, size: 14),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _isEditing = false),
                          child: const Icon(Icons.close, color: Colors.red, size: 14),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () => setState(() => _isEditing = true),
                      child: Text(
                        currentUsername,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildTitleBanner() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 55,
          width: 200,
          decoration: BoxDecoration(
            color: AppColors.candyBlueDark,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -5),
          child: Container(
            height: 50,
            width: 200,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [AppColors.candyBlue, AppColors.candyBlueDark],
                center: Alignment(-0.3, -0.3),
                radius: 0.8,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white, width: 3),
            ),
            alignment: Alignment.center,
            child: const Text(
              'SOCIAL',
              style: TextStyle(
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
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final String playerId = authState is AuthAuthenticated ? authState.user.id : '';

    if (playerId.isEmpty) {
      return const Center(child: Text('Please log in to see friends.'));
    }

    // Refresh friends list
    context.read<FriendsBloc>().add(LoadFriends(playerId));

    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
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
              const SizedBox(height: 15),
              Expanded(
                child: state.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : state.friends.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: EdgeInsets.zero,
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
              width: 55,
              height: 55,
              borderRadius: 27,
              color: color,
              darkColor: darkColor,
              onPressed: onTap,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            if (badgeCount > 0)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.candyPurple, shape: BoxShape.circle),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildFriendRow(BuildContext context, dynamic friend, String playerId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.candyBlue, 
            child: Icon(Icons.person, color: Colors.white, size: 20)
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              friend.friendUsername,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
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
          Icon(Icons.sentiment_dissatisfied, size: 40, color: Colors.black26),
          SizedBox(height: 5),
          Text('No friends yet.', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  void _openAddFriend(BuildContext context, String playerId) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => BlocProvider.value(
        value: context.read<FriendsBloc>(),
        child: AddFriendDialog(currentUserId: playerId),
      ),
    );
  }

  void _openRequests(BuildContext context, String playerId) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => BlocProvider.value(
        value: context.read<FriendsBloc>(),
        child: FriendRequestsDialog(playerId: playerId),
      ),
    );
  }

  void _confirmRemove(BuildContext context, dynamic friend, String playerId) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => CandyDialog(
        title: 'REMOVE?',
        content: Text(
          'Remove ${friend.friendUsername}?',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          CandyButton(
            width: 100,
            height: 45,
            color: Colors.grey,
            darkColor: Colors.grey.shade700,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          CandyButton(
            width: 100,
            height: 45,
            color: Colors.redAccent,
            darkColor: Colors.red.shade900,
            onPressed: () {
              context.read<FriendsBloc>().add(RemoveFriend(playerId: playerId, friendId: friend.friendId));
              Navigator.pop(ctx);
            },
            child: const Text('REMOVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      right: -10,
      top: -10,
      child: CandyButton(
        width: 40,
        height: 40,
        borderRadius: 20,
        depth: 3,
        color: Colors.redAccent,
        darkColor: Colors.red.shade900,
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(Icons.close, color: Colors.white, size: 24),
      ),
    );
  }
}
