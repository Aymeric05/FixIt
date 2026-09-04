import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/repositories/profile_repository.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_event.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_state.dart';
import 'package:fixit/core/utils/app_logger.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _supabase = DatabaseService().supabase;
  final _profileRepository = ProfileRepository();

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      AppLogger.log('AuthBloc: Checking session...');
      final user = _supabase.auth.currentUser;
      if (user != null) {
        AppLogger.log('AuthBloc: Existing user found: ${user.id}');
        try {
          final profile = await _profileRepository.getOrCreateProfile(user.id)
              .timeout(const Duration(seconds: 10));
          emit(AuthAuthenticated(user, profile));
          AppLogger.log('AuthBloc: Authenticated successfully');
        } catch (e, stack) {
          AppLogger.error('AuthBloc: Auth check error', e, stack);
          emit(AuthFailure(e.toString()));
        }
      } else {
        AppLogger.log('AuthBloc: No user session, signing in anonymously...');
        add(AuthSignInAnonymous());
      }
    });

    on<AuthSignInAnonymous>((event, emit) async {
      emit(AuthLoading());
      try {
        AppLogger.log('AuthBloc: Signing in anonymously...');
        final authResponse = await _supabase.auth.signInAnonymously()
            .timeout(const Duration(seconds: 15));
        final user = authResponse.user;
        if (user != null) {
          AppLogger.log('AuthBloc: Anonymous sign in successful: ${user.id}');
          final profile = await _profileRepository.getOrCreateProfile(user.id)
              .timeout(const Duration(seconds: 10));
          emit(AuthAuthenticated(user, profile));
          AppLogger.log('AuthBloc: Profile created/fetched');
        } else {
          AppLogger.log('AuthBloc: Anonymous sign-in returned no user');
          emit(const AuthFailure('Failed to sign in.'));
        }
      } catch (e) {
        AppLogger.error('AuthBloc: Sign-in error', e);
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
          // 1. Fetch latest from Supabase
          final response = await _supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (response != null) {
            // 2. Update local Drift cache with EVERYTHING from Supabase
            await _profileRepository.updateUsername(user.id, response['username']);
            if (response['avatar_url'] != null) {
              await _profileRepository.updateAvatar(user.id, response['avatar_url']);
            }
          }
          
          // 3. Re-fetch from Repo (which now has updated cache) and emit
          final profile = await _profileRepository.getOrCreateProfile(user.id);
          emit(AuthAuthenticated(user, profile));
        } catch (e) {
          AppLogger.error('Error refreshing profile', e);
        }
      }
    });
  }
}
