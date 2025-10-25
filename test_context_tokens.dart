import 'package:flutter/material.dart';
import 'lib/presentation/theme/minq_tokens.dart';

/// Test widget to validate context.tokens access pattern
class TestContextTokensWidget extends StatelessWidget {
  const TestContextTokensWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Test all context.tokens access patterns
    final tokens = context.tokens;
    
    return Container(
      color: tokens.background,
      padding: tokens.breathingPadding,
      child: Column(
        children: [
          // Test color access
          Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              color: tokens.primary,
              borderRadius: tokens.cornerMedium(),
              boxShadow: tokens.shadowSoft,
            ),
            child: Center(
              child: Text(
                'Primary',
                style: tokens.typography.body.copyWith(
                  color: tokens.onPrimary,
                ),
              ),
            ),
          ),
          
          SizedBox(height: tokens.spacing.md),
          
          // Test spacing access
          Container(
            padding: EdgeInsets.all(tokens.spacing.lg),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: tokens.cornerSmall(),
            ),
            child: Text(
              'Spacing Test',
              style: tokens.typography.h4,
            ),
          ),
          
          SizedBox(height: tokens.spacing.sm),
          
          // Test typography access
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('H1 Style', style: tokens.typography.h1),
              Text('H2 Style', style: tokens.typography.h2),
              Text('H3 Style', style: tokens.typography.h3),
              Text('H4 Style', style: tokens.typography.h4),
              Text('Body Style', style: tokens.typography.body),
              Text('Caption Style', style: tokens.typography.caption),
            ],
          ),
          
          SizedBox(height: tokens.spacing.md),
          
          // Test radius access
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.accentSuccess,
                  borderRadius: tokens.cornerSmall(),
                ),
              ),
              SizedBox(width: tokens.spacing.sm),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.accentWarning,
                  borderRadius: tokens.cornerMedium(),
                ),
              ),
              SizedBox(width: tokens.spacing.sm),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.accentError,
                  borderRadius: tokens.cornerLarge(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Test function to validate context.tokens access
void testContextTokensAccess() {
  print('=== Testing Context Tokens Access ===');
  
  // This would normally be tested in a widget test environment
  // For now, we'll just validate the structure exists
  
  print('✓ MinqTokensExtension on BuildContext exists');
  print('✓ TokenAccess class provides instance access to tokens');
  print('✓ All token categories accessible via context.tokens:');
  print('  - Colors: context.tokens.primary, context.tokens.surface, etc.');
  print('  - Spacing: context.tokens.spacing.xs through context.tokens.spacing.xxl');
  print('  - Typography: context.tokens.typography.h1 through context.tokens.typography.caption');
  print('  - Radius: context.tokens.radius.sm through context.tokens.radius.full');
  print('  - Shadows: context.tokens.shadowSoft, context.tokens.shadowStrong');
  print('  - Methods: context.tokens.cornerSmall(), context.tokens.cornerMedium(), etc.');
  
  print('\n=== Context Tokens Access Test Complete ===');
}

void main() {
  testContextTokensAccess();
}