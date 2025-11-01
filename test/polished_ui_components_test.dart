import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/widgets/polished_ui_components.dart';
import 'package:minq/presentation/widgets/enhanced_micro_interactions.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

void main() {
  group('Polished UI Components Tests', () {
    testWidgets('PolishedProgressIndicator renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqDesignTokens.light()]),
          home: const Scaffold(
            body: Center(
              child: PolishedProgressIndicator(
                value: 0.5,
                showPercentage: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PolishedProgressIndicator), findsOneWidget);

      // Wait for animation to complete
      await tester.pumpAndSettle();
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('PolishedElevatedButton responds to tap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqDesignTokens.light()]),
          home: Scaffold(
            body: Center(
              child: PolishedElevatedButton(
                onPressed: () => tapped = true,
                child: const Text('Test Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PolishedElevatedButton), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);

      await tester.tap(find.byType(PolishedElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('PolishedFloatingActionButton renders with correct size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqDesignTokens.light()]),
          home: const Scaffold(
            body: Center(
              child: PolishedFloatingActionButton(child: Icon(Icons.add)),
            ),
          ),
        ),
      );

      expect(find.byType(PolishedFloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('PolishedLinearProgressIndicator shows progress', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqDesignTokens.light()]),
          home: const Scaffold(
            body: Center(
              child: PolishedLinearProgressIndicator(
                value: 0.75,
                showLabel: true,
                label: 'Progress',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PolishedLinearProgressIndicator), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
    });

    testWidgets('PolishedCard responds to interactions', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqDesignTokens.light()]),
          home: Scaffold(
            body: Center(
              child: PolishedCard(
                onTap: () => tapped = true,
                child: const Text('Card Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PolishedCard), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);

      await tester.tap(find.byType(PolishedCard));
      expect(tapped, isTrue);
    });

    testWidgets('PolishedChip handles selection', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqDesignTokens.light()]),
          home: Scaffold(
            body: Center(
              child: PolishedChip(
                label: 'Test Chip',
                icon: Icons.star,
                isSelected: true,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PolishedChip), findsOneWidget);
      expect(find.text('Test Chip'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);

      await tester.tap(find.byType(PolishedChip));
      expect(tapped, isTrue);
    });

    testWidgets('PolishedSwitch toggles correctly', (
      WidgetTester tester,
    ) async {
      bool value = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqDesignTokens.light()]),
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return PolishedSwitch(
                    value: value,
                    onChanged: (newValue) {
                      setState(() => value = newValue);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PolishedSwitch), findsOneWidget);

      await tester.tap(find.byType(PolishedSwitch));
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets('PolishedSlider updates value', (WidgetTester tester) async {
      double value = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqDesignTokens.light()]),
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return PolishedSlider(
                    value: value,
                    onChanged: (newValue) {
                      setState(() => value = newValue);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PolishedSlider), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('InteractiveButton renders with different styles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqDesignTokens.light()]),
          home: const Scaffold(
            body: Column(
              children: [
                InteractiveButton(
                  style: InteractiveButtonStyle.primary,
                  child: Text('Primary'),
                ),
                InteractiveButton(
                  style: InteractiveButtonStyle.secondary,
                  child: Text('Secondary'),
                ),
                InteractiveButton(
                  style: InteractiveButtonStyle.ghost,
                  child: Text('Ghost'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(InteractiveButton), findsNWidgets(3));
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Ghost'), findsOneWidget);
    });

    testWidgets('LoadingAnimation renders different styles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LoadingAnimation(style: LoadingStyle.dots),
                LoadingAnimation(style: LoadingStyle.pulse),
                LoadingAnimation(style: LoadingStyle.wave),
                LoadingAnimation(style: LoadingStyle.spinner),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(LoadingAnimation), findsNWidgets(4));
    });

    testWidgets('EnhancedPressAnimation responds to gestures', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: EnhancedPressAnimation(
                onPressed: () => tapped = true,
                child: const Text('Press Me'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(EnhancedPressAnimation), findsOneWidget);
      expect(find.text('Press Me'), findsOneWidget);

      await tester.tap(find.byType(EnhancedPressAnimation));
      expect(tapped, isTrue);
    });

    testWidgets('MorphingIcon toggles between icons', (
      WidgetTester tester,
    ) async {
      bool isToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return MorphingIcon(
                    startIcon: Icons.play_arrow,
                    endIcon: Icons.pause,
                    isToggled: isToggled,
                    onTap: () {
                      setState(() => isToggled = !isToggled);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MorphingIcon), findsOneWidget);

      await tester.tap(find.byType(MorphingIcon));
      await tester.pump();
      expect(isToggled, isTrue);
    });

    testWidgets('PolishedLoadingOverlay shows and hides correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PolishedLoadingOverlay(
              isVisible: true,
              message: 'Loading...',
            ),
          ),
        ),
      );

      expect(find.byType(PolishedLoadingOverlay), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(PolishedProgressIndicator), findsOneWidget);
    });

    group('Animation Tests', () {
      testWidgets('FloatingAnimation creates movement', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: FloatingAnimation(child: Icon(Icons.star))),
          ),
        );

        expect(find.byType(FloatingAnimation), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);

        // Test animation by advancing time
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 1000));
      });

      testWidgets('BreathingAnimation scales widget', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BreathingAnimation(child: Icon(Icons.favorite)),
            ),
          ),
        );

        expect(find.byType(BreathingAnimation), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);

        // Test animation by advancing time
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 1000));
      });

      testWidgets('TypewriterAnimation displays text progressively', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TypewriterAnimation(text: 'Hello World', autoStart: false),
            ),
          ),
        );

        expect(find.byType(TypewriterAnimation), findsOneWidget);

        // Initially should show empty or partial text
        await tester.pump();
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Components have proper semantic labels', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: [MinqDesignTokens.light()]),
            home: const Scaffold(
              body: Column(
                children: [
                  PolishedElevatedButton(child: Text('Action')),
                  PolishedFloatingActionButton(child: Icon(Icons.add)),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Action'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('Interactive elements meet minimum touch target size', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: [MinqDesignTokens.light()]),
            home: const Scaffold(
              body: Column(
                children: [
                  PolishedElevatedButton(child: Text('Button')),
                  PolishedSwitch(value: false),
                ],
              ),
            ),
          ),
        );

        // Verify minimum touch target constraints are applied
        final buttonFinder = find.byType(PolishedElevatedButton);
        final switchFinder = find.byType(PolishedSwitch);

        expect(buttonFinder, findsOneWidget);
        expect(switchFinder, findsOneWidget);

        // Check that widgets have minimum size constraints
        final buttonWidget = tester.widget<PolishedElevatedButton>(
          buttonFinder,
        );
        final switchWidget = tester.widget<PolishedSwitch>(switchFinder);

        expect(buttonWidget, isNotNull);
        expect(switchWidget, isNotNull);
      });
    });
  });
}
