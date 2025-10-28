// This test file validates the fallback mechanisms for the theme system.
// It ensures that even without a proper BuildContext, the token system
// provides graceful fallbacks and doesn't crash the application.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';
import 'package:minq/presentation/theme/token_access.dart';

void main() {
  group('Fallback Mechanism Validation', () {
    test('Fallback classes and global access patterns are available', () {
      // Test 1 & 2: Verify that global access through MinqTokensGlobal works.
      // This confirms the class exists and its methods are accessible.
      expect(MinqTokens.brandPrimary, isA<Color>());
      expect(MinqTokens.spacing(2), isA<double>());
      expect(MinqTokens.headline1, isA<TextStyle>());
      expect(MinqTokens.shadows.small, isA<BoxShadow>());
    });

    test('Extension safety and fallback values are reasonable', () {
      // Test 3 & 4: Verify TokenAccess provides safe access and has reasonable defaults.
      // This is a bit more conceptual, but we can check the default values.
      final tokenAccess = TokenAccess(context: null); // Simulate no context

      // Check that fallback values are not null and are of the correct type.
      expect(tokenAccess.color('brandPrimary'), isNotNull);
      expect(tokenAccess.color('brandPrimary'), isA<Color>());
      expect(tokenAccess.spacing(2), isNotNull);
      expect(tokenAccess.spacing(2), isA<double>());
      expect(tokenAccess.textStyle('headline1'), isNotNull);
      expect(tokenAccess.textStyle('headline1'), isA<TextStyle>());
      expect(tokenAccess.shadow('small'), isNotNull);
      expect(tokenAccess.shadow('small'), isA<BoxShadow>());

      // Check a specific fallback color to ensure it's a reasonable default.
      expect(tokenAccess.color('nonExistentColor'), equals(Colors.pink));
    });
  });
}
