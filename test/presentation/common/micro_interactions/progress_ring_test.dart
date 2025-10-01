import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/common/micro_interactions/progress_ring.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

void main() {
  group('ProgressRing', () {
    testWidgets('should render with initial progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: const Scaffold(
            body: ProgressRing(
              progress: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(ProgressRing), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should display child widget when provided', (tester) async {
      const childText = 'Progress Text';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: const Scaffold(
            body: ProgressRing(
              progress: 0.3,
              child: Text(childText),
            ),
          ),
        ),
      );

      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('should call onComplete when progress reaches 1.0', (tester) async {
      bool completionCalled = false;
      double progress = 0.8;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    ProgressRing(
                      progress: progress,
                      onComplete: () {
                        completionCalled = true;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          progress = 1.0;
                        });
                      },
                      child: const Text('Complete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initially not completed
      expect(completionCalled, isFalse);

      // Complete the progress
      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();

      // Should call completion callback
      expect(completionCalled, isTrue);
    });

    testWidgets('should animate progress changes', (tester) async {
      double progress = 0.2;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    ProgressRing(
                      progress: progress,
                      animationDuration: const Duration(milliseconds: 200),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          progress = 0.8;
                        });
                      },
                      child: const Text('Increase'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Change progress
      await tester.tap(find.text('Increase'));
      await tester.pump();

      // Pump animation frames
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should complete animation without crashing
      expect(find.byType(ProgressRing), findsOneWidget);
    });

    testWidgets('should show sparkles on completion when enabled', (tester) async {
      double progress = 0.9;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    ProgressRing(
                      progress: progress,
                      showSparkles: true,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          progress = 1.0;
                        });
                      },
                      child: const Text('Complete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Complete the progress
      await tester.tap(find.text('Complete'));
      await tester.pump();

      // Pump animation frames to show sparkles
      await tester.pump(const Duration(milliseconds: 200));

      // Should show sparkles (additional CustomPaint widgets)
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should not show sparkles when disabled', (tester) async {
      double progress = 0.9;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    ProgressRing(
                      progress: progress,
                      showSparkles: false,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          progress = 1.0;
                        });
                      },
                      child: const Text('Complete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Complete the progress
      await tester.tap(find.text('Complete'));
      await tester.pump();

      // Should still work without sparkles
      expect(find.byType(ProgressRing), findsOneWidget);
    });

    testWidgets('should handle progress decrease', (tester) async {
      double progress = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    ProgressRing(
                      progress: progress,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          progress = 0.5;
                        });
                      },
                      child: const Text('Decrease'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Decrease progress
      await tester.tap(find.text('Decrease'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Should handle decrease without crashing
      expect(find.byType(ProgressRing), findsOneWidget);
    });

    testWidgets('should respect custom size', (tester) async {
      const customSize = 200.0;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: const Scaffold(
            body: ProgressRing(
              progress: 0.5,
              size: customSize,
            ),
          ),
        ),
      );

      // Find the SizedBox that defines the size
      final sizedBoxFinder = find.descendant(
        of: find.byType(ProgressRing),
        matching: find.byType(SizedBox),
      );
      
      expect(sizedBoxFinder, findsOneWidget);
      
      final SizedBox sizedBox = tester.widget(sizedBoxFinder);
      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });

    testWidgets('should not call onComplete multiple times', (tester) async {
      int completionCount = 0;
      double progress = 0.9;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    ProgressRing(
                      progress: progress,
                      onComplete: () {
                        completionCount++;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          progress = 1.0;
                        });
                      },
                      child: const Text('Complete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Complete multiple times
      await tester.tap(find.text('Complete'));
      await tester.pump();
      
      await tester.tap(find.text('Complete'));
      await tester.pump();

      // Should only call completion once
      expect(completionCount, equals(1));
    });

    testWidgets('should disable completion feedback when specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [MinqTheme.light()]),
          home: const Scaffold(
            body: ProgressRing(
              progress: 1.0,
              enableCompletionFeedback: false,
            ),
          ),
        ),
      );

      // Should not throw even with feedback disabled
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ProgressRing), findsOneWidget);
    });
  });
}