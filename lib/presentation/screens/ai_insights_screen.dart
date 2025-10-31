import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/ai/ai_insights.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/charts/category_distribution_chart.dart';
import 'package:minq/presentation/widgets/charts/completion_trend_chart.dart';
import 'package:minq/presentation/widgets/insights/failure_prediction_card.dart';
import 'package:minq/presentation/widgets/insights/progress_summary_card.dart';
import 'package:minq/presentation/widgets/insights/recommendation_card.dart';

/// AI Insights Dashboard Screen
class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final insightsAsync = ref.watch(aiInsightsProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '戻る',
          onPressed: () => context.pop(),
        ),
        title: Text(
          'AIインサイト',
          style: tokens.typography.h4.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: _isRefreshing ? tokens.textMuted : tokens.textPrimary,
            ),
            tooltip: '更新',
            onPressed: _isRefreshing ? null : _refreshInsights,
          ),
        ],
      ),
      body: insightsAsync.when(
        data: (insights) => _buildInsightsDashboard(insights, tokens),
        loading: () => _buildLoadingState(tokens),
        error: (error, _) => _buildErrorState(error, tokens),
      ),
    );
  }

  Widget _buildInsightsDashboard(AIInsights insights, MinqTheme tokens) {
    return RefreshIndicator(
      onRefresh: _refreshInsights,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with generation time
            _buildHeader(insights, tokens),
            SizedBox(height: tokens.spacing.lg),

            // Progress Summary Card
            ProgressSummaryCard(analysis: insights.progressAnalysis),
            SizedBox(height: tokens.spacing.lg),

            // Trends Section
            _buildSectionHeader('習慣の傾向', tokens),
            SizedBox(height: tokens.spacing.md),
            CompletionTrendChart(trends: insights.trends),
            SizedBox(height: tokens.spacing.md),
            CategoryDistributionChart(trends: insights.trends),
            SizedBox(height: tokens.spacing.lg),

            // Failure Prediction (if exists)
            if (insights.failurePrediction != null) ...[
              _buildSectionHeader('リスク予測', tokens),
              SizedBox(height: tokens.spacing.md),
              FailurePredictionCard(prediction: insights.failurePrediction!),
              SizedBox(height: tokens.spacing.lg),
            ],

            // Recommendations Section
            _buildSectionHeader('パーソナライズされた提案', tokens),
            SizedBox(height: tokens.spacing.md),
            ...insights.recommendations.map((recommendation) => Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing.md),
              child: RecommendationCard(recommendation: recommendation),
            )),

            // Progress Insights
            if (insights.progressAnalysis.insights.isNotEmpty) ...[
              SizedBox(height: tokens.spacing.lg),
              _buildSectionHeader('進捗インサイト', tokens),
              SizedBox(height: tokens.spacing.md),
              ...insights.progressAnalysis.insights.map((insight) => 
                _buildInsightCard(insight, tokens),
              ),
            ],

            // Bottom padding
            SizedBox(height: tokens.spacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AIInsights insights, MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.brandPrimary.withAlpha((255 * 0.1).round()),
            tokens.brandPrimary.withAlpha((255 * 0.05).round()),
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
                  size: tokens.spacing.xl,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI分析レポート',
                      style: tokens.typography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      'あなたの習慣データを分析しました',
                      style: tokens.typography.body.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            insights.trends.trendDescription,
            style: tokens.typography.body.copyWith(
              fontStyle: FontStyle.italic,
              color: tokens.textSecondary,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            '最終更新: ${_formatDateTime(insights.generatedAt)}',
            style: tokens.typography.caption.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, MinqTheme tokens) {
    return Text(
      title,
      style: tokens.typography.h3.copyWith(
        fontWeight: FontWeight.bold,
        color: tokens.textPrimary,
      ),
    );
  }

  Widget _buildInsightCard(ProgressInsight insight, MinqTheme tokens) {
    final iconData = _getInsightIcon(insight.type);
    final color = _getInsightColor(insight.type, tokens);

    return Container(
      margin: EdgeInsets.only(bottom: tokens.spacing.md),
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
              Container(
                padding: EdgeInsets.all(tokens.spacing.sm),
                decoration: BoxDecoration(
                  color: color.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                child: Icon(iconData, color: color, size: 20),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: Text(
                  insight.title,
                  style: tokens.typography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.sm,
                  vertical: tokens.spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Text(
                  '影響度: ${(insight.impact * 100).toStringAsFixed(0)}%',
                  style: tokens.typography.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            insight.description,
            style: tokens.typography.body.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          if (insight.actionRecommendation != null) ...[
            SizedBox(height: tokens.spacing.sm),
            Text(
              '💡 ${insight.actionRecommendation}',
              style: tokens.typography.body.copyWith(
                color: tokens.brandPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(MinqTheme tokens) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(tokens.brandPrimary),
          ),
          SizedBox(height: tokens.spacing.lg),
          Text(
            'AIがあなたの習慣データを分析中...',
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, MinqTheme tokens) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: tokens.textMuted,
            ),
            SizedBox(height: tokens.spacing.lg),
            Text(
              'インサイトを読み込めませんでした',
              style: tokens.typography.h4.copyWith(
                color: tokens.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing.md),
            Text(
              'ネットワーク接続を確認して、もう一度お試しください。',
              style: tokens.typography.body.copyWith(
                color: tokens.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing.lg),
            FilledButton(
              onPressed: _refreshInsights,
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshInsights() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    
    try {
      unawaited(ref.refresh(aiInsightsProvider.future));
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.achievement:
        return Icons.emoji_events;
      case InsightType.improvement:
        return Icons.trending_up;
      case InsightType.warning:
        return Icons.warning_amber;
      case InsightType.opportunity:
        return Icons.lightbulb_outline;
      case InsightType.pattern:
        return Icons.analytics;
    }
  }

  Color _getInsightColor(InsightType type, MinqTheme tokens) {
    switch (type) {
      case InsightType.achievement:
        return Colors.green;
      case InsightType.improvement:
        return tokens.brandPrimary;
      case InsightType.warning:
        return Colors.orange;
      case InsightType.opportunity:
        return Colors.blue;
      case InsightType.pattern:
        return Colors.purple;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Provider for AI Insights
final aiInsightsProvider = FutureProvider<AIInsights>((ref) async {
  final insightsService = ref.read(aiInsightsServiceProvider);
  final questRepository = ref.read(questRepositoryProvider);
  final questLogRepository = ref.read(questLogRepositoryProvider);
  
  // Get current user ID (replace with actual user ID logic)
  const userId = 'current_user';
  
  return insightsService.generateInsights(
    userId: userId,
    questRepository: questRepository,
    questLogRepository: questLogRepository,
  );
});