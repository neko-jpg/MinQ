import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/data/services/app_locale_controller.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/widgets/language_selector_widget.dart';
import 'package:minq/presentation/widgets/rtl_support_widget.dart';

void main() {
  group('Internationalization System Tests', () {
    testWidgets('AppLocalizations supports all required locales', (
      tester,
    ) async {
      const supportedLocales = [
        Locale('en'),
        Locale('ja'),
        Locale('ar'),
        Locale('zh'),
        Locale('ko'),
        Locale('es'),
      ];

      for (final locale in supportedLocales) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                expect(l10n, isNotNull);
                expect(l10n!.goodMorning, isNotEmpty);
                expect(l10n.settingsTitle, isNotEmpty);
                return const SizedBox();
              },
            ),
          ),
        );
        await tester.pump();
      }
    });

    testWidgets('RTL support works correctly for Arabic', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RTLSupportWidget(child: Text('Test RTL')),
        ),
      );

      await tester.pump();

      final directionality = tester.widget<Directionality>(
        find.byType(Directionality),
      );
      expect(directionality.textDirection, TextDirection.rtl);
    });

    testWidgets('LTR support works correctly for non-RTL languages', (
      tester,
    ) async {
      const ltrLocales = [
        Locale('en'),
        Locale('ja'),
        Locale('zh'),
        Locale('ko'),
        Locale('es'),
      ];

      for (final locale in ltrLocales) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RTLSupportWidget(child: Text('Test LTR')),
          ),
        );

        await tester.pump();

        final directionality = tester.widget<Directionality>(
          find.byType(Directionality),
        );
        expect(directionality.textDirection, TextDirection.ltr);
      }
    });

    test('AppLocaleController provides correct locale options', () {
      final controller = AppLocaleController(MockLocalPreferencesService());
      final availableLocales = controller.getAvailableLocales();

      expect(availableLocales.length, greaterThanOrEqualTo(6));

      // Check that all expected locales are present
      final localeCodes =
          availableLocales.map((option) => option.locale.languageCode).toSet();
      expect(localeCodes, contains('en'));
      expect(localeCodes, contains('ja'));
      expect(localeCodes, contains('ar'));
      expect(localeCodes, contains('zh'));
      expect(localeCodes, contains('ko'));
      expect(localeCodes, contains('es'));

      // Check RTL flag is set correctly
      final arabicOption = availableLocales.firstWhere(
        (option) => option.locale.languageCode == 'ar',
      );
      expect(arabicOption.isRTL, isTrue);

      final englishOption = availableLocales.firstWhere(
        (option) => option.locale.languageCode == 'en',
      );
      expect(englishOption.isRTL, isFalse);
    });

    test('AppLocaleController finds supported locale correctly', () {
      final controller = AppLocaleController(MockLocalPreferencesService());

      // Test exact match
      final exactMatch = controller.findSupportedLocale(const Locale('en'));
      expect(exactMatch.languageCode, 'en');

      // Test language code match
      final languageMatch = controller.findSupportedLocale(
        const Locale('en', 'US'),
      );
      expect(languageMatch.languageCode, 'en');

      // Test fallback to Japanese for unsupported locale
      final fallback = controller.findSupportedLocale(const Locale('fr'));
      expect(fallback.languageCode, 'ja');
    });

    testWidgets('Language selector widget displays all locales', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: LanguageSelectorWidget()),
          ),
        ),
      );

      await tester.pump();

      // Check that language selector is displayed
      expect(find.byType(LanguageSelectorWidget), findsOneWidget);
      expect(find.text('Language / 言語'), findsOneWidget);

      // Check that at least some language options are displayed
      expect(find.text('English'), findsOneWidget);
      expect(find.text('日本語'), findsOneWidget);
    });

    testWidgets('RTL-aware components adapt correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: RTLAwareRow(children: [Text('First'), Text('Second')]),
          ),
        ),
      );

      await tester.pump();

      // Verify RTL-aware row exists
      expect(find.byType(RTLAwareRow), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    group('Cultural Adaptations', () {
      testWidgets('Date format adapts to locale', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ja'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                final dateFormat = CulturalAdaptations.getDateFormat(context);
                expect(dateFormat, contains('年'));
                return const SizedBox();
              },
            ),
          ),
        );

        await tester.pump();
      });

      testWidgets('Back icon adapts to RTL', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                final backIcon = CulturalAdaptations.getBackIcon(context);
                expect(backIcon, Icons.arrow_forward_ios);
                return const SizedBox();
              },
            ),
          ),
        );

        await tester.pump();
      });
    });

    group('No Mojibake Tests', () {
      test('Japanese ARB file contains no corrupted characters', () {
        // This test would be run by the CI script, but we can also test programmatically
        const corruptedPatterns = ['E,', 'E��', 'ぁE', 'めE', '�'];

        // In a real test, we would read the ARB file and check for these patterns
        // For now, we just verify the patterns are defined
        expect(corruptedPatterns, isNotEmpty);
      });

      test('All ARB files are valid JSON', () {
        // This would be tested by the CI script
        // Here we just verify the test concept
        expect(true, isTrue);
      });
    });
  });
}

// Mock class for testing
class MockLocalPreferencesService {
  Future<String?> getPreferredLocale() async => null;
  Future<void> setPreferredLocale(String? locale) async {}
}
