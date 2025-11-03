import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:minq/core/monitoring/crash_reporting_service.dart';

class CrashStatisticsCard extends StatelessWidget {
  final CrashStatistics statistics;

  const CrashStatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crash Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildOverviewMetrics(context),
            const SizedBox(height: 16),
            _buildCrashCharts(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewMetrics(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Crashes',
            statistics.totalCrashes.toString(),
            Icons.bug_report,
            Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Last 24h',
            statistics.crashesLast24Hours.toString(),
            Icons.access_time,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Last 7 days',
            statistics.crashesLast7Days.toString(),
            Icons.date_range,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Pending',
            statistics.pendingUploads.toString(),
            Icons.cloud_upload,
            Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCrashCharts(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCrashTypeChart()),
        const SizedBox(width: 16),
        Expanded(child: _buildSeverityChart()),
      ],
    );
  }

  Widget _buildCrashTypeChart() {
    if (statistics.crashesByType.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No crash type data')),
      );
    }

    final sections =
        statistics.crashesByType.entries.map((entry) {
          final color = _getTypeColor(entry.key);
          final percentage = (entry.value / statistics.totalCrashes) * 100;

          return PieChartSectionData(
            color: color,
            value: entry.value.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return Column(
      children: [
        const Text(
          'Crashes by Type',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 20,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildLegend(statistics.crashesByType, _getTypeColor),
      ],
    );
  }

  Widget _buildSeverityChart() {
    if (statistics.crashesBySeverity.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No severity data')),
      );
    }

    final sections =
        statistics.crashesBySeverity.entries.map((entry) {
          final color = _getSeverityColor(entry.key);
          final percentage = (entry.value / statistics.totalCrashes) * 100;

          return PieChartSectionData(
            color: color,
            value: entry.value.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return Column(
      children: [
        const Text(
          'Crashes by Severity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 20,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildLegend(statistics.crashesBySeverity, _getSeverityColor),
      ],
    );
  }

  Widget _buildLegend<T>(Map<T, int> data, Color Function(T) getColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children:
          data.entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: getColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.key.toString().split('.').last} (${entry.value})',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            );
          }).toList(),
    );
  }

  Color _getTypeColor(CrashType type) {
    switch (type) {
      case CrashType.flutter:
        return Colors.blue;
      case CrashType.platform:
        return Colors.green;
      case CrashType.async:
        return Colors.orange;
      case CrashType.custom:
        return Colors.purple;
    }
  }

  Color _getSeverityColor(CrashSeverity severity) {
    switch (severity) {
      case CrashSeverity.low:
        return Colors.green;
      case CrashSeverity.medium:
        return Colors.yellow;
      case CrashSeverity.high:
        return Colors.orange;
      case CrashSeverity.critical:
        return Colors.red;
    }
  }
}
