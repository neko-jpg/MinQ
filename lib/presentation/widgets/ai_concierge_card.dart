import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class AiConciergeCard extends ConsumerWidget {
  const AiConciergeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final navigation = ref.read(navigationUseCaseProvider);

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        onTap: navigation.goToAiInsights,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(tokens.spacing.sm),
                    decoration: BoxDecoration(
                      color: tokens.brandPrimary.withAlpha((255 * 0.2).round()),
                      borderRadius: BorderRadius.circular(tokens.radius.md),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: tokens.brandPrimary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: tokens.spacing.md),
                  Expanded(
                    child: Text(
                      'AIインサイト',
                      style: tokens.typography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: tokens.textMuted,
                    size: 16,
                  ),
                ],
              ),
              SizedBox(height: tokens.spacing.md),
              
              // Insights preview
              _InsightsPreview(tokens: tokens),
              
              SizedBox(height: tokens.spacing.lg),
              
              // Action button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.md,
                  vertical: tokens.spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                  border: Border.all(
                    color: tokens.brandPrimary.withAlpha((255 * 0.3).round()),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insights,
                      color: tokens.brandPrimary,
                      size: 16,
                    ),
                    SizedBox(width: tokens.spacing.sm),
                    Text(
                      'データ分析を見る',
                      style: tokens.typography.body.copyWith(
                        color: tokens.brandPrimary,
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

class _InsightsPreview extends StatelessWidget {
  const _InsightsPreview({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'あなたの習慣データを分析',
          style: tokens.typography.body.copyWith(
            color: tokens.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        
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
                      '完了率',
                      '${(stats.weeklyCompletionRate * 100).round()}%',
                      Icons.trending_up,
                      stats.weeklyCompletionRate > 0.7 ? Colors.green : Colors.orange,
                      tokens,
                    ),
                    loading: () => _buildInsightItem(
                      '完了率',
                      '-',
                      Icons.trending_up,
                      Colors.grey,
                      tokens,
                    ),
                    error: (_, __) => _buildInsightItem(
                      '完了率',
                      '-',
                      Icons.trending_up,
                      Colors.grey,
                      tokens,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: streakAsync.when(
                    data: (streak) => _buildInsightItem(
                      'ストリーク',
                      '${streak}日',
                      Icons.local_fire_department,
                      streak > 0 ? Colors.orange : Colors.grey,
                      tokens,
                    ),
                    loading: () => _buildInsightItem(
                      'ストリーク',
                      '-',
                      Icons.local_fire_department,
                      Colors.grey,
                      tokens,
                    ),
                    error: (_, __) => _buildInsightItem(
                      'ストリーク',
                      '-',
                      Icons.local_fire_department,
                      Colors.grey,
                      tokens,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: aiInsightsAsync.when(
                    data: (insights) => _buildInsightItem(
                      '提案',
                      '${insights.recommendations.length}件',
                      Icons.lightbulb_outline,
                      insights.recommendations.isNotEmpty ? Colors.blue : Colors.grey,
                      tokens,
                    ),
                    loading: () => _buildInsightItem(
                      '提案',
                      '-',
                      Icons.lightbulb_outline,
                      Colors.grey,
                      tokens,
                    ),
                    error: (_, __) => _buildInsightItem(
                      '提案',
                      '-',
                      Icons.lightbulb_outline,
                      Colors.grey,
                      tokens,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        
        SizedBox(height: tokens.spacing.md),
        
        Text(
          'パーソナライズされた分析とアドバイスを確認できます',
          style: tokens.typography.caption.copyWith(
            color: tokens.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    String label,
    String value,
    IconData icon,
    Color color,
    MinqTheme tokens,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(height: tokens.spacing.xs),
          Text(
            value,
            style: tokens.typography.body.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: tokens.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
