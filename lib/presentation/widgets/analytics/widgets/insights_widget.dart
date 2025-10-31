import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/analytics_insight.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';
import 'package:minq/presentation/providers/analytics_providers.dart';

class InsightsWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;

  const InsightsWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(analyticsInsightsProvider);

    return insights.when(
      data: (insightList) => _buildInsightsList(context, insightList),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildInsightsList(BuildContext context, List<AnalyticsInsight> insights) {
    if (insights.isEmpty) {
      return _buildEmptyState(context);
    }

    // 優先度の高いインサイトを最大3つ表示
    final topInsights = insights.take(3).toList();

    return ListView.separated(
      itemCount: topInsights.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final insight = topInsights[index];
        return _buildInsightCard(context, insight);
      },
    );
  }

  Widget _buildInsightCard(BuildContext context, AnalyticsInsight insight) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getPriorityColor(insight.priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getPriorityColor(insight.priority).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getInsightIcon(insight.type),
                size: 16,
                color: _getPriorityColor(insight.priority),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  insight.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getPriorityColor(insight.priority),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildPriorityBadge(context, insight.priority),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            insight.description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (insight.actionItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildActionButton(context, insight.actionItems.first),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ActionItem actionItem) {
    return SizedBox(
      width: double.infinity,
      height: 28,
      child: ElevatedButton(
        onPressed: () => _handleActionItem(context, actionItem),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: Theme.of(context).textTheme.bodySmall,
        ),
        child: Text(
          actionItem.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context, InsightPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _getPriorityText(priority),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 32,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            'インサイトなし',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          Text(
            'データが蓄積されると\n分析結果が表示されます',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(height: 8),
          Text(
            '分析中...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 32,
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          Text(
            'エラー',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
          ),
          Text(
            '分析に失敗しました',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.critical:
        return Colors.red;
      case InsightPriority.high:
        return Colors.orange;
      case InsightPriority.medium:
        return Colors.blue;
      case InsightPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityText(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.critical:
        return '重要';
      case InsightPriority.high:
        return '高';
      case InsightPriority.medium:
        return '中';
      case InsightPriority.low:
        return '低';
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.habitContinuity:
        return Icons.trending_up;
      case InsightType.failurePattern:
        return Icons.warning;
      case InsightType.goalPrediction:
        return Icons.track_changes;
      case InsightType.riskWarning:
        return Icons.error;
      case InsightType.optimization:
        return Icons.tune;
      case InsightType.achievement:
        return Icons.emoji_events;
    }
  }

  void _handleActionItem(BuildContext context, ActionItem actionItem) {
    switch (actionItem.actionType) {
      case ActionType.navigate:
        if (actionItem.route != null) {
          Navigator.of(context).pushNamed(actionItem.route!);
        }
        break;
      case ActionType.createQuest:
        Navigator.of(context).pushNamed('/create-quest');
        break;
      case ActionType.adjustSchedule:
        Navigator.of(context).pushNamed('/schedule');
        break;
      case ActionType.setReminder:
        Navigator.of(context).pushNamed('/reminders');
        break;
      case ActionType.viewStats:
        Navigator.of(context).pushNamed('/stats');
        break;
      case ActionType.shareProgress:
        // TODO: 進捗共有機能を実装
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('進捗共有機能は準備中です')),
        );
        break;
      case ActionType.adjustGoals:
        Navigator.of(context).pushNamed('/goals');
        break;
    }
  }
}