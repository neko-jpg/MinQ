import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/common/layout/layout_fixes.dart';
import 'package:minq/presentation/common/layout/responsive_layout.dart';
import 'package:minq/presentation/common/layout/safe_scaffold.dart';

void main() {
  group('Layout Fixes Tests', () {
    testWidgets('fixRowOverflow prevents overflow with long content', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Constrained width to force overflow
              child: LayoutFixes.fixRowOverflow(
                children: [
                  Container(width: 100, height: 50, color: Colors.red),
                  Container(width: 100, height: 50, color: Colors.blue),
                  Container(width: 100, height: 50, color: Colors.green),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fixColumnOverflow creates scrollable content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200, // Constrained height
              child: LayoutFixes.fixColumnOverflow(
                children: List.generate(
                  10,
                  (index) => Container(
                    height: 50,
                    color: Colors.primaries[index % Colors.primaries.length],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('responsiveContainer adapts to screen size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutFixes.responsiveContainer(
              child: Container(
                width: 1000, // Wide content
                height: 100,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ConstrainedBox), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fixTextOverflow handles long text properly', (tester) async {
      final longText =
          'This is a very long text that should overflow if not handled properly. ' *
          10;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: LayoutFixes.fixTextOverflow(text: longText, maxLines: 2),
            ),
          ),
        ),
      );

      expect(find.byType(Flexible), findsOneWidget);
      expect(find.text(longText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('safeCard creates proper container', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutFixes.safeCard(
              child: const Text('Card Content'),
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('responsiveGrid adapts column count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutFixes.responsiveGrid(
              children: List.generate(
                6,
                (index) => Container(
                  color: Colors.primaries[index % Colors.primaries.length],
                ),
              ),
              mobileColumns: 2,
              tabletColumns: 3,
              desktopColumns: 4,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fixButtonLayout ensures minimum touch targets', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutFixes.fixButtonLayout(
              button: ElevatedButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.minWidth, ResponsiveLayout.minTouchTarget);
      expect(container.constraints?.minHeight, ResponsiveLayout.minTouchTarget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('safeForm handles keyboard and scrolling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutFixes.safeForm(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Field 1'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Field 2'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Field 3'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(KeyboardAwareWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fixAppBar creates proper app bar with touch targets', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: LayoutFixes.fixAppBar(
              title: 'Test Title',
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('responsiveBottomNavigation adapts to screen size', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LayoutFixes.responsiveBottomNavigation(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
              ],
              currentIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Safe Layout Components Tests', () {
    testWidgets('SafeScaffold handles responsive layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SafeScaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Text('Body Content'),
            enableResponsiveLayout: true,
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Body Content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SafeScrollView prevents overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeScrollView(
              children: List.generate(
                20,
                (index) => Container(
                  height: 100,
                  color: Colors.primaries[index % Colors.primaries.length],
                  child: Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SafeRow prevents overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: SafeRow(
                children: [
                  Container(width: 100, height: 50, color: Colors.red),
                  Container(width: 100, height: 50, color: Colors.blue),
                  Container(width: 100, height: 50, color: Colors.green),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Flex), findsOneWidget);
      expect(find.byType(Flexible), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('SafeText handles overflow', (tester) async {
      const longText =
          'This is a very long text that should be handled properly';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 100, child: const SafeText(longText)),
          ),
        ),
      );

      expect(find.byType(Flexible), findsOneWidget);
      expect(find.text(longText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('KeyboardAwareWidget handles keyboard insets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardAwareWidget(child: const Text('Content')),
          ),
        ),
      );

      expect(find.byType(Padding), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Responsive Layout Tests', () {
    testWidgets('ResponsiveLayout provides correct breakpoints', (
      tester,
    ) async {
      // Test mobile breakpoint
      expect(ResponsiveLayout.getScreenType(500), ScreenType.mobile);

      // Test tablet breakpoint
      expect(ResponsiveLayout.getScreenType(700), ScreenType.tablet);

      // Test desktop breakpoint
      expect(ResponsiveLayout.getScreenType(1000), ScreenType.desktop);

      // Test large desktop breakpoint
      expect(ResponsiveLayout.getScreenType(1300), ScreenType.largeDesktop);
    });

    testWidgets('ResponsiveLayout provides correct padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = ResponsiveLayout.getResponsivePadding(context);
              return Scaffold(
                body: Padding(padding: padding, child: const Text('Content')),
              );
            },
          ),
        ),
      );

      expect(find.byType(Padding), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ResponsiveLayout ensures touch targets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout.ensureTouchTarget(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      expect(
        constrainedBox.constraints.minWidth,
        ResponsiveLayout.minTouchTarget,
      );
      expect(
        constrainedBox.constraints.minHeight,
        ResponsiveLayout.minTouchTarget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
