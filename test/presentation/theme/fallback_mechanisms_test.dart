import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// Test widget to validate that MinqTokens are accessible and work correctly.
/// The concept of "fallbacks" is now obsolete since tokens are compile-time constants.
/// This test ensures the tokens are directly usable as intended.
class TokenUsageTestWidget extends StatelessWidget {
  const TokenUsageTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: MinqTokens.background,
        appBar: AppBar(
          title: const Text('Token Usage Test', style: MinqTokens.titleMedium),
          backgroundColor: MinqTokens.surface,
        ),
        body: Padding(
          padding: EdgeInsets.all(MinqTokens.spacing(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(MinqTokens.spacing(4)),
                decoration: BoxDecoration(
                  color: MinqTokens.surface,
                  borderRadius: MinqTokens.cornerMedium(),
                ),
                child: const Text(
                  'Styled Container',
                  style: MinqTokens.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Text with brand color',
                style: TextStyle(color: MinqTokens.brandPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('MinqTokens can be used without fallbacks', (
    WidgetTester tester,
  ) async {
    // Build the test widget.
    await tester.pumpWidget(const TokenUsageTestWidget());

    // Verify the AppBar title is found.
    expect(find.text('Token Usage Test'), findsOneWidget);

    // Verify the styled container is found.
    expect(find.text('Styled Container'), findsOneWidget);

    // Verify text with brand color is found.
    expect(find.text('Text with brand color'), findsOneWidget);

    // No need to test for fallbacks, as compile-time constants don't fail at runtime.
    // The test's ability to compile and run is proof that the tokens are working.
  });
}
