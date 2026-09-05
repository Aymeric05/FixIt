import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/main.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:fixit/core/database/app_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';

void main() {
  setUpAll(() async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Basic Supabase initialization for tests to avoid late initialization errors
    // Use dummy values as tests shouldn't make real network calls
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co',
      // ignore: deprecated_member_use
      anonKey: 'placeholder',
    );

    // Initialize DatabaseService with memory database for tests
    final memoryDb = AppDatabase(NativeDatabase.memory());
    await DatabaseService().initialize(database: memoryDb);
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CandyPuzzleGame());

    // Basic check that the app starts and shows something
    expect(find.byType(CandyPuzzleGame), findsOneWidget);
  });
}
