import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';

class WeeklyTrendWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;

  const WeeklyTrendWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 実際の週間データプロバイダーを実装
    final weeklyData = _getMockWeeklyData();
    
    return _buildLineChart(context, weeklyData);
  }

  Widget _buildLineChart(BuildContext context, List<WeeklyDataPoint> weeklyData) {
    if (weeklyData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < weeklyData.length) {
                        return Text(
                          weeklyData[index].dayLabel,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: weeklyData.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.completionCount.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  // tooltipBgColor: Colors.blueGrey, // Deprecated parameter
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.toInt();
                      if (index >= 0 && index < weeklyData.length) {
                        final data = weeklyData[index];
                        return LineTooltipItem(
                          '${data.dayLabel}\n${data.completionCount}個完了',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }
                      return null;
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildSummary(context, weeklyData),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, List<WeeklyDataPoint> weeklyData) {
    final totalCompletions = weeklyData.fold<int>(0, (sum, data) => sum + data.completionCount);
    final averageCompletions = totalCompletions / weeklyData.length;
    final trend = _calculateTrend(weeklyData);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            '合計',
            '$totalCompletions',
            Icons.add,
          ),
          _buildSummaryItem(
            context,
            '平均',
            averageCompletions.toStringAsFixed(1),
            Icons.trending_flat,
          ),
          _buildSummaryItem(
            context,
            'トレンド',
            trend > 0 ? '+${trend.toStringAsFixed(1)}' : trend.toStringAsFixed(1),
            trend > 0 ? Icons.trending_up : Icons.trending_down,
            color: trend > 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Colors.grey,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
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
            Icons.trending_up,
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

  double _calculateTrend(List<WeeklyDataPoint> weeklyData) {
    if (weeklyData.length < 2) return 0.0;
    
    final firstHalf = weeklyData.take(weeklyData.length ~/ 2).toList();
    final secondHalf = weeklyData.skip(weeklyData.length ~/ 2).toList();
    
    final firstAverage = firstHalf.fold<int>(0, (sum, data) => sum + data.completionCount) / firstHalf.length;
    final secondAverage = secondHalf.fold<int>(0, (sum, data) => sum + data.completionCount) / secondHalf.length;
    
    return secondAverage - firstAverage;
  }

  List<WeeklyDataPoint> _getMockWeeklyData() {
    // TODO: 実際のデータソースから取得
    return [
      WeeklyDataPoint(dayLabel: '月', completionCount: 3),
      WeeklyDataPoint(dayLabel: '火', completionCount: 5),
      WeeklyDataPoint(dayLabel: '水', completionCount: 2),
      WeeklyDataPoint(dayLabel: '木', completionCount: 7),
      WeeklyDataPoint(dayLabel: '金', completionCount: 4),
      WeeklyDataPoint(dayLabel: '土', completionCount: 6),
      WeeklyDataPoint(dayLabel: '日', completionCount: 3),
    ];
  }
}

class WeeklyDataPoint {
  final String dayLabel;
  final int completionCount;

  WeeklyDataPoint({
    required this.dayLabel,
    required this.completionCount,
  });
}