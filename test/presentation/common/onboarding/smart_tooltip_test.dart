import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/common/onboarding/smart_tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SmartTooltip', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should render child widget', (WidgetTester tester) async {
      const childText = 'Test Child';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartTooltip(
              message: 'Test Message',
              tooltipId: 'test_tooltip',
              child: Text(childText),
            ),
          ),
        ),
      );

      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('should show tooltip on long press by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartTooltip(
              message: 'Test Message',
              tooltipId: 'test_tooltip',
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      // Long press to trigger tooltip
      await tester.longPress(find.text('Test Child'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tooltip should be visible
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('should show tooltip on tap when trigger is set to tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartTooltip(
              message: 'Test Message',
              tooltipId: 'test_tooltip',
              trigger: TooltipTrigger.tap,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      // Tap to trigger tooltip
      await tester.tap(find.text('Test Child'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tooltip should be visible
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('should hide tooltip after duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartTooltip(
              message: 'Test Message',
              tooltipId: 'test_tooltip',
              showDuration: Duration(milliseconds: 500),
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      // Trigger tooltip
      await tester.longPress(find.text('Test Child'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tooltip should be visible
      expect(find.text('Test Message'), findsOneWidget);

      // Wait for duration to pass and animation to complete
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 400)); // Animation duration

      // Tooltip should be hidden
      expect(find.text('Test Message'), findsNothing);
    });

    testWidgets('should allow manual dismissal', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartTooltip(
              message: 'Test Message',
              tooltipId: 'test_tooltip',
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      // Trigger tooltip
      await tester.longPress(find.text('Test Child'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tooltip should be visible
      expect(find.text('Test Message'), findsOneWidget);

      // Tap close button with warnIfMissed: false to handle positioning issues
      await tester.tap(find.byIcon(Icons.close), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Tooltip should be hidden
      expect(find.text('Test Message'), findsNothing);
    });

    testWidgets('should not show tooltip again when showOnce is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartTooltip(
              message: 'Test Message',
              tooltipId: 'test_tooltip_once',
              showOnce: true,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      // First trigger
      await tester.longPress(find.text('Test Child'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Message'), findsOneWidget);

      // Dismiss tooltip
      await tester.tap(find.byIcon(Icons.close), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Try to trigger again
      await tester.longPress(find.text('Test Child'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tooltip should not appear again
      expect(find.text('Test Message'), findsNothing);
    });
  });

  group('AutoSmartTooltip', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should render child widget', (WidgetTester tester) async {
      const childText = 'Auto Test Child';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AutoSmartTooltip(
              message: 'Auto Test Message',
              tooltipId: 'auto_test_tooltip',
              child: Text(childText),
            ),
          ),
        ),
      );

      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('should show tooltip automatically after delay', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AutoSmartTooltip(
              message: 'Auto Test Message',
              tooltipId: 'auto_test_tooltip',
              delay: Duration(milliseconds: 100),
              child: Text('Auto Test Child'),
            ),
          ),
        ),
      );

      // Initially no tooltip
      expect(find.byIcon(Icons.help_outline), findsNothing);

      // Wait for delay and animation
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 400)); // Animation duration

      // Tooltip indicator should appear
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });

    testWidgets('should hide tooltip after show duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AutoSmartTooltip(
              message: 'Auto Test Message',
              tooltipId: 'auto_test_tooltip',
              delay: Duration(milliseconds: 100),
              showDuration: Duration(milliseconds: 200),
              child: Text('Auto Test Child'),
            ),
          ),
        ),
      );

      // Wait for delay and animation
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 400)); // Animation duration
      expect(find.byIcon(Icons.help_outline), findsOneWidget);

      // Wait for show duration and hide animation
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 400)); // Hide animation duration
      expect(find.byIcon(Icons.help_outline), findsNothing);
    });

    testWidgets('should allow manual dismissal', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AutoSmartTooltip(
              message: 'Auto Test Message',
              tooltipId: 'auto_test_tooltip',
              delay: Duration(milliseconds: 100),
              child: Text('Auto Test Child'),
            ),
          ),
        ),
      );

      // Wait for delay and animation
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 400)); // Animation duration
      expect(find.byIcon(Icons.help_outline), findsOneWidget);

      // Tap to dismiss
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byIcon(Icons.help_outline), findsNothing);
    });
  });

  group('TooltipTrigger', () {
    test('should have correct enum values', () {
      expect(TooltipTrigger.values.length, 3);
      expect(TooltipTrigger.values.contains(TooltipTrigger.tap), true);
      expect(TooltipTrigger.values.contains(TooltipTrigger.longPress), true);
      expect(TooltipTrigger.values.contains(TooltipTrigger.manual), true);
    });
  });
}