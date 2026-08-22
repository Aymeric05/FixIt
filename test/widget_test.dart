import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CandyPuzzleGame());

    // Basic check that the app starts. 
    // Since the UI is now based on images and custom buttons, 
    // the old counter test is no longer applicable.
    expect(find.byType(CandyPuzzleGame), findsOneWidget);
  });
}
