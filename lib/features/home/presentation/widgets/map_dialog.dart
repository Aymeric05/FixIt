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
        height: 450,
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
              // Parchment Background Image
              Positioned.fill(
                child: Image.asset(
                  'parchemin.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Invisible Clickable Worlds (Placeholders)
              // World 1 (Meadow) - Bottom Left
              Positioned(
                left: 30,
                bottom: 40,
                child: _buildWorldPoint(
                  context,
                  label: 'MEADOW WORLD',
                  isUnlocked: true,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),

              // Other Worlds (Locked for now)
              Positioned(
                right: 50,
                bottom: 80,
                child: _buildWorldPoint(context, label: 'LOCKED', isUnlocked: false),
              ),
              Positioned(
                top: 80,
                left: 60,
                child: _buildWorldPoint(context, label: 'LOCKED', isUnlocked: false),
              ),
              Positioned(
                top: 50,
                right: 40,
                child: _buildWorldPoint(context, label: 'LOCKED', isUnlocked: false),
              ),
              Positioned(
                top: 180,
                left: 150,
                child: _buildWorldPoint(context, label: 'LOCKED', isUnlocked: false),
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

  Widget _buildWorldPoint(BuildContext context, {required String label, required bool isUnlocked, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.transparent, // Invisible button area
              shape: BoxShape.circle,
            ),
          ),
          if (isUnlocked)
            Text(
              label,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                shadows: [Shadow(color: Colors.white, blurRadius: 4)],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildClouds() {
    return [
      _positionedCloud(top: -20, left: -20, size: 160),
      _positionedCloud(top: -10, right: -30, size: 180),
      _positionedCloud(top: 60, left: 120, size: 150),
      _positionedCloud(top: 140, left: -30, size: 170),
      _positionedCloud(top: 130, right: -10, size: 190),
      _positionedCloud(top: 180, left: 90, size: 140),
      _positionedCloud(bottom: -10, right: -10, size: 180),
      _positionedCloud(bottom: 70, right: 10, size: 140),
      _positionedCloud(bottom: 10, left: 130, size: 160),
      _positionedCloud(top: 250, left: 20, size: 150),
      _positionedCloud(top: 100, right: 80, size: 160),
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
