import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:minq/presentation/theme/minq_theme_v2.dart';
import 'package:minq/presentation/theme/color_tokens.dart';

void main() {
  group('MinQ Theme v2.0 Tests', () {
    testWidgets('Light theme builds without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: MinqThemeV2.light(),
          home: const ThemeShowcaseScreen(),
        ),
      );

      expect(find.byType(ThemeShowcaseScreen), findsOneWidget);
    });

    testWidgets('Dark theme builds without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: MinqThemeV2.dark(),
          home: const ThemeShowcaseScreen(),
        ),
      );

      expect(find.byType(ThemeShowcaseScreen), findsOneWidget);
    });

    testWidgets('Color palette showcase builds without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: MinqThemeV2.light(),
          home: const ColorPaletteShowcase(),
        ),
      );

      expect(find.byType(ColorPaletteShowcase), findsOneWidget);
    });
  });

  group('Color Token Tests', () {
    test('Light theme colors meet WCAG AA standards', () {
      const colors = ColorTokens.light;

      // Test primary color combinations
      expect(
        colors.meetsWCAGAA(colors.onPrimary, colors.primary),
        isTrue,
        reason:
            'onPrimary (${colors.onPrimary}) should have sufficient contrast on primary (${colors.primary})',
      );
      expect(
        colors.meetsWCAGAA(colors.onSecondary, colors.secondary),
        isTrue,
        reason:
            'onSecondary (${colors.onSecondary}) should have sufficient contrast on secondary (${colors.secondary})',
      );
      expect(
        colors.meetsWCAGAA(colors.onTertiary, colors.tertiary),
        isTrue,
        reason:
            'onTertiary (${colors.onTertiary}) should have sufficient contrast on tertiary (${colors.tertiary})',
      );

      // Test text on background combinations
      expect(
        colors.meetsWCAGAA(colors.textPrimary, colors.background),
        isTrue,
        reason:
            'textPrimary (${colors.textPrimary}) should have sufficient contrast on background (${colors.background})',
      );
      expect(
        colors.meetsWCAGAA(colors.textPrimary, colors.surface),
        isTrue,
        reason:
            'textPrimary (${colors.textPrimary}) should have sufficient contrast on surface (${colors.surface})',
      );
      expect(
        colors.meetsWCAGAA(colors.textSecondary, colors.background),
        isTrue,
        reason:
            'textSecondary (${colors.textSecondary}) should have sufficient contrast on background (${colors.background})',
      );

      // Test semantic color combinations
      expect(
        colors.meetsWCAGAA(colors.onError, colors.error),
        isTrue,
        reason:
            'onError (${colors.onError}) should have sufficient contrast on error (${colors.error})',
      );
      expect(
        colors.meetsWCAGAA(colors.onWarning, colors.warning),
        isTrue,
        reason:
            'onWarning (${colors.onWarning}) should have sufficient contrast on warning (${colors.warning})',
      );
      expect(
        colors.meetsWCAGAA(colors.onSuccess, colors.success),
        isTrue,
        reason:
            'onSuccess (${colors.onSuccess}) should have sufficient contrast on success (${colors.success})',
      );
      expect(
        colors.meetsWCAGAA(colors.onInfo, colors.info),
        isTrue,
        reason:
            'onInfo (${colors.onInfo}) should have sufficient contrast on info (${colors.info})',
      );
    });

    test('Dark theme colors meet WCAG AA standards', () {
      const colors = ColorTokens.dark;

      // Test primary color combinations
      expect(colors.meetsWCAGAA(colors.onPrimary, colors.primary), isTrue);
      expect(colors.meetsWCAGAA(colors.onSecondary, colors.secondary), isTrue);
      expect(colors.meetsWCAGAA(colors.onTertiary, colors.tertiary), isTrue);

      // Test text on background combinations
      expect(colors.meetsWCAGAA(colors.textPrimary, colors.background), isTrue);
      expect(colors.meetsWCAGAA(colors.textPrimary, colors.surface), isTrue);
      expect(
        colors.meetsWCAGAA(colors.textSecondary, colors.background),
        isTrue,
      );

      // Test semantic color combinations
      expect(colors.meetsWCAGAA(colors.onError, colors.error), isTrue);
      expect(colors.meetsWCAGAA(colors.onWarning, colors.warning), isTrue);
      expect(colors.meetsWCAGAA(colors.onSuccess, colors.success), isTrue);
      expect(colors.meetsWCAGAA(colors.onInfo, colors.info), isTrue);
    });

    test('Brand colors match specification', () {
      const lightColors = ColorTokens.light;
      const darkColors = ColorTokens.dark;

      // Test Midnight Indigo primary
      expect(lightColors.primary, equals(const Color(0xFF4F46E5)));

      // Test Aurora Violet secondary
      expect(lightColors.secondary, equals(const Color(0xFF8B5CF6)));

      // Test Horizon Teal tertiary
      expect(lightColors.tertiary, equals(const Color(0xFF14B8A6)));

      // Test dark theme adjustments
      expect(darkColors.primary, equals(const Color(0xFF818CF8)));
      expect(darkColors.secondary, equals(const Color(0xFFA78BFA)));
      expect(darkColors.tertiary, equals(const Color(0xFF2DD4BF)));
    });
  });
}

