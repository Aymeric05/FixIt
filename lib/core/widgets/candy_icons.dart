import 'package:flutter/material.dart';

class CandyIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const CandyIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          icon,
          size: size + 4,
          color: Colors.black26,
        ),
        Icon(
          icon,
          size: size,
          color: color,
        ),
        Positioned(
          top: 2,
          left: 2,
          child: Icon(
            icon,
            size: size * 0.5,
            color: Colors.white30,
          ),
        ),
      ],
    );
  }
}

class NoAdsIcon extends StatelessWidget {
  final double size;
  const NoAdsIcon({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.movie_creation_outlined,
      size: size,
      color: Colors.white,
    );
  }
}
