import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/home/bloc/home_bloc.dart';
import 'package:fixit/features/home/widgets/candy_dialog.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/utils/app_logger.dart';
import 'package:fixit/core/widgets/candy_button.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _isResetting = false;

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
              
              if (_isResetting)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Colors.red),
                    SizedBox(height: 10),
                    Text('Wiping all data...', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                )
              else
                Column(
                  children: [
                    CandyButton(
                      width: 250,
                      height: 50,
                      color: state.isDebugLevelActive ? AppColors.candyGreen : Colors.grey,
                      darkColor: state.isDebugLevelActive ? AppColors.candyGreenDark : Colors.grey.shade700,
                      onPressed: () {
                         context.read<HomeBloc>().add(DebugSetLevel(10, isActive: !state.isDebugLevelActive));
                      },
                      child: Text(
                        state.isDebugLevelActive ? 'DEACTIVATE DEBUG' : 'DEBUG: UNLOCK LEVEL 10',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('HARD RESET'),
                            content: const Text('This will delete all local progress, social data, and logout. Are you sure?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('YES, RESET')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          setState(() => _isResetting = true);
                          try {
                            await DatabaseService().hardReset();
                            AppLogger.log('Reset complete, closing app in 1s...');
                            await Future.delayed(const Duration(seconds: 1));
                            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                            await Future.delayed(const Duration(seconds: 1));
                            exit(0);
                          } catch (e) {
                            AppLogger.error('Error during debug reset', e);
                            if (!context.mounted) return;
                            setState(() => _isResetting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Reset failed: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'RESET ALL DATA',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
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
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.candyBlue.withValues(alpha: 0.3), width: 3),
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
            Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                color: value ? AppColors.candyGreen : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
