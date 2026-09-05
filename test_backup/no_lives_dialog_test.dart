import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/features/home/presentation/widgets/no_lives_dialog.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends Mock implements HomeBloc {}

void main() {
  late MockHomeBloc mockHomeBloc;

  setUp(() {
    mockHomeBloc = MockHomeBloc();
    // Return a default state for the bloc
    when(() => mockHomeBloc.state).thenReturn(const HomeState());
    when(() => mockHomeBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHomeBloc.close()).thenAnswer((_) async => {});
  });

  testWidgets('NoLivesDialog displays correct elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HomeBloc>.value(
          value: mockHomeBloc,
          child: const Scaffold(
            body: NoLivesDialog(),
          ),
        ),
      ),
    );

    expect(find.text('OUT OF LIVES'), findsOneWidget);
    expect(find.text("OH NO! YOU'RE OUT OF LIVES!"), findsOneWidget);
    expect(find.text('GET MORE LIVES'), findsOneWidget);
    expect(find.byIcon(Icons.heart_broken), findsOneWidget);
  });
}

// Helper classes for mocktail
abstract class MockWithBloc extends Mock {}
