import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/utils/app_logger.dart';

class FriendsRepository {
  SupabaseClient get _supabase => DatabaseService().supabase;
  AppDatabase get _db => DatabaseService().db;

  RealtimeChannel subscribeToSocialChanges(String playerId, VoidCallback onUpdate) {
    final channel = _supabase.channel('social_changes_$playerId');
    
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friends',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'player_id',
            value: playerId,
          ),
          callback: (payload) => onUpdate(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friend_requests',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: playerId,
          ),
          callback: (payload) => onUpdate(),
        )
        .subscribe();

    return channel;
  }

  Future<List<Friend>> fetchFriends(String playerId) async {
    try {
      // 1. Fetch from Supabase with join on profiles
      final response = await _supabase
          .from('friends')
          .select('friend_id, profiles!friend_id(username)')
          .eq('player_id', playerId);

      final List<dynamic> data = response as List<dynamic>;
      
      // 2. Sync to local Drift
      await _db.batch((batch) {
        batch.deleteWhere(_db.friends, (t) => t.playerId.equals(playerId));
        for (var item in data) {
          final friendId = item['friend_id'] as String;
          final profileData = item['profiles'];
          final username = (profileData != null) ? profileData['username'] as String : 'Unknown';
          
          batch.insert(_db.friends, FriendsCompanion.insert(
            playerId: playerId,
            friendId: friendId,
            friendUsername: username,
          ));
        }
      });
    } catch (e) {
      AppLogger.error('Error syncing friends from Supabase', e);
    }

    return await (_db.select(_db.friends)..where((t) => t.playerId.equals(playerId))).get();
  }

  Future<List<FriendRequest>> fetchIncomingRequests(String playerId) async {
    try {
      // Using the sender_id relation to get the pseudo
      final response = await _supabase
          .from('friend_requests')
          .select('id, sender_id, profiles!sender_id(username), status, created_at')
          .eq('receiver_id', playerId)
          .eq('status', 'pending');

      final List<dynamic> data = response as List<dynamic>;

      await _db.batch((batch) {
        batch.deleteWhere(_db.friendRequests, (t) => t.receiverId.equals(playerId));
        for (var item in data) {
          final profileData = item['profiles'];
          final senderUsername = (profileData != null) ? profileData['username'] as String : 'Unknown';

          batch.insert(_db.friendRequests, FriendRequestsCompanion.insert(
            id: item['id'],
            senderId: item['sender_id'],
            receiverId: playerId,
            senderUsername: senderUsername,
            status: const Value('pending'),
            createdAt: Value(DateTime.parse(item['created_at'])),
          ));
        }
      });
    } catch (e) {
      AppLogger.error('Error syncing requests', e);
    }

    return await (_db.select(_db.friendRequests)
          ..where((t) => t.receiverId.equals(playerId) & t.status.equals('pending')))
        .get();
  }

  Future<List<Map<String, dynamic>>> searchPlayers(String query, String currentUserId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, username')
          .ilike('username', '%$query%')
          .neq('id', currentUserId)
          .limit(20);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Search error', e);
      return [];
    }
  }

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    if (senderId == receiverId) {
      throw Exception('You cannot add yourself as a friend!');
    }

    // Check if they are already friends
    final alreadyFriends = await _supabase
        .from('friends')
        .select()
        .eq('player_id', senderId)
        .eq('friend_id', receiverId)
        .maybeSingle();
    
    if (alreadyFriends != null) {
      throw Exception('You are already friends!');
    }

    // Check if request already exists (either direction)
    final existing = await _supabase
        .from('friend_requests')
        .select()
        .or('and(sender_id.eq.$senderId,receiver_id.eq.$receiverId),and(sender_id.eq.$receiverId,receiver_id.eq.$senderId)')
        .maybeSingle();

    if (existing != null) {
      if (existing['sender_id'] == senderId) {
        throw Exception('Request already sent!');
      } else {
        throw Exception('This player already sent you a request!');
      }
    }

    await _supabase.from('friend_requests').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': 'pending',
    });
  }

  Future<void> handleFriendRequest(String requestId, bool accept) async {
    if (accept) {
      // Use the RPC function to handle atomic double-sided friendship creation
      await _supabase.rpc('accept_friend_request', params: {'req_id': requestId});
    } else {
      // Just delete/reject
      await _supabase.from('friend_requests').delete().eq('id', requestId);
    }
    
    // Cleanup local
    await (_db.delete(_db.friendRequests)..where((t) => t.id.equals(requestId))).go();
  }

  Future<void> removeFriend(String playerId, String friendId) async {
    // Use RPC to remove from both sides on Supabase
    await _supabase.rpc('remove_friend_v2', params: {'target_id': friendId});
    
    // Cleanup local Drift
    await (_db.delete(_db.friends)
          ..where((t) => (t.playerId.equals(playerId) & t.friendId.equals(friendId)) | 
                         (t.playerId.equals(friendId) & t.friendId.equals(playerId))))
        .go();
  }
}
