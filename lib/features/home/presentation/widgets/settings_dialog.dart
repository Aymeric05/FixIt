import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/services/database_service.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return CandyDialog(
          title: 'SETTINGS',
          content: Column(
            children: [
              _buildSettingRow(
                context,
                icon: state.isMusicEnabled ? Icons.music_note : Icons.music_off,
                label: 'Music',
                value: state.isMusicEnabled,
                onToggle: () => context.read<HomeBloc>().add(ToggleMusic()),
              ),
              const SizedBox(height: 16),
              _buildSettingRow(
                context,
                icon: state.isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                label: 'Sound Effects',
                value: state.isSoundEnabled,
                onToggle: () => context.read<HomeBloc>().add(ToggleSound()),
              ),
              const SizedBox(height: 30),
              // Debug Reset Button
              TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('HARD RESET'),
                      content: const Text('This will delete all local progress and logout. Are you sure?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('YES, RESET')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await DatabaseService().hardReset();
                    // Close the app automatically
                    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  }
                },
                child: const Text(
                  'DEBUG: RESET ALL DATA',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.candyBlue.withOpacity(0.3), width: 3),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.candyBlue, size: 35),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.candyPurple,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.candyGreen,
            activeTrackColor: AppColors.candyGreen.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
