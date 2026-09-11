import 'package:flutter/material.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fixit/features/home/widgets/candy_dialog.dart';

class MapDialog extends StatefulWidget {
  final Set<String> unlockedWorldIds;
  final ValueChanged<String>? onWorldSelected;
  final String currentWorldId;

  const MapDialog({
    super.key,
    this.unlockedWorldIds = const {'meadow'},
    this.onWorldSelected,
    this.currentWorldId = 'meadow',
  });

  @override
  State<MapDialog> createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  final List<WorldData> worlds = [
    WorldData(
      id: 'meadow', 
      name: 'Meadow', 
      asset: 'assets/images/world1.png', 
      color: Colors.green,
      previewText: "Connect the numbers to guide the serpent through the lush meadow!",
    ),
    WorldData(
      id: 'desert', 
      name: 'Desert', 
      asset: 'assets/images/world2.png', 
      color: Colors.orange,
      previewText: "Rotate the pipes to guide the water and restore the oasis!",
    ),
    WorldData(
      id: 'ice', 
      name: 'Ice', 
      asset: 'assets/images/world3.png', 
      color: Colors.blueAccent,
      previewText: "Slide through the frozen kingdom and solve icy puzzles!",
    ),
    WorldData(
      id: 'volcano', 
      name: 'Volcano', 
      asset: 'assets/images/world4.png', 
      color: Colors.red,
      previewText: "Navigate dangerous lava flows in the heart of the volcano!",
    ),
    WorldData(
      id: 'city', 
      name: 'City', 
      asset: 'assets/images/world5.png', 
      color: Colors.purple,
      previewText: "Restore power to the urban jungle and fix the city grid!",
    ),
  ];

  late final PageController _rollController;
  
  // For infinite scroll
  static const int _infiniteFactor = 10000;
  late int _currentRollIndex;

  @override
  void initState() {
    super.initState();
    final initialIndex = worlds.indexWhere((w) => w.id == widget.currentWorldId);
    _currentRollIndex = (initialIndex != -1) ? (_infiniteFactor ~/ 2 + initialIndex) : (_infiniteFactor ~/ 2);
    
    _rollController = PageController(
      viewportFraction: 0.6,
      initialPage: _currentRollIndex,
    );
  }

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  bool _isUnlocked(String id) => id == 'meadow' || widget.unlockedWorldIds.contains(id);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Body
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.candyPink, width: 8),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  // Background
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/ciel.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.lightBlue.shade100,
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 70, 0, 20),
                    child: _buildIslandsRoll(),
                  ),
                ],
              ),
            ),
          ),
          
          // Title Banner
          _buildTitleBanner(),
          
          // Close Button
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildIslandsRoll() {
    return PageView.builder(
      controller: _rollController,
      scrollDirection: Axis.vertical,
      onPageChanged: (page) => setState(() => _currentRollIndex = page),
      itemBuilder: (context, index) {
        final worldIndex = index % worlds.length;
        final world = worlds[worldIndex];
        final unlocked = _isUnlocked(world.id);
        
        return AnimatedBuilder(
          animation: _rollController,
          builder: (context, child) {
            double value = 1.0;
            if (_rollController.position.haveDimensions) {
              value = _rollController.page! - index;
              value = (1 - (value.abs() * 0.4)).clamp(0.0, 1.0);
            }
            return Center(
              child: Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Opacity(
                  opacity: value,
                  child: GestureDetector(
                    onTap: () {
                      if (unlocked) {
                        Navigator.of(context).pop();
                        widget.onWorldSelected?.call(world.id);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            ColorFiltered(
                              colorFilter: unlocked 
                                ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                                : const ColorFilter.matrix([
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0,      0,      0,      1, 0,
                                  ]),
                              child: Image.asset(
                                world.asset,
                                height: 200, 
                                fit: BoxFit.contain,
                              ),
                            ),
                            if (!unlocked) ...[
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.lock, color: Colors.white, size: 45),
                              ),
                              Positioned(
                                top: 0,
                                right: -10,
                                child: CandyButton(
                                  width: 44,
                                  height: 44,
                                  borderRadius: 22,
                                  color: AppColors.candyBlue,
                                  darkColor: AppColors.candyBlueDark,
                                  onPressed: () => _showPreview(world),
                                  child: Text(
                                    "?",
                                    style: GoogleFonts.luckiestGuy(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            world.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPreview(WorldData world) {
    showDialog(
      context: context,
      builder: (ctx) => CandyDialog(
        title: world.name.toUpperCase(),
        content: Column(
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  world.asset,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              world.previewText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          CandyButton(
            width: 150,
            height: 50,
            color: AppColors.candyGreen,
            darkColor: AppColors.candyGreenDark,
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "GOT IT!",
              style: GoogleFonts.luckiestGuy(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBanner() {
    return Stack(
      children: [
        Container(
          height: 65,
          width: 240,
          decoration: BoxDecoration(
            color: AppColors.candyBlueDark,
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -6),
          child: Container(
            height: 60,
            width: 240,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [AppColors.candyBlue, AppColors.candyBlueDark],
                center: Alignment(-0.3, -0.3),
                radius: 0.8,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white, width: 4),
            ),
            alignment: Alignment.center,
            child: const Text(
              'WORLD MAP',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      right: -10,
      top: -10,
      child: CandyButton(
        width: 52,
        height: 52,
        borderRadius: 26,
        depth: 4,
        color: Colors.redAccent,
        darkColor: Colors.red.shade900,
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(Icons.close, color: Colors.white, size: 30),
      ),
    );
  }
}

class WorldData {
  final String id;
  final String name;
  final String asset;
  final Color color;
  final String previewText;

  WorldData({
    required this.id, 
    required this.name, 
    required this.asset,
    required this.color,
    required this.previewText,
  });
}
