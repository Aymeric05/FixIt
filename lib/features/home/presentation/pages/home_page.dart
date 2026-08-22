import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/main_play_button.dart';

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
                      const TopNavBar(),

                      // Title
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            const Text(
                              'WORLD 1',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(2, 2))],
                              ),
                            ),
                            Text(
                              'The Enchanted Prairie',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

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
