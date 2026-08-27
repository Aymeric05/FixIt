import 'package:equatable/equatable.dart';
import 'package:fixit/core/database/app_database.dart';

class FriendsState extends Equatable {
  final List<Friend> friends;
  final List<FriendRequest> incomingRequests;
  final List<Map<String, dynamic>> searchResults;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const FriendsState({
    this.friends = const [],
    this.incomingRequests = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  FriendsState copyWith({
    List<Friend>? friends,
    List<FriendRequest>? incomingRequests,
    List<Map<String, dynamic>>? searchResults,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [friends, incomingRequests, searchResults, isLoading, error, successMessage];
}
