import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/main_play_button.dart';
import '../../../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeData()),
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'monde1_background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.lightBlue, Colors.green],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main UI
            SafeArea(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header Section
                      TopNavBar(
                        lives: state.lives,
                        maxLives: state.maxLives,
                      ),

                      // Middle Section (Empty for now, can be world elements)
                      const Spacer(),

                      // Bottom Section
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60.0),
                        child: MainPlayButton(
                          level: state.currentLevel,
                          difficulty: state.difficulty,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
