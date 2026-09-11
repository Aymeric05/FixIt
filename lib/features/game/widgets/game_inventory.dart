import 'package:flutter/material.dart';
import 'package:fixit/core/theme/app_colors.dart';

class GameInventory extends StatelessWidget {
  final List<GameItemData> items;

  const GameInventory({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          final int idx = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(left: idx == 0 ? 0 : 25),
            child: _buildItemButton(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemButton(GameItemData item) {
    final bool canUse = item.count > 0 && !item.isUsed;

    return GestureDetector(
      onTap: canUse ? item.onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ColorFiltered(
            colorFilter: item.isUsed
                ? const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0, 0, 0, 1, 0,
                  ])
                : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [item.color.withValues(alpha: 0.8), item.color],
                  center: const Alignment(-0.3, -0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(item.icon, color: Colors.white, size: 30),
            ),
          ),
          // Inventory Badge
          Positioned(
            right: -8,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.candyPurple,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              constraints: const BoxConstraints(minWidth: 22),
              child: Text(
                "${item.count}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          if (item.isUsed)
            const Positioned(
              top: -5,
              left: -5,
              child: Icon(Icons.block, color: Colors.redAccent, size: 20),
            ),
        ],
      ),
    );
  }
}

class GameItemData {
  final IconData icon;
  final Color color;
  final int count;
  final bool isUsed;
  final VoidCallback onTap;

  const GameItemData({
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
    this.isUsed = false,
  });
}
