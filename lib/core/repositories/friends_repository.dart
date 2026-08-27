import 'package:drift/drift.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:fixit/core/services/database_service.dart';

class FriendsRepository {
  final _supabase = DatabaseService().supabase;
  final _db = DatabaseService().db;

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
          final username = item['profiles']['username'] as String;
          batch.insert(_db.friends, FriendsCompanion.insert(
            playerId: playerId,
            friendId: friendId,
            friendUsername: username,
          ));
        }
      });
    } catch (e) {
      print('Error syncing friends from Supabase: $e');
    }

    return await (_db.select(_db.friends)..where((t) => t.playerId.equals(playerId))).get();
  }

  Future<List<FriendRequest>> fetchIncomingRequests(String playerId) async {
    try {
      final response = await _supabase
          .from('friend_requests')
          .select('id, sender_id, profiles!sender_id(username), status, created_at')
          .eq('receiver_id', playerId)
          .eq('status', 'pending');

      final List<dynamic> data = response as List<dynamic>;

      await _db.batch((batch) {
        batch.deleteWhere(_db.friendRequests, (t) => t.receiverId.equals(playerId));
        for (var item in data) {
          batch.insert(_db.friendRequests, FriendRequestsCompanion.insert(
            id: item['id'],
            senderId: item['sender_id'],
            receiverId: playerId,
            senderUsername: item['profiles']['username'],
            status: const Value('pending'),
            createdAt: Value(DateTime.parse(item['created_at'])),
          ));
        }
      });
    } catch (e) {
      print('Error syncing requests: $e');
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
      print('Search error: $e');
      return [];
    }
  }

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    if (senderId == receiverId) {
      throw Exception('You cannot add yourself as a friend!');
    }

    // Check if request already exists
    final existing = await _supabase
        .from('friend_requests')
        .select()
        .eq('sender_id', senderId)
        .eq('receiver_id', receiverId)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Request already sent!');
    }

    await _supabase.from('friend_requests').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': 'pending',
    });
  }

  Future<void> handleFriendRequest(String requestId, bool accept) async {
    if (accept) {
      // Supabase function or multiple calls
      // 1. Get the request details
      final req = await _supabase.from('friend_requests').select().eq('id', requestId).single();
      final senderId = req['sender_id'];
      final receiverId = req['receiver_id'];

      // 2. Add both ways in friends table
      await _supabase.from('friends').insert([
        {'player_id': senderId, 'friend_id': receiverId},
        {'player_id': receiverId, 'friend_id': senderId},
      ]);

      // 3. Delete the request
      await _supabase.from('friend_requests').delete().eq('id', requestId);
    } else {
      // Just delete/reject
      await _supabase.from('friend_requests').delete().eq('id', requestId);
    }
    
    // Cleanup local
    await (_db.delete(_db.friendRequests)..where((t) => t.id.equals(requestId))).go();
  }

  Future<void> removeFriend(String playerId, String friendId) async {
    await _supabase.from('friends').delete().eq('player_id', playerId).eq('friend_id', friendId);
    await _supabase.from('friends').delete().eq('player_id', friendId).eq('friend_id', playerId);
    
    await (_db.delete(_db.friends)
          ..where((t) => (t.playerId.equals(playerId) & t.friendId.equals(friendId)) | 
                         (t.playerId.equals(friendId) & t.friendId.equals(playerId))))
        .go();
  }
}
