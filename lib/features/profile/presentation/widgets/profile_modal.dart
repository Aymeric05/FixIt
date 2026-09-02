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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nickname updated!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avatar updated!')),
                );
              }
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
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
                    _buildAvatarSection(context),
                    const SizedBox(height: 30),
                    _buildNicknameSection(),
                    const SizedBox(height: 20),
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
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.candyBlue, width: 4),
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
                      : const Icon(Icons.person, size: 70, color: AppColors.candyBlue),
                ),
              ),
              // Pencil edit icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.candyGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
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
            return Column(
              children: [
                const Text(
                  "Pseudo :",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.candyPurple,
                  ),
                ),
                const SizedBox(height: 10),
                if (_isEditing)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.candyBlue, width: 2),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nicknameController,
                            autofocus: true,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<ProfileBloc>().add(
                                  UpdateNicknameRequested(_nicknameController.text),
                                );
                          },
                          child: const Icon(Icons.check, color: Colors.green),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() => _isEditing = false),
                          child: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => setState(() => _isEditing = true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
                        ],
                        border: Border.all(color: AppColors.candyBlue.withValues(alpha: 0.3), width: 2),
                      ),
                      child: Text(
                        currentUsername,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(Icons.videogame_asset, widget.player.totalGamesPlayed.toString(), "GAMES"),
          Container(width: 2, height: 30, color: Colors.white),
          _buildStatItem(Icons.emoji_events, widget.player.highscore.toString(), "BEST"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.candyPurple, size: 24),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.candyPurple),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      ],
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
              'PROFIL',
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
