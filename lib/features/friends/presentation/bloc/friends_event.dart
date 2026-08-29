import 'package:equatable/equatable.dart';

abstract class FriendsEvent extends Equatable {
  const FriendsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFriends extends FriendsEvent {
  final String playerId;
  const LoadFriends(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class StartSocialSubscription extends FriendsEvent {
  final String playerId;
  const StartSocialSubscription(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class SearchPlayers extends FriendsEvent {
  final String query;
  final String currentUserId;
  const SearchPlayers(this.query, this.currentUserId);

  @override
  List<Object?> get props => [query, currentUserId];
}

class SendRequest extends FriendsEvent {
  final String senderId;
  final String receiverId;
  const SendRequest({required this.senderId, required this.receiverId});

  @override
  List<Object?> get props => [senderId, receiverId];
}

class HandleRequest extends FriendsEvent {
  final String requestId;
  final String playerId;
  final bool accept;
  const HandleRequest({required this.requestId, required this.playerId, required this.accept});

  @override
  List<Object?> get props => [requestId, playerId, accept];
}

class RemoveFriend extends FriendsEvent {
  final String playerId;
  final String friendId;
  const RemoveFriend({required this.playerId, required this.friendId});

  @override
  List<Object?> get props => [playerId, friendId];
}

class ClearSocialMessages extends FriendsEvent {}
