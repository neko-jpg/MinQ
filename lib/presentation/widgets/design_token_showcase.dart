import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

/// Design Token Showcase Widget
/// 
/// This widget demonstrates how to use the MinQ design tokens
/// and serves as a reference for developers migrating from hardcoded values.
class DesignTokenShowcase extends StatelessWidget {
  const DesignTokenShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Token Showcase'),
      ),
      body: SingleChildScrollView(
        padding: tokens.spacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildColorSection(context, tokens),
            SizedBox(height: tokens.spacing.sectionGap),
            _buildTypographySection(context, tokens),
            SizedBox(height: tokens.spacing.sectionGap),
            _buildSpacingSection(context, tokens),
            SizedBox(height: tokens.spacing.sectionGap),
            _buildButtonSection(context, tokens),
            SizedBox(height: tokens.spacing.sectionGap),
            _buildCardSection(context, tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(BuildContext context, MinqDesignTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colors',
          style: tokens.typography.headlineSmall.copyWith(
            color: tokens.colors.onSurface,
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        Wrap(
          spacing: tokens.spacing.sm,
          runSpacing: tokens.spacing.sm,
          children: [
            _buildColorSwatch('Primary', tokens.colors.primary, tokens.colors.onPrimary),
            _buildColorSwatch('Secondary', tokens.colors.secondary, tokens.colors.onSecondary),
            _buildColorSwatch('Tertiary', tokens.colors.tertiary, tokens.colors.onTertiary),
            _buildColorSwatch('Error', tokens.colors.error, tokens.colors.onError),
            _buildColorSwatch('Warning', tokens.colors.warning, tokens.colors.onWarning),
            _buildColorSwatch('Success', tokens.colors.success, tokens.colors.onSuccess),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSwatch(String label, Color backgroundColor, Color textColor) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTypographySection(BuildContext context, MinqDesignTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography',
          style: tokens.typography.headlineSmall.copyWith(
            color: tokens.colors.onSurface,
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        _buildTypographyExample('Display Large', tokens.typography.displayLarge, tokens),
        _buildTypographyExample('Headline Large', tokens.typography.headlineLarge, tokens),
        _buildTypographyExample('Title Large', tokens.typography.titleLarge, tokens),
        _buildTypographyExample('Body Large', tokens.typography.bodyLarge, tokens),
        _buildTypographyExample('Label Large', tokens.typography.labelLarge, tokens),
      ],
    );
  }

  Widget _buildTypographyExample(String label, TextStyle style, MinqDesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tokens.typography.labelSmall.copyWith(
              color: tokens.colors.onSurfaceVariant,
            ),
          ),
          Text(
            'The quick brown fox jumps over the lazy dog',
            style: style.copyWith(color: tokens.colors.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingSection(BuildContext context, MinqDesignTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spacing',
          style: tokens.typography.headlineSmall.copyWith(
            color: tokens.colors.onSurface,
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        _buildSpacingExample('XS (4px)', MinqSpacingTokens.xs, tokens),
        _buildSpacingExample('SM (8px)', MinqSpacingTokens.sm, tokens),
        _buildSpacingExample('MD (12px)', MinqSpacingTokens.md, tokens),
        _buildSpacingExample('LG (16px)', MinqSpacingTokens.lg, tokens),
        _buildSpacingExample('XL (20px)', MinqSpacingTokens.xl, tokens),
        _buildSpacingExample('XXL (24px)', MinqSpacingTokens.xxl, tokens),
      ],
    );
  }

  Widget _buildSpacingExample(String label, double spacing, MinqDesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: tokens.typography.labelSmall.copyWith(
                color: tokens.colors.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            width: spacing,
            height: 20,
            decoration: BoxDecoration(
              color: tokens.colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context, MinqDesignTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buttons',
          style: tokens.typography.headlineSmall.copyWith(
            color: tokens.colors.onSurface,
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        Wrap(
          spacing: tokens.spacing.sm,
          runSpacing: tokens.spacing.sm,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardSection(BuildContext context, MinqDesignTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cards',
          style: tokens.typography.headlineSmall.copyWith(
            color: tokens.colors.onSurface,
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        Card(
          child: Padding(
            padding: tokens.spacing.cardPaddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Title',
                  style: tokens.typography.titleMedium.copyWith(
                    color: tokens.colors.onSurface,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  'This is a card using design tokens for consistent spacing, colors, and typography.',
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.colors.onSurface,
                  ),
                ),
                SizedBox(height: tokens.spacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Action'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Example of how to migrate from hardcoded values to design tokens
class MigrationExample extends StatelessWidget {
  const MigrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        // ❌ OLD WAY - Hardcoded values
        Container(
          padding: const EdgeInsets.all(16.0), // Hardcoded
          margin: const EdgeInsets.symmetric(horizontal: 20.0), // Hardcoded
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2), // Hardcoded
            borderRadius: BorderRadius.circular(12.0), // Hardcoded
          ),
          child: const Text(
            'Old way with hardcoded values',
            style: TextStyle( // Hardcoded
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ✅ NEW WAY - Using design tokens
        Container(
          padding: tokens.spacing.cardPaddingAll, // Design token
          margin: tokens.spacing.horizontal(tokens.spacing.xl), // Design token
          decoration: BoxDecoration(
            color: tokens.colors.primary, // Design token
            borderRadius: tokens.radius.cardRadius, // Design token
          ),
          child: Text(
            'New way with design tokens',
            style: tokens.typography.bodyLarge.copyWith( // Design token
              color: tokens.colors.onPrimary, // Design token
            ),
          ),
        ),
      ],
    );
  }
}