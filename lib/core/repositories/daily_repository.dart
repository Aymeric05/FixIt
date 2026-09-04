import 'package:drift/drift.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/utils/level_generator.dart';
import 'package:fixit/core/models/grid_offset.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fixit/core/utils/app_logger.dart';

class DailyRepository {
  AppDatabase get _db => DatabaseService().db;
  SupabaseClient get _supabase => DatabaseService().supabase;

  // Static cache to store the offset between local device time and server time
  static Duration _serverTimeOffset = Duration.zero;

  /// Fetches the official server time from Supabase and calculates the offset.
  Future<void> syncWithServerTime() async {
    try {
      final response = await _supabase.rpc('get_server_time');
      if (response != null) {
        final serverTime = DateTime.parse(response as String);
        _serverTimeOffset = serverTime.difference(DateTime.now().toUtc());
        AppLogger.log('Server time synced. Offset: ${_serverTimeOffset.inSeconds}s');
      }
    } catch (e) {
      AppLogger.error('Failed to sync server time. Falling back to local time.', e);
    }
  }

  /// Returns the current time aligned with the server.
  DateTime _getServerAlignedTime() {
    return DateTime.now().toUtc().add(_serverTimeOffset);
  }

  String _getTodayDate() {
    final now = _getServerAlignedTime();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  /// Returns the number of seconds remaining until the next UTC midnight.
  int getSecondsUntilMidnight() {
    final now = _getServerAlignedTime();
    final tomorrow = DateTime.utc(now.year, now.month, now.day + 1);
    return tomorrow.difference(now).inSeconds;
  }

  String getTodayWorldId() {
    return "daily_${_getTodayDate()}";
  }

  String getTodaySeriesWorldId() {
    return "series_${_getTodayDate()}";
  }

  int _getSeedForDate(String date, {int offset = 0}) {
    // Basic deterministic seed from date string
    return date.hashCode + offset;
  }

  Future<DailyChallenge?> getDailyStatus(String playerId) async {
    final today = _getTodayDate();
    
    // Check local first
    var status = await (_db.select(_db.dailyChallenges)
          ..where((t) => t.playerSupabaseId.equals(playerId) & t.date.equals(today)))
        .getSingleOrNull();

    if (status == null) {
      // Check Supabase
      try {
        final response = await _supabase
            .from('daily_challenges')
            .select()
            .eq('player_id', playerId)
            .eq('date', today)
            .maybeSingle();

        if (response != null) {
          final companion = DailyChallengesCompanion.insert(
            playerSupabaseId: playerId,
            date: today,
            isDailyLevelCompleted: Value(response['is_daily_completed'] ?? false),
            dailyLevelTime: Value(response['daily_level_time'] ?? 0),
            seriesCurrentLevel: Value(response['series_current_level'] ?? 0),
            seriesAccumulatedTime: Value(response['series_accumulated_time'] ?? 0),
            isSeriesCompleted: Value(response['is_series_completed'] ?? false),
          );
          await _db.into(_db.dailyChallenges).insert(companion);
          status = await (_db.select(_db.dailyChallenges)
                ..where((t) => t.playerSupabaseId.equals(playerId) & t.date.equals(today)))
              .getSingle();
        }
      } catch (e) {
        AppLogger.error('Error fetching daily status from Supabase', e);
      }
    }

    return status;
  }

  ({List<List<int?>> hints, List<GridOffset> solution, Set<String> walls}) generateDailyLevel({
    required int worldLevel, // e.g. 1, 2, 3 for series
    required bool isSeries,
  }) {
    final today = _getTodayDate();
    final seed = _getSeedForDate(today, offset: isSeries ? worldLevel * 100 : 0);
    
    final result = LevelGenerator.generate(12, random: Random(seed));
    return (hints: result.hints, solution: result.solution, walls: result.walls);
  }

  Future<void> updateDailyStatus({
    required String playerId,
    bool? isDailyLevelCompleted,
    int? dailyLevelTime,
    int? seriesCurrentLevel,
    int? seriesAccumulatedTime,
    bool? isSeriesCompleted,
  }) async {
    final today = _getTodayDate();
    
    // Companion for initial insert if row doesn't exist
    final insertCompanion = DailyChallengesCompanion.insert(
      playerSupabaseId: playerId,
      date: today,
      isDailyLevelCompleted: Value(isDailyLevelCompleted ?? false),
      dailyLevelTime: Value(dailyLevelTime ?? 0),
      seriesCurrentLevel: Value(seriesCurrentLevel ?? 0),
      seriesAccumulatedTime: Value(seriesAccumulatedTime ?? 0),
      isSeriesCompleted: Value(isSeriesCompleted ?? false),
    );

    // Companion for update if row already exists (only update non-null fields)
    final updateCompanion = DailyChallengesCompanion(
      isDailyLevelCompleted: isDailyLevelCompleted != null ? Value(isDailyLevelCompleted) : const Value.absent(),
      dailyLevelTime: dailyLevelTime != null ? Value(dailyLevelTime) : const Value.absent(),
      seriesCurrentLevel: seriesCurrentLevel != null ? Value(seriesCurrentLevel) : const Value.absent(),
      seriesAccumulatedTime: seriesAccumulatedTime != null ? Value(seriesAccumulatedTime) : const Value.absent(),
      isSeriesCompleted: isSeriesCompleted != null ? Value(isSeriesCompleted) : const Value.absent(),
    );

    await _db.into(_db.dailyChallenges).insert(
      insertCompanion,
      onConflict: DoUpdate((_) => updateCompanion, target: [_db.dailyChallenges.playerSupabaseId, _db.dailyChallenges.date]),
    );

    // Update Supabase
    try {
      final current = await getDailyStatus(playerId);
      if (current != null) {
        await _supabase.from('daily_challenges').upsert({
          'player_id': playerId,
          'date': today,
          'is_daily_completed': current.isDailyLevelCompleted,
          'daily_level_time': current.dailyLevelTime,
          'series_current_level': current.seriesCurrentLevel,
          'series_accumulated_time': current.seriesAccumulatedTime,
          'is_series_completed': current.isSeriesCompleted,
        }, onConflict: 'player_id,date');
      }
    } catch (e) {
      AppLogger.error('Error updating daily status to Supabase', e);
    }
  }
}
