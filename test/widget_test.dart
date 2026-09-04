import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/main.dart';
import 'package:fixit/core/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    // Basic Supabase initialization for tests to avoid late initialization errors
    // Use dummy values as tests shouldn't make real network calls
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co',
      // ignore: deprecated_member_use
      anonKey: 'placeholder',
    );
    await DatabaseService().initialize();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CandyPuzzleGame());

    // Basic check that the app starts and shows something
    expect(find.byType(CandyPuzzleGame), findsOneWidget);
  });
}
