import 'package:flutter/material.dart';
import 'candy_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/candy_button.dart';

class MapDialog extends StatelessWidget {
  const MapDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CandyDialog(
      title: 'WORLD MAP',
      content: Container(
        height: 380,
        width: 340,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              // Parchment Image
              Positioned.fill(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Image.asset(
                    'parchemin.avif',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // World 1 Button (Bottom Left)
              Positioned(
                left: 20,
                bottom: 30,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'WORLD 1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'MEADOW',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Cloud Fog (Scattered on everything EXCEPT World 1 zone)
              Positioned.fill(
                child: ClipPath(
                  clipper: _CloudHoleClipper(),
                  child: Stack(
                    children: _buildClouds(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildClouds() {
    return [
      _positionedCloud(top: -10, left: -10, size: 150),
      _positionedCloud(top: -20, right: -20, size: 180),
      _positionedCloud(top: 60, left: 120, size: 140),
      _positionedCloud(top: 140, left: -30, size: 160),
      _positionedCloud(top: 130, right: -10, size: 170),
      _positionedCloud(top: 180, left: 90, size: 150),
      _positionedCloud(bottom: -10, right: -10, size: 180),
      _positionedCloud(bottom: 70, right: 10, size: 140),
      _positionedCloud(bottom: 10, left: 130, size: 160),
    ];
  }

  Widget _positionedCloud({double? top, double? left, double? right, double? bottom, required double size}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Image.asset(
          'nuages.png',
          width: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _CloudHoleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: Offset(65, size.height - 75), radius: 65))
      ..fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 5; i++) {
      final path = Path()
        ..moveTo(0, size.height * (0.2 + i * 0.15))
        ..quadraticBezierTo(size.width * 0.5, size.height * (0.1 + i * 0.15), size.width, size.height * (0.3 + i * 0.15));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
