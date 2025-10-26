import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/screens/settings_screen.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

void main() {
  group('Settings Screen Tests', () {
    testWidgets('Settings screen displays essential options only', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(
              extensions: [MinqDesignTokens.light()],
            ),
            home: const SettingsScreen(),
          ),
        ),
      );

      // Verify essential settings are present
      expect(find.text('プロフィール管理'), findsOneWidget);
      expect(find.text('テーマ'), findsOneWidget);
      expect(find.text('通知設定'), findsOneWidget);
      expect(find.text('AIコーチ設定'), findsOneWidget);
      expect(find.text('ヘルプセンター'), findsOneWidget);
      expect(find.text('お問い合わせ'), findsOneWidget);
      expect(find.text('アプリを評価する'), findsOneWidget);
      expect(find.text('プライバシーポリシー'), findsOneWidget);

      // Verify reduced complexity - should have 8 main options
      final settingsTiles = find.byType(Card);
      expect(settingsTiles, findsNWidgets(8));
    });

    testWidgets('Settings tiles have proper touch targets', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(
              extensions: [MinqDesignTokens.light()],
            ),
            home: const SettingsScreen(),
          ),
        ),
      );

      // Find all ConstrainedBox widgets that should have minimum 44pt height
      final constrainedBoxes = find.byType(ConstrainedBox);
      
      for (final constrainedBox in constrainedBoxes.evaluate()) {
        final widget = constrainedBox.widget as ConstrainedBox;
        final constraints = widget.constraints;
        
        // Verify minimum touch target size (44pt)
        expect(constraints.minHeight, greaterThanOrEqualTo(44.0));
      }
    });

    testWidgets('Advanced settings sheet can be opened', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(
              extensions: [MinqDesignTokens.light()],
            ),
            home: const SettingsScreen(),
          ),
        ),
      );

      // Find and tap the more options button
      final moreButton = find.byIcon(Icons.more_vert);
      expect(moreButton, findsOneWidget);
      
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Verify advanced settings sheet is shown
      expect(find.text('その他の設定'), findsOneWidget);
      expect(find.text('プレミアム機能'), findsOneWidget);
      expect(find.text('詳細設定'), findsOneWidget);
    });

    testWidgets('Theme switch works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(
              extensions: [MinqDesignTokens.light()],
            ),
            home: const SettingsScreen(),
          ),
        ),
      );

      // Find the theme switch
      final themeSwitch = find.byType(Switch);
      expect(themeSwitch, findsOneWidget);

      // Tap the switch
      await tester.tap(themeSwitch);
      await tester.pump();

      // Verify snackbar appears
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}