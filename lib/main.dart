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
import 'package:fixit/core/utils/app_logger.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    AppLogger.log('App starting...');
    // Initialize Databases
    final dbService = DatabaseService();
    await dbService.initialize();
    
    // Sync with server time to prevent cheating and handle midnight transitions
    await DailyRepository().syncWithServerTime();
    
    AppLogger.log('Databases initialized. Launching app...');
    
    runApp(const CandyPuzzleGame());
  } catch (e, stack) {
    AppLogger.error('CRITICAL ERROR DURING STARTUP', e, stack);
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
  bool _assetsPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_assetsPrecached) {
      _precacheAssets();
      _assetsPrecached = true;
    }
  }

  Future<void> _precacheAssets() async {
    final assets = [
      'monde1_background.png',
      'jeu_serpent_contour_pas_ouf.png',
      'buisson.png',
      'ciel.png',
      'world1.png',
      'world2.png',
      'world3.png',
      'world4.png',
      'world5.png',
    ];
    
    // Parallelize pre-caching
    await Future.wait([
      ...assets.map((asset) => precacheImage(AssetImage(asset), context).catchError((e) => AppLogger.error('Precache failed: $asset', e))),
      GoogleFonts.pendingFonts([
        GoogleFonts.luckiestGuy(),
      ]),
    ]);
  }

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
