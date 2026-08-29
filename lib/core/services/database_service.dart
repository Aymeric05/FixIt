import 'package:supabase_flutter/supabase_flutter.dart';
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
      // 1. Initialize Supabase
      await Supabase.initialize(
        url: 'https://kvxokvqkpjxpqceceqds.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt2eG9rdnFrcGp4cHFjZWNlcWRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc3NjYyMzcsImV4cCI6MjEwMzM0MjIzN30.FlpwOII-Pqf--HsSHhfiYnMTr63Qi6W4GgdhvcfcD9o',
      ).timeout(const Duration(seconds: 10));
      supabase = Supabase.instance.client;
      print('Supabase initialized.');

      // 2. Initialize Drift
      db = AppDatabase();
      print('Drift Database initialized.');
    } catch (e) {
      print('Error during DatabaseService initialization: $e');
      rethrow;
    }
  }

  Future<void> hardReset() async {
    try {
      final user = supabase.auth.currentUser;
      
      // 1. Wipe remote data if user exists
      if (user != null) {
        try {
          print('Wiping remote data for user: ${user.id}');
          await supabase.from('level_completions').delete().eq('player_id', user.id).timeout(const Duration(seconds: 5));
          await supabase.from('progression').delete().eq('player_id', user.id).timeout(const Duration(seconds: 5));
          await supabase.from('daily_challenges').delete().eq('player_id', user.id).timeout(const Duration(seconds: 5));
          await supabase.from('profiles').delete().eq('id', user.id).timeout(const Duration(seconds: 5));
          print('Remote data wiped successfully.');
        } catch (e) {
          print('Error wiping remote data: $e');
        }
      }

      // 2. Clear local Drift tables
      print('Clearing local Drift tables...');
      await db.customStatement('DELETE FROM level_completions');
      await db.customStatement('DELETE FROM progressions');
      await db.customStatement('DELETE FROM daily_challenges');
      await db.customStatement('DELETE FROM players');
      print('Local tables cleared.');
      
      // 3. Sign out from Supabase
      print('Signing out from Supabase...');
      await supabase.auth.signOut().timeout(const Duration(seconds: 5));
      print('Signed out.');
    } catch (e) {
      print('Error during hardReset: $e');
    }
  }
}
