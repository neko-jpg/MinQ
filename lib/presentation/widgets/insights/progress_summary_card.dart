import 'package:flutter/material.dart';
import 'package:minq/domain/ai/ai_insights.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Card widget displaying progress analysis summary
class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({
    super.key,
    required this.analysis,
  });

  final ProgressAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.brandPrimary.withAlpha((255 * 0.1).round()),
            tokens.accentSecondary.withAlpha((255 * 0.05).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with overall score
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(tokens.spacing.sm),
                decoration: BoxDecoration(
                  color: tokens.brandPrimary.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                child: Icon(
                  Icons.analytics,
                  color: tokens.brandPrimary,
                  size: 24,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '進捗サマリー',
                      style: tokens.typography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      _getScoreDescription(analysis.overallScore),
                      style: tokens.typography.body.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Overall score circle
              _buildScoreCircle(analysis.overallScore, tokens),
            ],
          ),
          
          SizedBox(height: tokens.spacing.lg),
          
          // Key metrics grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '現在のストリーク',
                  '${analysis.currentStreak.toInt()}日',
                  Icons.local_fire_department,
                  _getStreakColor(analysis.currentStreak),
                  tokens,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: _buildMetricCard(
                  '週間完了率',
                  '${(analysis.weeklyCompletionRate * 100).toStringAsFixed(0)}%',
                  Icons.calendar_today,
                  _getCompletionColor(analysis.weeklyCompletionRate),
                  tokens,
                ),
              ),
            ],
          ),
          
          SizedBox(height: tokens.spacing.md),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '最長ストリーク',
                  '${analysis.longestStreak.toInt()}日',
                  Icons.emoji_events,
                  Colors.amber,
                  tokens,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: _buildMetricCard(
                  '総完了数',
                  '${analysis.totalHabitsCompleted}回',
                  Icons.check_circle,
                  Colors.green,
                  tokens,
                ),
              ),
            ],
          ),
          
          // Category performance section
          if (analysis.categoryPerformance.isNotEmpty) ...[
            SizedBox(height: tokens.spacing.lg),
            Text(
              'カテゴリ別パフォーマンス',
              style: tokens.typography.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing.md),
            ...analysis.categoryPerformance.entries.map((entry) =>
              _buildCategoryPerformanceBar(entry.key, entry.value, tokens),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreCircle(double score, MinqTheme tokens) {
    final color = _getScoreColor(score);
    
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 6,
            backgroundColor: tokens.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(tokens.surfaceVariant),
          ),
          CircularProgressIndicator(
            value: score,
            strokeWidth: 6,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (score * 100).toStringAsFixed(0),
                  style: tokens.typography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'スコア',
                  style: tokens.typography.caption.copyWith(
                    color: tokens.textMuted,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    MinqTheme tokens,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.border.withAlpha((255 * 0.5).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: tokens.spacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: tokens.typography.caption.copyWith(
                    color: tokens.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            value,
            style: tokens.typography.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPerformanceBar(
    String category,
    double performance,
    MinqTheme tokens,
  ) {
    final color = _getPerformanceColor(performance);
    
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: tokens.typography.body.copyWith(
                  color: tokens.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(performance * 100).toStringAsFixed(0)}%',
                style: tokens.typography.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xs),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: tokens.surfaceVariant,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: performance.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.blue;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Color _getStreakColor(double streak) {
    if (streak >= 7) return Colors.orange;
    if (streak >= 3) return Colors.blue;
    if (streak >= 1) return Colors.green;
    return Colors.grey;
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.6) return Colors.blue;
    if (rate >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Color _getPerformanceColor(double performance) {
    if (performance >= 0.8) return Colors.green;
    if (performance >= 0.6) return Colors.blue;
    if (performance >= 0.4) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(double score) {
    if (score >= 0.8) return '素晴らしい継続力です！';
    if (score >= 0.6) return '良いペースで継続中';
    if (score >= 0.4) return '改善の余地があります';
    return '継続をサポートします';
  }
}