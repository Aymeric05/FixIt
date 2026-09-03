import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'package:fixit/core/utils/level_generator.dart';
import 'package:fixit/core/models/level_win_summary.dart';

class ProgressionRepository {
  final _supabase = DatabaseService().supabase;
  final _db = DatabaseService().db;

  Future<LevelWinSummary> getLevelWinSummary({
    required String worldId,
    required int levelNumber,
    required String playerId,
    required int playerTime,
  }) async {
    try {
      // 1. Global Completion Count (before recording this one)
      final globalResponse = await _supabase
          .from('level_completions')
          .select('completion_time_seconds, profiles!player_id(username)')
          .eq('world_id', worldId)
          .eq('level_number', levelNumber)
          .order('completion_time_seconds', ascending: true);
      
      final List<dynamic> allRecords = globalResponse as List<dynamic>;
      final int globalCount = allRecords.length;

      // 2. World Record + Holder (current record before saving new one)
      int wrSeconds = 0;
      String wrHolder = '--';
      if (allRecords.isNotEmpty) {
        wrSeconds = allRecords[0]['completion_time_seconds'] as int? ?? 0;
        final profiles = allRecords[0]['profiles'];
        wrHolder = (profiles != null && profiles['username'] != null) ? profiles['username'] as String : 'Unknown';
      }

      // 3. Global Average
      int avgSeconds = 0;
      if (allRecords.isNotEmpty) {
        final total = allRecords.fold<int>(0, (sum, item) => sum + (item['completion_time_seconds'] as int));
        avgSeconds = (total / allRecords.length).round();
      }

      // 4. Global Percentile (if we added this attempt)
      double? percentile;
      if (globalCount >= 1) {
        int rank = 1;
        for (var record in allRecords) {
          if ((record['completion_time_seconds'] as int) < playerTime) {
            rank++;
          }
        }
        percentile = rank / (globalCount + 1);
      }

      // 5. Friends Data
      final friendIdsResponse = await _supabase
          .from('friends')
          .select('friend_id')
          .eq('player_id', playerId);
      final List<String> friendIds = (friendIdsResponse as List).map((e) => e['friend_id'] as String).toList();
      final List<String> relevantIds = [playerId, ...friendIds];

      // Note: This includes older records of the same player if they exist, 
      // but level_completions has a unique constraint on (player_id, world_id, level_number) 
      // due to our upsert logic, so it's safe.
      final socialRankingsResponse = await _supabase
          .from('level_completions')
          .select('player_id, completion_time_seconds, profiles!player_id(username)')
          .eq('world_id', worldId)
          .eq('level_number', levelNumber)
          .inFilter('player_id', relevantIds)
          .order('completion_time_seconds', ascending: true);
      
      final List<dynamic> socialData = socialRankingsResponse as List<dynamic>;
      final List<FriendRankEntry> socialRankings = [];
      
      // Update social data with current performance if it's better or if it doesn't exist yet
      bool userIncluded = false;
      for (var entry in socialData) {
        String entryId = entry['player_id'] as String;
        int time = entry['completion_time_seconds'] as int;
        if (entryId == playerId) {
          userIncluded = true;
          if (playerTime < time) time = playerTime; // Use better time for ranking display
        }
        final profiles = entry['profiles'];
        final username = (profiles != null && profiles['username'] != null) ? profiles['username'] as String : 'Unknown';
        socialRankings.add(FriendRankEntry(
          playerId: entryId,
          username: username,
          timeSeconds: time,
          rank: 0, // Will calculate below
        ));
      }
      
      if (!userIncluded) {
        final myProfile = await _supabase.from('profiles').select('username').eq('id', playerId).maybeSingle();
        final username = (myProfile != null && myProfile['username'] != null) ? myProfile['username'] as String : 'Me';
        socialRankings.add(FriendRankEntry(
          playerId: playerId,
          username: username,
          timeSeconds: playerTime,
          rank: 0,
        ));
      }

      socialRankings.sort((a, b) => a.timeSeconds.compareTo(b.timeSeconds));
      for (int i = 0; i < socialRankings.length; i++) {
        socialRankings[i] = FriendRankEntry(
          playerId: socialRankings[i].playerId,
          username: socialRankings[i].username,
          timeSeconds: socialRankings[i].timeSeconds,
          rank: i + 1,
        );
      }

      // Mini-leaderboard: Above, User, Below
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
      print('Error generating LevelWinSummary: $e');
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
      final friendIdsResponse = await _supabase
          .from('friends')
          .select('friend_id')
          .eq('player_id', playerId);
      final List<String> friendIds = (friendIdsResponse as List).map((e) => e['friend_id'] as String).toList();
      final List<String> relevantIds = [playerId, ...friendIds];

      final response = await _supabase
          .from('level_completions')
          .select('player_id, completion_time_seconds, profiles!player_id(username)')
          .eq('world_id', worldId)
          .eq('level_number', levelNumber)
          .inFilter('player_id', relevantIds)
          .order('completion_time_seconds', ascending: true);
      
      final List<dynamic> data = response as List<dynamic>;
      final List<FriendRankEntry> rankings = [];
      for (int i = 0; i < data.length; i++) {
        final profiles = data[i]['profiles'];
        final username = (profiles != null && profiles['username'] != null) ? profiles['username'] as String : 'Unknown';
        rankings.add(FriendRankEntry(
          playerId: data[i]['player_id'] as String,
          username: username,
          timeSeconds: data[i]['completion_time_seconds'] as int,
          rank: i + 1,
        ));
      }
      return rankings;
    } catch (e) {
      print('Error fetching friends leaderboard: $e');
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
      final newPuzzles = player.puzzlePieces + 100;
      
      await _supabase.from('profiles').update({'puzzle_pieces': newPuzzles}).eq('id', playerSupabaseId);
      await (_db.update(_db.players)..where((t) => t.supabaseId.equals(playerSupabaseId)))
          .write(PlayersCompanion(puzzlePieces: Value(newPuzzles)));
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
