import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  Timer? _rechargeTimer;

  HomeBloc() : super(const HomeState()) {
    on<LoadHomeData>((event, emit) {
      _startRechargeTimer();
      emit(state.copyWith(isLoading: false));
    });

    on<UpdateUsername>((event, emit) {
      emit(state.copyWith(username: event.username));
    });

    on<ToggleMusic>((event, emit) {
      emit(state.copyWith(isMusicEnabled: !state.isMusicEnabled));
    });

    on<ToggleSound>((event, emit) {
      emit(state.copyWith(isSoundEnabled: !state.isSoundEnabled));
    });

    on<WatchVideoForLife>((event, emit) {
      if (state.videosWatched < 3 && state.lives < state.maxLives) {
        emit(state.copyWith(
          lives: state.lives + 1,
          videosWatched: state.videosWatched + 1,
        ));
      }
    });

    on<BuyLives>((event, emit) {
      int newLives = state.lives + event.count;
      if (newLives > state.maxLives) newLives = state.maxLives;
      emit(state.copyWith(lives: newLives));
    });

    on<BuyNoAds>((event, emit) {
      emit(state.copyWith(isNoAdsActive: true));
    });

    on<TickLifeRecharge>((event, emit) {
      if (state.lives < state.maxLives) {
        final now = DateTime.now();
        if (state.nextLifeTime == null) {
          emit(state.copyWith(nextLifeTime: now.add(const Duration(minutes: 60))));
        } else if (now.isAfter(state.nextLifeTime!)) {
          final newLives = state.lives + 1;
          final nextTime = newLives < state.maxLives 
              ? now.add(const Duration(minutes: 60)) 
              : null;
          emit(state.copyWith(lives: newLives, nextLifeTime: nextTime));
        }
      } else {
        emit(state.copyWith(nextLifeTime: null));
      }
    });

    on<CompleteLevel>((event, emit) {
      int newLevelsInWorld = state.levelsCompletedInWorld + 1;
      int newCurrentLevel = state.currentLevel + 1;
      
      if (newLevelsInWorld >= state.maxLevelsInWorld) {
        // World transition logic could go here
        emit(state.copyWith(
          currentLevel: newCurrentLevel,
          levelsCompletedInWorld: newLevelsInWorld,
        ));
      } else {
        emit(state.copyWith(
          currentLevel: newCurrentLevel,
          levelsCompletedInWorld: newLevelsInWorld,
        ));
      }
    });

    on<ChangeWorld>((event, emit) {
      emit(state.copyWith(currentWorldIndex: event.worldIndex));
    });
  }

  void _startRechargeTimer() {
    _rechargeTimer?.cancel();
    _rechargeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TickLifeRecharge());
    });
  }

  @override
  Future<void> close() {
    _rechargeTimer?.cancel();
    return super.close();
  }
}
