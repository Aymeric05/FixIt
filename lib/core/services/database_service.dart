import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixit/core/database/app_database.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late final AppDatabase db;
  late final SupabaseClient supabase;

  Future<void> initialize() async {
    try {
      print('Initializing DatabaseService...');
      
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        print('CRITICAL: Supabase environment variables are missing!');
      }

      // 1. Initialize Supabase
      await Supabase.initialize(
        url: supabaseUrl.isNotEmpty ? supabaseUrl : 'https://kvxokvqkpjxpqceceqds.supabase.co',
        anonKey: supabaseAnonKey.isNotEmpty ? supabaseAnonKey : 'placeholder',
      ).timeout(const Duration(seconds: 10));
      supabase = Supabase.instance.client;
      print('Supabase initialized.');

      // 2. Initialize Drift
      db = AppDatabase();
      print('DatabaseService: Initialization complete');
    } catch (e) {
      print('Error during DatabaseService initialization: $e');
      rethrow;
    }
  }

  Future<void> hardReset() async {
    print('Starting Hard Reset...');
    try {
      final user = supabase.auth.currentUser;
      
      // 1. Wipe remote data if user exists
      if (user != null) {
        try {
          print('Wiping remote data for user: ${user.id}');
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
          print('Remote data wiped successfully.');
        } catch (e) {
          print('Warning: Remote data wipe incomplete: $e');
        }
      }

      // 2. Clear local Drift tables
      print('Clearing local Drift tables...');
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
          print('Cleared local table: $table');
        } catch (e) {
          print('Could not clear local table $table: $e');
        }
      }

      // 3. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('SharedPreferences cleared.');

      // 4. Sign out
      try {
        await supabase.auth.signOut().timeout(const Duration(seconds: 5));
        print('Signed out from Supabase.');
      } catch (e) {
        print('Warning: Sign out failed: $e');
      }

      print('Hard Reset complete.');
    } catch (e) {
      print('CRITICAL error during hardReset: $e');
    }
  }
}
