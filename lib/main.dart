import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/theme/app_theme.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/features/home/presentation/pages/home_page.dart';
import 'package:fixit/features/home/presentation/pages/loading_screen.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_bloc.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_event.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_event.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:fixit/core/repositories/daily_repository.dart';

void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    print('App starting...');
    // Initialize Databases
    final dbService = DatabaseService();
    await dbService.initialize();
    
    // Sync with server time to prevent cheating and handle midnight transitions
    await DailyRepository().syncWithServerTime();
    
    print('Databases initialized. Launching app...');
    
    runApp(const CandyPuzzleGame());
  } catch (e, stack) {
    print('CRITICAL ERROR DURING STARTUP: $e');
    print(stack);
    // Even if it fails, try to run something to avoid white screen
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Fatal Error: $e'),
        ),
      ),
    ));
  }
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
        BlocProvider(create: (context) => FriendsBloc()),
      ],
      child: MaterialApp(
        title: 'Puzzle Quest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: _AppStartupWrapper(),
      ),
    );
  }
}

class _AppStartupWrapper extends StatefulWidget {
  @override
  State<_AppStartupWrapper> createState() => _AppStartupWrapperState();
}

class _AppStartupWrapperState extends State<_AppStartupWrapper> {
  bool _loadingAnimationDone = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (!_loadingAnimationDone) {
          return LoadingScreen(
            isDataLoading: state.isLoading,
            onComplete: () {
              setState(() {
                _loadingAnimationDone = true;
              });
            },
          );
        }
        return const HomePage();
      },
    );
  }
}
