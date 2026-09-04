import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fixit/features/game/presentation/bloc/game_bloc.dart';
import 'package:fixit/features/game/presentation/bloc/game_event.dart';
import 'package:fixit/features/game/presentation/bloc/game_state.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/core/repositories/progression_repository.dart';
import 'package:fixit/core/repositories/daily_repository.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/core/models/daily_mode.dart';

class MockProgressionRepository extends Mock implements ProgressionRepository {}
class MockDailyRepository extends Mock implements DailyRepository {}

void main() {
  late ProgressionRepository mockProgressionRepo;
  late DailyRepository mockDailyRepo;

  setUp(() {
    mockProgressionRepo = MockProgressionRepository();
    mockDailyRepo = MockDailyRepository();
    
    when(() => mockDailyRepo.generateDailyLevel(
      worldLevel: any(named: 'worldLevel'),
      isSeries: any(named: 'isSeries'),
    )).thenReturn((
      hints: List.generate(6, (_) => List<int?>.filled(6, null)),
      solution: List.generate(36, (i) => GridOffset(i ~/ 6, i % 6)),
      walls: <String>{},
    ));

    when(() => mockDailyRepo.getDailyStatus(any())).thenAnswer((_) async => null);
  });

  group('GameBloc Regression Tests', () {
    blocTest<GameBloc, GameState>(
      'starts game correctly and sets initial state',
      build: () => GameBloc(progressionRepo: mockProgressionRepo, dailyRepo: mockDailyRepo),
      act: (bloc) => bloc.add(const StartGame(
        level: 1,
        difficulty: GameDifficulty.easy,
        playerId: 'player-1',
        mode: GameMode.dailySingle,
      )),
      verify: (bloc) {
        expect(bloc.state.status, equals(GameStatus.playing));
        expect(bloc.state.levelNumber, equals(1));
        expect(bloc.state.currentPath, isEmpty);
      },
    );

    blocTest<GameBloc, GameState>(
      'cell selection: only adjacent cells can be added',
      build: () => GameBloc(progressionRepo: mockProgressionRepo, dailyRepo: mockDailyRepo),
      seed: () {
        final hints = List.generate(6, (_) => List<int?>.filled(6, null));
        hints[0][0] = 1;
        return GameState(
          status: GameStatus.playing,
          hints: hints,
          currentPath: [const GridOffset(0, 0)],
          walls: {},
        );
      },
      act: (bloc) {
        bloc.add(const SelectCell(0, 2)); // Not adjacent
        bloc.add(const SelectCell(0, 1)); // Adjacent
      },
      expect: () => [
        isA<GameState>().having((s) => s.currentPath, 'path', [const GridOffset(0, 0), const GridOffset(0, 1)]),
      ],
    );

    blocTest<GameBloc, GameState>(
      'walls: prevents moving through a bush',
      build: () => GameBloc(progressionRepo: mockProgressionRepo, dailyRepo: mockDailyRepo),
      seed: () {
        final hints = List.generate(6, (_) => List<int?>.filled(6, null));
        hints[0][0] = 1;
        return GameState(
          status: GameStatus.playing,
          hints: hints,
          currentPath: [const GridOffset(0, 0)],
          walls: {'0,0-0,1'},
        );
      },
      act: (bloc) => bloc.add(const SelectCell(0, 1)),
      expect: () => [],
    );

    blocTest<GameBloc, GameState>(
      'Angry Snake: becomes angry when sequence is broken',
      build: () => GameBloc(progressionRepo: mockProgressionRepo, dailyRepo: mockDailyRepo),
      seed: () {
        final hints = List.generate(6, (_) => List<int?>.filled(6, null));
        hints[0][0] = 1;
        hints[0][2] = 3;
        return GameState(
          status: GameStatus.playing,
          hints: hints,
          currentPath: [const GridOffset(0, 0), const GridOffset(0, 1)],
          walls: {},
        );
      },
      act: (bloc) => bloc.add(const SelectCell(0, 2)),
      expect: () => [
        isA<GameState>().having((s) => s.isAngry, 'angry', isTrue),
      ],
    );
  });
}
