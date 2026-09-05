import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/core/utils/level_generator.dart';
import 'package:fixit/core/models/level_win_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fixit/core/utils/app_logger.dart';

class ProgressionRepository {
  SupabaseClient get _supabase => DatabaseService().supabase;
  AppDatabase get _db => DatabaseService().db;

  Future<LevelWinSummary> getLevelWinSummary({
    required String worldId,
    required int levelNumber,
    required String playerId,
    required int playerTime,
  }) async {
    try {
      // 0. Fetch real username from local Drift
      String myUsername = 'Me';
      try {
        final localPlayer = await (_db.select(_db.players)..where((t) => t.supabaseId.equals(playerId))).getSingleOrNull();
        if (localPlayer != null) myUsername = localPlayer.username;
      } catch (e) {
        AppLogger.error('Error fetching local username', e);
      }

      // 1. Global Completions
      final globalResponse = await _supabase
          .from('level_completions')
          .select('player_id, completion_time_seconds, profiles!player_id(username)')
          .eq('world_id', worldId)
          .eq('level_number', levelNumber);
      
      final List<dynamic> rawRecords = globalResponse as List<dynamic>;
      
      // 2. Integration of CURRENT attempt into global stats
      final List<Map<String, dynamic>> processedRecords = [];
      bool currentUserFoundInRaw = false;
      
      for (var record in rawRecords) {
        final pid = record['player_id'] as String;
        int time = record['completion_time_seconds'] as int;
        String uname = (record['profiles'] != null && record['profiles']['username'] != null) 
            ? record['profiles']['username'] as String 
            : 'Unknown';

        if (pid == playerId) {
          currentUserFoundInRaw = true;
          uname = myUsername; // Use latest username
          if (playerTime < time) time = playerTime; // Use the best one for stats
        }
        
        processedRecords.add({
          'player_id': pid,
          'time': time,
          'username': uname,
        });
      }
      
      if (!currentUserFoundInRaw) {
        processedRecords.add({
          'player_id': playerId,
          'time': playerTime,
          'username': myUsername,
        });
      }

      // Sort by time
      processedRecords.sort((a, b) => (a['time'] as int).compareTo(b['time'] as int));

      final int globalCount = processedRecords.length;

      // 3. World Record + Holder
      int wrSeconds = processedRecords[0]['time'] as int;
      String wrHolder = processedRecords[0]['username'] as String;

      // 4. Global Average
      final totalSeconds = processedRecords.fold<int>(0, (sum, item) => sum + (item['time'] as int));
      final avgSeconds = (totalSeconds / globalCount).round();

      // 5. Global Percentile
      int rankInGlobal = 0;
      for (int i = 0; i < processedRecords.length; i++) {
        if (processedRecords[i]['player_id'] == playerId) {
          rankInGlobal = i + 1;
          break;
        }
      }
      final double percentile = rankInGlobal / globalCount;

      // 6. Friends Data
      final friendIdsResponse = await _supabase
          .from('friends')
          .select('friend_id')
          .eq('player_id', playerId);
      final List<String> friendIds = (friendIdsResponse as List).map((e) => e['friend_id'] as String).toList();
      final List<String> relevantIds = [playerId, ...friendIds];

      final List<FriendRankEntry> socialRankings = [];
      for (var record in processedRecords) {
        if (relevantIds.contains(record['player_id'])) {
          socialRankings.add(FriendRankEntry(
            playerId: record['player_id'] as String,
            username: record['username'] as String,
            timeSeconds: record['time'] as int,
            rank: 0, // Calculated after sorting
          ));
        }
      }

      // Ensure rankings are correct
      for (int i = 0; i < socialRankings.length; i++) {
        socialRankings[i] = FriendRankEntry(
          playerId: socialRankings[i].playerId,
          username: socialRankings[i].username,
          timeSeconds: socialRankings[i].timeSeconds,
          rank: i + 1,
        );
      }

      // Mini-leaderboard
      final userRankIdx = socialRankings.indexWhere((e) => e.playerId == playerId);
      final List<FriendRankEntry> miniLeaderboard = [];
      if (userRankIdx != -1) {
        if (userRankIdx > 0) miniLeaderboard.add(socialRankings[userRankIdx - 1]);
        miniLeaderboard.add(socialRankings[userRankIdx]);
        if (userRankIdx < socialRankings.length - 1) miniLeaderboard.add(socialRankings[userRankIdx + 1]);
      }

      return LevelWinSummary(
        globalCompletionCount: globalCount,
        friendCompletionCount: socialRankings.length - 1,
        globalAverageSeconds: avgSeconds,
        worldRecordSeconds: wrSeconds,
        worldRecordHolder: wrHolder,
        globalPercentile: percentile,
        friendsMiniLeaderboard: miniLeaderboard,
      );
    } catch (e) {
      AppLogger.error('Error generating LevelWinSummary', e);
      return LevelWinSummary(
        globalCompletionCount: 0,
        friendCompletionCount: 0,
        globalAverageSeconds: 0,
        worldRecordSeconds: 0,
        worldRecordHolder: '--',
        friendsMiniLeaderboard: [],
      );
    }
  }

