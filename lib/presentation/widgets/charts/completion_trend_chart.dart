import 'package:flutter/material.dart';
import 'package:minq/domain/ai/ai_insights.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Chart widget for displaying habit completion trends
class CompletionTrendChart extends StatelessWidget {
  const CompletionTrendChart({
    super.key,
    required this.trends,
  });

  final HabitCompletionTrends trends;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: tokens.brandPrimary,
                size: 20,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                '週間完了率の推移',
                style: tokens.typography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.sm,
                  vertical: tokens.spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getTrendColor(trends.overallTrend).withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTrendIcon(trends.overallTrend),
                      color: _getTrendColor(trends.overallTrend),
                      size: 16,
                    ),
                    SizedBox(width: tokens.spacing.xs),
                    Text(
                      _getTrendText(trends.overallTrend),
                      style: tokens.typography.caption.copyWith(
                        color: _getTrendColor(trends.overallTrend),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.lg),

          // Weekly trend bars
          ...trends.weeklyTrends.entries.map((entry) =>
            _buildTrendBar(entry.key, entry.value, tokens),
          ),

          SizedBox(height: tokens.spacing.md),

          // Daily trend section
          Text(
            '曜日別パフォーマンス',
            style: tokens.typography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: tokens.textSecondary,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),

          // Daily trend grid
          Row(
            children: trends.dailyTrends.entries.map((entry) =>
              Expanded(
                child: _buildDayColumn(entry.key, entry.value, tokens),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBar(String week, double value, MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                week,
                style: tokens.typography.body.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: tokens.typography.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tokens.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xs),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: tokens.surfaceVariant,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tokens.brandPrimary,
                      tokens.accentSecondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(String day, double value, MinqTheme tokens) {
    final height = (value * 60).clamp(4.0, 60.0); // Min 4px, max 60px

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing.xs),
      child: Column(
        children: [
          Container(
            height: 60,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 20,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    tokens.brandPrimary.withAlpha((255 * 0.7).round()),
                    tokens.brandPrimary,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            day,
            style: tokens.typography.caption.copyWith(
              color: tokens.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${(value * 100).toStringAsFixed(0)}%',
            style: tokens.typography.caption.copyWith(
              color: tokens.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(double trend) {
    if (trend > 0.1) return Colors.green;
    if (trend < -0.1) return Colors.red;
    return Colors.orange;
  }

  IconData _getTrendIcon(double trend) {
    if (trend > 0.1) return Icons.trending_up;
    if (trend < -0.1) return Icons.trending_down;
    return Icons.trending_flat;
  }

  String _getTrendText(double trend) {
    if (trend > 0.1) return '上昇中';
    if (trend < -0.1) return '下降中';
    return '安定';
  }
}