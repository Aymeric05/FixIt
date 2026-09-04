import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:fixit/core/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        // ignore: deprecated_member_use
        anonKey: 'placeholder',
      );
    } catch (_) {}
    
    db = AppDatabase(NativeDatabase.memory());
    await DatabaseService().initialize(database: db);
  });

  group('HomeBloc Lives Logic', () {
    blocTest<HomeBloc, HomeState>(
      'Calculates lives correctly based on lastLifeLostAt',
      build: () => HomeBloc(),
      act: (bloc) async {
        final twoHoursAgo = DateTime.now().subtract(const Duration(minutes: 150));
        
        await db.into(db.players).insert(PlayersCompanion.insert(
          supabaseId: const Value('test-user'),
          username: 'Tester',
          lives: const Value(2),
          lastLifeLostAt: Value(twoHoursAgo),
        ));

        bloc.add(const LoadHomeData(playerId: 'test-user'));
      },
      wait: const Duration(milliseconds: 500),
      verify: (bloc) {
        expect(bloc.state.lives, equals(4));
        expect(bloc.state.nextLifeTime, isNotNull);
      },
    );
  });
}
