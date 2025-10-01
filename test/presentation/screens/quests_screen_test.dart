import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/screens/quests_screen.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:mockito/mockito.dart';

// Mock GoRouter
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  Widget createTestableWidget(Widget child) {
    final mockGoRouter = MockGoRouter();
    return ProviderScope(
      overrides: [
        routerProvider.overrideWithValue(mockGoRouter),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('ja', ''),
        ],
        home: child,
      ),
    );
  }

  testWidgets('QuestsScreen displays skeleton when loading', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          templateQuestsProvider.overrideWith((ref) => const AsyncValue.loading()),
          userQuestsProvider.overrideWith((ref) => const AsyncValue.loading()),
        ],
        child: createTestableWidget(const QuestsScreen()),
      ),
    );

    // Let the initial delay in initState finish
    await tester.pump(const Duration(milliseconds: 700));

    // Verify that the skeleton is shown
    expect(find.byType(MinqSkeletonGrid), findsOneWidget);
    // Verify that the main content (FAB) is not shown
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('QuestsScreen displays content when data is loaded', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          templateQuestsProvider.overrideWith((ref) => const AsyncValue.data([])),
          userQuestsProvider.overrideWith((ref) => const AsyncValue.data([])),
        ],
        child: createTestableWidget(const QuestsScreen()),
      ),
    );

    // Let the initial delay in initState finish and settle the UI
    await tester.pumpAndSettle(const Duration(milliseconds: 700));

    // Verify that the skeleton is NOT shown
    expect(find.byType(MinqSkeletonGrid), findsNothing);
    // Verify that the main content is shown
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget); // Search bar
  });
}