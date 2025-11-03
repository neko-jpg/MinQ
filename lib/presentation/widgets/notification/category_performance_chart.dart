import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:minq/domain/notification/notification_analytics.dart';
import 'package:minq/domain/notification/notification_settings.dart';
import 'package:minq/l10n/l10n.dart';

/// カテゴリパフォーマンスチャート
class CategoryPerformanceChart extends StatefulWidget {
  final Map<NotificationCategory, NotificationMetrics> metrics;

  const CategoryPerformanceChart({super.key, required this.metrics});

  @override
  State<CategoryPerformanceChart> createState() =>
      _CategoryPerformanceChartState();
}

class _CategoryPerformanceChartState extends State<CategoryPerformanceChart> {
  String _selectedMetric = 'openRate';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Category Performance',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedMetric,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMetric = value;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'openRate',
                      child: Text('Open Rate'),
                    ),
                    DropdownMenuItem(
                      value: 'conversionRate',
                      child: Text('Conversion Rate'),
                    ),
                    DropdownMenuItem(
                      value: 'totalSent',
                      child: Text('Total Sent'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final category =
                            NotificationCategory.values[group.x.toInt()];
                        final value = rod.toY;
                        final displayValue =
                            _selectedMetric == 'totalSent'
                                ? value.toInt().toString()
                                : '${(value * 100).toStringAsFixed(1)}%';

                        return BarTooltipItem(
                          '${_getCategoryDisplayName(category, l10n)}\n$displayValue',
                          theme.textTheme.bodySmall!,
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
                          final categoryIndex = value.toInt();
                          if (categoryIndex >= 0 &&
                              categoryIndex <
                                  NotificationCategory.values.length) {
                            final category =
                                NotificationCategory.values[categoryIndex];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _getCategoryIcon(category),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          if (_selectedMetric == 'totalSent') {
                            return Text(
                              value.toInt().toString(),
                              style: theme.textTheme.bodySmall,
                            );
                          } else {
                            return Text(
                              '${(value * 100).toInt()}%',
                              style: theme.textTheme.bodySmall,
                            );
                          }
                        },
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
                  barGroups: _buildBarGroups(theme),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildLegend(context, l10n),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(ThemeData theme) {
    return NotificationCategory.values.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final metrics = widget.metrics[category];

      if (metrics == null) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: 0,
              color: theme.colorScheme.surfaceContainerHighest,
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        );
      }

      final value = _getMetricValue(metrics);
      final color = _getCategoryColor(category, theme);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: color,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  double _getMetricValue(NotificationMetrics metrics) {
    switch (_selectedMetric) {
      case 'openRate':
        return metrics.openRate;
      case 'conversionRate':
        return metrics.conversionRate;
      case 'totalSent':
        return metrics.totalSent.toDouble();
      default:
        return 0.0;
    }
  }

  double _getMaxY() {
    if (_selectedMetric == 'totalSent') {
      final maxSent = widget.metrics.values
          .map((m) => m.totalSent)
          .fold(0, (max, value) => value > max ? value : max);
      return (maxSent * 1.2).toDouble();
    } else {
      return 1.0; // For percentage values
    }
  }

  Widget _buildLegend(BuildContext context, AppLocalizations l10n) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          NotificationCategory.values.map((category) {
            final color = _getCategoryColor(category, Theme.of(context));

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _getCategoryShortName(category),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
    );
  }

  Color _getCategoryColor(NotificationCategory category, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    return colors[category.index % colors.length];
  }

  Icon _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.quest:
        return const Icon(Icons.task_alt, size: 16);
      case NotificationCategory.challenge:
        return const Icon(Icons.emoji_events, size: 16);
      case NotificationCategory.pair:
        return const Icon(Icons.people, size: 16);
      case NotificationCategory.league:
        return const Icon(Icons.leaderboard, size: 16);
      case NotificationCategory.ai:
        return const Icon(Icons.psychology, size: 16);
      case NotificationCategory.system:
        return const Icon(Icons.settings, size: 16);
      case NotificationCategory.achievement:
        return const Icon(Icons.military_tech, size: 16);
      case NotificationCategory.reminder:
        return const Icon(Icons.alarm, size: 16);
    }
  }

  String _getCategoryDisplayName(
    NotificationCategory category,
    AppLocalizations l10n,
  ) {
    switch (category) {
      case NotificationCategory.quest:
        return l10n.questNotifications;
      case NotificationCategory.challenge:
        return l10n.challengeNotifications;
      case NotificationCategory.pair:
        return l10n.pairNotifications;
      case NotificationCategory.league:
        return l10n.leagueNotifications;
      case NotificationCategory.ai:
        return l10n.aiNotifications;
      case NotificationCategory.system:
        return l10n.systemNotifications;
      case NotificationCategory.achievement:
        return l10n.achievementNotifications;
      case NotificationCategory.reminder:
        return l10n.reminderNotifications;
    }
  }

  String _getCategoryShortName(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.quest:
        return 'Quest';
      case NotificationCategory.challenge:
        return 'Challenge';
      case NotificationCategory.pair:
        return 'Pair';
      case NotificationCategory.league:
        return 'League';
      case NotificationCategory.ai:
        return 'AI';
      case NotificationCategory.system:
        return 'System';
      case NotificationCategory.achievement:
        return 'Achievement';
      case NotificationCategory.reminder:
        return 'Reminder';
    }
  }
}
