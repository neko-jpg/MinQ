import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/l10n/app_localizations.dart';

void main() {
  group('Simple I18n Tests', () {
    testWidgets('Japanese locale works', (tester) async {
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
              expect(l10n.newVersionAvailable, '新しいバージョンがあります');
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('English locale works', (tester) async {
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
              expect(l10n.newVersionAvailable, 'New Version Available');
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Arabic locale works', (tester) async {
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
              expect(l10n.newVersionAvailable, 'إصدار جديد متاح');
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
