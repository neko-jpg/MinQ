import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/app_theme.dart';
import 'package:minq/presentation/widgets/minq_buttons.dart';

void main() {
  group('Golden Tests - Buttons', () {
    testWidgets('Primary button - light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: MinqButton.primary(
                onPressed: () {},
                label: 'Primary Button',
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/button_primary_light.png'),
      );
    });

    testWidgets('Primary button - dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Center(
              child: MinqButton.primary(
                onPressed: () {},
                label: 'Primary Button',
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/button_primary_dark.png'),
      );
    });

    testWidgets('Secondary button - light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: MinqButton.secondary(
                onPressed: () {},
                label: 'Secondary Button',
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/button_secondary_light.png'),
      );
    });

    testWidgets('Disabled button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: MinqButton.primary(
                onPressed: null,
                label: 'Disabled Button',
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/button_disabled.png'),
      );
    });
  });

  group('Golden Tests - Device Sizes', () {
    testWidgets('Small device (iPhone SE)', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(title: const Text('Small Device')),
            body: const Center(
              child: Text('iPhone SE Size'),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/device_small.png'),
      );

      addTearDown(tester.view.reset);
    });

    testWidgets('Medium device (iPhone 14)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(title: const Text('Medium Device')),
            body: const Center(
              child: Text('iPhone 14 Size'),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/device_medium.png'),
      );

      addTearDown(tester.view.reset);
    });

    testWidgets('Large device (iPad)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(title: const Text('Large Device')),
            body: const Center(
              child: Text('iPad Size'),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/device_large.png'),
      );

      addTearDown(tester.view.reset);
    });
  });
}
