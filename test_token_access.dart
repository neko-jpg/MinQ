import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// Test widget to validate all token access patterns
class TokenAccessTestWidget extends StatelessWidget {
  const TokenAccessTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Token Access Test',
      home: Scaffold(
        backgroundColor: context.tokens.background,
        appBar: AppBar(
          backgroundColor: context.tokens.surface,
          title: Text(
            'Token Access Test',
            style: context.tokens.typography.h4,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.tokens.breathingPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorTests(context),
                SizedBox(height: context.tokens.spacing.lg),
                _buildSpacingTests(context),
                SizedBox(height: context.tokens.spacing.lg),
                _buildTypographyTests(context),
                SizedBox(height: context.tokens.spacing.lg),
                _buildRadiusTests(context),
                SizedBox(height: context.tokens.spacing.lg),
                _buildShadowTests(context),
                SizedBox(height: context.tokens.spacing.lg),
                _buildAccessibilityTests(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorTests(BuildContext context) {
    final tokens = context.tokens;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color Token Tests', style: tokens.typography.h3),
        SizedBox(height: tokens.spacing.md),
        
        // Primary colors
        _buildColorSwatch('Primary', tokens.primary),
        _buildColorSwatch('Primary Hover', tokens.primaryHover),
        _buildColorSwatch('Secondary', tokens.secondary),
        
        // Accent colors
        _buildColorSwatch('Accent Success', tokens.accentSuccess),
        _buildColorSwatch('Accent Warning', tokens.accentWarning),
        _buildColorSwatch('Accent Error', tokens.accentError),
        _buildColorSwatch('Encouragement', tokens.encouragement),
        _buildColorSwatch('Joy Accent', tokens.joyAccent),
        _buildColorSwatch('Serenity', tokens.serenity),
        _buildColorSwatch('Warmth', tokens.warmth),
        
        // Surface colors
        _buildColorSwatch('Background', tokens.background),
        _buildColorSwatch('Surface', tokens.surface),
        _buildColorSwatch('Surface Alt', tokens.surfaceAlt),
        _buildColorSwatch('Surface Variant', tokens.surfaceVariant),
        
        // Text colors
        _buildColorSwatch('Text Primary', tokens.textPrimary),
        _buildColorSwatch('Text Secondary', tokens.textSecondary),
        _buildColorSwatch('Text Muted', tokens.textMuted),
        
        // Border and divider
        _buildColorSwatch('Border', tokens.border),
        _buildColorSwatch('Divider', tokens.divider),
        
        // State colors
        _buildColorSwatch('Success', tokens.success),
        _buildColorSwatch('Error', tokens.error),
      ],
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingTests(BuildContext context) {
    final tokens = context.tokens;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Spacing Token Tests', style: tokens.typography.h3),
        SizedBox(height: tokens.spacing.md),
        
        // Test all spacing values
        _buildSpacingDemo('XS', tokens.spacing.xs),
        _buildSpacingDemo('SM', tokens.spacing.sm),
        _buildSpacingDemo('MD', tokens.spacing.md),
        _buildSpacingDemo('LG', tokens.spacing.lg),
        _buildSpacingDemo('XL', tokens.spacing.xl),
        _buildSpacingDemo('XXL', tokens.spacing.xxl),
        
        const SizedBox(height: 16),
        
        // Test breathing padding
        Container(
          padding: tokens.breathingPadding,
          decoration: BoxDecoration(
            color: tokens.surfaceAlt,
            borderRadius: tokens.cornerMedium(),
          ),
          child: Text(
            'Breathing Padding Test',
            style: tokens.typography.body,
          ),
        ),
      ],
    );
  }

  Widget _buildSpacingDemo(String name, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$name (${value}px)', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            width: value,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypographyTests(BuildContext context) {
    final tokens = context.tokens;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Typography Token Tests', style: tokens.typography.h3),
        SizedBox(height: tokens.spacing.md),
        
        // Test all typography styles
        Text('H1 Style', style: tokens.typography.h1),
        Text('H2 Style', style: tokens.typography.h2),
        Text('H3 Style', style: tokens.typography.h3),
        Text('H4 Style', style: tokens.typography.h4),
        Text('Body Style', style: tokens.typography.body),
        Text('Caption Style', style: tokens.typography.caption),
        
        const SizedBox(height: 16),
        
        // Test type scale access
        Text('Type Scale H1', style: tokens.typeScale.h1),
        Text('Type Scale Body Large', style: tokens.typeScale.bodyLarge),
        Text('Type Scale Button', style: tokens.typeScale.button),
      ],
    );
  }

