import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';
import 'package:fixit/features/home/presentation/widgets/lives_store_dialog.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';

class NoLivesDialog extends StatefulWidget {
  const NoLivesDialog({super.key});

  @override
  State<NoLivesDialog> createState() => _NoLivesDialogState();
}

class _NoLivesDialogState extends State<NoLivesDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CandyDialog(
      title: 'OUT OF LIVES',
      content: Column(
        children: [
          const SizedBox(height: 10),
          ScaleTransition(
            scale: _scaleAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.favorite_border, color: Colors.red.shade200, size: 120),
                const Icon(Icons.heart_broken, color: Colors.redAccent, size: 80),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "OH NO! YOU'RE OUT OF LIVES!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.candyPurple,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Wait for a refill or get more now to keep playing!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          CandyButton(
            width: 240,
            height: 60,
            borderRadius: 30,
            color: Colors.redAccent,
            darkColor: Colors.red.shade900,
            onPressed: () {
              Navigator.pop(context); // Close this dialog
              showDialog(
                context: context,
                builder: (dialogContext) => BlocProvider.value(
                  value: BlocProvider.of<HomeBloc>(context),
                  child: const LivesStoreDialog(),
                ),
              );
            },
            child: const FittedBox(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'GET MORE LIVES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
