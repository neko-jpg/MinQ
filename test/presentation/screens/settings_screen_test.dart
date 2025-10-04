import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/screens/settings_screen.dart';
import 'package:mockito/mockito.dart';

// Mock GoRouter
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  // We need a wrapper widget to provide the necessary context (MaterialApp, l10n)
  Widget createTestableWidget(Widget child) {
    final mockGoRouter = MockGoRouter();
    return ProviderScope(
      overrides: [
        // Mock the router provider to prevent navigation errors in tests
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

  testWidgets('SettingsScreen displays sections correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const SettingsScreen()));

    // Wait for the widget to build
    await tester.pumpAndSettle();

    // Find translated strings. This makes the test more robust.
    final finder = find.byType(SettingsScreen);
    final element = tester.element(finder);
    final l10n = AppLocalizations.of(element)!;

    // Verify that all section titles are displayed
    expect(find.text(l10n.settingsSectionGeneral), findsOneWidget);
    expect(find.text(l10n.settingsSectionPrivacy), findsOneWidget);
    expect(find.text(l10n.settingsSectionAbout), findsOneWidget);

    // Verify a few specific tiles are present
    expect(find.text(l10n.settingsPushNotifications), findsOneWidget);
    expect(find.text(l10n.settingsDeleteAccount), findsOneWidget);
    expect(find.text(l10n.settingsTermsOfService), findsOneWidget);
  });
}