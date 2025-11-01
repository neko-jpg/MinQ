import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';

class PremiumFeatureList extends ConsumerWidget {
  const PremiumFeatureList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Features',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Unlock powerful features to supercharge your habit building journey',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ..._buildFeatureItems(context),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureItems(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.all_inclusive,
        title: 'Unlimited Quests',
        description: 'Create as many quests as you need without any limits',
        color: context.colorTokens.primary,
      ),
      _FeatureItem(
        icon: Icons.psychology,
        title: 'Priority AI Coach',
        description:
            'Get faster responses and more detailed insights from your AI coach',
        color: context.colorTokens.secondary,
      ),
      _FeatureItem(
        icon: Icons.analytics,
        title: 'Advanced Analytics',
        description:
            'Deep insights, predictions, and personalized recommendations',
        color: context.colorTokens.tertiary,
      ),
      _FeatureItem(
        icon: Icons.palette,
        title: 'Premium Themes',
        description: 'Exclusive themes, animations, and customization options',
        color: context.colorTokens.warning,
      ),
      _FeatureItem(
        icon: Icons.cloud_download,
        title: 'Data Export & Backup',
        description:
            'Export your data and automatic cloud backup for peace of mind',
        color: context.colorTokens.info,
      ),
      _FeatureItem(
        icon: Icons.support_agent,
        title: 'Priority Support',
        description:
            'Get priority customer support and early access to new features',
        color: context.colorTokens.success,
      ),
      _FeatureItem(
        icon: Icons.tune,
        title: 'Advanced Customization',
        description:
            'Customize every aspect of the app to match your preferences',
        color: context.colorTokens.error,
      ),
      _FeatureItem(
        icon: Icons.family_restroom,
        title: 'Family Plans',
        description: 'Share premium features with up to 6 family members',
        color: context.colorTokens.primary,
      ),
    ];

    return features
        .map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildFeatureItem(context, feature),
          ),
        )
        .toList();
  }

  Widget _buildFeatureItem(BuildContext context, _FeatureItem feature) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: feature.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(feature.icon, color: feature.color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                feature.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
