import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/core/utils/level_generator.dart';
import 'dart:math';

void main() {
  group('LevelGenerator', () {
    test('generates a full 6x6 grid solution (36 cells)', () {
      final result = LevelGenerator.generate(12);
      expect(result.solution.length, 36);
      
      // Verify all cells are unique
      final uniqueCells = result.solution.toSet();
      expect(uniqueCells.length, 36);
    });

    test('respects the requested hint count', () {
      const hintCount = 8;
      final result = LevelGenerator.generate(hintCount);
      
      int actualHints = 0;
      for (var row in result.hints) {
        for (var cell in row) {
          if (cell != null) actualHints++;
        }
      }
      
      expect(actualHints, equals(hintCount));
    });

    test('always includes digit 1 as a hint', () {
      final result = LevelGenerator.generate(5);
      bool foundOne = false;
      for (var row in result.hints) {
        if (row.contains(1)) foundOne = true;
      }
      expect(foundOne, isTrue);
    });

    test('generates deterministic levels with a seed', () {
      final random1 = Random(42);
      final random2 = Random(42);
      
      final result1 = LevelGenerator.generate(10, random: random1);
      final result2 = LevelGenerator.generate(10, random: random2);
      
      expect(result1.solution, equals(result2.solution));
      expect(result1.hints, equals(result2.hints));
    });
  });
}
