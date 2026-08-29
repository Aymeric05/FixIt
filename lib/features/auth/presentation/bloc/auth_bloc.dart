import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/repositories/profile_repository.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_event.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _supabase = DatabaseService().supabase;
  final _profileRepository = ProfileRepository();

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        try {
          final profile = await _profileRepository.getOrCreateProfile(user.id);
          emit(AuthAuthenticated(user, profile));
        } catch (e) {
          emit(AuthFailure(e.toString()));
        }
      } else {
        // Auto-sign in anonymously if no user is found
        add(AuthSignInAnonymous());
      }
    });

    on<AuthSignInAnonymous>((event, emit) async {
      emit(AuthLoading());
      try {
        print('Signing in anonymously...');
        final authResponse = await _supabase.auth.signInAnonymously().timeout(const Duration(seconds: 15));
        final user = authResponse.user;
        if (user != null) {
          print('Anonymous sign in successful: ${user.id}');
          final profile = await _profileRepository.getOrCreateProfile(user.id);
          emit(AuthAuthenticated(user, profile));
        } else {
          emit(const AuthFailure('Failed to sign in.'));
        }
      } catch (e) {
        print('Error during anonymous sign in: $e');
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignOutRequested>((event, emit) async {
      await _supabase.auth.signOut();
      emit(AuthUnauthenticated());
      // Re-sign in anonymously after sign out to keep a session
      add(AuthSignInAnonymous());
    });

    on<RefreshProfileRequested>((event, emit) async {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        try {
          // Force a fresh fetch from Supabase to ensure consistency
          final response = await _supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (response != null) {
            // Update local Drift too
            await _profileRepository.updateUsername(user.id, response['username']);
            final profile = await _profileRepository.getOrCreateProfile(user.id);
            emit(AuthAuthenticated(user, profile));
          }
        } catch (e) {
          print('Error refreshing profile: $e');
        }
      }
    });
  }
}
