import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:minq/presentation/widgets/user_behavior_heatmap.dart';

void main() {
  testWidgets('renders heatmap with semantics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserBehaviorHeatmap(
            dataset: {
              DateTime(2024, 1, 1): 1,
              DateTime(2024, 1, 2): 3,
            },
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('週間達成ヒートマップ'), findsOneWidget);
  });
}
