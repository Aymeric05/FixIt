import 'package:flutter/material.dart';
import '../../../../core/widgets/candy_button.dart';
import '../../../../core/theme/app_colors.dart';

/// Dialogue "Carte du Monde" : le parchemin est divisé en une grille
/// 3x3 (9 cases). Chaque case est soit un monde (recouvert de nuages
/// tant qu'il n'est pas débloqué), soit une case "mystère" (toujours
/// recouverte, futur monde non développé). La case du monde 1
/// (meadow, bas-gauche) n'est jamais recouverte.
class MapDialog extends StatelessWidget {
  final Set<String> unlockedWorldIds;
  final ValueChanged<String>? onWorldSelected;

  const MapDialog({
    super.key,
    this.unlockedWorldIds = const {'meadow'},
    this.onWorldSelected,
  });

  static const double _mapRatio = 1024 / 1536;

  // Marge fixe tout autour de la carte : les nuages ne dessinent JAMAIS
  // au-delà de cette zone, donc le contour du parchemin reste visible.
  static const double _marginX = 0.08;
  static const double _marginY = 0.06;

  static const List<_GridCell> _grid = [
    _GridCell(row: 0, col: 0, id: null, label: null),
    _GridCell(row: 0, col: 1, id: null, label: null),
    _GridCell(row: 0, col: 2, id: null, label: null),
    _GridCell(row: 1, col: 0, id: 'ice', label: 'ICE'),
    _GridCell(row: 1, col: 1, id: null, label: null),
    _GridCell(row: 1, col: 2, id: 'city', label: 'CITY'),
    _GridCell(row: 2, col: 0, id: 'meadow', label: 'MEADOW'),
    _GridCell(row: 2, col: 1, id: 'desert', label: 'DESERT'),
    _GridCell(row: 2, col: 2, id: 'volcano', label: 'VOLCANO'),
  ];

