import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fixit/core/database/app_database.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late final AppDatabase db;
  late final SupabaseClient supabase;

  Future<void> initialize() async {
    // 1. Initialize Supabase
    await Supabase.initialize(
      url: 'https://kvxokvqkpjxpqceceqds.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt2eG9rdnFrcGp4cHFjZWNlcWRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc3NjYyMzcsImV4cCI6MjEwMzM0MjIzN30.FlpwOII-Pqf--HsSHhfiYnMTr63Qi6W4GgdhvcfcD9o',
    );
    supabase = Supabase.instance.client;

    // 2. Initialize Drift
    db = AppDatabase();
  }

  Future<void> hardReset() async {
    final user = supabase.auth.currentUser;
    
    // 1. Wipe remote data if user exists
    if (user != null) {
      try {
        print('Wiping remote data for user: ${user.id}');
        // Order matters if there are FKs (though CASCADE helps)
        await supabase.from('level_completions').delete().eq('player_id', user.id);
        await supabase.from('progression').delete().eq('player_id', user.id);
        await supabase.from('profiles').delete().eq('id', user.id);
        print('Remote data wiped successfully.');
      } catch (e) {
        print('Error wiping remote data: $e');
      }
    }

    // 2. Clear local Drift tables
    await db.customStatement('DELETE FROM level_completions');
    await db.customStatement('DELETE FROM progressions');
    await db.customStatement('DELETE FROM players');
    
    // 3. Sign out from Supabase
    await supabase.auth.signOut();
  }
}
