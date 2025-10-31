import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';
import 'package:minq/presentation/widgets/analytics/widgets/achievements_widget.dart';
import 'package:minq/presentation/widgets/analytics/widgets/category_breakdown_widget.dart';
import 'package:minq/presentation/widgets/analytics/widgets/completion_rate_widget.dart';
import 'package:minq/presentation/widgets/analytics/widgets/goal_progress_widget.dart';
import 'package:minq/presentation/widgets/analytics/widgets/insights_widget.dart';
import 'package:minq/presentation/widgets/analytics/widgets/monthly_heatmap_widget.dart';
import 'package:minq/presentation/widgets/analytics/widgets/predictions_widget.dart';
import 'package:minq/presentation/widgets/analytics/widgets/streak_counter_widget.dart';
import 'package:minq/presentation/widgets/analytics/widgets/time_pattern_widget.dart';
import 'package:minq/presentation/widgets/analytics/widgets/weekly_trend_widget.dart';

class DashboardWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;
  final Function(DashboardWidgetConfig) onConfigChanged;

  const DashboardWidget({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            Expanded(
              child: _buildContent(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          _getWidgetIcon(config.type),
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            config.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    switch (config.type) {
      case DashboardWidgetType.streakCounter:
        return StreakCounterWidget(config: config);
      case DashboardWidgetType.completionRate:
        return CompletionRateWidget(config: config);
      case DashboardWidgetType.timePattern:
        return TimePatternWidget(config: config);
      case DashboardWidgetType.categoryBreakdown:
        return CategoryBreakdownWidget(config: config);
      case DashboardWidgetType.goalProgress:
        return GoalProgressWidget(config: config);
      case DashboardWidgetType.weeklyTrend:
        return WeeklyTrendWidget(config: config);
      case DashboardWidgetType.monthlyHeatmap:
        return MonthlyHeatmapWidget(config: config);
      case DashboardWidgetType.insights:
        return InsightsWidget(config: config);
      case DashboardWidgetType.predictions:
        return PredictionsWidget(config: config);
      case DashboardWidgetType.achievements:
        return AchievementsWidget(config: config);
      case DashboardWidgetType.comparisons:
        return _buildComparisonsWidget(context);
      case DashboardWidgetType.customChart:
        return _buildCustomChartWidget(context);
    }
  }

  Widget _buildComparisonsWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people,
            size: 32,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            '比較機能',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '準備中',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomChartWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bar_chart,
            size: 32,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            'カスタムチャート',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '準備中',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWidgetIcon(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.streakCounter:
        return Icons.local_fire_department;
      case DashboardWidgetType.completionRate:
        return Icons.check_circle;
      case DashboardWidgetType.timePattern:
        return Icons.access_time;
      case DashboardWidgetType.categoryBreakdown:
        return Icons.pie_chart;
      case DashboardWidgetType.goalProgress:
        return Icons.track_changes;
      case DashboardWidgetType.weeklyTrend:
        return Icons.trending_up;
      case DashboardWidgetType.monthlyHeatmap:
        return Icons.calendar_view_month;
      case DashboardWidgetType.insights:
        return Icons.lightbulb;
      case DashboardWidgetType.predictions:
        return Icons.psychology;
      case DashboardWidgetType.achievements:
        return Icons.emoji_events;
      case DashboardWidgetType.comparisons:
        return Icons.people;
      case DashboardWidgetType.customChart:
        return Icons.bar_chart;
    }
  }
}