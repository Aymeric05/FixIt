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
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'ADS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          Transform.rotate(
            angle: -0.78,
            child: Container(
              width: size * 0.8,
              height: 4,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
