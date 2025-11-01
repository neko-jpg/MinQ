import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:minq/core/monitoring/performance_monitoring_service.dart';

class PerformanceChart extends StatelessWidget {
  final Map<String, PerformanceTrend> trends;

  const PerformanceChart({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const Center(child: Text('No performance data available'));
    }

    return Column(
      children: [
        _buildTrendsList(),
        const SizedBox(height: 16),
        Expanded(child: _buildChart()),
      ],
    );
  }

  Widget _buildTrendsList() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: trends.length,
        itemBuilder: (context, index) {
          final trend = trends.values.elementAt(index);
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTrendColor(trend.direction).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getTrendColor(trend.direction),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getTrendIcon(trend.direction),
                      color: _getTrendColor(trend.direction),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trend.changePercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _getTrendColor(trend.direction),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  trend.metricName,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    // Create sample data for demonstration
    final lineChartData = LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 0.5);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 0.5);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(0),
                style: const TextStyle(fontSize: 10),
              );
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 10,
      minY: 0,
      maxY: 100,
      lineBarsData: _generateLineChartData(),
    );

    return LineChart(lineChartData);
  }

  List<LineChartBarData> _generateLineChartData() {
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange];
    final lines = <LineChartBarData>[];

    int colorIndex = 0;
    for (final trend in trends.values.take(4)) {
      final spots = <FlSpot>[];

      // Generate sample data points based on trend
      for (int i = 0; i <= 10; i++) {
        double value = 50; // Base value

        switch (trend.direction) {
          case TrendDirection.increasing:
            value += i * 3 + (i * 0.5); // Increasing trend
            break;
          case TrendDirection.decreasing:
            value -= i * 2 + (i * 0.3); // Decreasing trend
            break;
          case TrendDirection.stable:
            value += (i % 2 == 0 ? 2 : -2); // Stable with minor fluctuations
            break;
        }

        spots.add(FlSpot(i.toDouble(), value.clamp(0, 100)));
      }

      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: colors[colorIndex % colors.length],
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: colors[colorIndex % colors.length].withOpacity(0.1),
          ),
        ),
      );

      colorIndex++;
    }

    return lines;
  }

  Color _getTrendColor(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return Colors.green;
      case TrendDirection.decreasing:
        return Colors.red;
      case TrendDirection.stable:
        return Colors.blue;
    }
  }

  IconData _getTrendIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return Icons.trending_up;
      case TrendDirection.decreasing:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }
}
