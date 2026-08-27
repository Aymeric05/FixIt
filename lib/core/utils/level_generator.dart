import 'dart:math';
import 'package:fixit/core/models/grid_offset.dart';

class LevelGenerator {
  static ({
    List<List<int?>> hints,
    List<GridOffset> solution,
    Map<GridOffset, int> hintSteps,
    Set<String> walls
  }) generate(int hintsCount) {
    final List<GridOffset>? solution = _generateHamiltonianPath();
    final finalSolution = solution ?? _generateSnakePath();

    final hints = List.generate(6, (_) => List<int?>.generate(6, (_) => null));
    final Map<GridOffset, int> hintSteps = {};
    
    final random = Random();
    final Set<int> indices = {0, 35}; 
    
    while (indices.length < hintsCount) {
      indices.add(random.nextInt(36));
    }

    final sortedIndices = indices.toList()..sort();
    for (int i = 0; i < sortedIndices.length; i++) {
      final stepIndex = sortedIndices[i];
      final pos = finalSolution[stepIndex];
      hints[pos.row][pos.col] = i + 1;
      hintSteps[pos] = stepIndex;
    }

    final Set<String> walls = {};
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        final current = GridOffset(r, c);
        final neighbors = [GridOffset(r + 1, c), GridOffset(r, c + 1)];
        for (var neighbor in neighbors) {
          if (neighbor.row < 6 && neighbor.col < 6) {
            if (!_areConsecutive(current, neighbor, finalSolution)) {
              if (random.nextDouble() < 0.2) {
                final list = [current.toString(), neighbor.toString()]..sort();
                walls.add('${list[0]}-${list[1]}');
              }
            }
          }
        }
      }
    }

    return (hints: hints, solution: finalSolution, hintSteps: hintSteps, walls: walls);
  }

  static bool _areConsecutive(GridOffset a, GridOffset b, List<GridOffset> path) {
    final idxA = path.indexOf(a);
    final idxB = path.indexOf(b);
    return (idxA - idxB).abs() == 1;
  }

  static List<GridOffset> _generateSnakePath() {
    final List<GridOffset> path = [];
    for (int r = 0; r < 6; r++) {
      if (r % 2 == 0) {
        for (int c = 0; c < 6; c++) path.add(GridOffset(r, c));
      } else {
        for (int c = 5; c >= 0; c--) path.add(GridOffset(r, c));
      }
    }
    return path;
  }

  static List<GridOffset>? _generateHamiltonianPath() {
    final random = Random();
    final startRow = random.nextInt(6);
    final startCol = random.nextInt(6);
    final path = [GridOffset(startRow, startCol)];
    final visited = List.generate(6, (_) => List<bool>.generate(6, (_) => false));
    visited[startRow][startCol] = true;

    if (_solvePath(path, visited, random)) return path;
    return null;
  }

  static bool _solvePath(List<GridOffset> path, List<List<bool>> visited, Random random) {
    if (path.length == 36) return true;
    final last = path.last;
    final neighbors = [
      GridOffset(last.row + 1, last.col), GridOffset(last.row - 1, last.col),
      GridOffset(last.row, last.col + 1), GridOffset(last.row, last.col - 1),
    ];
    neighbors.shuffle(random);
    for (var neighbor in neighbors) {
      if (neighbor.row >= 0 && neighbor.row < 6 && neighbor.col >= 0 && neighbor.col < 6 && !visited[neighbor.row][neighbor.col]) {
        visited[neighbor.row][neighbor.col] = true;
        path.add(neighbor);
        if (_solvePath(path, visited, random)) return true;
        path.removeLast();
        visited[neighbor.row][neighbor.col] = false;
      }
    }
    return false;
  }
}
