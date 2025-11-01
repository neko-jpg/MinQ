import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// Test widget to validate context.tokens access pattern
class TestContextTokensWidget extends StatelessWidget {
  const TestContextTokensWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Test all context.tokens access patterns
    return MaterialApp(
      home: Scaffold(
        backgroundColor: MinqTokens.background,
        body: Padding(
          padding: EdgeInsets.all(MinqTokens.spacing(4)),
          child: Column(
            children: [
              // Test color access
              Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                  color: MinqTokens.brandPrimary,
                  borderRadius: MinqTokens.cornerMedium(),
                ),
                child: const Center(
                  child: Text('Primary', style: MinqTokens.bodyMedium),
                ),
              ),

              SizedBox(height: MinqTokens.spacing(4)),

              // Test spacing access
              Container(
                padding: EdgeInsets.all(MinqTokens.spacing(6)),
                decoration: BoxDecoration(
                  color: MinqTokens.surface,
                  borderRadius: MinqTokens.cornerSmall(),
                ),
                child: const Text(
                  'Spacing Test',
                  style: MinqTokens.titleMedium,
                ),
              ),

              SizedBox(height: MinqTokens.spacing(2)),

              // Test typography access
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title Large', style: MinqTokens.titleLarge),
                  Text('Body Large', style: MinqTokens.bodyLarge),
                ],
              ),

              SizedBox(height: MinqTokens.spacing(4)),

              // Test radius access
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: MinqTokens.brandSecondary,
                      borderRadius: MinqTokens.cornerSmall(),
                    ),
                  ),
                  SizedBox(width: MinqTokens.spacing(2)),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: MinqTokens.brandSecondary,
                      borderRadius: MinqTokens.cornerMedium(),
                    ),
                  ),
                  SizedBox(width: MinqTokens.spacing(2)),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: MinqTokens.brandSecondary,
                      borderRadius: MinqTokens.cornerLarge(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('MinqTokens can be used without context extension', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TestContextTokensWidget());

    // Verify that our widgets are being displayed.
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Spacing Test'), findsOneWidget);
    expect(find.text('Title Large'), findsOneWidget);
  });
}
