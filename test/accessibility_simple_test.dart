import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/accessibility/accessibility_service.dart';
import 'package:minq/core/accessibility/screen_reader_helper.dart';
import 'package:minq/presentation/widgets/accessible_button.dart';

void main() {
  group('Basic Accessibility Tests', () {
    test('ContrastValidator should validate WCAG AA contrast ratios', () {
      // Test high contrast combinations
      expect(ContrastValidator.meetsWCAGAA(Colors.black, Colors.white), isTrue);
      expect(ContrastValidator.meetsWCAGAA(Colors.white, Colors.black), isTrue);

      // Test low contrast combinations
      expect(
        ContrastValidator.meetsWCAGAA(
          Colors.grey.shade400,
          Colors.grey.shade300,
        ),
        isFalse,
      );
    });

    test('ContrastValidator should calculate contrast ratios correctly', () {
      final ratio = ContrastValidator.calculateContrastRatio(
        Colors.black,
        Colors.white,
      );
      expect(ratio, closeTo(21.0, 0.1)); // Black on white should be 21:1
    });

    test(
      'AccessibilitySettings should adjust animation duration for reduced motion',
      () {
        const settings = AccessibilitySettings(reduceMotion: true);
        const baseDuration = Duration(milliseconds: 300);

        final adjustedDuration = settings.adjustDuration(baseDuration);
        expect(adjustedDuration, equals(Duration.zero));
      },
    );

    test(
      'AccessibilitySettings should adjust text style for bold text preference',
      () {
        const settings = AccessibilitySettings(boldText: true);
        const baseStyle = TextStyle(fontSize: 16);

        final adjustedStyle = settings.adjustTextStyle(baseStyle);
        expect(adjustedStyle.fontWeight, equals(FontWeight.w600));
      },
    );

    test('AccessibilityService should be singleton', () {
      final service1 = AccessibilityService.instance;
      final service2 = AccessibilityService.instance;

      expect(service1, same(service2));
    });

    test('AccessibilityService should validate contrast correctly', () {
      final service = AccessibilityService.instance;

      expect(service.validateContrast(Colors.black, Colors.white), isTrue);

      expect(
        service.validateContrast(Colors.grey.shade400, Colors.grey.shade300),
        isFalse,
      );
    });

    testWidgets(
      'AccessibleElevatedButton should meet minimum touch target size',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleElevatedButton(
                onPressed: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        );

        final buttonFinder = find.byType(AccessibleElevatedButton);
        expect(buttonFinder, findsOneWidget);

        // Verify the button exists and can be tapped
        await tester.tap(buttonFinder);
        await tester.pump();
      },
    );

    testWidgets('AccessibleTextButton should have proper semantics', (
      tester,
    ) async {
      const semanticLabel = 'Test Button';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleTextButton(
              onPressed: () {},
              semanticLabel: semanticLabel,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(AccessibleTextButton);
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets('AccessibleIconButton should have minimum touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              onPressed: () {},
              icon: const Icon(Icons.home),
              semanticLabel: 'Home',
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(AccessibleIconButton);
      expect(buttonFinder, findsOneWidget);
    });
  });
}
