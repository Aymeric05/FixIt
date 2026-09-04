import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/utils/app_logger.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late final AppDatabase db;
  late final SupabaseClient supabase;
  bool _initialized = false;

  Future<void> initialize({AppDatabase? database, SupabaseClient? supabaseClient}) async {
    if (_initialized) return;
    try {
      AppLogger.log('Initializing DatabaseService...');
      
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        AppLogger.log('CRITICAL: Supabase environment variables are missing!');
      }

      // 1. Initialize Supabase
      SupabaseClient? client;
      try {
        client = Supabase.instance.client;
      } catch (_) {
        // Not initialized
      }

      if (client == null) {
        await Supabase.initialize(
          url: supabaseUrl.isNotEmpty ? supabaseUrl : 'https://kvxokvqkpjxpqceceqds.supabase.co',
          // ignore: deprecated_member_use
          anonKey: supabaseAnonKey.isNotEmpty ? supabaseAnonKey : 'placeholder',
        ).timeout(const Duration(seconds: 10));
      }
      
      supabase = supabaseClient ?? Supabase.instance.client;
      AppLogger.log('Supabase initialized.');

      // 2. Initialize Drift
      db = database ?? AppDatabase();
      _initialized = true;
      AppLogger.log('DatabaseService: Initialization complete');
    } catch (e) {
      AppLogger.error('Error during DatabaseService initialization', e);
      rethrow;
    }
  }

  Future<void> hardReset() async {
    AppLogger.log('Starting Hard Reset...');
    try {
      final user = supabase.auth.currentUser;
      
      // 1. Wipe remote data if user exists
      if (user != null) {
        try {
          AppLogger.log('Wiping remote data for user: ${user.id}');
          // Order: child tables first to respect possible foreign keys
          final remoteTables = [
            'level_completions',
            'progression',
            'daily_challenges',
            'friends',
            'friend_requests',
          ];

          for (final table in remoteTables) {
            try {
              // Try player_id column
              await supabase.from(table).delete().eq('player_id', user.id).timeout(const Duration(seconds: 3));
            } catch (_) {
              // Try sender_id / receiver_id / friend_id for social tables
              try {
                if (table == 'friend_requests') {
                  await supabase.from(table).delete().eq('sender_id', user.id).timeout(const Duration(seconds: 2));
                  await supabase.from(table).delete().eq('receiver_id', user.id).timeout(const Duration(seconds: 2));
                } else if (table == 'friends') {
                  await supabase.from(table).delete().eq('player_id', user.id).timeout(const Duration(seconds: 2));
                  await supabase.from(table).delete().eq('friend_id', user.id).timeout(const Duration(seconds: 2));
                }
              } catch (_) {}
            }
          }
          
          // Finally the profile
          await supabase.from('profiles').delete().eq('id', user.id).timeout(const Duration(seconds: 5));
          AppLogger.log('Remote data wiped successfully.');
        } catch (e) {
          AppLogger.log('Warning: Remote data wipe incomplete: $e');
        }
      }

      // 2. Clear local Drift tables
      AppLogger.log('Clearing local Drift tables...');
      final tables = [
        'level_completions',
        'progressions',
        'daily_challenges',
        'friends',
        'friend_requests',
        'players',
        'global_levels'
      ];
      
      for (final table in tables) {
        try {
          await db.customStatement('DELETE FROM $table');
          AppLogger.log('Cleared local table: $table');
        } catch (e) {
          AppLogger.log('Could not clear local table $table: $e');
        }
      }

      // 3. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      AppLogger.log('SharedPreferences cleared.');

      // 4. Sign out
      try {
        await supabase.auth.signOut().timeout(const Duration(seconds: 5));
        AppLogger.log('Signed out from Supabase.');
      } catch (e) {
        AppLogger.log('Warning: Sign out failed: $e');
      }

      AppLogger.log('Hard Reset complete.');
    } catch (e) {
      AppLogger.error('CRITICAL error during hardReset', e);
    }
  }
}
