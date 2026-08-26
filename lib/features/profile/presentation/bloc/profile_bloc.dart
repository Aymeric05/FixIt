import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final _profileRepository = ProfileRepository();
  final _supabase = DatabaseService().supabase;

  ProfileBloc() : super(ProfileInitial()) {
    on<UpdateNicknameRequested>((event, emit) async {
      emit(ProfileUpdating());
      try {
        final user = _supabase.auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        
        await _profileRepository.updateUsername(user.id, event.newNickname);
        emit(ProfileUpdated(event.newNickname));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
