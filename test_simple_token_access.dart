import 'package:flutter/material.dart';
import 'lib/presentation/theme/minq_tokens.dart';

/// Simple test to validate token access patterns
void main() {
  print('=== Testing Token Access Patterns ===');
  
  // Test 1: Static access to MinqTokens
  print('1. Testing static MinqTokens access...');
  final primaryColor = MinqTokens.primary;
  final spacingMd = MinqTokens.spacing.md;
  final radiusSm = MinqTokens.radius.sm;
  final h1Style = MinqTokens.typography.h1;
  
  assert(primaryColor == const Color(0xFF6366F1), 'Primary color should match');
  assert(spacingMd == 16.0, 'Spacing MD should be 16.0');
  assert(radiusSm == 8.0, 'Radius SM should be 8.0');
  assert(h1Style.fontSize == 42, 'H1 fontSize should be 42');
  print('✓ Static access works');
  
  // Test 2: Method calls
  print('2. Testing method calls...');
  final cornerSmall = MinqTokens.cornerSmall();
  final cornerMedium = MinqTokens.cornerMedium();
  final cornerLarge = MinqTokens.cornerLarge();
  final cornerXLarge = MinqTokens.cornerXLarge();
  final cornerFull = MinqTokens.cornerFull();
  
  assert(cornerSmall.topLeft.x == 8.0, 'Corner small should be 8.0');
  assert(cornerMedium.topLeft.x == 12.0, 'Corner medium should be 12.0');
  assert(cornerLarge.topLeft.x == 16.0, 'Corner large should be 16.0');
  assert(cornerXLarge.topLeft.x == 24.0, 'Corner XLarge should be 24.0');
  assert(cornerFull.topLeft.x == 999.0, 'Corner full should be 999.0');
  print('✓ Method calls work');
  
  // Test 3: Scale access
  print('3. Testing scale access...');
  const spacing = SpacingScale();
  const radius = RadiusScale();
  const typeScale = TypeScale();
  const typography = TypographyTokens();
  
  assert(spacing.xs == 4.0, 'Spacing XS should be 4.0');
  assert(spacing.sm == 8.0, 'Spacing SM should be 8.0');
  assert(spacing.md == 16.0, 'Spacing MD should be 16.0');
  assert(spacing.lg == 24.0, 'Spacing LG should be 24.0');
  assert(spacing.xl == 32.0, 'Spacing XL should be 32.0');
  assert(spacing.xxl == 40.0, 'Spacing XXL should be 40.0');
  
  assert(radius.sm == 8.0, 'Radius SM should be 8.0');
  assert(radius.md == 12.0, 'Radius MD should be 12.0');
  assert(radius.lg == 16.0, 'Radius LG should be 16.0');
  assert(radius.xl == 24.0, 'Radius XL should be 24.0');
  assert(radius.full == 999.0, 'Radius full should be 999.0');
  
  assert(typeScale.h1.fontSize == 42, 'TypeScale H1 fontSize should be 42');
  assert(typeScale.h2.fontSize == 34, 'TypeScale H2 fontSize should be 34');
  assert(typeScale.h3.fontSize == 28, 'TypeScale H3 fontSize should be 28');
  assert(typeScale.h4.fontSize == 22, 'TypeScale H4 fontSize should be 22');
  
  assert(typography.h1.fontSize == 42, 'Typography H1 fontSize should be 42');
  assert(typography.body.fontSize == 15, 'Typography body fontSize should be 15');
  assert(typography.caption.fontSize == 13, 'Typography caption fontSize should be 13');
  print('✓ Scale access works');
  
  // Test 4: TokenAccess class
  print('4. Testing TokenAccess class...');
  const tokenAccess = TokenAccess._();
  
  assert(tokenAccess.primary == MinqTokens.primary, 'TokenAccess primary should match MinqTokens');
  assert(tokenAccess.spacing.md == MinqTokens.spacing.md, 'TokenAccess spacing should match');
  assert(tokenAccess.typography.h1.fontSize == MinqTokens.typography.h1.fontSize, 'TokenAccess typography should match');
  
  // Test corner methods
  final accessCornerSmall = tokenAccess.cornerSmall();
  final accessCornerMedium = tokenAccess.cornerMedium();
  assert(accessCornerSmall.topLeft.x == 8.0, 'TokenAccess corner small should be 8.0');
  assert(accessCornerMedium.topLeft.x == 12.0, 'TokenAccess corner medium should be 12.0');
  print('✓ TokenAccess class works');
  
  // Test 5: Color values
  print('5. Testing color values...');
  final colors = [
    MinqTokens.primary,
    MinqTokens.primaryHover,
    MinqTokens.accentSecondary,
    MinqTokens.accentSuccess,
    MinqTokens.accentWarning,
    MinqTokens.accentError,
    MinqTokens.encouragement,
    MinqTokens.joyAccent,
    MinqTokens.serenity,
    MinqTokens.warmth,
    MinqTokens.background,
    MinqTokens.surface,
    MinqTokens.surfaceAlt,
    MinqTokens.surfaceVariant,
    MinqTokens.border,
    MinqTokens.divider,
    MinqTokens.textPrimary,
    MinqTokens.textSecondary,
    MinqTokens.textMuted,
    MinqTokens.success,
    MinqTokens.error,
  ];
  
  for (final color in colors) {
    assert(color.value != 0, 'Color should have a valid value');
  }
  print('✓ All color values are valid');
  
  // Test 6: Shadow values
  print('6. Testing shadow values...');
  assert(MinqTokens.shadowSoft.isNotEmpty, 'Soft shadow should not be empty');
  assert(MinqTokens.shadowStrong.isNotEmpty, 'Strong shadow should not be empty');
  assert(MinqTokens.shadowSoft.first.blurRadius > 0, 'Soft shadow should have blur radius');
  assert(MinqTokens.shadowStrong.first.blurRadius > 0, 'Strong shadow should have blur radius');
  print('✓ Shadow values work');
  
  // Test 7: Accessibility helpers (without BuildContext)
  print('7. Testing accessibility helpers...');
  final accessibleColor = MinqTokens.ensureAccessibleOnBackground(
    MinqTokens.primary,
    MinqTokens.background,
  );
  assert(accessibleColor != null, 'Accessible color should not be null');
  print('✓ Accessibility helpers work');
  
  print('=== All Token Access Pattern Tests Passed! ===');
  print('');
  print('Summary of tested patterns:');
  print('- MinqTokens.primary (static color access)');
  print('- MinqTokens.spacing.md (static spacing access)');
  print('- MinqTokens.radius.sm (static radius access)');
  print('- MinqTokens.typography.h1 (static typography access)');
  print('- MinqTokens.cornerSmall() (static method calls)');
  print('- SpacingScale() (const instance access)');
  print('- RadiusScale() (const instance access)');
  print('- TypeScale() (const instance access)');
  print('- TypographyTokens() (const instance access)');
  print('- TokenAccess._() (token access helper)');
  print('- MinqTokens.shadowSoft (shadow access)');
  print('- MinqTokens.ensureAccessibleOnBackground() (accessibility helpers)');
  print('');
  print('Context-based access pattern (context.tokens) requires BuildContext');
  print('and should be tested in a widget environment.');
}