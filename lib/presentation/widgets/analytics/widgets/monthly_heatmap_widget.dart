import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';

class MonthlyHeatmapWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;

  const MonthlyHeatmapWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 実際の月間データプロバイダーを実装
    final heatmapData = _getMockHeatmapData();
    
    return _buildHeatmap(context, heatmapData);
  }

  Widget _buildHeatmap(BuildContext context, Map<DateTime, int> heatmapData) {
    if (heatmapData.isEmpty) {
      return _buildEmptyState(context);
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return Column(
      children: [
        _buildWeekdayLabels(context),
        const SizedBox(height: 4),
        Expanded(
          child: _buildCalendarGrid(context, heatmapData, startOfMonth, endOfMonth),
        ),
        const SizedBox(height: 8),
        _buildLegend(context, heatmapData),
      ],
    );
  }

  Widget _buildWeekdayLabels(BuildContext context) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    
    return Row(
      children: weekdays.map((day) => Expanded(
        child: Center(
          child: Text(
            day,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    Map<DateTime, int> heatmapData,
    DateTime startOfMonth,
    DateTime endOfMonth,
  ) {
    final weeks = <List<DateTime>>[];
    var currentWeek = <DateTime>[];
    
    // 月の最初の週の空白日を追加
    final firstWeekday = startOfMonth.weekday;
    for (int i = 1; i < firstWeekday; i++) {
      currentWeek.add(DateTime(0)); // 空白日
    }
    
    // 月の日付を追加
    for (int day = 1; day <= endOfMonth.day; day++) {
      final date = DateTime(startOfMonth.year, startOfMonth.month, day);
      currentWeek.add(date);
      
      if (currentWeek.length == 7) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
    }
    
    // 最後の週の空白日を追加
    while (currentWeek.isNotEmpty && currentWeek.length < 7) {
      currentWeek.add(DateTime(0)); // 空白日
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }
    
    return Column(
      children: weeks.map((week) => Expanded(
        child: Row(
          children: week.map((date) => Expanded(
            child: _buildDayCell(context, date, heatmapData),
          )).toList(),
        ),
      )).toList(),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date, Map<DateTime, int> heatmapData) {
    if (date.year == 0) {
      // 空白日
      return Container();
    }
    
    final completionCount = heatmapData[DateTime(date.year, date.month, date.day)] ?? 0;
    final intensity = _getIntensity(completionCount);
    
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: _getIntensityColor(intensity),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: 10,
            color: intensity > 0.5 ? Colors.white : Colors.black87,
            fontWeight: completionCount > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, Map<DateTime, int> heatmapData) {
    final maxCompletions = heatmapData.values.fold<int>(0, (max, count) => count > max ? count : max);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '少ない',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            final intensity = index / 4.0;
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: _getIntensityColor(intensity),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        Text(
          '多い ($maxCompletions)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_view_month,
            size: 32,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            'データなし',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  double _getIntensity(int completionCount) {
    if (completionCount == 0) return 0.0;
    if (completionCount <= 2) return 0.25;
    if (completionCount <= 4) return 0.5;
    if (completionCount <= 6) return 0.75;
    return 1.0;
  }

  Color _getIntensityColor(double intensity) {
    const baseColor = Colors.blue; // TODO: Use theme color
    
    if (intensity == 0.0) {
      return Colors.grey.withOpacity(0.1);
    }
    
    return baseColor.withOpacity(0.2 + (intensity * 0.8));
  }

  Map<DateTime, int> _getMockHeatmapData() {
    // TODO: 実際のデータソースから取得
    final now = DateTime.now();
    final data = <DateTime, int>{};
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dayKey = DateTime(date.year, date.month, date.day);
      data[dayKey] = (i % 7 == 0) ? 0 : (i % 3) + 1; // ランダムなデータ
    }
    
    return data;
  }
}