// test/project_boots_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots a basic MaterialApp', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('App boots')) ,
      ),
    );

    // Sanity check: our text is on screen
    expect(find.text('App boots'), findsOneWidget);
  });
}
