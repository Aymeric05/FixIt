import 'dart:async';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isDataLoading;
  final Duration duration;

  const LoadingScreen({
    super.key, 
    required this.onComplete, 
    this.isDataLoading = false,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  
  int _dotCount = 0;
  Timer? _dotTimer;
  bool _timerFinished = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Pre-cache background images to avoid flicker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/monde1_background.png'), context);
      precacheImage(const AssetImage('assets/images/loading_ecran.png'), context);
    });

    _progressController.forward().then((_) {
      setState(() => _timerFinished = true);
      _checkCompletion();
    });

    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });
  }

  @override
  void didUpdateWidget(LoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkCompletion();
  }

  void _checkCompletion() {
    // Only fade out and complete if BOTH:
    // 1. The progress bar reached 100% (_timerFinished)
    // 2. The app has finished loading data (!widget.isDataLoading)
    if (_timerFinished && !widget.isDataLoading && !_fadeController.isAnimating && _fadeController.value == 0) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _fadeController.forward().then((_) {
            widget.onComplete();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = "";
    if (_dotCount == 1) dots = ".";
    if (_dotCount == 2) dots = "..";
    if (_dotCount == 3) dots = "...";
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/loading_ecran.png',
                fit: BoxFit.cover,
              ),
            ),
            
            // Loading Bar at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: _buildLoadingBar(dots),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBar(String dots) {
    return Container(
      width: 320,
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF5D4037), // Dark brown background
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFF8D6E63), width: 3), // Wooden border
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          // Progress Fill
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: _progressController.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF8BC34A), Color(0xFF4CAF50)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              );
            },
          ),
          
          // Glossy highlight
          Positioned(
            left: 10,
            top: 6,
            child: Container(
              width: 40,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Loading Text
          Center(
            child: Text(
              "LOADING$dots",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 2,
                shadows: [
                  Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 1))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