  bool _isUnlocked(String id) => unlockedWorldIds.contains(id);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 34),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: AspectRatio(
                aspectRatio: _mapRatio,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.55),
                        blurRadius: 26,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                        Size(constraints.maxWidth, constraints.maxHeight);
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset('parchemin.png',
                                  fit: BoxFit.cover),
                            ),
                            for (final cell in _grid)
                              if (cell.id != null)
                                _buildWorldButton(context, cell, size),
                            // Nuages, clippés strictement à la zone
                            // intérieure pour ne jamais déborder du bord
                            // visible du parchemin.
                            Positioned(
                              left: _marginX * size.width,
                              top: _marginY * size.height,
                              width: (1 - _marginX * 2) * size.width,
                              height: (1 - _marginY * 2) * size.height,
                              child: ClipRect(
                                child: OverflowBox(
                                  minWidth: 0,
                                  minHeight: 0,
                                  maxWidth: double.infinity,
                                  maxHeight: double.infinity,
                                  alignment: Alignment.topLeft,
                                  child: SizedBox(
                                    width: size.width,
                                    height: size.height,
                                    child: Stack(
                                      children: [
                                        for (final cell in _grid)
                                          if (cell.id != 'meadow' &&
                                              !(cell.id != null &&
                                                  _isUnlocked(cell.id!)))
                                            _buildCloudCell(cell, size),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildTitleBanner(),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Rect _cellRect(_GridCell cell) {
    final gridW = 1 - _marginX * 2;
    final gridH = 1 - _marginY * 2;
    final cellW = gridW / 3;
    final cellH = gridH / 3;
    return Rect.fromLTWH(
      _marginX + cell.col * cellW,
      _marginY + cell.row * cellH,
      cellW,
      cellH,
    );
  }

  Widget _buildWorldButton(BuildContext context, _GridCell cell, Size size) {
    final id = cell.id!;
    final unlocked = _isUnlocked(id);
    final rect = _cellRect(cell);
    final isMeadow = id == 'meadow';
    return Positioned(
      left: rect.left * size.width,
      top: rect.top * size.height,
      width: rect.width * size.width,
      height: rect.height * size.height,
      child: IgnorePointer(
        ignoring: isMeadow,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isMeadow
              ? null
              : () {
            if (unlocked) {
              Navigator.of(context).pop();
              onWorldSelected?.call(id);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFF5C3A21),
                  content: Text('🔒 Monde verrouillé',
                      textAlign: TextAlign.center),
                ),
              );
            }
          },
          child: Center(child: _worldLabel(cell.label!)),
        ),
      ),
    );
  }

  Widget _worldLabel(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 14,
        letterSpacing: 0.6,
        shadows: [
          Shadow(
              color: Colors.black.withOpacity(0.9),
              offset: const Offset(1, 1),
              blurRadius: 1),
          Shadow(
              color: Colors.black.withOpacity(0.9),
              offset: const Offset(-1, -1),
              blurRadius: 1),
          Shadow(
              color: Colors.black.withOpacity(0.9),
              offset: const Offset(1, -1),
              blurRadius: 1),
          Shadow(
              color: Colors.black.withOpacity(0.9),
              offset: const Offset(-1, 1),
              blurRadius: 1),
        ],
      ),
    );
  }

  /// Remplit une case avec 6 nuages ENTIERS (BoxFit.contain dans une
  /// boîte carrée -> jamais de recadrage) qui se superposent fortement
  /// pour ne laisser aucun trou. Le débordement vers les cases voisines
  /// est volontaire ; le ClipRect global (voir build()) garantit que
  /// rien ne dépasse le bord visible de la carte.
  Widget _buildCloudCell(_GridCell cell, Size size) {
    final rect = _cellRect(cell);
    final left = rect.left * size.width;
    final top = rect.top * size.height;
    final w = rect.width * size.width;
    final h = rect.height * size.height;
    final cx = left + w / 2;
    final cy = top + h / 2;
    final ref = w > h ? w : h; // dimension de référence pour la taille
    final idx = cell.row * 3 + cell.col;

    final specs = [
      _CloudSpec(dx: 0.0, dy: 0.0, size: 1.15, rot: 0.0),
      _CloudSpec(dx: -0.34, dy: -0.28, size: 0.85, rot: -0.12),
      _CloudSpec(dx: 0.32, dy: -0.26, size: 0.8, rot: 0.10),
      _CloudSpec(dx: -0.30, dy: 0.30, size: 0.8, rot: 0.08),
      _CloudSpec(dx: 0.34, dy: 0.28, size: 0.85, rot: -0.09),
      _CloudSpec(dx: 0.0, dy: -0.36, size: 0.6, rot: 0.05),
    ];

    return IgnorePointer(
      child: Stack(
        children: List.generate(specs.length, (i) {
          final spec = specs[i];
          final j = ((idx * 1.7 + i * 0.9) % 1);
          final scaleJ = 0.9 + j * 0.3; // variation de taille
          final rotJ = (j - 0.5) * 0.4;
          final box = ref * spec.size * scaleJ;
          final offX = (j - 0.5) * w * 0.08;
          final offY = ((j * 3.1) % 1 - 0.5) * h * 0.08;
          return Positioned(
            left: cx + spec.dx * w + offX - box / 2,
            top: cy + spec.dy * h + offY - box / 2,
            width: box,
            height: box,
            child: Transform.rotate(
              angle: spec.rot + rotJ,
              // BoxFit.contain dans une boîte carrée : l'image entière
              // est toujours affichée, jamais rognée, seulement mise
              // à l'échelle et centrée.
              child: Image.asset('nuages.png', fit: BoxFit.contain),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTitleBanner() {
    return Stack(
      children: [
        Container(
          height: 62,
          width: 250,
          decoration: BoxDecoration(
            color: AppColors.candyBlueDark,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -5),
          child: Container(
            height: 56,
            width: 250,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [AppColors.candyBlue, AppColors.candyBlueDark],
                center: Alignment(-0.3, -0.3),
                radius: 0.8,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 3),
            ),
            alignment: Alignment.center,
            child: const Text(
              'WORLD MAP',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
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
        width: 56,
        height: 56,
        borderRadius: 28,
        depth: 4,
        color: Colors.redAccent,
        darkColor: Colors.red.shade900,
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(Icons.close, color: Colors.white, size: 32),
      ),
    );
  }
}

class _GridCell {
  final int row;
  final int col;
  final String? id;
  final String? label;

  const _GridCell({required this.row, required this.col, this.id, this.label});
}

class _CloudSpec {
  final double dx, dy;
  final double size; // fraction de la dimension de référence de la case
  final double rot;

  const _CloudSpec({
    required this.dx,
    required this.dy,
    required this.size,
    required this.rot,
  });
}