import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/core/models/daily_mode.dart';
import 'package:fixit/core/utils/app_logger.dart';

class GameSessionRepository {
  AppDatabase get _db => DatabaseService().db;

  Future<void> saveSession({
    required String playerId,
    required String worldId,
    required int levelNumber,
    required GameMode mode,
    required int remainingSeconds,
    required List<GridOffset> currentPath,
  }) async {
    try {
      final pathJson = jsonEncode(currentPath.map((e) => {'r': e.row, 'c': e.col}).toList());
      final modeStr = mode.name;

      final companion = ActiveGameStatesCompanion.insert(
        playerSupabaseId: playerId,
        worldId: worldId,
        levelNumber: levelNumber,
        gameMode: modeStr,
        remainingSeconds: remainingSeconds,
        currentPathJson: pathJson,
        updatedAt: Value(DateTime.now()),
      );

      await _db.into(_db.activeGameStates).insert(
            companion,
            mode: InsertMode.insertOrReplace,
          );
    } catch (e) {
      AppLogger.error('Error saving game session', e);
    }
  }

  Future<ActiveGameState?> loadSession({
    required String playerId,
    required String worldId,
    required int levelNumber,
    required GameMode mode,
  }) async {
    try {
      final modeStr = mode.name;
      return await (_db.select(_db.activeGameStates)
            ..where((t) =>
                t.playerSupabaseId.equals(playerId) &
                t.worldId.equals(worldId) &
                t.levelNumber.equals(levelNumber) &
                t.gameMode.equals(modeStr)))
          .getSingleOrNull();
    } catch (e) {
      AppLogger.error('Error loading game session', e);
      return null;
    }
  }

  Future<void> deleteSession({
    required String playerId,
    required String worldId,
    required int levelNumber,
    required GameMode mode,
  }) async {
    try {
      final modeStr = mode.name;
      await (_db.delete(_db.activeGameStates)
            ..where((t) =>
                t.playerSupabaseId.equals(playerId) &
                t.worldId.equals(worldId) &
                t.levelNumber.equals(levelNumber) &
                t.gameMode.equals(modeStr)))
          .go();
    } catch (e) {
      AppLogger.error('Error deleting game session', e);
    }
  }
}
