import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/theme/app_theme.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/features/home/presentation/pages/home_page.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_bloc.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_event.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_event.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';

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
        BlocProvider(create: (context) => HomeBloc()..add(LoadHomeData())),
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
