import 'dart:convert';
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
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/repositories/game_session_repository.dart';

class MockProgressionRepository extends Mock implements ProgressionRepository {}
class MockDailyRepository extends Mock implements DailyRepository {}
class MockGameSessionRepository extends Mock implements GameSessionRepository {}

void main() {
  late ProgressionRepository mockProgressionRepo;
  late DailyRepository mockDailyRepo;
  late GameSessionRepository mockSessionRepo;

  setUpAll(() {
    registerFallbackValue(GameMode.story);
  });

  setUp(() {
    mockProgressionRepo = MockProgressionRepository();
    mockDailyRepo = MockDailyRepository();
    mockSessionRepo = MockGameSessionRepository();
    
    when(() => mockDailyRepo.generateDailyLevel(
      worldLevel: any(named: 'worldLevel'),
      isSeries: any(named: 'isSeries'),
    )).thenReturn((
      hints: List.generate(6, (_) => List<int?>.filled(6, null)),
      solution: List.generate(36, (i) => GridOffset(i ~/ 6, i % 6)),
      walls: <String>{},
    ));

    when(() => mockDailyRepo.getDailyStatus(any())).thenAnswer((_) async => null);
    when(() => mockDailyRepo.getTodayWorldId()).thenReturn('daily_today');
    when(() => mockDailyRepo.getTodaySeriesWorldId()).thenReturn('series_today');

    when(() => mockSessionRepo.loadSession(
          playerId: any(named: 'playerId'),
          worldId: any(named: 'worldId'),
          levelNumber: any(named: 'levelNumber'),
          mode: any(named: 'mode'),
        )).thenAnswer((_) async => null);
    
    when(() => mockSessionRepo.saveSession(
      playerId: any(named: 'playerId'),
      worldId: any(named: 'worldId'),
      levelNumber: any(named: 'levelNumber'),
      mode: any(named: 'mode'),
      remainingSeconds: any(named: 'remainingSeconds'),
      currentPath: any(named: 'currentPath'),
    )).thenAnswer((_) async => {});

    when(() => mockSessionRepo.deleteSession(
      playerId: any(named: 'playerId'),
      worldId: any(named: 'worldId'),
      levelNumber: any(named: 'levelNumber'),
      mode: any(named: 'mode'),
    )).thenAnswer((_) async => {});

    // Background stubs
    when(() => mockProgressionRepo.ensureNextLevelsExist(any(), any())).thenAnswer((_) async => {});
    when(() => mockProgressionRepo.saveGlobalLevel(
      worldId: any(named: 'worldId'),
      levelNumber: any(named: 'levelNumber'),
      hints: any(named: 'hints'),
      walls: any(named: 'walls'),
      solution: any(named: 'solution'),
    )).thenAnswer((_) async => {});
    
    when(() => mockProgressionRepo.getGlobalLevel(any(), any())).thenAnswer((_) async => null);
    when(() => mockProgressionRepo.grantLevel1Reward(any())).thenAnswer((_) async => {});
  });

  group('GameBloc Regression Tests', () {
    blocTest<GameBloc, GameState>(
      'starts game correctly and sets initial state',
      build: () => GameBloc(
        progressionRepo: mockProgressionRepo,
        dailyRepo: mockDailyRepo,
        sessionRepo: mockSessionRepo,
      ),
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
      build: () => GameBloc(
        progressionRepo: mockProgressionRepo,
        dailyRepo: mockDailyRepo,
        sessionRepo: mockSessionRepo,
      ),
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
      build: () => GameBloc(
        progressionRepo: mockProgressionRepo,
        dailyRepo: mockDailyRepo,
        sessionRepo: mockSessionRepo,
      ),
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
      build: () => GameBloc(
        progressionRepo: mockProgressionRepo,
        dailyRepo: mockDailyRepo,
        sessionRepo: mockSessionRepo,
      ),
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

    blocTest<GameBloc, GameState>(
      'Dragging on body makes snake angry but does not reset position',
      build: () => GameBloc(
        progressionRepo: mockProgressionRepo,
        dailyRepo: mockDailyRepo,
        sessionRepo: mockSessionRepo,
      ),
      seed: () {
        final hints = List.generate(6, (_) => List<int?>.filled(6, null));
        hints[0][0] = 1;
        return GameState(
          status: GameStatus.playing,
          hints: hints,
          currentPath: [const GridOffset(0, 0), const GridOffset(0, 1), const GridOffset(0, 2)],
          walls: {},
        );
      },
      act: (bloc) => bloc.add(const SelectCell(0, 1, isDrag: true)),
      expect: () => [
        isA<GameState>()
          .having((s) => s.isAngry, 'angry', isTrue)
          .having((s) => s.currentPath.length, 'path length', 3),
      ],
    );

    blocTest<GameBloc, GameState>(
      'Tapping on body resets position',
      build: () => GameBloc(
        progressionRepo: mockProgressionRepo,
        dailyRepo: mockDailyRepo,
        sessionRepo: mockSessionRepo,
      ),
      seed: () {
        final hints = List.generate(6, (_) => List<int?>.filled(6, null));
        hints[0][0] = 1;
        return GameState(
          status: GameStatus.playing,
          hints: hints,
          currentPath: [const GridOffset(0, 0), const GridOffset(0, 1), const GridOffset(0, 2)],
          walls: {},
        );
      },
      act: (bloc) => bloc.add(const SelectCell(0, 1, isDrag: false)),
      expect: () => [
        isA<GameState>()
          .having((s) => s.currentPath.length, 'path length', 2),
      ],
    );

    blocTest<GameBloc, GameState>(
      'session restoration: loads saved path and time on start',
      build: () {
        // Specifically stub loadSession for this test
        when(() => mockSessionRepo.loadSession(
              playerId: any(named: 'playerId'),
              worldId: any(named: 'worldId'),
              levelNumber: any(named: 'levelNumber'),
              mode: any(named: 'mode'),
            )).thenAnswer((_) async => ActiveGameState(
              id: 1,
              playerSupabaseId: 'player-1',
              worldId: 'world_1',
              levelNumber: 1,
              gameMode: 'story',
              remainingSeconds: 150,
              currentPathJson: '[{"r":0,"c":0},{"r":0,"c":1}]',
              updatedAt: DateTime.now(),
            ));
        return GameBloc(
          progressionRepo: mockProgressionRepo,
          dailyRepo: mockDailyRepo,
          sessionRepo: mockSessionRepo,
        );
      },
      act: (bloc) => bloc.add(const StartGame(
        level: 1,
        difficulty: GameDifficulty.easy,
        playerId: 'player-1',
        mode: GameMode.story,
      )),
      verify: (bloc) {
        expect(bloc.state.remainingSeconds, equals(150));
        expect(bloc.state.currentPath, hasLength(2));
        expect(bloc.state.currentPath.first, equals(const GridOffset(0, 0)));
      },
    );
  });
}
