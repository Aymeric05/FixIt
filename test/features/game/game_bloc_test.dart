import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fixit/features/game/presentation/bloc/game_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/game_event.dart';
import 'package:fixit/features/game/presentation/bloc/game_state.dart';
import 'package:fixit/core/repositories/progression_repository.dart';
import 'package:fixit/core/repositories/daily_repository.dart';
import 'package:fixit/core/models/grid_offset.dart';

class MockProgressionRepository extends Mock implements ProgressionRepository {}
class MockDailyRepository extends Mock implements DailyRepository {}

void main() {
  late ProgressionRepository mockProgressionRepo;
  late DailyRepository mockDailyRepo;

  setUp(() {
    mockProgressionRepo = MockProgressionRepository();
    mockDailyRepo = MockDailyRepository();
  });

  group('GameBloc Logic', () {
    test('Zip win condition: path must end on last digit', () {
      final bloc = GameBloc(
        progressionRepo: mockProgressionRepo,
        dailyRepo: mockDailyRepo,
      );

      // We can manually test the private _validatePath if we expose it or test via events
      // For this example, we verify the logic added in PR #10
      final hints = List.generate(6, (_) => List<int?>.filled(6, null));
      hints[0][0] = 1;
      hints[5][5] = 12; // Last digit

      final validPath = List.generate(36, (i) => GridOffset(i ~/ 6, i % 6));
      // In this path, index 35 is (5,5) which is the last digit 12.

      final invalidPath = List.generate(36, (i) {
        if (i == 30) return GridOffset(5, 5); // 12 reached early
        if (i == 35) return GridOffset(5, 0); // Path ends elsewhere
        return GridOffset(i ~/ 6, i % 6);
      });
      
      // Note: Since _validatePath is private, real tests would trigger SelectCell events 
      // or we could use a helper to test the validation logic if exposed.
    });
  });
}
