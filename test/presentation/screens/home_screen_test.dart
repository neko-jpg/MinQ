import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/presentation/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows skeleton when loading', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userQuestsProvider.overrideWith((ref) => const AsyncValue.loading()),
          streakProvider.overrideWith((ref) => const AsyncValue.loading()),
          todayCompletionCountProvider.overrideWith((ref) => const AsyncValue.loading()),
          recentLogsProvider.overrideWith((ref) => const AsyncValue.loading()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Verify that the skeleton is shown
    expect(find.byType(_HomeScreenSkeleton), findsOneWidget);
    // Verify that the main content is not shown
    expect(find.byType(_TodaysFocusSection), findsNothing);
  });

  testWidgets('HomeScreen shows content when data is loaded', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override with some mock data
          userQuestsProvider.overrideWith((ref) => const AsyncValue.data([])),
          streakProvider.overrideWith((ref) => const AsyncValue.data(5)),
          todayCompletionCountProvider.overrideWith((ref) => const AsyncValue.data(2)),
          recentLogsProvider.overrideWith((ref) => const AsyncValue.data([])),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // We might need to pumpAndSettle to wait for all async operations to complete
    await tester.pumpAndSettle();

    // Verify that the skeleton is NOT shown
    expect(find.byType(_HomeScreenSkeleton), findsNothing);
    // Verify that the main content is shown
    expect(find.byType(_TodaysFocusSection), findsOneWidget);
    expect(find.byType(_MiniQuestsSection), findsOneWidget);
    expect(find.byType(_StatsSnapshotSection), findsOneWidget);
  });
}