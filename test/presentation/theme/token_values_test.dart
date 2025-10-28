import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// Simple test to validate token values without Flutter imports
void main() {
  test('Token values match expected constants', () {
    // Test basic values that should be accessible
    const expectedPrimaryColor = Color(0xFF6366F1);
    const expectedSpacingMd = 16.0;

    expect(MinqTokens.brandPrimary, expectedPrimaryColor);
    expect(MinqTokens.spacing(4), expectedSpacingMd);
    expect(MinqTokens.cornerMedium(), BorderRadius.circular(8));

    // Test spacing scale values
    const spacingValues = {
      'xs': 4.0,
      'sm': 8.0,
      'md': 16.0,
      'lg': 24.0,
      'xl': 32.0,
      'xxl': 40.0,
    };

    expect(MinqTokens.spacing(1), spacingValues['xs']);
    expect(MinqTokens.spacing(2), spacingValues['sm']);
    expect(MinqTokens.spacing(4), spacingValues['md']);
    expect(MinqTokens.spacing(6), spacingValues['lg']);
    expect(MinqTokens.spacing(8), spacingValues['xl']);
    // This one doesn't exist, so we'll test the multiplier directly.
    expect(MinqTokens.spacing(10), 40.0);

    // Test radius scale values
    expect(MinqTokens.cornerSmall(), BorderRadius.circular(4));
    expect(MinqTokens.cornerMedium(), BorderRadius.circular(8));
    expect(MinqTokens.cornerLarge(), BorderRadius.circular(16));
  });
}
