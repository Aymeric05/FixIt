import 'dart:math';
import 'package:drift/drift.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/services/database_service.dart';

class ProfileRepository {
  final _supabase = DatabaseService().supabase;
  final _db = DatabaseService().db;

  Future<Player> getOrCreateProfile(String supabaseId) async {
    // 1. Check Drift (local cache)
    final localPlayer = await (_db.select(_db.players)..where((t) => t.supabaseId.equals(supabaseId))).getSingleOrNull();
    if (localPlayer != null) return localPlayer;

    // 2. Check Supabase
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', supabaseId)
        .maybeSingle();

    if (response != null) {
      // Profile exists on Supabase, sync to Drift
      final companion = PlayersCompanion.insert(
        supabaseId: Value(supabaseId),
        username: response['username'],
        avatarUrl: Value(response['avatar_url']),
        updatedAt: Value(DateTime.now()),
      );
      
      final id = await _db.into(_db.players).insert(companion);
      return (await (_db.select(_db.players)..where((t) => t.id.equals(id))).getSingle());
    }

    // 3. Create new profile
    final randomDigits = Random().nextInt(9000) + 1000;
    final defaultUsername = 'Guest#$randomDigits';

    // Ensure profile exists on Supabase
    await _supabase.from('profiles').upsert({
      'id': supabaseId,
      'username': defaultUsername,
    });

    // Ensure progression exists on Supabase
    await _supabase.from('progression').upsert({
      'player_id': supabaseId,
      'current_level': 1,
    });

    final companion = PlayersCompanion.insert(
      supabaseId: Value(supabaseId),
      username: defaultUsername,
      updatedAt: Value(DateTime.now()),
    );

    final id = await _db.into(_db.players).insertOnConflictUpdate(companion);
    
    // Ensure progression exists on Drift
    await _db.into(_db.progressions).insertOnConflictUpdate(ProgressionsCompanion.insert(
      playerSupabaseId: Value(supabaseId),
      currentLevel: const Value(1),
      unlockedWorlds: const ['world_1'],
    ));

    return (await (_db.select(_db.players)..where((t) => t.id.equals(id))).getSingle());
  }

  Future<void> updateUsername(String supabaseId, String newUsername) async {
    // 1. Check if username is already taken
    final existing = await _supabase
        .from('profiles')
        .select('id')
        .eq('username', newUsername)
        .maybeSingle();

    if (existing != null && existing['id'] != supabaseId) {
      throw Exception('This username is already taken. Please choose another one!');
    }

    // 2. Update Supabase
    await _supabase
        .from('profiles')
        .update({'username': newUsername})
        .eq('id', supabaseId);

    // 3. Update Drift
    await (_db.update(_db.players)..where((t) => t.supabaseId.equals(supabaseId)))
        .write(PlayersCompanion(username: Value(newUsername), updatedAt: Value(DateTime.now())));
  }
}
