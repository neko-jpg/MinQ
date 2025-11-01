import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';

class SubscriptionBenefits extends StatelessWidget {
  const SubscriptionBenefits({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Why Choose Premium?',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildBenefitCard(
                  context,
                  icon: Icons.trending_up,
                  title: '3x Faster',
                  subtitle: 'Habit Formation',
                  description:
                      'Premium users build habits 3x faster with advanced features',
                  color: context.colorTokens.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBenefitCard(
                  context,
                  icon: Icons.psychology,
                  title: 'AI Powered',
                  subtitle: 'Insights',
                  description:
                      'Get personalized recommendations and predictions',
                  color: context.colorTokens.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBenefitCard(
                  context,
                  icon: Icons.security,
                  title: 'Secure',
                  subtitle: 'Cloud Backup',
                  description:
                      'Never lose your progress with automatic backups',
                  color: context.colorTokens.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBenefitCard(
                  context,
                  icon: Icons.support_agent,
                  title: 'Priority',
                  subtitle: 'Support',
                  description:
                      'Get help when you need it with priority support',
                  color: context.colorTokens.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorTokens.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
