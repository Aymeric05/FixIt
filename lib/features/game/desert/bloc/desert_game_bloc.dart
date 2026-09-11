import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/game/desert/bloc/desert_game_event.dart';
import 'package:fixit/features/game/desert/bloc/desert_game_state.dart';
import 'package:fixit/core/repositories/progression_repository.dart';
import 'package:fixit/core/repositories/daily_repository.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:fixit/core/utils/app_logger.dart';
import 'package:fixit/core/models/daily_mode.dart';

class DesertGameBloc extends Bloc<DesertGameEvent, DesertGameState> {
  Timer? _timer;
  final _progressionRepo = ProgressionRepository();
  final _dailyRepo = DailyRepository();
  String? _playerId;

  DesertGameBloc() : super(const DesertGameState()) {
    on<StartDesertGame>(_onStartDesertGame);
    on<RotateTile>(_onRotateTile);
    on<DesertTimerTick>(_onDesertTimerTick);
    on<UseWaterBucket>(_onUseWaterBucket);
    on<UseGoldenWrench>(_onUseGoldenWrench);
    on<UseSandShovel>(_onUseSandShovel);
    on<PauseDesertTimer>(_onPauseDesertTimer);
    on<ResumeDesertTimer>(_onResumeDesertTimer);
  }

  Future<void> _onStartDesertGame(StartDesertGame event, Emitter<DesertGameState> emit) async {
    _timer?.cancel();
    _playerId = event.playerId;

    final grid = _generateGrid(event.level);
    final initialSeconds = 120 + (event.level * 5); 

    emit(state.copyWith(
      status: DesertGameStatus.playing,
      grid: grid,
      remainingSeconds: initialSeconds,
      initialSeconds: initialSeconds,
      levelNumber: event.level,
      mode: event.mode,
      invWaterBucket: event.invWaterBucket,
      invGoldenWrench: event.invGoldenWrench,
      invSandShovel: event.invSandShovel,
    ));

    _updateWaterFlow(emit);
    _startTimer(initialSeconds);
  }

  void _onRotateTile(RotateTile event, Emitter<DesertGameState> emit) {
    if (state.status != DesertGameStatus.playing) return;
    final tile = state.grid[event.row][event.col];
    if (tile.isFixed || tile.hasSandStorm || tile.type == DesertTileType.empty) return;

    final newRotation = (tile.rotation + 1) % 4;
    final newGrid = state.grid.map((row) => List<DesertTile>.from(row)).toList();
    newGrid[event.row][event.col] = tile.copyWith(rotation: newRotation);

    emit(state.copyWith(grid: newGrid));
    _updateWaterFlow(emit);
    _checkWin(emit);
  }