/// Widget to showcase theme components for golden tests
class ThemeShowcaseScreen extends StatelessWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Showcase'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Typography Section
            Text(
              'Typography',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Display Large',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              'Headline Large',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
            Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
            Text('Label Large', style: Theme.of(context).textTheme.labelLarge),

            const SizedBox(height: 32),

            // Buttons Section
            Text('Buttons', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                TextButton(onPressed: () {}, child: const Text('Text')),
              ],
            ),

            const SizedBox(height: 32),

            // Form Elements Section
            Text(
              'Form Elements',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Text Field',
                hintText: 'Enter text here',
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Checkbox(value: true, onChanged: (value) {}),
                const Text('Checkbox'),
                const SizedBox(width: 16),
                Radio<bool>(
                  value: true,
                  groupValue: true,
                  onChanged: (value) {},
                ),
                const Text('Radio'),
                const SizedBox(width: 16),
                Switch(value: true, onChanged: (value) {}),
                const Text('Switch'),
              ],
            ),

            const SizedBox(height: 32),

            // Cards Section
            Text('Cards', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card Title',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Card content goes here',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget to showcase color palette for golden tests
class ColorPaletteShowcase extends StatelessWidget {
  const ColorPaletteShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Color Palette')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Brand Colors',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            // Primary Colors
            _ColorSwatch(
              title: 'Primary (Midnight Indigo)',
              color: colorScheme.primary,
              onColor: colorScheme.onPrimary,
            ),

            _ColorSwatch(
              title: 'Secondary (Aurora Violet)',
              color: colorScheme.secondary,
              onColor: colorScheme.onSecondary,
            ),

            _ColorSwatch(
              title: 'Tertiary (Horizon Teal)',
              color: colorScheme.tertiary,
              onColor: colorScheme.onTertiary,
            ),

            const SizedBox(height: 32),

            Text(
              'Semantic Colors',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            _ColorSwatch(
              title: 'Error',
              color: colorScheme.error,
              onColor: colorScheme.onError,
            ),

            _ColorSwatch(
              title: 'Surface',
              color: colorScheme.surface,
              onColor: colorScheme.onSurface,
            ),

            _ColorSwatch(
              title: 'Background',
              color: colorScheme.background,
              onColor: colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.title,
    required this.color,
    required this.onColor,
  });

  final String title;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(color: onColor, fontWeight: FontWeight.w600),
            ),
            Text(
              '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
              style:
                  TextStyle(color: onColor.withAlpha((255 * 0.8).round()), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
