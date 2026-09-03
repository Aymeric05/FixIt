import 'dart:math';
import 'package:drift/drift.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/services/database_service.dart';

class ProfileRepository {
  final _supabase = DatabaseService().supabase;
  final _db = DatabaseService().db;

  Future<Player> getOrCreateProfile(String supabaseId) async {
    try {
      print('ProfileRepository: Checking local Drift for $supabaseId');
      // 1. Check Drift (local cache) safely
      Player? localPlayer;
      try {
        localPlayer = await (_db.select(_db.players)..where((t) => t.supabaseId.equals(supabaseId))).getSingleOrNull();
      } catch (e) {
        print('ProfileRepository: Warning - local player map failed ($e). Re-syncing from Supabase.');
      }

      if (localPlayer != null) {
        print('ProfileRepository: Found player in local Drift');
        return localPlayer;
      }

      print('ProfileRepository: Checking Supabase for $supabaseId');
      // 2. Check Supabase
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', supabaseId)
          .maybeSingle();

      print('ProfileRepository: Supabase response = $response');

      if (response != null) {
        // Profile exists on Supabase, sync to Drift
        final username = (response['username'] != null && (response['username'] as String).trim().isNotEmpty)
            ? response['username'] as String
            : 'Guest#${Random().nextInt(9000) + 1000}';

        final companion = PlayersCompanion.insert(
          supabaseId: Value(supabaseId),
          username: username,
          avatarUrl: Value(response['avatar_url'] as String?),
          puzzlePieces: Value((response['puzzle_pieces'] as int?) ?? 50),
          itemPlusTime: Value((response['item_plus_time'] as int?) ?? 5),
          itemMoreNumbers: Value((response['item_more_numbers'] as int?) ?? 5),
          itemRevealPath: Value((response['item_reveal_path'] as int?) ?? 5),
          updatedAt: Value(DateTime.now()),
        );
        
        await _db.into(_db.players).insert(
          companion,
          onConflict: DoUpdate((_) => companion, target: [_db.players.supabaseId]),
        );
        return (await (_db.select(_db.players)..where((t) => t.supabaseId.equals(supabaseId))).getSingle());
      }

      print('ProfileRepository: Creating new profile for $supabaseId');
      // 3. Create new profile
      final randomDigits = Random().nextInt(9000) + 1000;
      final defaultUsername = 'Guest#$randomDigits';

      // Ensure profile exists on Supabase
      try {
        await _supabase.from('profiles').upsert({
          'id': supabaseId,
          'username': defaultUsername,
          'puzzle_pieces': 50,
          'item_plus_time': 5,
          'item_more_numbers': 5,
          'item_reveal_path': 5,
        });

        // Ensure progression exists on Supabase
        await _supabase.from('progression').upsert({
          'player_id': supabaseId,
          'current_level': 1,
        });
      } catch (e) {
        print('Error upserting profile/progression on Supabase: $e');
      }

      final companion = PlayersCompanion.insert(
        supabaseId: Value(supabaseId),
        username: defaultUsername,
        puzzlePieces: const Value(50),
        itemPlusTime: const Value(5),
        itemMoreNumbers: const Value(5),
        itemRevealPath: const Value(5),
        updatedAt: Value(DateTime.now()),
      );

      await _db.into(_db.players).insert(
        companion,
        onConflict: DoUpdate((_) => companion, target: [_db.players.supabaseId]),
      );
      
      // Ensure progression exists on Drift
      await _db.into(_db.progressions).insert(
        ProgressionsCompanion.insert(
          playerSupabaseId: Value(supabaseId),
          currentLevel: const Value(1),
          unlockedWorlds: const ['world_1'],
        ),
        onConflict: DoUpdate((_) => ProgressionsCompanion.insert(
          playerSupabaseId: Value(supabaseId),
          currentLevel: const Value(1),
          unlockedWorlds: const ['world_1'],
        ), target: [_db.progressions.playerSupabaseId]),
      );

      return (await (_db.select(_db.players)..where((t) => t.supabaseId.equals(supabaseId))).getSingle());
    } catch (e, stack) {
      print('ERROR in getOrCreateProfile: $e');
      print(stack);
      rethrow;
    }
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

  Future<void> updateAvatar(String supabaseId, String imagePath) async {
    // 1. Update Supabase
    await _supabase
        .from('profiles')
        .update({'avatar_url': imagePath})
        .eq('id', supabaseId);

    // 2. Update Drift
    await (_db.update(_db.players)..where((t) => t.supabaseId.equals(supabaseId)))
        .write(PlayersCompanion(avatarUrl: Value(imagePath), updatedAt: Value(DateTime.now())));
  }
}
