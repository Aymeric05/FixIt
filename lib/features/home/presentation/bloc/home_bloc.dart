import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<LoadHomeData>((event, emit) {
      // For now, just a placeholder for future data loading (from Isar/Supabase)
      emit(state.copyWith(isLoading: false));
    });
  }
}
