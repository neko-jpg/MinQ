import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/behavior_pattern.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';
import 'package:minq/presentation/providers/analytics_providers.dart';

class TimePatternWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;

  const TimePatternWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timePatterns = ref.watch(timePatternProvider);

    return timePatterns.when(
      data: (patterns) => _buildChart(context, patterns),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context),
    );
  }

  Widget _buildChart(BuildContext context, List<TimePattern> patterns) {
    if (patterns.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 1.0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  // tooltipBgColor: Colors.blueGrey, // Deprecated parameter
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final pattern = patterns[group.x.toInt()];
                    return BarTooltipItem(
                      '${pattern.hour}時\n成功率: ${(pattern.successRate * 100).toStringAsFixed(1)}%\n完了数: ${pattern.completionCount}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final hour = value.toInt();
                      if (hour < patterns.length) {
                        return Text(
                          '${patterns[hour].hour}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 20,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups:
                  patterns.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pattern = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: pattern.successRate,
                          color: _getBarColor(pattern.successRate),
                          width: 12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildLegend(context, patterns),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, List<TimePattern> patterns) {
    // 最も成功率の高い時間帯を見つける
    final bestPattern = patterns.fold<TimePattern?>(null, (best, current) {
      if (best == null || current.successRate > best.successRate) {
        return current;
      }
      return best;
    });

    if (bestPattern == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.star, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '最適: ${bestPattern.hour}時 (${(bestPattern.successRate * 100).toStringAsFixed(1)}%)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 32, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'データなし',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          Text(
            'クエストを完了すると\n時間帯パターンが表示されます',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
          Text('分析中...', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 32, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            'エラー',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Color _getBarColor(double successRate) {
    if (successRate >= 0.8) {
      return Colors.green;
    } else if (successRate >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