  void _updateWaterFlow(Emitter<DesertGameState> emit) {
    final grid = state.grid.map((row) => List<DesertTile>.from(row)).toList();
    for (var row in grid) {
      for (int i = 0; i < row.length; i++) {
        row[i] = row[i].copyWith(isWatered: row[i].type == DesertTileType.source);
      }
    }

    final queue = <Point<int>>[];
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        if (grid[r][c].type == DesertTileType.source) queue.add(Point(r, c));
      }
    }

    final visited = <Point<int>>{};
    while (queue.isNotEmpty) {
      final curr = queue.removeAt(0);
      if (visited.contains(curr)) continue;
      visited.add(curr);

      final r = curr.x;
      final c = curr.y;
      final neighbors = [
        Point(r - 1, c),
        Point(r + 1, c),
        Point(r, c - 1),
        Point(r, c + 1),
      ];

      for (var next in neighbors) {
        if (next.x < 0 || next.x >= 6 || next.y < 0 || next.y >= 6) continue;
        if (visited.contains(next)) continue;

        if (_canConnect(curr, next, grid)) {
          grid[next.x][next.y] = grid[next.x][next.y].copyWith(isWatered: true);
          queue.add(next);
        }
      }
    }

    emit(state.copyWith(grid: grid));
  }

  bool _canConnect(Point<int> a, Point<int> b, List<List<DesertTile>> grid) {
    final tileA = grid[a.x][a.y];
    final tileB = grid[b.x][b.y];
    if (tileA.type == DesertTileType.empty || tileB.type == DesertTileType.empty) return false;
    final dr = b.x - a.x;
    final dc = b.y - a.y;
    return _hasOpening(tileA, dr, dc) && _hasOpening(tileB, -dr, -dc);
  }

  bool _hasOpening(DesertTile tile, int dr, int dc) {
    if (tile.type == DesertTileType.source || tile.type == DesertTileType.sink || tile.type == DesertTileType.cross) return true;
    final rot = tile.rotation;
    if (tile.type == DesertTileType.straight) {
      if (rot == 0 || rot == 2) return dc != 0;
      return dr != 0;
    }
    if (tile.type == DesertTileType.elbow) {
      if (rot == 0) return (dr == -1 && dc == 0) || (dr == 0 && dc == 1);
      if (rot == 1) return (dr == 0 && dc == 1) || (dr == 1 && dc == 0);
      if (rot == 2) return (dr == 1 && dc == 0) || (dr == 0 && dc == -1);
      if (rot == 3) return (dr == 0 && dc == -1) || (dr == -1 && dc == 0);
    }
    return false;
  }

  Future<void> _checkWin(Emitter<DesertGameState> emit) async {
    bool allCactiWatered = true;
    for (var row in state.grid) {
      for (var tile in row) {
        if (tile.type == DesertTileType.sink && !tile.isWatered) {
          allCactiWatered = false;
          break;
        }
      }
    }

    if (allCactiWatered) {
      _timer?.cancel();
      final timeTaken = max(1, state.initialSeconds - state.remainingSeconds);
      final worldId = state.mode == FixItGameMode.story ? 'desert' : _dailyRepo.getTodayWorldId();
      
      if (state.mode != FixItGameMode.story && _playerId != null) {
        if (state.mode == FixItGameMode.dailySingle) {
          await _dailyRepo.updateDailyStatus(playerId: _playerId!, isDailyLevelCompleted: true, dailyLevelTime: timeTaken);
          await _progressionRepo.markLevelAsCompleted(playerSupabaseId: _playerId!, worldId: worldId, levelNumber: state.levelNumber, timeSeconds: timeTaken, updateProgression: false);
        } else if (state.mode == FixItGameMode.dailySeries) {
          await _dailyRepo.updateDailyStatus(playerId: _playerId!, seriesCurrentLevel: state.levelNumber, seriesAccumulatedTime: timeTaken, isSeriesCompleted: state.levelNumber >= 3);
          await _progressionRepo.markLevelAsCompleted(playerSupabaseId: _playerId!, worldId: _dailyRepo.getTodaySeriesWorldId(), levelNumber: state.levelNumber, timeSeconds: timeTaken, updateProgression: false);
        }
      }
      emit(state.copyWith(status: DesertGameStatus.won));
    }
  }

  List<List<DesertTile>> _generateGrid(int level) {
    final rand = Random();
    final grid = List.generate(6, (_) => List.generate(6, (_) => const DesertTile(type: DesertTileType.empty)));
    grid[0][rand.nextInt(6)] = const DesertTile(type: DesertTileType.source, isFixed: true, isWatered: true);
    for (int i = 0; i < 3; i++) {
      int r = rand.nextInt(4) + 2;
      int c = rand.nextInt(6);
      if (grid[r][c].type == DesertTileType.empty) {
        grid[r][c] = const DesertTile(type: DesertTileType.sink, isFixed: true);
      } else {
        i--;
      }
    }
    final types = [DesertTileType.straight, DesertTileType.elbow, DesertTileType.cross];
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        if (grid[r][c].type == DesertTileType.empty) {
          grid[r][c] = DesertTile(type: types[rand.nextInt(types.length)], rotation: rand.nextInt(4), hasSandStorm: rand.nextDouble() < 0.1);
        }
      }
    }
    return grid;
  }

  void _startTimer(int seconds) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = seconds - timer.tick;
      if (remaining <= 0) {
        _timer?.cancel();
        add(const DesertTimerTick(0));
      } else {
        add(DesertTimerTick(remaining));
      }
    });
  }

  void _onDesertTimerTick(DesertTimerTick event, Emitter<DesertGameState> emit) {
    if (event.remainingSeconds == 0) {
      emit(state.copyWith(remainingSeconds: 0, status: DesertGameStatus.lost));
    } else {
      emit(state.copyWith(remainingSeconds: event.remainingSeconds));
    }
  }

  Future<void> _onUseWaterBucket(UseWaterBucket event, Emitter<DesertGameState> emit) async {
    if (state.invWaterBucket <= 0) return;
    _timer?.cancel();
    final newTime = state.remainingSeconds + 60;
    emit(state.copyWith(remainingSeconds: newTime, invWaterBucket: state.invWaterBucket - 1));
    _startTimer(newTime);
    _updateLocalInventory('item_water_bucket', state.invWaterBucket - 1);
  }

  void _onUseGoldenWrench(UseGoldenWrench event, Emitter<DesertGameState> emit) {
    if (state.invGoldenWrench <= 0) return;
    final grid = state.grid.map((row) => List<DesertTile>.from(row)).toList();
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        if (!grid[r][c].isFixed && !grid[r][c].isWatered && grid[r][c].type != DesertTileType.empty) {
           grid[r][c] = grid[r][c].copyWith(isWatered: true); 
           emit(state.copyWith(grid: grid, invGoldenWrench: state.invGoldenWrench - 1));
           _updateWaterFlow(emit);
           _updateLocalInventory('item_golden_wrench', state.invGoldenWrench - 1);
           return;
        }
      }
    }
  }

  void _onUseSandShovel(UseSandShovel event, Emitter<DesertGameState> emit) {
    if (state.invSandShovel <= 0) return;
    final grid = state.grid.map((row) => List<DesertTile>.from(row)).toList();
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        grid[r][c] = grid[r][c].copyWith(hasSandStorm: false);
      }
    }
    emit(state.copyWith(grid: grid, invSandShovel: state.invSandShovel - 1));
    _updateLocalInventory('item_sand_shovel', state.invSandShovel - 1);
  }

  void _onPauseDesertTimer(PauseDesertTimer event, Emitter<DesertGameState> emit) {
    _timer?.cancel();
  }

  void _onResumeDesertTimer(ResumeDesertTimer event, Emitter<DesertGameState> emit) {
    _timer?.cancel();
    _startTimer(state.remainingSeconds);
  }

  Future<void> _updateLocalInventory(String field, int newValue) async {
    final db = DatabaseService().db;
    if (field == 'item_water_bucket') {
      await (db.update(db.players)..where((t) => t.id.isNotNull())).write(PlayersCompanion(itemWaterBucket: drift.Value(newValue)));
    } else if (field == 'item_golden_wrench') {
      await (db.update(db.players)..where((t) => t.id.isNotNull())).write(PlayersCompanion(itemGoldenWrench: drift.Value(newValue)));
    } else if (field == 'item_sand_shovel') {
      await (db.update(db.players)..where((t) => t.id.isNotNull())).write(PlayersCompanion(itemSandShovel: drift.Value(newValue)));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
