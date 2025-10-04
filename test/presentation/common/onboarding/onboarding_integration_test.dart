import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/common/onboarding/onboarding_integration_demo.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingIntegrationDemo', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display all onboarding components', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingIntegrationDemo(),
        ),
      );

      await tester.pump();

      // Check if main components are displayed
      expect(find.text('Progressive Onboarding Demo'), findsOneWidget);
      expect(find.text('オンボーディング状態'), findsOneWidget);
      expect(find.text('コンテキスト依存ガイド'), findsOneWidget);
      expect(find.text('スマートツールチップ'), findsOneWidget);
      expect(find.text('プログレッシブヒント'), findsOneWidget);
      expect(find.text('インタラクティブツアー'), findsOneWidget);
    });

    testWidgets('should show contextual guide buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingIntegrationDemo(),
        ),
      );

      await tester.pump();

      // Check contextual guide buttons
      expect(find.text('ホーム画面'), findsOneWidget);
      expect(find.text('クエスト作成'), findsOneWidget);
      expect(find.text('統計画面'), findsOneWidget);
      expect(find.text('ペア画面'), findsOneWidget);
    });

    testWidgets('should show smart tooltip components', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingIntegrationDemo(),
        ),
      );

      await tester.pump();

      // Check smart tooltip components
      expect(find.text('長押しツールチップ'), findsOneWidget);
      expect(find.text('タップツールチップ'), findsOneWidget);
      expect(find.text('2秒後に自動でツールチップが表示されます'), findsOneWidget);
    });

    testWidgets('should show interactive tour buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingIntegrationDemo(),
        ),
      );

      await tester.pump();

      // Check interactive tour buttons
      expect(find.text('デフォルトツアー'), findsOneWidget);
      expect(find.text('カスタムツアー'), findsOneWidget);
    });

    testWidgets('should show initial progress state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingIntegrationDemo(),
        ),
      );

      await tester.pump();

      // Initial state should be displayed
      expect(find.text('クエスト数: 0, 完了数: 0, 連続記録: 0'), findsOneWidget);
      expect(find.text('進捗をシミュレート'), findsOneWidget);
    });

    testWidgets('should show tour restart button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingIntegrationDemo(),
        ),
      );

      await tester.pump();

      // Check if tour restart button is in app bar (there might be multiple tour icons)
      expect(find.byIcon(Icons.tour), findsAtLeastNWidgets(1));
    });

    testWidgets('should display contextual guide buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingIntegrationDemo(),
        ),
      );

      await tester.pump();

      // Contextual guide buttons should be present
      expect(find.text('ホーム画面'), findsOneWidget);
      expect(find.text('クエスト作成'), findsOneWidget);
      expect(find.text('統計画面'), findsOneWidget);
      expect(find.text('ペア画面'), findsOneWidget);
    });

    testWidgets('should show onboarding status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingIntegrationDemo(),
        ),
      );

      await tester.pump();

      // Initially should show as not completed
      expect(find.text('未完了'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });
  });
}