  Future<List<FriendRankEntry>> getFriendsLeaderboard({
    required String worldId,
    required int levelNumber,
    required String playerId,
  }) async {
    try {
      // 0. Get local username
      String myUsername = 'Me';
      try {
        final localPlayer = await (_db.select(_db.players)..where((t) => t.supabaseId.equals(playerId))).getSingleOrNull();
        if (localPlayer != null) myUsername = localPlayer.username;
      } catch (_) {}

      // 1. Get friend IDs
      final friendIdsResponse = await _supabase
          .from('friends')
          .select('friend_id')
          .eq('player_id', playerId);
      final List<String> friendIds = (friendIdsResponse as List).map((e) => e['friend_id'] as String).toList();
      final List<String> relevantIds = [playerId, ...friendIds];

      // 2. Fetch completions
      final response = await _supabase
          .from('level_completions')
          .select('player_id, completion_time_seconds, profiles!player_id(username)')
          .eq('world_id', worldId)
          .eq('level_number', levelNumber)
          .inFilter('player_id', relevantIds)
          .order('completion_time_seconds', ascending: true);
      
      final List<dynamic> data = response as List<dynamic>;
      final List<FriendRankEntry> rankings = [];
      bool meFound = false;

      for (int i = 0; i < data.length; i++) {
        final pid = data[i]['player_id'] as String;
        if (pid == playerId) meFound = true;

        final profiles = data[i]['profiles'];
        String uname = (profiles != null && profiles['username'] != null) ? profiles['username'] as String : 'Unknown';
        if (pid == playerId) uname = myUsername;

        rankings.add(FriendRankEntry(
          playerId: pid,
          username: uname,
          timeSeconds: data[i]['completion_time_seconds'] as int,
          rank: 0, // Will recalculate
        ));
      }

      // 3. Fallback: Add self if not in remote list yet (but we probably completed it)
      if (!meFound) {
        // Try to get my local completion for this level if available, 
        // or we just skip if not found yet (unlikely if summary just called)
        final localComp = await (_db.select(_db.levelCompletions)
              ..where((t) => t.playerSupabaseId.equals(playerId) & t.worldId.equals(worldId) & t.levelNumber.equals(levelNumber)))
            .getSingleOrNull();
        
        if (localComp != null) {
          rankings.add(FriendRankEntry(
            playerId: playerId,
            username: myUsername,
            timeSeconds: localComp.completionTimeSeconds,
            rank: 0,
          ));
          rankings.sort((a, b) => a.timeSeconds.compareTo(b.timeSeconds));
        }
      }

      // Recalculate ranks
      for (int i = 0; i < rankings.length; i++) {
        rankings[i] = FriendRankEntry(
          playerId: rankings[i].playerId,
          username: rankings[i].username,
          timeSeconds: rankings[i].timeSeconds,
          rank: i + 1,
        );
      }

      return rankings;
    } catch (e) {
      AppLogger.error('Error fetching friends leaderboard', e);
      return [];
    }
  }

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
      AppLogger.error('Error fetching global level from Supabase', e);
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
      AppLogger.log('Synced global level $levelNumber to Supabase.');
    } catch (e) {
      AppLogger.error('Error saving global level to Supabase', e);
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
        AppLogger.log('Background Pre-generating level $levelNum...');
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
    bool updateProgression = true,
  }) async {
    // 1. Fetch current progress to avoid downgrades
    int? currentLevel;
    if (updateProgression) {
      final currentProg = await (_db.select(_db.progressions)
            ..where((t) => t.playerSupabaseId.equals(playerSupabaseId)))
          .getSingleOrNull();
      currentLevel = currentProg?.currentLevel;
    }
    
    final int nextLevelToSave = levelNumber + 1;
    final bool shouldUpdateProgression = updateProgression && (currentLevel == null || nextLevelToSave > currentLevel);

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
        AppLogger.log('Synced progression for Level $nextLevelToSave to Supabase.');
      }
    } catch (e) {
      AppLogger.error('Error saving completion to Supabase', e);
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
      final newPuzzles = player.puzzlePieces + 100;
      
      await _supabase.from('profiles').update({'puzzle_pieces': newPuzzles}).eq('id', playerSupabaseId);
      await (_db.update(_db.players)..where((t) => t.supabaseId.equals(playerSupabaseId)))
          .write(PlayersCompanion(puzzlePieces: Value(newPuzzles)));
    } catch (e) {
      AppLogger.error('Error granting Level 1 reward', e);
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
      AppLogger.error('Error fetching statistics', e);
      return (averageSeconds: 0, bestSeconds: 0);
    }
  }
}
