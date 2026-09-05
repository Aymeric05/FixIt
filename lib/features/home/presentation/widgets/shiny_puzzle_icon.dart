import 'package:flutter/material.dart';

class ShinyPuzzleIcon extends StatelessWidget {
  final double size;
  
  const ShinyPuzzleIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Drop Shadow for depth
        Icon(
          Icons.extension,
          size: size * 1.1,
          color: Colors.black.withValues(alpha: 0.5),
        ),
        // Glow effect (eclat)
        Icon(
          Icons.extension,
          size: size * 1.2,
          color: Colors.orange.withValues(alpha: 0.3),
        ),
        // Main icon with contrast
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.orangeAccent,
              Colors.orange,
              Color(0xFFCC7A00), // Darker orange for contrast
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ).createShader(bounds),
          child: Icon(
            Icons.extension,
            size: size,
            color: Colors.white,
          ),
        ),
        // Reflection (reflet)
        Positioned(
          top: size * 0.1,
          left: size * 0.2,
          child: Transform.rotate(
            angle: -0.5,
            child: Container(
              width: size * 0.4,
              height: size * 0.1,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
