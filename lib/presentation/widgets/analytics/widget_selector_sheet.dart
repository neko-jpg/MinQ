import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';
import 'package:minq/presentation/providers/analytics_providers.dart';

class WidgetSelectorSheet extends ConsumerWidget {
  final String dashboardId;
  final Function(DashboardWidgetType) onWidgetSelected;

  const WidgetSelectorSheet({
    super.key,
    required this.dashboardId,
    required this.onWidgetSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableWidgets = ref.read(dashboardServiceProvider).getAvailableWidgetTypes();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ウィジェットを追加',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: availableWidgets.length,
              itemBuilder: (context, index) {
                final widgetType = availableWidgets[index];
                return _buildWidgetCard(context, ref, widgetType);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetCard(BuildContext context, WidgetRef ref, DashboardWidgetType widgetType) {
    final description = ref.read(dashboardServiceProvider).getWidgetTypeDescription(widgetType);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          onWidgetSelected(widgetType);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getWidgetIcon(widgetType),
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                _getWidgetTitle(widgetType),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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

  String _getWidgetTitle(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.streakCounter:
        return 'ストリーク';
      case DashboardWidgetType.completionRate:
        return '完了率';
      case DashboardWidgetType.timePattern:
        return '時間帯パターン';
      case DashboardWidgetType.categoryBreakdown:
        return 'カテゴリ分析';
      case DashboardWidgetType.goalProgress:
        return '目標進捗';
      case DashboardWidgetType.weeklyTrend:
        return '週間トレンド';
      case DashboardWidgetType.monthlyHeatmap:
        return '月間ヒートマップ';
      case DashboardWidgetType.insights:
        return 'インサイト';
      case DashboardWidgetType.predictions:
        return '予測・警告';
      case DashboardWidgetType.achievements:
        return '実績';
      case DashboardWidgetType.comparisons:
        return '比較';
      case DashboardWidgetType.customChart:
        return 'カスタムチャート';
    }
  }
}