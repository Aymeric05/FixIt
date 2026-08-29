import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fixit/core/repositories/friends_repository.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_event.dart';
import 'package:fixit/features/friends/presentation/bloc/friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendsRepository _repository = FriendsRepository();
  RealtimeChannel? _socialChannel;

  FriendsBloc() : super(const FriendsState()) {
    on<LoadFriends>(_onLoadFriends);
    on<StartSocialSubscription>(_onStartSocialSubscription);
    on<SearchPlayers>(_onSearchPlayers);
    on<SendRequest>(_onSendRequest);
    on<HandleRequest>(_onHandleRequest);
    on<RemoveFriend>(_onRemoveFriend);
    on<ClearSocialMessages>(_onClearMessages);
  }

  void _onClearMessages(ClearSocialMessages event, Emitter<FriendsState> emit) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  void _onStartSocialSubscription(StartSocialSubscription event, Emitter<FriendsState> emit) {
    _socialChannel?.unsubscribe();
    _socialChannel = _repository.subscribeToSocialChanges(event.playerId, () {
      add(LoadFriends(event.playerId));
    });
  }

  Future<void> _onLoadFriends(LoadFriends event, Emitter<FriendsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final friends = await _repository.fetchFriends(event.playerId);
      final requests = await _repository.fetchIncomingRequests(event.playerId);
      emit(state.copyWith(friends: friends, incomingRequests: requests, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onSearchPlayers(SearchPlayers event, Emitter<FriendsState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }
    emit(state.copyWith(isLoading: true));
    try {
      final results = await _repository.searchPlayers(event.query, event.currentUserId);
      emit(state.copyWith(searchResults: results, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onSendRequest(SendRequest event, Emitter<FriendsState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repository.sendFriendRequest(event.senderId, event.receiverId);
      emit(state.copyWith(
        isLoading: false, 
        successMessage: 'Request sent!',
      ));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(state.copyWith(error: msg, isLoading: false));
    }
  }

  Future<void> _onHandleRequest(HandleRequest event, Emitter<FriendsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.handleFriendRequest(event.requestId, event.accept);
      // Reload everything
      final friends = await _repository.fetchFriends(event.playerId);
      final requests = await _repository.fetchIncomingRequests(event.playerId);
      emit(state.copyWith(
        friends: friends, 
        incomingRequests: requests, 
        isLoading: false,
        successMessage: event.accept ? 'Friend added!' : 'Request rejected'
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onRemoveFriend(RemoveFriend event, Emitter<FriendsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.removeFriend(event.playerId, event.friendId);
      final friends = await _repository.fetchFriends(event.playerId);
      emit(state.copyWith(friends: friends, isLoading: false, successMessage: 'Friend removed'));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  @override
  Future<void> close() {
    _socialChannel?.unsubscribe();
    return super.close();
  }
}
