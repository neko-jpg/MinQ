import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/common/layout/responsive_layout.dart';

void main() {
  group('ResponsiveLayout', () {
    testWidgets('getScreenType returns correct type for different widths', (tester) async {
      expect(ResponsiveLayout.getScreenType(500), ScreenType.mobile);
      expect(ResponsiveLayout.getScreenType(700), ScreenType.tablet);
      expect(ResponsiveLayout.getScreenType(1000), ScreenType.desktop);
      expect(ResponsiveLayout.getScreenType(1300), ScreenType.largeDesktop);
    });

    testWidgets('ensureTouchTarget enforces minimum size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout.ensureTouchTarget(
              child: Container(
                width: 20,
                height: 20,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final constrainedBox = tester.widget<ConstrainedBox>(find.byType(ConstrainedBox));
      
      expect(constrainedBox.constraints.minWidth, ResponsiveLayout.minTouchTarget);
      expect(constrainedBox.constraints.minHeight, ResponsiveLayout.minTouchTarget);
    });

    testWidgets('constrainedContainer applies max width constraint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              child: ResponsiveLayout.constrainedContainer(
                maxWidth: 600,
                child: Container(color: Colors.blue),
              ),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(find.byType(ConstrainedBox));
      expect(constrainedBox.constraints.maxWidth, 600);
    });

    testWidgets('getResponsiveColumns returns correct count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Container(),
              );
            },
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(500, 800));
      await tester.pumpAndSettle();
      
      final context = tester.element(find.byType(Container));
      expect(ResponsiveLayout.getResponsiveColumns(context), 2);

      await tester.binding.setSurfaceSize(const Size(700, 800));
      await tester.pumpAndSettle();
      expect(ResponsiveLayout.getResponsiveColumns(context), 3);

      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpAndSettle();
      expect(ResponsiveLayout.getResponsiveColumns(context), 4);
    });
  });

  group('ResponsiveContext extension', () {
    testWidgets('provides correct screen type information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    Text('Mobile: ${context.isMobile}'),
                    Text('Tablet: ${context.isTablet}'),
                    Text('Desktop: ${context.isDesktop}'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(500, 800));
      await tester.pumpAndSettle();
      
      expect(find.text('Mobile: true'), findsOneWidget);
      expect(find.text('Tablet: false'), findsOneWidget);
      expect(find.text('Desktop: false'), findsOneWidget);

      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(700, 800));
      await tester.pumpAndSettle();
      
      expect(find.text('Mobile: false'), findsOneWidget);
      expect(find.text('Tablet: true'), findsOneWidget);
      expect(find.text('Desktop: false'), findsOneWidget);
    });
  });
}