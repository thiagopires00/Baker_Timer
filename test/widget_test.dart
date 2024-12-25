import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dough_timer_app/main.dart';

void main() {
  testWidgets('Test showing snack bar when no dough is configured', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DoughTimerApp(),
        ),
      ),
    );

    // Tap the 'Start Timer' button when there are no doughs configured.
    await tester.tap(find.text('Start Timer'));
    await tester.pump();

    // Check if we navigate to a new screen or show the snack bar warning if no dough is configured.
    expect(find.text('No dough types configured yet!'), findsOneWidget);
  });
}
