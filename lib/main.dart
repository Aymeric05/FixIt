import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const CandyPuzzleGame());
}

class CandyPuzzleGame extends StatelessWidget {
  const CandyPuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade600,
          secondary: Colors.orangeAccent,
        ),
        textTheme: GoogleFonts.fredokaTextTheme(),
        useMaterial3: true,
      ),
      home: const WorldMapScreen(),
    );
  }
}

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Custom Background Image
          Positioned.fill(
            child: Image.asset(
              'monde1_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const PrairieBackground(); // Fallback if image not found
              },
            ),
          ),

          // Top Header
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MONDE 1',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 4),
                          ),
                          Shadow(
                            blurRadius: 2,
                            color: Colors.green.shade900,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'La Prairie Enchantée',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top Right Action Buttons
          Positioned(
            top: 50,
            right: 20,
            child: Column(
              children: [
                const MenuButton(
                  icon: Icons.settings,
                  color: Colors.blueGrey,
                  label: 'Paramètres',
                ),
                const SizedBox(height: 16),
                const MenuButton(
                  icon: Icons.calendar_today_rounded,
                  color: Colors.deepPurpleAccent,
                  label: 'Défi Quotidien',
                  isDaily: true,
                ),
              ],
            ),
          ),

          // Bottom Play Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade800.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                      ],
                    ),
                    child: const Text(
                      'JOUER NIVEAU 1',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const LevelButton(level: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isDaily;

  const MenuButton({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    this.isDaily = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isDaily ? 'Ouverture du défi quotidien...' : 'Ouverture des paramètres...'),
                backgroundColor: color,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        if (isDaily)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'NEW',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}

class PrairieBackground extends StatelessWidget {
  const PrairieBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlue.shade200,
            Colors.green.shade300,
            Colors.green.shade500,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Stack(
        children: List.generate(15, (index) {
          final top = (index * 70.0) % MediaQuery.of(context).size.height;
          final left = (index * 50.0) % MediaQuery.of(context).size.width;
          return Positioned(
            top: top,
            left: left,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.eco,
                size: 40 + (index % 3) * 10,
                color: Colors.green.shade900,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LevelButton extends StatefulWidget {
  final int level;
  const LevelButton({super.key, required this.level});

  @override
  State<LevelButton> createState() => _LevelButtonState();
}

class _LevelButtonState extends State<LevelButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chargement du niveau ${widget.level}...'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Colors.orangeAccent, Colors.deepOrange],
              center: Alignment(-0.2, -0.2),
              radius: 0.8,
            ),
            boxShadow: [
              const BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 8),
                blurRadius: 10,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                offset: const Offset(-3, -3),
                blurRadius: 6,
              ),
            ],
            border: Border.all(color: Colors.white, width: 5),
          ),
          child: Center(
            child: Text(
              '${widget.level}',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black38,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
