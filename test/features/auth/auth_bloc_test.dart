import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:fixit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fixit/features/auth/presentation/bloc/auth_state.dart';
import 'package:fixit/core/repositories/profile_repository.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  late ProfileRepository mockProfileRepository;
  late SupabaseClient mockSupabase;
  late GoTrueClient mockAuth;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    mockProfileRepository = MockProfileRepository();
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    
    when(() => mockSupabase.auth).thenReturn(mockAuth);

    // Re-initialize for each test to clear singleton state if possible
    // Note: DatabaseService is a singleton, so we need to be careful.
    // In a real app we would reset it or use a proper DI.
    await DatabaseService().initialize(supabaseClient: mockSupabase);
  });

  group('AuthBloc', () {
    test('Initial state is AuthInitial', () {
      expect(AuthBloc(profileRepository: mockProfileRepository).state, equals(AuthInitial()));
    });
  });
}
