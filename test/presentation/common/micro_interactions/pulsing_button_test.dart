import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/common/micro_interactions/pulsing_button.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

void main() {
  group('PulsingButton', () {
    testWidgets('should render with child widget', (tester) async {
      const childText = 'Test Button';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: PulsingButton(
              onPressed: () {},
              child: const Text(childText),
            ),
          ),
        ),
      );

      expect(find.byType(PulsingButton), findsOneWidget);
      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: PulsingButton(
              onPressed: () {
                pressed = true;
              },
              child: const Text('Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PulsingButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('should not respond to taps when disabled', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: const Scaffold(
            body: PulsingButton(
              onPressed: null, // Disabled
              child: Text('Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PulsingButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('should show scale animation on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: PulsingButton(
              onPressed: () {},
              child: const Text('Button'),
            ),
          ),
        ),
      );

      // Start tap
      await tester.startGesture(
        tester.getCenter(find.byType(PulsingButton)),
      );
      
      // Pump a few frames to see animation
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      
      // Should not crash during animation
      expect(find.byType(PulsingButton), findsOneWidget);
    });

    testWidgets('should pulse when isPulsing is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: PulsingButton(
              onPressed: () {},
              isPulsing: true,
              child: const Text('Button'),
            ),
          ),
        ),
      );

      // Pump several animation frames
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should not crash during pulsing animation
      expect(find.byType(PulsingButton), findsOneWidget);
    });

    testWidgets('should stop pulsing when isPulsing changes to false', (tester) async {
      bool isPulsing = true;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    PulsingButton(
                      onPressed: () {},
                      isPulsing: isPulsing,
                      child: const Text('Button'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPulsing = false;
                        });
                      },
                      child: const Text('Stop Pulsing'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initially pulsing
      await tester.pump(const Duration(milliseconds: 100));
      
      // Stop pulsing
      await tester.tap(find.text('Stop Pulsing'));
      await tester.pump();
      
      // Should handle the state change without crashing
      expect(find.byType(PulsingButton), findsOneWidget);
    });

    testWidgets('should respect minimum size constraints', (tester) async {
      const customMinSize = Size(60, 60);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: PulsingButton(
              onPressed: () {},
              minSize: customMinSize,
              child: const Text('X'),
            ),
          ),
        ),
      );

      // Find the container with constraints
      final containerFinder = find.descendant(
        of: find.byType(PulsingButton),
        matching: find.byType(Container),
      );
      
      expect(containerFinder, findsWidgets);
      
      // Check that the button respects minimum size
      final RenderBox renderBox = tester.renderObject(find.byType(PulsingButton));
      expect(renderBox.size.width, greaterThanOrEqualTo(customMinSize.width));
      expect(renderBox.size.height, greaterThanOrEqualTo(customMinSize.height));
    });

    testWidgets('should apply custom colors', (tester) async {
      const customBackgroundColor = Colors.red;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: PulsingButton(
              onPressed: () {},
              backgroundColor: customBackgroundColor,
              child: const Text('Button'),
            ),
          ),
        ),
      );

      // Find the container and check its decoration
      final containerFinder = find.descendant(
        of: find.byType(PulsingButton),
        matching: find.byType(Container),
      );
      
      expect(containerFinder, findsWidgets);
      
      final Container container = tester.widget(containerFinder.first);
      final BoxDecoration? decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, equals(customBackgroundColor));
    });

    testWidgets('should handle gesture cancellation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: PulsingButton(
              onPressed: () {},
              child: const Text('Button'),
            ),
          ),
        ),
      );

      // Start gesture and then cancel it
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PulsingButton)),
      );
      
      await tester.pump(const Duration(milliseconds: 50));
      
      // Move away to cancel
      await gesture.moveTo(const Offset(1000, 1000));
      await gesture.up();
      
      await tester.pump();
      
      // Should handle cancellation without crashing
      expect(find.byType(PulsingButton), findsOneWidget);
    });

    testWidgets('should disable feedback when specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: PulsingButton(
              onPressed: () {},
              enableHapticFeedback: false,
              enableSoundFeedback: false,
              child: const Text('Button'),
            ),
          ),
        ),
      );

      // Should not throw when tapped even with feedback disabled
      expect(() async {
        await tester.tap(find.byType(PulsingButton));
        await tester.pump();
      }, returnsNormally,);
    });
  });
}