import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Example widget demonstrating the enhanced MinqTheme usage
/// This serves as a reference for developers on how to use the new theme properties
class EnhancedThemeExample extends StatelessWidget {
  const EnhancedThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);

    return Scaffold(
      backgroundColor: theme.getAccessibleBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Enhanced Theme Demo',
          style: theme.titleLarge.copyWith(
            color: theme.getAccessibleTextColor(context),
          ),
        ),
        backgroundColor: theme.surface,
      ),
      body: SingleChildScrollView(
        padding: theme.breathingPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emotional Colors Section
            _buildSection(context, 'Emotional Colors', [
              _buildColorCard(context, 'Joy Accent', theme.joyAccent),
              _buildColorCard(context, 'Encouragement', theme.encouragement),
              _buildColorCard(context, 'Serenity', theme.serenity),
              _buildColorCard(context, 'Warmth', theme.warmth),
            ]),

            SizedBox(height: theme.respectfulSpace),

            // State Colors Section
            _buildSection(context, 'State Colors', [
              _buildColorCard(context, 'Progress Active', theme.progressActive),
              _buildColorCard(
                context,
                'Progress Complete',
                theme.progressComplete,
              ),
              _buildColorCard(
                context,
                'Progress Pending',
                theme.progressPending,
              ),
            ]),

            SizedBox(height: theme.respectfulSpace),

            // Typography Section
            _buildSection(context, 'Emotional Typography', [
              Text('🎉 Celebration Text!', style: theme.celebrationText),
              SizedBox(height: theme.intimateSpace),
              Text('💪 You can do it!', style: theme.encouragementText),
              SizedBox(height: theme.intimateSpace),
              Text('💡 Here\'s a helpful tip', style: theme.guidanceText),
              SizedBox(height: theme.intimateSpace),
              Text('(whispered hint)', style: theme.whisperText),
            ]),

            SizedBox(height: theme.respectfulSpace),

            // Spacing Examples
            _buildSection(context, 'Enhanced Spacing', [
              Container(
                padding: theme.intimatePadding,
                decoration: BoxDecoration(
                  color: theme.serenity.withValues(alpha: 0.1),
                  borderRadius: theme.cornerSmall(),
                ),
                child: Text('Intimate Spacing', style: theme.bodySmall),
              ),
              SizedBox(height: theme.breathingSpace),
              Container(
                padding: theme.breathingPadding,
                decoration: BoxDecoration(
                  color: theme.warmth.withValues(alpha: 0.1),
                  borderRadius: theme.cornerMedium(),
                ),
                child: Text('Breathing Space', style: theme.bodyMedium),
              ),
            ]),

            SizedBox(height: theme.respectfulSpace),

            // Interactive Elements
            _buildSection(context, 'Interactive Elements', [
              _buildAnimatedButton(context, 'Joy Button', theme.joyAccent),
              SizedBox(height: theme.breathingSpace),
              _buildAnimatedButton(
                context,
                'Success Button',
                theme.progressComplete,
              ),
              SizedBox(height: theme.breathingSpace),
              _buildAnimatedButton(
                context,
                'Warning Button',
                theme.accentWarning,
              ),
            ]),

            SizedBox(height: theme.dramaticSpace),

            // Accessibility Info
            _buildAccessibilityInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = MinqTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.titleMedium.copyWith(
            color: theme.getAccessibleTextColor(context),
          ),
        ),
        SizedBox(height: theme.breathingSpace),
        ...children,
      ],
    );
  }

  Widget _buildColorCard(BuildContext context, String name, Color color) {
    final theme = MinqTheme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: theme.intimateSpace),
      padding: theme.intimatePadding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: theme.cornerSmall(),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: theme.cornerSmall(),
            ),
          ),
          SizedBox(width: theme.intimateSpace),
          Text(name, style: theme.bodySmall),
          const Spacer(),
          Text(
            '#${color.toARGB32().toRadixString(16).toUpperCase().substring(2)}',
            style: theme.whisperText,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(BuildContext context, String text, Color color) {
    final theme = MinqTheme.of(context);

    return AnimatedContainer(
      duration: theme.getAnimationDuration(
        context,
        const Duration(milliseconds: 200),
      ),
      curve: theme.easeInOutCubic,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$text pressed!'),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: theme.cornerMedium()),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            MinqTheme.minTouchTargetSize,
          ),
          shape: RoundedRectangleBorder(borderRadius: theme.cornerMedium()),
        ),
        child: Text(
          text,
          style: theme.bodyMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAccessibilityInfo(BuildContext context) {
    final theme = MinqTheme.of(context);
    final isHighContrast = theme.isHighContrastMode(context);

    return Container(
      padding: theme.breathingPadding,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: theme.cornerLarge(),
        boxShadow: theme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accessibility Status',
            style: theme.titleSmall.copyWith(
              color: theme.getAccessibleTextColor(context),
            ),
          ),
          SizedBox(height: theme.intimateSpace),
          _buildAccessibilityRow(
            context,
            'High Contrast Mode',
            isHighContrast ? 'Enabled' : 'Disabled',
            isHighContrast ? theme.progressComplete : theme.progressPending,
          ),
          _buildAccessibilityRow(
            context,
            'Min Touch Target',
            '${MinqTheme.minTouchTargetSize}pt',
            theme.progressComplete,
          ),
          _buildAccessibilityRow(
            context,
            'WCAG AA Compliance',
            theme.meetsWCAGAA(theme.textPrimary, theme.background)
                ? 'Pass'
                : 'Fail',
            theme.meetsWCAGAA(theme.textPrimary, theme.background)
                ? theme.progressComplete
                : theme.accentError,
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityRow(
    BuildContext context,
    String label,
    String value,
    Color statusColor,
  ) {
    final theme = MinqTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.intimateSpace / 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: theme.intimateSpace),
          Text(label, style: theme.bodySmall),
          const Spacer(),
          Text(
            value,
            style: theme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
