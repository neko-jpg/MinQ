import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:minq/domain/notification/notification_analytics.dart';
import 'package:minq/domain/notification/notification_settings.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/l10n/l10n.dart';

/// 最適タイミングチャート
class OptimalTimingChart extends StatelessWidget {
  final NotificationCategory category;
  final OptimalTimingAnalysis analysis;

  const OptimalTimingChart({
    super.key,
    required this.category,
    required this.analysis,
  });

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
                _getCategoryIcon(category),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getCategoryDisplayName(category, l10n),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(
                      analysis.confidence,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Confidence: ${(analysis.confidence * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getConfidenceColor(analysis.confidence),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (analysis.hourlyEngagementRates != null) ...[
              Text(
                'Hourly Engagement Rates',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1.0,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final hour = group.x.toInt();
                          final rate = rod.toY;
                          return BarTooltipItem(
                            '${hour.toString().padLeft(2, '0')}:00\n${(rate * 100).toStringAsFixed(1)}%',
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
                            final hour = value.toInt();
                            if (hour % 4 == 0) {
                              return Text(
                                hour.toString().padLeft(2, '0'),
                                style: theme.textTheme.bodySmall,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${(value * 100).toInt()}%',
                              style: theme.textTheme.bodySmall,
                            );
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
                    barGroups: _buildBarGroups(
                      analysis.hourlyEngagementRates!,
                      theme,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            if (analysis.optimalHours.isNotEmpty) ...[
              Text('Optimal Hours', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    analysis.optimalHours.map((hour) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Sample Size',
                    analysis.sampleSize.toString(),
                    Icons.data_usage,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Analyzed',
                    _formatDate(analysis.analyzedAt),
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    Map<String, double> hourlyRates,
    ThemeData theme,
  ) {
    return List.generate(24, (index) {
      final rate = hourlyRates[index.toString()] ?? 0.0;
      final isOptimal = analysis.optimalHours.contains(index);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: rate,
            color:
                isOptimal
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.3),
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ],
      );
    });
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Icon _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.quest:
        return const Icon(Icons.task_alt);
      case NotificationCategory.challenge:
        return const Icon(Icons.emoji_events);
      case NotificationCategory.pair:
        return const Icon(Icons.people);
      case NotificationCategory.league:
        return const Icon(Icons.leaderboard);
      case NotificationCategory.ai:
        return const Icon(Icons.psychology);
      case NotificationCategory.system:
        return const Icon(Icons.settings);
      case NotificationCategory.achievement:
        return const Icon(Icons.military_tech);
      case NotificationCategory.reminder:
        return const Icon(Icons.alarm);
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

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
