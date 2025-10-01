import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/main.dart';

void main() {
  testWidgets('App shows loading indicator on startup', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MinQApp(),
      ),
    );

    // Verify that a loading indicator is shown.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}