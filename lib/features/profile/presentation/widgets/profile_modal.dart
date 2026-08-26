import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/candy_button.dart';
import 'package:fixit/core/database/app_database.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

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
              // Refresh Auth state to update the header
              context.read<AuthBloc>().add(AuthCheckRequested());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nickname updated!')),
              );
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
                width: 300,
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.dialogBackground,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.candyOrange, width: 4),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 16),
                    _buildNicknameSection(),
                    const SizedBox(height: 12),
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

  Widget _buildAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.candyBlue.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.candyBlue, width: 3),
      ),
      child: const Icon(Icons.person, size: 50, color: AppColors.candyBlue),
    );
  }

  Widget _buildNicknameSection() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (_isEditing) {
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nicknameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  context.read<ProfileBloc>().add(
                    UpdateNicknameRequested(_nicknameController.text),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => setState(() => _isEditing = false),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Nickname: ${widget.player.username}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dialogTitle,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => setState(() => _isEditing = true),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleBanner() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 50,
          width: 180,
          decoration: BoxDecoration(
            color: AppColors.candyOrangeDark,
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -4),
          child: Container(
            height: 46,
            width: 180,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [AppColors.candyOrange, AppColors.candyOrangeDark],
                center: Alignment(-0.3, -0.3),
                radius: 0.8,
              ),
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: Colors.white, width: 2),
            ),
            alignment: Alignment.center,
            child: const Text(
              'PROFILE',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
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
