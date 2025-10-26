import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/common/layout/safe_scaffold.dart';

void main() {
  group('SafeScaffold', () {
    testWidgets('wraps body in SafeArea', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SafeScaffold(
            body: Container(
              key: const Key('test-body'),
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byKey(const Key('test-body')), findsOneWidget);
    });

    testWidgets('applies responsive layout when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SafeScaffold(
            enableResponsiveLayout: true,
            body: Container(
              key: const Key('test-body'),
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.byType(LayoutBuilder), findsOneWidget);
      expect(find.byKey(const Key('test-body')), findsOneWidget);
    });

    testWidgets('skips responsive layout when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SafeScaffold(
            enableResponsiveLayout: false,
            body: Container(
              key: const Key('test-body'),
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test-body')), findsOneWidget);
    });
  });

  group('SafeScrollView', () {
    testWidgets('creates scrollable column', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeScrollView(
              children: [
                Container(height: 100, child: const Text('Item 1')),
                Container(height: 100, child: const Text('Item 2')),
                Container(height: 100, child: const Text('Item 3')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('applies responsive layout when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeScrollView(
              enableResponsiveLayout: true,
              children: [
                Container(height: 100, child: const Text('Item 1')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(LayoutBuilder), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });
  });

  group('SafeFlex', () {
    testWidgets('wraps children in Flexible widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeFlex(
              children: [
                Container(width: 100, height: 50, child: const Text('Item 1')),
                Container(width: 100, height: 50, child: const Text('Item 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Flex), findsOneWidget);
      expect(find.byType(Flexible), findsNWidgets(2));
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('preserves existing Flexible and Expanded widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeFlex(
              children: [
                Expanded(child: Container(child: const Text('Expanded'))),
                Flexible(child: Container(child: const Text('Flexible'))),
                Container(child: const Text('Regular')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Expanded), findsOneWidget);
      expect(find.byType(Flexible), findsNWidgets(2)); // Original + wrapped regular
      expect(find.text('Expanded'), findsOneWidget);
      expect(find.text('Flexible'), findsOneWidget);
      expect(find.text('Regular'), findsOneWidget);
    });
  });

  group('SafeRow', () {
    testWidgets('creates horizontal flex layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeRow(
              children: [
                Container(width: 50, height: 50, child: const Text('1')),
                Container(width: 50, height: 50, child: const Text('2')),
              ],
            ),
          ),
        ),
      );

      final flex = tester.widget<Flex>(find.byType(Flex));
      expect(flex.direction, Axis.horizontal);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('SafeColumn', () {
    testWidgets('creates vertical flex layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeColumn(
              children: [
                Container(width: 50, height: 50, child: const Text('1')),
                Container(width: 50, height: 50, child: const Text('2')),
              ],
            ),
          ),
        ),
      );

      final flex = tester.widget<Flex>(find.byType(Flex));
      expect(flex.direction, Axis.vertical);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}