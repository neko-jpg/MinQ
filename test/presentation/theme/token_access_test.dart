import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// Test widget to validate all token access patterns
class TokenAccessTestWidget extends StatelessWidget {
  const TokenAccessTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Token Access Test',
      home: Scaffold(
        backgroundColor: MinqTokens.background,
        appBar: AppBar(
          backgroundColor: MinqTokens.surface,
          title: const Text('Token Access Test', style: MinqTokens.titleMedium),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorTests(context),
                const SizedBox(height: 24),
                _buildSpacingTests(context),
                const SizedBox(height: 24),
                _buildTypographyTests(context),
                const SizedBox(height: 24),
                _buildRadiusTests(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorTests(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color Token Tests', style: MinqTokens.titleMedium),
        const SizedBox(height: 4),

        // Primary colors
        _buildColorSwatch('Primary', MinqTokens.brandPrimary),
        _buildColorSwatch('Secondary', MinqTokens.brandSecondary),

        // Surface colors
        _buildColorSwatch('Background', MinqTokens.background),
        _buildColorSwatch('Surface', MinqTokens.surface),

        // Text colors
        _buildColorSwatch('Text Primary', MinqTokens.textPrimary),
        _buildColorSwatch('Text Secondary', MinqTokens.textSecondary),
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
                  '#${color.toString().substring(10, 16).toUpperCase()}',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Spacing Token Tests', style: MinqTokens.titleMedium),
        SizedBox(height: MinqTokens.spacing(4)),

        // Test all spacing values
        _buildSpacingDemo('XS', MinqTokens.spacing(1)),
        _buildSpacingDemo('SM', MinqTokens.spacing(2)),
        _buildSpacingDemo('MD', MinqTokens.spacing(4)),
        _buildSpacingDemo('LG', MinqTokens.spacing(6)),
        _buildSpacingDemo('XL', MinqTokens.spacing(8)),
        _buildSpacingDemo('XXL', MinqTokens.spacing(12)),

        const SizedBox(height: 16),

        // Test breathing padding
        Container(
          padding: EdgeInsets.all(MinqTokens.spacing(4)),
          decoration: BoxDecoration(
            color: MinqTokens.background,
            borderRadius: MinqTokens.cornerMedium(),
          ),
          child: const Text(
            'Breathing Padding Test',
            style: MinqTokens.bodyMedium,
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
            child: Text(
              '$name (${value}px)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Typography Token Tests', style: MinqTokens.titleMedium),
        SizedBox(height: MinqTokens.spacing(4)),

        // Test all typography styles
        const Text('Title Large Style', style: MinqTokens.titleLarge),
        const Text('Title Medium Style', style: MinqTokens.titleMedium),
        const Text('Body Large Style', style: MinqTokens.bodyLarge),
        const Text('Body Medium Style', style: MinqTokens.bodyMedium),
        const Text('Body Small Style', style: MinqTokens.bodySmall),
      ],
    );
  }

  Widget _buildRadiusTests(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Radius Token Tests', style: MinqTokens.titleMedium),
        const SizedBox(height: 4),

        // Test all radius values
        _buildRadiusDemo('Small', MinqTokens.cornerSmall()),
        _buildRadiusDemo('Medium', MinqTokens.cornerMedium()),
        _buildRadiusDemo('Large', MinqTokens.cornerLarge()),
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
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
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
}

void main() {
  testWidgets('TokenAccessTestWidget renders correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TokenAccessTestWidget());

    // Verify that our counter starts at 0.
    expect(find.text('Token Access Test'), findsOneWidget);
  });
}
