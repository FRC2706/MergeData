import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:merge_data/screens/start.dart';

void main() {
  testWidgets('StartPage UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: StartPage(
        title: 'Test Title',
        year: 2022,
        api: 'https://google.com',
      ),
    ));

    // Verify that the StartPage is shown
    expect(find.byType(StartPage), findsOneWidget);
  });
}