import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/controllers/stats_data_controller.dart';
import 'package:minq/presentation/screens/ai_insights_screen.dart';

class AiConciergeCard extends ConsumerWidget {
  const AiConciergeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final navigation = ref.read(navigationUseCaseProvider);

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: navigation.goToAiInsights,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha((255 * 0.2).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AIインサイト',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Insights preview
              const _InsightsPreview(),
              
              const SizedBox(height: 16),
              
              // Action button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withAlpha((255 * 0.3).round()),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insights,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'データ分析を見る',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightsPreview extends ConsumerWidget {
  const _InsightsPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'あなたの習慣データを分析',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        
        // Real insights preview
        Consumer(
          builder: (context, ref, child) {
            final streakAsync = ref.watch(streakProvider);
            final statsAsync = ref.watch(statsDataProvider);
            final aiInsightsAsync = ref.watch(aiInsightsProvider);
            
            return Row(
              children: [
                Expanded(
                  child: statsAsync.when(
                    data: (stats) => _buildInsightItem(
                      context,
                      '完了率',
                      '${(stats.weeklyCompletionRate * 100).round()}%',
                      Icons.trending_up,
                      stats.weeklyCompletionRate > 0.7 ? Colors.green : Colors.orange,
                    ),
                    loading: () => _buildInsightItem(
                      context,
                      '完了率',
                      '-',
                      Icons.trending_up,
                      Colors.grey,
                    ),
                    error: (_, __) => _buildInsightItem(
                      context,
                      '完了率',
                      '-',
                      Icons.trending_up,
                      Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: streakAsync.when(
                    data: (streak) => _buildInsightItem(
                      context,
                      'ストリーク',
                      '$streak日',
                      Icons.local_fire_department,
                      streak > 0 ? Colors.orange : Colors.grey,
                    ),
                    loading: () => _buildInsightItem(
                      context,
                      'ストリーク',
                      '-',
                      Icons.local_fire_department,
                      Colors.grey,
                    ),
                    error: (_, __) => _buildInsightItem(
                      context,
                      'ストリーク',
                      '-',
                      Icons.local_fire_department,
                      Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: aiInsightsAsync.when(
                    data: (insights) => _buildInsightItem(
                      context,
                      '提案',
                      '${insights.recommendations.length}件',
                      Icons.lightbulb_outline,
                      insights.recommendations.isNotEmpty ? Colors.blue : Colors.grey,
                    ),
                    loading: () => _buildInsightItem(
                      context,
                      '提案',
                      '-',
                      Icons.lightbulb_outline,
                      Colors.grey,
                    ),
                    error: (_, __) => _buildInsightItem(
                      context,
                      '提案',
                      '-',
                      Icons.lightbulb_outline,
                      Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'パーソナライズされた分析とアドバイスを確認できます',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
