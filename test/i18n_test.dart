import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/data/services/app_locale_controller.dart';
import 'package:minq/presentation/widgets/language_selector_widget.dart';
import 'package:minq/presentation/widgets/rtl_support_widget.dart';

void main() {
  group('Internationalization Tests', () {
    testWidgets('AppLocalizations supports all required locales', (
      tester,
    ) async {
      // Test Japanese locale
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ja'),
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              expect(l10n.goodMorning, 'おはようございます！');
              expect(l10n.settingsTitle, '設定');
              return const SizedBox();
            },
          ),
        ),
      );

      // Test English locale
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              expect(l10n.goodMorning, 'Good Morning!');
              expect(l10n.settingsTitle, 'Settings');
              return const SizedBox();
            },
          ),
        ),
      );

      // Test Arabic locale
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              expect(l10n.goodMorning, 'صباح الخير!');
              expect(l10n.settingsTitle, 'الإعدادات');
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Parameterized messages work correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;

              // Test question counter
              expect(
                l10n.question
                    .replaceAll('{current}', '1')
                    .replaceAll('{total}', '5'),
                'Question 1 / 5',
              );

              // Test delivery date
              expect(
                l10n.deliveryDate
                    .replaceAll('{year}', '2025')
                    .replaceAll('{month}', '10')
                    .replaceAll('{day}', '26'),
                'Delivery Date: 2025/10/26',
              );

              return const SizedBox();
            },
          ),
        ),
      );
    });

    test('AppLocaleController manages locales correctly', () {
      final controller = AppLocaleController(MockLocalPreferencesService());

      // Test available locales
      final availableLocales = controller.getAvailableLocales();
      expect(availableLocales.length, 3);
      expect(
        availableLocales.map((l) => l.locale.languageCode),
        containsAll(['ja', 'en', 'ar']),
      );

      // Test locale switching
      controller.setLocale(const Locale('en'));
      expect(controller.state, const Locale('en'));

      controller.setLocale(const Locale('ar'));
      expect(controller.state, const Locale('ar'));
    });

    testWidgets('RTL support works correctly', (tester) async {
      // Test LTR language (English)
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              expect(RTLSupportWidget.isRTL(context), false);
              expect(
                RTLSupportWidget.getTextDirection(context),
                TextDirection.ltr,
              );
              expect(
                CulturalAdaptations.getBackIcon(context),
                Icons.arrow_back_ios,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Test RTL language (Arabic)
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              expect(RTLSupportWidget.isRTL(context), true);
              expect(
                RTLSupportWidget.getTextDirection(context),
                TextDirection.rtl,
              );
              expect(
                CulturalAdaptations.getBackIcon(context),
                Icons.arrow_forward_ios,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Language selector widget displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(body: LanguageSelectorWidget()),
        ),
      );

      // Check if language options are displayed
      expect(find.text('日本語'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
    });

    testWidgets('Cultural adaptations work correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ja'),
          home: Builder(
            builder: (context) {
              // Test Japanese date format
              expect(CulturalAdaptations.getDateFormat(context), 'yyyy年MM月dd日');
              expect(CulturalAdaptations.getTimeFormat(context), 'HH:mm');
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              // Test English date format
              expect(CulturalAdaptations.getDateFormat(context), 'MM/dd/yyyy');
              expect(CulturalAdaptations.getTimeFormat(context), 'h:mm a');
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              // Test Arabic date format
              expect(CulturalAdaptations.getDateFormat(context), 'dd/MM/yyyy');
              expect(CulturalAdaptations.getTimeFormat(context), 'HH:mm');
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('RTL-aware widgets adapt correctly', (tester) async {
      // Test RTL-aware row with Arabic locale
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: const Scaffold(
            body: RTLAwareRow(
              children: [Text('First'), Text('Second'), Text('Third')],
            ),
          ),
        ),
      );

      // In RTL, children should be reversed
      final rowWidget = tester.widget<Row>(find.byType(Row));
      final textWidgets = rowWidget.children.cast<Text>();
      expect(textWidgets[0].data, 'Third');
      expect(textWidgets[1].data, 'Second');
      expect(textWidgets[2].data, 'First');
    });

    test('Locale fallback works correctly', () {
      final controller = AppLocaleController(MockLocalPreferencesService());

      // Test unsupported locale falls back to supported one
      final supportedLocale = controller.findSupportedLocale(
        const Locale('fr'),
      );
      expect(
        supportedLocale,
        const Locale('ja'),
      ); // Should fallback to Japanese

      // Test supported locale is returned as-is
      final exactMatch = controller.findSupportedLocale(const Locale('en'));
      expect(exactMatch, const Locale('en'));
    });
  });
}

// Mock implementation for testing
class MockLocalPreferencesService {
  String? _locale;

  Future<String?> getPreferredLocale() async => _locale;

  Future<void> setPreferredLocale(String? locale) async {
    _locale = locale;
  }
}
