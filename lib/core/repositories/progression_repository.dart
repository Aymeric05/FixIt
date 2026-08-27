import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/core/utils/level_generator.dart';

class ProgressionRepository {
  final _supabase = DatabaseService().supabase;
  final _db = DatabaseService().db;

  Future<GlobalLevel?> getGlobalLevel(String worldId, int levelNumber) async {
    final local = await (_db.select(_db.globalLevels)
          ..where((t) => t.worldId.equals(worldId) & t.levelNumber.equals(levelNumber)))
        .getSingleOrNull();
    if (local != null) return local;

    try {
      final response = await _supabase
          .from('global_levels')
          .select()
          .eq('world_id', worldId)
          .eq('level_number', levelNumber)
          .maybeSingle();

      if (response != null) {
        final companion = GlobalLevelsCompanion.insert(
          worldId: worldId,
          levelNumber: levelNumber,
          hintsJson: jsonEncode(response['hints_json']),
          wallsJson: jsonEncode(response['walls_json']),
          solutionJson: jsonEncode(response['solution_json']),
        );
        
        await _db.into(_db.globalLevels).insert(
          companion,
          onConflict: DoUpdate((old) => companion, target: [_db.globalLevels.worldId, _db.globalLevels.levelNumber]),
        );
        
        return await (_db.select(_db.globalLevels)
              ..where((t) => t.worldId.equals(worldId) & t.levelNumber.equals(levelNumber)))
            .getSingle();
      }
    } catch (e) {
      print('Error fetching global level from Supabase: $e');
    }
    return null;
  }

  Future<void> saveGlobalLevel({
    required String worldId,
    required int levelNumber,
    required List<List<int?>> hints,
    required Set<String> walls,
    required List<GridOffset> solution,
  }) async {
    final hintsData = hints;
    final wallsData = walls.toList();
    final solutionData = solution.map((e) => {'r': e.row, 'c': e.col}).toList();

    try {
      await _supabase.from('global_levels').upsert({
        'world_id': worldId,
        'level_number': levelNumber,
        'hints_json': hintsData,
        'walls_json': wallsData,
        'solution_json': solutionData,
      }, onConflict: 'world_id,level_number');
      print('Synced global level $levelNumber to Supabase.');
    } catch (e) {
      print('Error saving global level to Supabase: $e');
    }

    final companion = GlobalLevelsCompanion.insert(
      worldId: worldId,
      levelNumber: levelNumber,
      hintsJson: jsonEncode(hintsData),
      wallsJson: jsonEncode(wallsData),
      solutionJson: jsonEncode(solutionData),
    );

    await _db.into(_db.globalLevels).insert(
      companion,
      onConflict: DoUpdate((old) => companion, target: [_db.globalLevels.worldId, _db.globalLevels.levelNumber]),
    );
  }

  Future<void> ensureNextLevelsExist(String worldId, int currentLevel) async {
    for (int i = 1; i <= 2; i++) {
      final levelNum = currentLevel + i;
      final existing = await getGlobalLevel(worldId, levelNum);
      if (existing == null) {
        print('Background Pre-generating level $levelNum...');
        final result = LevelGenerator.generate(12);
        await saveGlobalLevel(
          worldId: worldId,
          levelNumber: levelNum,
          hints: result.hints,
          walls: result.walls,
          solution: result.solution,
        );
      }
    }
  }

  Future<void> markLevelAsCompleted({
    required String playerSupabaseId,
    required String worldId,
    required int levelNumber,
    required int timeSeconds,
  }) async {
    // 1. Fetch current progress to avoid downgrades
    final currentProg = await (_db.select(_db.progressions)
          ..where((t) => t.playerSupabaseId.equals(playerSupabaseId)))
        .getSingleOrNull();
    
    final int nextLevelToSave = levelNumber + 1;
    final bool shouldUpdateProgression = currentProg == null || nextLevelToSave > currentProg.currentLevel;

    try {
      // 2. Save completion record to Supabase
      await _supabase.from('level_completions').upsert({
        'player_id': playerSupabaseId,
        'world_id': worldId,
        'level_number': levelNumber,
        'completion_time_seconds': timeSeconds,
      }, onConflict: 'player_id,world_id,level_number');

      // 3. Update main progression on Supabase ONLY if it's a new level
      if (shouldUpdateProgression) {
        await _supabase.from('progression').upsert({
          'player_id': playerSupabaseId,
          'current_level': nextLevelToSave,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'player_id');
        print('Synced progression for Level $nextLevelToSave to Supabase.');
      }
    } catch (e) {
      print('Error saving completion to Supabase: $e');
    }

    // 4. Save to local Drift completion (Using explicit conflict target)
    final completionCompanion = LevelCompletionsCompanion.insert(
      playerSupabaseId: playerSupabaseId,
      worldId: worldId,
      levelNumber: levelNumber,
      completionTimeSeconds: timeSeconds,
    );
    
    await _db.into(_db.levelCompletions).insert(
      completionCompanion,
      onConflict: DoUpdate((old) => completionCompanion, target: [
        _db.levelCompletions.playerSupabaseId,
        _db.levelCompletions.worldId,
        _db.levelCompletions.levelNumber
      ]),
    );

    // 5. Update local Drift progression
    if (shouldUpdateProgression) {
      final progressionCompanion = ProgressionsCompanion.insert(
        playerSupabaseId: Value(playerSupabaseId),
        currentLevel: Value(nextLevelToSave),
        unlockedWorlds: const ['world_1'],
        updatedAt: Value(DateTime.now()),
      );
      
      await _db.into(_db.progressions).insert(
        progressionCompanion,
        onConflict: DoUpdate((old) => progressionCompanion, target: [_db.progressions.playerSupabaseId]),
      );
    }
  }

  Future<bool> isLevelCompleted(String playerSupabaseId, String worldId, int levelNumber) async {
    final local = await (_db.select(_db.levelCompletions)
          ..where((t) =>
              t.playerSupabaseId.equals(playerSupabaseId) &
              t.worldId.equals(worldId) &
              t.levelNumber.equals(levelNumber)))
        .getSingleOrNull();
    return local != null;
  }
  
  Future<void> grantLevel1Reward(String playerSupabaseId) async {
    try {
      final player = await (_db.select(_db.players)..where((t) => t.supabaseId.equals(playerSupabaseId))).getSingle();
      final newHints = player.hints + 5;
      
      await _supabase.from('profiles').update({'hints': newHints}).eq('id', playerSupabaseId);
      await (_db.update(_db.players)..where((t) => t.supabaseId.equals(playerSupabaseId)))
          .write(PlayersCompanion(hints: Value(newHints)));
    } catch (e) {
      print('Error granting Level 1 reward: $e');
    }
  }

  Future<({int averageSeconds, int bestSeconds})> getLevelStatistics(String worldId, int levelNumber) async {
    try {
      final response = await _supabase
          .from('level_completions')
          .select('completion_time_seconds')
          .eq('world_id', worldId)
          .eq('level_number', levelNumber);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return (averageSeconds: 0, bestSeconds: 0);
      }

      int total = 0;
      int best = 999999;
      for (var entry in data) {
        final time = entry['completion_time_seconds'] as int;
        total += time;
        if (time < best) best = time;
      }

      return (
        averageSeconds: (total / data.length).round(),
        bestSeconds: best == 999999 ? 0 : best,
      );
    } catch (e) {
      print('Error fetching statistics: $e');
      return (averageSeconds: 0, bestSeconds: 0);
    }
  }
}
