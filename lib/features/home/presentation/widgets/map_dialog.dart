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
        height: 400, // Reduced height
        width: 340,
        decoration: BoxDecoration(
          color: const Color(0xFFF4E4BC), // Parchment base
          borderRadius: BorderRadius.circular(25),
          image: const DecorationImage(
            image: NetworkImage('https://www.transparenttextures.com/patterns/parchment.png'),
            repeat: ImageRepeat.repeat,
            opacity: 0.5,
          ),
          border: Border.all(color: const Color(0xFF5D4037), width: 8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            children: [
              // Hand-drawn Map Style Elements (Simulated)
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapPainter(),
                ),
              ),
              
              // Scrollable Worlds
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildWorldNode(
                      context,
                      index: 1,
                      name: 'Meadow',
                      color: Colors.green.shade700,
                      isUnlocked: true,
                    ),
                    _buildWorldNode(
                      context,
                      index: 2,
                      name: 'Cloud City',
                      color: Colors.blue.shade400,
                      isUnlocked: false,
                    ),
                    _buildWorldNode(
                      context,
                      index: 3,
                      name: 'Candy Cave',
                      color: Colors.purple.shade600,
                      isUnlocked: false,
                    ),
                  ],
                ),
              ),
              
              // Thick Fog on edges/locked areas (Simulated)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 150,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.95),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorldNode(
    BuildContext context, {
    required int index,
    required String name,
    required Color color,
    required bool isUnlocked,
  }) {
    return Container(
      width: 220, // Smaller width
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: isUnlocked ? () {
              // Navigation logic
              Navigator.of(context).pop();
            } : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // World Illustration Container (Smaller circle)
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: isUnlocked ? color : Colors.grey.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF8D6E63), width: 5),
                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isUnlocked) ...[
                        const Icon(Icons.terrain, color: Colors.white, size: 40),
                        const SizedBox(height: 4),
                        Text(
                          'WORLD $index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ] else ...[
                        const Icon(Icons.cloud, color: Colors.white, size: 60),
                      ],
                    ],
                  ),
                ),
                
                // Thick Mist for locked worlds
                if (!isUnlocked)
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.lock, color: Color(0xFF5D4037), size: 30),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          if (!isUnlocked)
            Text(
              'LOCKED',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Colors.grey.shade700,
                shadows: const [Shadow(color: Colors.white, offset: Offset(1, 1))],
              ),
            ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw some "old map" lines
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
