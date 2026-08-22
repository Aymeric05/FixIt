import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/lives/presentation/bloc/lives_bloc.dart';
import 'features/lives/presentation/bloc/lives_event.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const CandyPuzzleGame());
}

class CandyPuzzleGame extends StatelessWidget {
  const CandyPuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LivesBloc()..add(LoadLives()),
      child: MaterialApp(
        title: 'Puzzle Quest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}
