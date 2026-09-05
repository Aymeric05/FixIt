import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
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

  group('HomeBloc Regression Tests', () {
    blocTest<HomeBloc, HomeState>(
      'Lives Timer: recovers 3 lives after 3 hours',
      build: () => HomeBloc(),
      act: (bloc) async {
        final threeHoursAgo = DateTime.now().subtract(const Duration(minutes: 185));
        
        await db.delete(db.players).go();
        await db.delete(db.dailyChallenges).go();
        
        await db.into(db.players).insert(PlayersCompanion.insert(
          supabaseId: const Value('test-user'),
          username: 'Tester',
          lives: const Value(1),
          lastLifeLostAt: Value(threeHoursAgo),
        ));

        // Insert dummy daily challenge to avoid Supabase call
        final now = DateTime.now().toUtc();
        final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        await db.into(db.dailyChallenges).insert(DailyChallengesCompanion.insert(
          playerSupabaseId: 'test-user',
          date: today,
        ));

        bloc.add(const LoadHomeData(playerId: 'test-user'));
      },
      wait: const Duration(milliseconds: 1000),
      verify: (bloc) {
        expect(bloc.state.lives, equals(4));
        expect(bloc.state.nextLifeTime, isNotNull);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'Lives Timer: does not exceed 5 lives',
      build: () => HomeBloc(),
      act: (bloc) async {
        final tenHoursAgo = DateTime.now().subtract(const Duration(hours: 10));
        
        await db.delete(db.players).go();
        await db.delete(db.dailyChallenges).go();

        await db.into(db.players).insert(PlayersCompanion.insert(
          supabaseId: const Value('test-user-2'),
          username: 'Tester2',
          lives: const Value(4),
          lastLifeLostAt: Value(tenHoursAgo),
        ));

        // Insert dummy daily challenge to avoid Supabase call
        final now = DateTime.now().toUtc();
        final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        await db.into(db.dailyChallenges).insert(DailyChallengesCompanion.insert(
          playerSupabaseId: 'test-user-2',
          date: today,
        ));

        bloc.add(const LoadHomeData(playerId: 'test-user-2'));
      },
      wait: const Duration(milliseconds: 500),
      verify: (bloc) {
        expect(bloc.state.lives, equals(5));
        expect(bloc.state.nextLifeTime, isNull);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'Boosters: deducts puzzle pieces when buying an item',
      build: () => HomeBloc(),
      act: (bloc) async {
        await db.delete(db.players).go();
        await db.delete(db.dailyChallenges).go();

        await db.into(db.players).insert(PlayersCompanion.insert(
          supabaseId: const Value('test-user-3'),
          username: 'Tester3',
          puzzlePieces: const Value(100),
          itemPlusTime: const Value(0),
        ));

        // Insert dummy daily challenge to avoid Supabase call
        final now = DateTime.now().toUtc();
        final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        await db.into(db.dailyChallenges).insert(DailyChallengesCompanion.insert(
          playerSupabaseId: 'test-user-3',
          date: today,
        ));

        bloc.add(const LoadHomeData(playerId: 'test-user-3'));
        await Future.delayed(const Duration(milliseconds: 500));
        bloc.add(const BuyItem('plus_time', 10));
      },
      wait: const Duration(milliseconds: 1000),
      verify: (bloc) {
        expect(bloc.state.puzzlePieces, equals(90));
        expect(bloc.state.itemPlusTime, equals(1));
      },
    );
  });
}
