import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_event.dart';
import 'package:fixit/features/lives/presentation/bloc/lives_state.dart';

class LivesBloc extends Bloc<LivesEvent, LivesState> {
  LivesBloc() : super(const LivesState()) {
    on<LoadLives>((event, emit) {
      // In the future, load from Isar/Supabase
    });

    on<DecrementLife>((event, emit) {
      if (state.currentLives > 0) {
        emit(state.copyWith(
          currentLives: state.currentLives - 1,
          lastLifeLost: DateTime.now(),
        ));
      }
    });

    on<IncrementLife>((event, emit) {
      if (state.currentLives < state.maxLives) {
        emit(state.copyWith(currentLives: state.currentLives + 1));
      }
    });
  }
}
