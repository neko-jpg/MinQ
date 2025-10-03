import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:minq/presentation/widgets/ime_safe_area.dart';

void main() {
  testWidgets('ImeSafeArea responds to viewInsets', (tester) async {
    const childKey = Key('ime-child');
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(),
          child: Scaffold(
            body: ImeSafeArea(
              child: Container(key: childKey),
            ),
          ),
        ),
      ),
    );

    final initialRect = tester.getRect(find.byKey(childKey));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 120)),
          child: Scaffold(
            body: ImeSafeArea(
              child: Container(key: childKey),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 150));

    final updatedRect = tester.getRect(find.byKey(childKey));
    expect(updatedRect.top, greaterThan(initialRect.top));
  });
}
