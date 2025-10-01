import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minq/presentation/common/onboarding/interactive_tour.dart';
import 'package:minq/presentation/common/onboarding/onboarding_engine.dart';

void main() {
  group('InteractiveTourScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    final testSteps = [
      const TourStep(
        title: 'Step 1',
        description: 'First step description',
      ),
      const TourStep(
        title: 'Step 2',
        description: 'Second step description',
      ),
      const TourStep(
        title: 'Step 3',
        description: 'Third step description',
      ),
    ];

    testWidgets('should display first step initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveTourScreen(steps: testSteps),
        ),
      );

      await tester.pump();

      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('First step description'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('should show MinQ ツアー title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveTourScreen(steps: testSteps),
        ),
      );

      await tester.pump();

      expect(find.text('MinQ ツアー'), findsOneWidget);
    });

    testWidgets('should show skip button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveTourScreen(steps: testSteps),
        ),
      );

      await tester.pump();

      expect(find.text('スキップ'), findsOneWidget);
    });

    testWidgets('should navigate to next step when next button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveTourScreen(steps: testSteps),
        ),
      );

      await tester.pump();

      // Initially on step 1
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);

      // Tap next button
      await tester.tap(find.text('次へ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Should be on step 2
      expect(find.text('Step 2'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('should show back button on second step', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveTourScreen(steps: testSteps),
        ),
      );

      await tester.pump();

      // Navigate to second step
      await tester.tap(find.text('次へ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Back button should be visible
      expect(find.text('戻る'), findsOneWidget);
    });

    testWidgets('should navigate back when back button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveTourScreen(steps: testSteps),
        ),
      );

      await tester.pump();

      // Navigate to second step
      await tester.tap(find.text('次へ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Step 2'), findsOneWidget);

      // Navigate back
      await tester.tap(find.text('戻る'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Step 1'), findsOneWidget);
    });

    testWidgets('should show 完了 button on last step', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveTourScreen(steps: testSteps),
        ),
      );

      await tester.pump();

      // Navigate to last step
      await tester.tap(find.text('次へ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('次へ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Should show complete button
      expect(find.text('完了'), findsOneWidget);
      expect(find.text('3 / 3'), findsOneWidget);
    });

    testWidgets('should show step indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveTourScreen(steps: testSteps),
        ),
      );

      await tester.pump();

      // Should have 3 step indicators
      final indicators = find.byType(Container).evaluate()
          .where((element) => element.widget is Container)
          .map((element) => element.widget as Container)
          .where((container) => 
              container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).shape == BoxShape.circle)
          .toList();

      expect(indicators.length, greaterThanOrEqualTo(3));
    });

    testWidgets('should show skip confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveTourScreen(steps: testSteps),
        ),
      );

      await tester.pump();

      // Tap skip button
      await tester.tap(find.text('スキップ'));
      await tester.pump();

      // Should show confirmation dialog
      expect(find.text('ツアーをスキップしますか？'), findsOneWidget);
      expect(find.text('後で設定画面からツアーを再開できます。'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
      expect(find.text('スキップ'), findsAtLeastNWidgets(1));
    });

    testWidgets('should call onComplete when tour is completed', (WidgetTester tester) async {
      bool onCompleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveTourScreen(
            steps: testSteps,
            onComplete: () {
              onCompleteCalled = true;
            },
          ),
        ),
      );

      await tester.pump();

      // Navigate through all steps
      await tester.tap(find.text('次へ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('次へ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Complete tour
      await tester.tap(find.text('完了'));
      await tester.pump();

      expect(onCompleteCalled, true);
    });
  });

  group('TourStepBuilder', () {
    test('should build default tour with correct number of steps', () {
      final steps = TourStepBuilder.buildDefaultTour();
      
      expect(steps.length, 6);
      expect(steps[0].title, 'MinQへようこそ！');
      expect(steps[1].title, 'クエストを作成しましょう');
      expect(steps[2].title, 'クエストを完了しましょう');
      expect(steps[3].title, '進捗を確認しましょう');
      expect(steps[4].title, 'ペアと一緒に頑張りましょう');
      expect(steps[5].title, '準備完了です！');
    });

    test('should have meaningful descriptions for all steps', () {
      final steps = TourStepBuilder.buildDefaultTour();
      
      for (final step in steps) {
        expect(step.description.isNotEmpty, true);
        expect(step.description.length, greaterThan(10));
      }
    });
  });
}