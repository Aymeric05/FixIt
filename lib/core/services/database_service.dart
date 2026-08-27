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
    // 1. Clear local Drift tables
    await db.customStatement('DELETE FROM level_completions');
    await db.customStatement('DELETE FROM progressions');
    await db.customStatement('DELETE FROM players');
    
    // 2. Sign out from Supabase (this will trigger a new anonymous session on next restart)
    await supabase.auth.signOut();
  }
}
