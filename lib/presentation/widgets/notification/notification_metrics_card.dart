import 'package:flutter/material.dart';
import 'package:minq/domain/notification/notification_analytics.dart';
import 'package:minq/domain/notification/notification_settings.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/l10n/l10n.dart';

/// 通知メトリクスカード
class NotificationMetricsCard extends StatelessWidget {
  final NotificationCategory category;
  final NotificationMetrics metrics;
  final bool showDetails;

  const NotificationMetricsCard({
    super.key,
    required this.category,
    required this.metrics,
    this.showDetails = false,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getCategoryDisplayName(category, l10n),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (metrics.totalSent > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPerformanceColor(
                        metrics.openRate,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(metrics.openRate * 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getPerformanceColor(metrics.openRate),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Sent',
                    metrics.totalSent.toString(),
                    Icons.send,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Opened',
                    metrics.totalOpened.toString(),
                    Icons.open_in_new,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Converted',
                    metrics.totalConverted.toString(),
                    Icons.star,
                  ),
                ),
              ],
            ),

            if (showDetails) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              _buildDetailedMetrics(context, metrics, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildDetailedMetrics(
    BuildContext context,
    NotificationMetrics metrics,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detailed Metrics', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                'Delivery Rate',
                '${(metrics.deliveryRate * 100).toStringAsFixed(1)}%',
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                context,
                'Click Rate',
                '${(metrics.clickRate * 100).toStringAsFixed(1)}%',
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                'Avg. Response Time',
                _formatDuration(metrics.averageTimeToAction),
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                context,
                'Dismissed',
                metrics.totalDismissed.toString(),
              ),
            ),
          ],
        ),

        if (metrics.hourlyDistribution != null) ...[
          const SizedBox(height: 16),
          Text('Peak Hours', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _buildPeakHours(context, metrics.hourlyDistribution!),
        ],
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPeakHours(
    BuildContext context,
    Map<String, int> hourlyDistribution,
  ) {
    final sortedHours =
        hourlyDistribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final topHours = sortedHours.take(3).toList();

    return Wrap(
      spacing: 8,
      children:
          topHours.map((entry) {
            final hour = int.parse(entry.key);
            final count = entry.value;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00 ($count)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            );
          }).toList(),
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

  Color _getPerformanceColor(double rate) {
    if (rate >= 0.7) return Colors.green;
    if (rate >= 0.4) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
