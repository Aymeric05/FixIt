import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/services/database_service.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/lives/presentation/bloc/lives_bloc.dart';
import 'features/lives/presentation/bloc/lives_event.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Databases
  final dbService = DatabaseService();
  await dbService.initialize();
  
  runApp(const CandyPuzzleGame());
}

class CandyPuzzleGame extends StatelessWidget {
  const CandyPuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LivesBloc()..add(LoadLives())),
        BlocProvider(create: (context) => AuthBloc()..add(AuthCheckRequested())),
      ],
      child: MaterialApp(
        title: 'Puzzle Quest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}
