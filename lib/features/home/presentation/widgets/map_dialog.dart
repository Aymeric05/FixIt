import 'package:flutter/material.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/core/theme/app_colors.dart';

class MapDialog extends StatefulWidget {
  final Set<String> unlockedWorldIds;
  final ValueChanged<String>? onWorldSelected;

  const MapDialog({
    super.key,
    this.unlockedWorldIds = const {'meadow'},
    this.onWorldSelected,
  });

  @override
  State<MapDialog> createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  final List<WorldData> worlds = [
    WorldData(id: 'meadow', name: 'Meadow', asset: 'world1.png', color: Colors.green),
    WorldData(id: 'desert', name: 'Desert', asset: 'world2.png', color: Colors.orange),
    WorldData(id: 'ice', name: 'Ice', asset: 'world3.png', color: Colors.blueAccent),
    WorldData(id: 'volcano', name: 'Volcano', asset: 'world4.png', color: Colors.red),
    WorldData(id: 'city', name: 'City', asset: 'world5.png', color: Colors.purple),
  ];

  late final PageController _rollController;
  int _viewMode = 0; // 0: Roll, 1: Path
  
  // For infinite scroll
  static const int _infiniteFactor = 10000;
  late int _currentRollIndex;

  @override
  void initState() {
    super.initState();
    _currentRollIndex = _infiniteFactor ~/ 2;
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

  bool _isUnlocked(String id) => widget.unlockedWorldIds.contains(id);

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
                      'ciel.png',
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
                    child: Column(
                      children: [
                        // Tabs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTab(0, 'ISLANDS'),
                            const SizedBox(width: 30),
                            _buildTab(1, 'MAP PATH'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Switchable Views
                        Expanded(
                          child: _viewMode == 0 ? _buildIslandsRoll() : _buildPathView(),
                        ),
                      ],
                    ),
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

  Widget _buildTab(int mode, String label) {
    final active = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: active ? Colors.white : Colors.white60,
              fontSize: 16,
              letterSpacing: 1.2,
              shadows: active ? [const Shadow(color: Colors.black45, blurRadius: 4)] : null,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 4,
            width: 50,
            decoration: BoxDecoration(
              color: active ? AppColors.candyPink : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: active ? [const BoxShadow(color: Colors.black26, blurRadius: 2)] : null,
            ),
          ),
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
                                height: 200, // Enlarged
                                fit: BoxFit.contain,
                              ),
                            ),
                            if (!unlocked)
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.lock, color: Colors.white, size: 45),
                              ),
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

  Widget _buildPathView() {
    final hasWorld4 = worlds.length > 3;
    final hasWorld5 = worlds.length > 4;
    final hasWorld6 = worlds.length > 5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Row 2: (6) -- 5 -- 4
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEmptyNode(),
              hasWorld6 ? _buildDashedLine() : const SizedBox(width: 40),
              _buildPathIsland(4), // World 5
              hasWorld5 ? _buildDashedLine() : const SizedBox(width: 40),
              _buildPathIsland(3), // World 4
            ],
          ),
          // Vertical connector on the RIGHT (between 3 and 4)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 85), // island 6
              const SizedBox(width: 40), // line
              const SizedBox(width: 85), // island 5
              const SizedBox(width: 40), // line
              hasWorld4 ? _buildVerticalDashedLine() : const SizedBox(width: 85, height: 40),
            ],
          ),
          // Row 1: 1 -- 2 -- 3
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPathIsland(0), // World 1
              worlds.length > 1 ? _buildDashedLine() : const SizedBox(width: 40),
              _buildPathIsland(1), // World 2
              worlds.length > 2 ? _buildDashedLine() : const SizedBox(width: 40),
              _buildPathIsland(2), // World 3
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPathIsland(int index) {
    if (index >= worlds.length) return _buildEmptyNode();
    final world = worlds[index];
    final unlocked = _isUnlocked(world.id);

    return GestureDetector(
      onTap: () {
        if (unlocked) {
          Navigator.of(context).pop();
          widget.onWorldSelected?.call(world.id);
        }
      },
      child: SizedBox(
        width: 85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
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
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                if (!unlocked)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, color: Colors.white, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              "${index + 1}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNode() {
    return const SizedBox(width: 85, height: 85);
  }

  Widget _buildDashedLine() {
    const dashColor = Color(0xFF8D6E63); // Slightly browner
    return SizedBox(
      width: 40,
      height: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) => Container(
          width: 8,
          height: 4,
          decoration: BoxDecoration(
            color: dashColor,
            borderRadius: BorderRadius.circular(2),
          ),
        )),
      ),
    );
  }

  Widget _buildVerticalDashedLine() {
    return SizedBox(
      width: 85,
      height: 40,
      child: Center(
        child: RotatedBox(
          quarterTurns: 1,
          child: _buildDashedLine(),
        ),
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

  WorldData({
    required this.id, 
    required this.name, 
    required this.asset,
    required this.color,
  });
}