  Widget _buildRadiusTests(BuildContext context) {
    final tokens = context.tokens;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Radius Token Tests', style: tokens.typography.h3),
        SizedBox(height: tokens.spacing.md),
        
        // Test all radius values
        _buildRadiusDemo('Small', tokens.cornerSmall()),
        _buildRadiusDemo('Medium', tokens.cornerMedium()),
        _buildRadiusDemo('Large', tokens.cornerLarge()),
        _buildRadiusDemo('X-Large', tokens.cornerXLarge()),
        _buildRadiusDemo('Full', tokens.cornerFull()),
        
        const SizedBox(height: 16),
        
        // Test radius scale access
        Row(
          children: [
            _buildRadiusScaleDemo('SM', tokens.radius.sm),
            const SizedBox(width: 8),
            _buildRadiusScaleDemo('MD', tokens.radius.md),
            const SizedBox(width: 8),
            _buildRadiusScaleDemo('LG', tokens.radius.lg),
            const SizedBox(width: 8),
            _buildRadiusScaleDemo('XL', tokens.radius.xl),
          ],
        ),
      ],
    );
  }

  Widget _buildRadiusDemo(String name, BorderRadius radius) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade200,
              borderRadius: radius,
              border: Border.all(color: Colors.blue.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusScaleDemo(String name, double value) {
    return Column(
      children: [
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: BorderRadius.circular(value),
            border: Border.all(color: Colors.green.shade400),
          ),
        ),
        Text('${value}px', style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildShadowTests(BuildContext context) {
    final tokens = context.tokens;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shadow Token Tests', style: tokens.typography.h3),
        SizedBox(height: tokens.spacing.md),
        
        Row(
          children: [
            Expanded(
              child: Container(
                height: 80,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: tokens.cornerMedium(),
                  boxShadow: tokens.shadowSoft,
                ),
                child: Center(
                  child: Text('Soft Shadow', style: tokens.typography.body),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 80,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: tokens.cornerMedium(),
                  boxShadow: tokens.shadowStrong,
                ),
                child: Center(
                  child: Text('Strong Shadow', style: tokens.typography.body),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccessibilityTests(BuildContext context) {
    final tokens = context.tokens;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accessibility Token Tests', style: tokens.typography.h3),
        SizedBox(height: tokens.spacing.md),
        
        // Test accessibility methods
        Container(
          padding: tokens.breathingPadding,
          decoration: BoxDecoration(
            color: tokens.surfaceAlt,
            borderRadius: tokens.cornerMedium(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'High Contrast Mode: ${MinqTokens.isHighContrastMode(context)}',
                style: tokens.typography.body,
              ),
              SizedBox(height: tokens.spacing.sm),
              Text(
                'Accessible Text Color Test',
                style: tokens.typography.body.copyWith(
                  color: MinqTokens.getAccessibleTextColor(context),
                ),
              ),
              SizedBox(height: tokens.spacing.sm),
              Text(
                'Animation Duration: ${MinqTokens.getAnimationDuration(context, const Duration(milliseconds: 300)).inMilliseconds}ms',
                style: tokens.typography.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Test function to validate all token access patterns programmatically
void testTokenAccessPatterns() {
  print('=== Token Access Pattern Tests ===');
  
  // Test static access patterns
  print('Testing static MinqTokens access...');
  assert(MinqTokens.primary == const Color(0xFF6366F1), 'Primary color mismatch');
  assert(MinqTokens.spacing.md == 16.0, 'Spacing MD mismatch');
  assert(MinqTokens.radius.sm == 8.0, 'Radius SM mismatch');
  print('✓ Static access patterns work');
  
  // Test const instances
  print('Testing const instances...');
  const spacing = SpacingScale();
  const radius = RadiusScale();
  const typeScale = TypeScale();
  const typography = TypographyTokens();
  
  assert(spacing.md == 16.0, 'SpacingScale MD mismatch');
  assert(radius.sm == 8.0, 'RadiusScale SM mismatch');
  assert(typeScale.h1.fontSize == 42, 'TypeScale H1 fontSize mismatch');
  assert(typography.body.fontSize == 15, 'Typography body fontSize mismatch');
  print('✓ Const instances work');
  
  // Test method calls
  print('Testing method calls...');
  final cornerSmall = MinqTokens.cornerSmall();
  final cornerMedium = MinqTokens.cornerMedium();
  assert(cornerSmall.topLeft.x == 8.0, 'Corner small radius mismatch');
  assert(cornerMedium.topLeft.x == 12.0, 'Corner medium radius mismatch');
  print('✓ Method calls work');
  
  // Test accessibility helpers
  print('Testing accessibility helpers...');
  final accessibleColor = MinqTokens.ensureAccessibleOnBackground(
    MinqTokens.primary,
    MinqTokens.background,
  );
  assert(accessibleColor != null, 'Accessible color should not be null');
  print('✓ Accessibility helpers work');
  
  print('=== All Token Access Pattern Tests Passed! ===');
}

/// Main function to run the test
void main() {
  // Run programmatic tests
  testTokenAccessPatterns();
  
  // Run the visual test widget
  runApp(const TokenAccessTestWidget());
}