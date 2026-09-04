import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/core/repositories/daily_repository.dart';
import 'package:fixit/core/utils/level_generator.dart';
import 'dart:math';

void main() {
  late DailyRepository repository;

  setUp(() {
    repository = DailyRepository();
  });

  group('DailyRepository', () {
    test('generateDailyLevel produces deterministic results for the same date', () {
      // We simulate two generations for the same date
      // Note: Today's date is calculated inside the repo, so we just check consistency
      final level1 = repository.generateDailyLevel(worldLevel: 1, isSeries: false);
      final level2 = repository.generateDailyLevel(worldLevel: 1, isSeries: false);

      expect(level1.solution, equals(level2.solution));
      expect(level1.hints, equals(level2.hints));
    });

    test('generateDailyLevel produces different results for different world levels in series', () {
      final level1 = repository.generateDailyLevel(worldLevel: 1, isSeries: true);
      final level2 = repository.generateDailyLevel(worldLevel: 2, isSeries: true);

      expect(level1.solution, isNot(equals(level2.solution)));
    });
  });
}
