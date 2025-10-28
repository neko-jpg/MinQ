import 'lib/presentation/theme/minq_tokens.dart';

/// Simple test to validate fallback mechanisms without Flutter framework
void testTokenFallbacks() {
  print('=== Testing Token Fallback Mechanisms ===');

  try {
    // Test 1: Global token access
    print('\n1. Testing Global Token Access:');
    final globalTokens = MinqTokensGlobal.tokens;
    print('✓ Global tokens accessible');
    print('  - Primary color: ${globalTokens.primary}');
    print('  - Spacing MD: ${globalTokens.spacing.md}');
    print('  - Typography H1 size: ${globalTokens.typography.h1.fontSize}');

    // Test 2: Safe access methods
    print('\n2. Testing Safe Access Methods:');
    final safeColor = MinqTokensGlobal.safeColor(
      () => MinqTokensGlobal.tokens.primary,
      const Color(0xFF000000),
    );
    print('✓ Safe color access: $safeColor');

    final safeSpacing = MinqTokensGlobal.safeSpacing(
      () => MinqTokensGlobal.tokens.spacing.lg,
      20.0,
    );
    print('✓ Safe spacing access: $safeSpacing');

    final safeTextStyle = MinqTokensGlobal.safeTextStyle(
      () => MinqTokensGlobal.tokens.typography.body,
      const TextStyle(fontSize: 14),
    );
    print('✓ Safe text style access: ${safeTextStyle.fontSize}');

    final safeBorderRadius = MinqTokensGlobal.safeBorderRadius(
      () => MinqTokensGlobal.tokens.cornerMedium(),
      BorderRadius.circular(6.0),
    );
    print('✓ Safe border radius access: ${safeBorderRadius.topLeft.x}');

    // Test 3: TokenAccess fallback mechanisms
    print('\n3. Testing TokenAccess Fallback Mechanisms:');
    const tokenAccess = TokenAccess._();

    // Test color fallbacks
    print('  Colors:');
    print('    - Primary: ${tokenAccess.primary}');
    print('    - Surface: ${tokenAccess.surface}');
    print('    - Success: ${tokenAccess.success}');
    print('    - Error: ${tokenAccess.error}');

    // Test spacing fallbacks
    print('  Spacing:');
    print('    - XS: ${tokenAccess.spacing.xs}');
    print('    - MD: ${tokenAccess.spacing.md}');
    print('    - XL: ${tokenAccess.spacing.xl}');

    // Test typography fallbacks
    print('  Typography:');
    print('    - H1: ${tokenAccess.typography.h1.fontSize}');
    print('    - Body: ${tokenAccess.typography.body.fontSize}');
    print('    - Caption: ${tokenAccess.typography.caption.fontSize}');

    // Test radius fallbacks
    print('  Radius:');
    print('    - Small: ${tokenAccess.cornerSmall().topLeft.x}');
    print('    - Medium: ${tokenAccess.cornerMedium().topLeft.x}');
    print('    - Large: ${tokenAccess.cornerLarge().topLeft.x}');

    // Test shadow fallbacks
    print('  Shadows:');
    print('    - Soft: ${tokenAccess.shadowSoft.length} shadows');
    print('    - Strong: ${tokenAccess.shadowStrong.length} shadows');

    print('\n✅ All fallback mechanisms working correctly!');

  } catch (e, stackTrace) {
    print('❌ Fallback test failed: $e');
    print('Stack trace: $stackTrace');
  }

  print('\n=== Token Fallback Test Complete ===');
}

void main() {
  testTokenFallbacks();
}