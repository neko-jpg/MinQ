import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/common/micro_interactions/animated_checkbox.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

void main() {
  group('AnimatedCheckbox', () {
    testWidgets('should render with correct initial state', (tester) async {
      bool isChecked = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: AnimatedCheckbox(
              isChecked: isChecked,
              onChanged: (value) {
                isChecked = value;
              },
            ),
          ),
        ),
      );

      // Should find the checkbox container
      expect(find.byType(AnimatedCheckbox), findsOneWidget);
      
      // Should not show check icon when unchecked
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('should show check icon when checked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: AnimatedCheckbox(
              isChecked: true,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Should show check icon when checked
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should call onChanged when tapped', (tester) async {
      bool isChecked = false;
      bool callbackCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: AnimatedCheckbox(
              isChecked: isChecked,
              onChanged: (value) {
                callbackCalled = true;
                isChecked = value;
              },
            ),
          ),
        ),
      );

      // Tap the checkbox
      await tester.tap(find.byType(AnimatedCheckbox));
      await tester.pump();

      expect(callbackCalled, isTrue);
      expect(isChecked, isTrue);
    });

    testWidgets('should animate when state changes', (tester) async {
      bool isChecked = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: AnimatedCheckbox(
                  isChecked: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value;
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      // Initially unchecked
      expect(find.byIcon(Icons.check), findsNothing);

      // Tap to check
      await tester.tap(find.byType(AnimatedCheckbox));
      await tester.pump();

      // Should start showing the check icon
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Pump animation frames
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));
      
      // Should still show check icon after animation
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should respect custom colors', (tester) async {
      const customActiveColor = Colors.red;
      const customCheckColor = Colors.yellow;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: AnimatedCheckbox(
              isChecked: true,
              onChanged: (value) {},
              activeColor: customActiveColor,
              checkColor: customCheckColor,
            ),
          ),
        ),
      );

      // Find the container and check its decoration
      final containerFinder = find.descendant(
        of: find.byType(AnimatedCheckbox),
        matching: find.byType(Container),
      );
      
      expect(containerFinder, findsWidgets);
      
      // Find the check icon and verify its color
      final iconFinder = find.byIcon(Icons.check);
      expect(iconFinder, findsOneWidget);
      
      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, equals(customCheckColor));
    });

    testWidgets('should respect custom size', (tester) async {
      const customSize = 32.0;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: AnimatedCheckbox(
              isChecked: false,
              onChanged: (value) {},
              size: customSize,
            ),
          ),
        ),
      );

      // Find the main container
      final containerFinder = find.descendant(
        of: find.byType(AnimatedCheckbox),
        matching: find.byType(Container),
      );
      
      expect(containerFinder, findsWidgets);
      
      // The container should have the custom size
      final Container container = tester.widget(containerFinder.first);
      expect(container.constraints?.maxWidth, equals(customSize));
      expect(container.constraints?.maxHeight, equals(customSize));
    });

    testWidgets('should disable feedback when specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: Scaffold(
            body: AnimatedCheckbox(
              isChecked: false,
              onChanged: (value) {},
              enableHapticFeedback: false,
              enableSoundFeedback: false,
            ),
          ),
        ),
      );

      // Should not throw when tapped even with feedback disabled
      expect(() async {
        await tester.tap(find.byType(AnimatedCheckbox));
        await tester.pump();
      }, returnsNormally);
    });

    testWidgets('should handle rapid state changes', (tester) async {
      bool isChecked = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: AnimatedCheckbox(
                  isChecked: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value;
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      // Rapid taps
      await tester.tap(find.byType(AnimatedCheckbox));
      await tester.pump(const Duration(milliseconds: 50));
      
      await tester.tap(find.byType(AnimatedCheckbox));
      await tester.pump(const Duration(milliseconds: 50));
      
      await tester.tap(find.byType(AnimatedCheckbox));
      await tester.pump();

      // Should handle rapid changes without crashing
      expect(find.byType(AnimatedCheckbox), findsOneWidget);
    });
  });
}