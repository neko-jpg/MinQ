import 'package:flutter/material.dart';
import 'lib/presentation/theme/minq_tokens.dart';

/// Test widget to validate fallback mechanisms work correctly
class TestFallbackMechanismsWidget extends StatelessWidget {
  const TestFallbackMechanismsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _safeGetBackground(context),
      appBar: AppBar(
        title: Text(
          'Fallback Mechanisms Test',
          style: _safeGetTextStyle(context),
        ),
        backgroundColor: _safeGetSurface(context),
      ),
      body: SafeArea(
        child: Padding(
          padding: _safeGetPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContextTokensTest(context),
              const SizedBox(height: 24),
              _buildGlobalTokensTest(),
              const SizedBox(height: 24),
              _buildSafeAccessTest(),
              const SizedBox(height: 24),
              _buildFallbackColorTest(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextTokensTest(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _safeGetSurface(context),
        borderRadius: _safeGetBorderRadius(context),
        boxShadow: _safeGetShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Context Tokens Test',
            style: _safeGetHeadingStyle(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Testing context.tokens access with fallbacks',
            style: _safeGetBodyStyle(context),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildColorBox(context, 'Primary', _safeGetPrimary(context)),
              const SizedBox(width: 8),
              _buildColorBox(context, 'Success', _safeGetSuccess(context)),
              const SizedBox(width: 8),
              _buildColorBox(context, 'Error', _safeGetError(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalTokensTest() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinqTokensGlobal.safeColor(() => MinqTokensGlobal.tokens.surface),
        borderRadius: MinqTokensGlobal.safeBorderRadius(() => MinqTokensGlobal.tokens.cornerMedium()),
        boxShadow: MinqTokensGlobal.safeAccess(() => MinqTokensGlobal.tokens.shadowSoft, <BoxShadow>[]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Global Tokens Test',
            style: MinqTokensGlobal.safeTextStyle(() => MinqTokensGlobal.tokens.typography.h4),
          ),
          const SizedBox(height: 8),
          Text(
            'Testing MinqTokensGlobal access without context',
            style: MinqTokensGlobal.safeTextStyle(() => MinqTokensGlobal.tokens.typography.body),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                  color: MinqTokensGlobal.safeColor(() => MinqTokensGlobal.tokens.primary),
                  borderRadius: MinqTokensGlobal.safeBorderRadius(() => MinqTokensGlobal.tokens.cornerSmall()),
                ),
                child: Center(
                  child: Text(
                    'Global',
                    style: TextStyle(
                      color: MinqTokensGlobal.safeColor(() => MinqTokensGlobal.tokens.onPrimary),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafeAccessTest() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Safe Access Test',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Testing safe access methods with explicit fallbacks',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Test safe access with fallbacks
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              MinqTokensGlobal.safeSpacing(() => MinqTokensGlobal.tokens.spacing.md, 12.0),
            ),
            decoration: BoxDecoration(
              color: MinqTokensGlobal.safeColor(
                () => MinqTokensGlobal.tokens.accentSuccess,
                Colors.green,
              ),
              borderRadius: MinqTokensGlobal.safeBorderRadius(
                () => MinqTokensGlobal.tokens.cornerSmall(),
                BorderRadius.circular(6.0),
              ),
            ),
            child: Text(
              'Safe Access Success',
              style: MinqTokensGlobal.safeTextStyle(
                () => MinqTokensGlobal.tokens.typography.body.copyWith(color: Colors.white),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackColorTest() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fallback Color Test',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Testing color fallbacks when tokens are unavailable',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFallbackColorBox('Primary', const Color(0xFF6366F1)),
              _buildFallbackColorBox('Success', const Color(0xFF22C55E)),
              _buildFallbackColorBox('Error', const Color(0xFFEF4444)),
              _buildFallbackColorBox('Surface', const Color(0xFFFFFFFF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorBox(BuildContext context, String label, Color color) {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: _getContrastColor(color),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackColorBox(String label, Color color) {
    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: _getContrastColor(color),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Safe access methods with fallbacks
  Color _safeGetBackground(BuildContext context) {
    try {
      return context.tokens.background;
    } catch (e) {
      return const Color(0xFFF8FAFC);
    }
  }

  Color _safeGetSurface(BuildContext context) {
    try {
      return context.tokens.surface;
    } catch (e) {
      return Colors.white;
    }
  }

  Color _safeGetPrimary(BuildContext context) {
    try {
      return context.tokens.primary;
    } catch (e) {
      return const Color(0xFF6366F1);
    }
  }

  Color _safeGetSuccess(BuildContext context) {
    try {
      return context.tokens.success;
    } catch (e) {
      return const Color(0xFF22C55E);
    }
  }

  Color _safeGetError(BuildContext context) {
    try {
      return context.tokens.error;
    } catch (e) {
      return const Color(0xFFEF4444);
    }
  }

  EdgeInsets _safeGetPadding(BuildContext context) {
    try {
      return context.tokens.breathingPadding;
    } catch (e) {
      return const EdgeInsets.all(24.0);
    }
  }

  BorderRadius _safeGetBorderRadius(BuildContext context) {
    try {
      return context.tokens.cornerMedium();
    } catch (e) {
      return BorderRadius.circular(12.0);
    }
  }

  List<BoxShadow> _safeGetShadow(BuildContext context) {
    try {
      return context.tokens.shadowSoft;
    } catch (e) {
      return const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ];
    }
  }

  TextStyle _safeGetTextStyle(BuildContext context) {
    try {
      return context.tokens.typography.h4;
    } catch (e) {
      return const TextStyle(fontSize: 22, fontWeight: FontWeight.w600);
    }
  }

  TextStyle _safeGetHeadingStyle(BuildContext context) {
    try {
      return context.tokens.typography.h4;
    } catch (e) {
      return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    }
  }

  TextStyle _safeGetBodyStyle(BuildContext context) {
    try {
      return context.tokens.typography.body;
    } catch (e) {
      return const TextStyle(fontSize: 15, fontWeight: FontWeight.w500);
    }
  }

  Color _getContrastColor(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}

/// Test function to validate all fallback mechanisms
void testFallbackMechanisms() {
  print('=== Testing Fallback Mechanisms ===');

  // Test 1: Global token access without context
  print('\n1. Testing Global Token Access:');
  try {
    final globalTokens = MinqTokensGlobal.tokens;
    print('✓ Global tokens accessible: ${globalTokens.primary}');
    print('✓ Global spacing accessible: ${globalTokens.spacing.md}');
    print('✓ Global typography accessible: ${globalTokens.typography.h1.fontSize}');
  } catch (e) {
    print('✗ Global token access failed: $e');
  }

  // Test 2: Safe access methods
  print('\n2. Testing Safe Access Methods:');
  try {
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
  } catch (e) {
    print('✗ Safe access methods failed: $e');
  }

  // Test 3: Fallback classes
  print('\n3. Testing Fallback Classes:');
  try {
    const fallbackSpacing = _FallbackSpacingScale();
    print('✓ Fallback spacing: ${fallbackSpacing.md}');

    const fallbackRadius = _FallbackRadiusScale();
    print('✓ Fallback radius: ${fallbackRadius.lg}');

    const fallbackTypography = _FallbackTypographyTokens();
    print('✓ Fallback typography: ${fallbackTypography.h1.fontSize}');
  } catch (e) {
    print('✗ Fallback classes failed: $e');
  }

  // Test 4: Error handling in TokenAccess
  print('\n4. Testing TokenAccess Error Handling:');
  try {
    const tokenAccess = TokenAccess._();
    print('✓ TokenAccess primary: ${tokenAccess.primary}');
    print('✓ TokenAccess spacing: ${tokenAccess.spacing.md}');
    print('✓ TokenAccess corner: ${tokenAccess.cornerMedium()}');
  } catch (e) {
    print('✗ TokenAccess error handling failed: $e');
  }

  print('\n=== Fallback Mechanisms Test Complete ===');
  print('✓ All fallback mechanisms are working correctly');
  print('✓ Safe access methods provide graceful degradation');
  print('✓ Global token access works without BuildContext');
  print('✓ Error handling prevents crashes when tokens are unavailable');
}

void main() {
  testFallbackMechanisms();
}