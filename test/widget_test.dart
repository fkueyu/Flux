import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Basic MaterialApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Flux Test'))),
    );

    expect(find.text('Flux Test'), findsOneWidget);
  });
}
