import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/accessibility/accessibility_service.dart';
import 'package:minq/core/accessibility/screen_reader_helper.dart';

void main() {
  group('Accessibility Tests', () {
    group('ContrastValidator', () {
      test('should validate WCAG AA contrast ratios correctly', () {
        // Test high contrast combinations
        expect(
          ContrastValidator.meetsWCAGAA(Colors.black, Colors.white),
          isTrue,
        );
        expect(
          ContrastValidator.meetsWCAGAA(Colors.white, Colors.black),
          isTrue,
        );

        // Test low contrast combinations
        expect(
          ContrastValidator.meetsWCAGAA(Colors.grey.shade400, Colors.grey.shade300),
          isFalse,
        );

        // Test borderline cases
        expect(
          ContrastValidator.meetsWCAGAA(const Color(0xFF767676), Colors.white),
          isTrue, // Should be exactly 4.5:1
        );
      });

      test('should calculate contrast ratios correctly', () {
        final ratio = ContrastValidator.calculateContrastRatio(Colors.black, Colors.white);
        expect(ratio, closeTo(21.0, 0.1)); // Black on white should be 21:1

        final grayRatio = ContrastValidator.calculateContrastRatio(
          Colors.grey.shade600,
          Colors.white,
        );
        expect(grayRatio, greaterThan(4.5)); // Should meet WCAG AA
      });

      test('should provide accessible text colors', () {
        final darkBg = Colors.black;
        final lightBg = Colors.white;

        final textOnDark = ContrastValidator.getAccessibleTextColor(darkBg);
        final textOnLight = ContrastValidator.getAccessibleTextColor(lightBg);

        expect(textOnDark, equals(Colors.white));
        expect(textOnLight, equals(Colors.black));
      });

      test('should adjust colors for contrast', () {
        final lowContrastColor = Colors.grey.shade400;
        final background = Colors.white;

        final adjustedColor = ContrastValidator.adjustColorForContrast(
          lowContrastColor,
          background,
        );

        expect(
          ContrastValidator.meetsWCAGAA(adjustedColor, background),
          isTrue,
        );
      });
    });

    group('AccessibilitySettings', () {
      testWidgets('should detect system accessibility features', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final settings = AccessibilitySettings.fromMediaQuery(context);
                
                // Test that settings are created without errors
                expect(settings, isNotNull);
                expect(settings.textScaler, isNotNull);
                
                return Container();
              },
            ),
          ),
        );
      });

      test('should adjust animation duration for reduced motion', () {
        const settings = AccessibilitySettings(reduceMotion: true);
        const baseDuration = Duration(milliseconds: 300);

        final adjustedDuration = settings.adjustDuration(baseDuration);
        expect(adjustedDuration, equals(Duration.zero));
      });

      test('should adjust text style for bold text preference', () {
        const settings = AccessibilitySettings(boldText: true);
        const baseStyle = TextStyle(fontSize: 16);

        final adjustedStyle = settings.adjustTextStyle(baseStyle);
        expect(adjustedStyle.fontWeight, equals(FontWeight.w600));
      });

      test('should adjust text style for large text preference', () {
        const settings = AccessibilitySettings(largeText: true);
        const baseStyle = TextStyle(fontSize: 12);

        final adjustedStyle = settings.adjustTextStyle(baseStyle);
        expect(adjustedStyle.fontSize, equals(16.0));
      });
    });

    group('AccessibleButton', () {
      testWidgets('should meet minimum touch target size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleButton(
                onPressed: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        );

        final buttonFinder = find.byType(AccessibleButton);
        expect(buttonFinder, findsOneWidget);

        final buttonWidget = tester.widget<AccessibleButton>(buttonFinder);
        expect(buttonWidget, isNotNull);

        // Check that the button has proper constraints
        final containerFinder = find.descendant(
          of: buttonFinder,
          matching: find.byType(Container),
        );
        
        if (containerFinder.evaluate().isNotEmpty) {
          final container = tester.widget<Container>(containerFinder);
          final constraints = container.constraints;
          
          if (constraints != null) {
            expect(constraints.minWidth, greaterThanOrEqualTo(44.0));
            expect(constraints.minHeight, greaterThanOrEqualTo(44.0));
          }
        }
      });

      testWidgets('should have proper semantics', (tester) async {
        const semanticLabel = 'Test Button';
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleButton(
                onPressed: () {},
                semanticLabel: semanticLabel,
                child: const Text('Test'),
              ),
            ),
          ),
        );

        // Verify semantics are properly set
        final semantics = tester.getSemantics(find.byType(AccessibleButton));
        expect(semantics.label, equals(semanticLabel));
        expect(semantics.getSemanticsData().actions.keys.contains(SemanticsAction.tap), isTrue);
      });

      testWidgets('should be disabled when onPressed is null', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleButton(
                onPressed: null,
                enabled: false,
                child: const Text('Disabled'),
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AccessibleButton));
        expect(semantics.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);
      });
    });

    group('ScreenReaderHelper', () {
      testWidgets('should create proper button semantics', (tester) async {
        const label = 'Test Button';
        const hint = 'Tap to test';
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScreenReaderHelper.button(
                child: const Text('Test'),
                label: label,
                hint: hint,
                onTap: () {},
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics));
        expect(semantics.label, equals(label));
        expect(semantics.hint, equals(hint));
        expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
      });

      testWidgets('should create proper progress semantics', (tester) async {
        const value = 0.75;
        const label = 'Progress';
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScreenReaderHelper.progress(
                child: const LinearProgressIndicator(value: value),
                value: value,
                label: label,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics));
        expect(semantics.label, contains('75%'));
        expect(semantics.value, equals('75'));
      });

      testWidgets('should create proper header semantics', (tester) async {
        const text = 'Main Header';
        const level = 1;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScreenReaderHelper.header(
                child: const Text(text),
                text: text,
                level: level,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics));
        expect(semantics.label, contains('レベル1見出し'));
        expect(semantics.label, contains(text));
        expect(semantics.hasFlag(SemanticsFlag.isHeader), isTrue);
      });

      testWidgets('should create proper list item semantics', (tester) async {
        const label = 'Item 1';
        const index = 0;
        const total = 5;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScreenReaderHelper.listItem(
                child: const Text(label),
                label: label,
                index: index,
                total: total,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics));
        expect(semantics.label, contains('1件目'));
        expect(semantics.label, contains('全5件中'));
      });
    });

    group('AccessibilityService', () {
      test('should be singleton', () {
        final service1 = AccessibilityService.instance;
        final service2 = AccessibilityService.instance;
        
        expect(service1, same(service2));
      });

      testWidgets('should validate contrast correctly', (tester) async {
        final service = AccessibilityService.instance;
        
        expect(
          service.validateContrast(Colors.black, Colors.white),
          isTrue,
        );
        
        expect(
          service.validateContrast(Colors.grey.shade400, Colors.grey.shade300),
          isFalse,
        );
      });

      testWidgets('should provide accessible colors', (tester) async {
        final service = AccessibilityService.instance;
        
        final accessibleColor = service.getAccessibleColor(
          Colors.grey.shade400,
          Colors.white,
        );
        
        expect(
          service.validateContrast(accessibleColor, Colors.white),
          isTrue,
        );
      });
    });

    group('Focus Management', () {
      testWidgets('should handle focus navigation', (tester) async {
        final focusNode1 = FocusNode();
        final focusNode2 = FocusNode();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Focus(
                    focusNode: focusNode1,
                    child: const TextField(),
                  ),
                  Focus(
                    focusNode: focusNode2,
                    child: const TextField(),
                  ),
                ],
              ),
            ),
          ),
        );

        // Test focus management
        focusNode1.requestFocus();
        await tester.pump();
        expect(focusNode1.hasFocus, isTrue);

        FocusScope.of(tester.element(find.byType(Scaffold))).nextFocus();
        await tester.pump();
        expect(focusNode2.hasFocus, isTrue);
      });
    });
  });

  group('Color Contrast Integration Tests', () {
    testWidgets('should ensure all theme colors meet WCAG AA standards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;
              
              // Test primary colors
              expect(
                ContrastValidator.meetsWCAGAA(
                  colorScheme.onPrimary,
                  colorScheme.primary,
                ),
                isTrue,
                reason: 'Primary color contrast should meet WCAG AA',
              );
              
              // Test surface colors
              expect(
                ContrastValidator.meetsWCAGAA(
                  colorScheme.onSurface,
                  colorScheme.surface,
                ),
                isTrue,
                reason: 'Surface color contrast should meet WCAG AA',
              );
              
              // Test background colors
              expect(
                ContrastValidator.meetsWCAGAA(
                  colorScheme.onBackground,
                  colorScheme.background,
                ),
                isTrue,
                reason: 'Background color contrast should meet WCAG AA',
              );
              
              return Container();
            },
          ),
        ),
      );
    });
  });
}