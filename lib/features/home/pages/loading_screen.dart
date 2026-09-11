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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressController.forward().then((_) {
      _startFadeOut();
    });

    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });
  }

  void _startFadeOut() {
    if (!mounted) return;
    _fadeController.forward().then((_) {
      widget.onComplete();
    });
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
            Positioned.fill(
              child: Image.asset(
                'assets/images/loading_ecran.png',
                fit: BoxFit.cover,
              ),
            ),
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
        color: const Color(0xFF5D4037),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFF8D6E63), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
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
