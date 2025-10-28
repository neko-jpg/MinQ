import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// Simple test to validate token access patterns
void main() {
  test('Token access patterns', () {
    log('=== Testing Token Access Patterns ===');

    // Test 1: Static access to MinqTokens
    log('1. Testing static MinqTokens access...');
    const primaryColor = MinqTokens.brandPrimary;
    final spacingMd = MinqTokens.spacing(4);
    const h1Style = MinqTokens.titleLarge;

    expect(primaryColor, const Color(0xFF6366F1));
    expect(spacingMd, 16.0);
    expect(h1Style.fontSize, 24);
    log('✓ Static access works');

    // Test 2: Method calls
    log('2. Testing method calls...');
    final cornerSmall = MinqTokens.cornerSmall();
    final cornerMedium = MinqTokens.cornerMedium();
    final cornerLarge = MinqTokens.cornerLarge();

    expect(cornerSmall.topLeft.x, 4.0);
    expect(cornerMedium.topLeft.x, 8.0);
    expect(cornerLarge.topLeft.x, 16.0);
    log('✓ Method calls work');

    // Test 5: Color values
    log('5. Testing color values...');
    final colors = [
      MinqTokens.brandPrimary,
      MinqTokens.brandSecondary,
      MinqTokens.background,
      MinqTokens.surface,
      MinqTokens.textPrimary,
      MinqTokens.textSecondary,
    ];

    for (final color in colors) {
      expect(color.toString(), isNot('Color(0x00000000)'));
    }
    log('✓ All color values are valid');

    log('=== All Token Access Pattern Tests Passed! ===');
  });
}