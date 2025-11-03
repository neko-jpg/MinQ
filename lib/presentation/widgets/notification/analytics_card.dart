import 'package:flutter/material.dart';
import 'package:minq/domain/notification/notification_settings.dart';
import 'package:minq/l10n/l10n.dart';

/// 通知分析設定カード
class AnalyticsCard extends StatelessWidget {
  final NotificationAnalyticsSettings settings;
  final ValueChanged<NotificationAnalyticsSettings> onSettingsChanged;

  const AnalyticsCard({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
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
            SwitchListTile(
              title: Text(l10n.enableAnalytics),
              subtitle: Text(l10n.enableAnalyticsDescription),
              value: settings.enabled,
              onChanged: (value) {
                onSettingsChanged(settings.copyWith(enabled: value));
              },
              contentPadding: EdgeInsets.zero,
            ),

            if (settings.enabled) ...[
              const Divider(),

              Text(l10n.trackingOptions, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),

              // 開封率追跡
              CheckboxListTile(
                title: Text(l10n.trackOpenRate),
                subtitle: Text(l10n.trackOpenRateDescription),
                value: settings.trackOpenRate,
                onChanged: (value) {
                  if (value != null) {
                    onSettingsChanged(settings.copyWith(trackOpenRate: value));
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              // エンゲージメント率追跡
              CheckboxListTile(
                title: Text(l10n.trackEngagementRate),
                subtitle: Text(l10n.trackEngagementRateDescription),
                value: settings.trackEngagementRate,
                onChanged: (value) {
                  if (value != null) {
                    onSettingsChanged(
                      settings.copyWith(trackEngagementRate: value),
                    );
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              // コンバージョン率追跡
              CheckboxListTile(
                title: Text(l10n.trackConversionRate),
                subtitle: Text(l10n.trackConversionRateDescription),
                value: settings.trackConversionRate,
                onChanged: (value) {
                  if (value != null) {
                    onSettingsChanged(
                      settings.copyWith(trackConversionRate: value),
                    );
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              // 最適タイミング分析
              CheckboxListTile(
                title: Text(l10n.trackOptimalTiming),
                subtitle: Text(l10n.trackOptimalTimingDescription),
                value: settings.trackOptimalTiming,
                onChanged: (value) {
                  if (value != null) {
                    onSettingsChanged(
                      settings.copyWith(trackOptimalTiming: value),
                    );
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),

              // データ保持期間
              Text(l10n.dataRetentionPeriod, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: settings.retentionPeriodDays.toDouble(),
                      min: 7.0,
                      max: 365.0,
                      divisions: 51, // 7日から365日まで、約7日刻み
                      label: l10n.daysCount(settings.retentionPeriodDays),
                      onChanged: (value) {
                        onSettingsChanged(
                          settings.copyWith(retentionPeriodDays: value.round()),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      l10n.daysCount(settings.retentionPeriodDays),
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              Text(
                l10n.dataRetentionDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),

              // プライバシー情報
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    (255 * 0.3).round(),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.analyticsPrivacyNote,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // データ管理ボタン
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDataExportDialog(context, l10n),
                      icon: const Icon(Icons.download),
                      label: Text(l10n.exportData),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDataDeleteDialog(context, l10n),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.deleteData),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDataExportDialog(BuildContext context, AppLocalizations l10n) {
    String selectedFormat = 'csv';
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.exportAnalyticsData),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.exportAnalyticsDataDescription),
                  const SizedBox(height: 16),
                  Text(
                    l10n.exportFormat,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  RadioGroup<String>(
                    groupValue: selectedFormat,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedFormat = value;
                        });
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RadioListTile<String>(
                          title: Text(l10n.csvFormat),
                          subtitle: Text(l10n.csvFormatDescription),
                          value: 'csv',
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: Text(l10n.jsonFormat),
                          subtitle: Text(l10n.jsonFormatDescription),
                          value: 'json',
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 実際の実装ではデータエクスポートを実行
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.dataExported)));
                  },
                  child: Text(l10n.export),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDataDeleteDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteAnalyticsData),
            content: Text(l10n.deleteAnalyticsDataConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 実際の実装では分析データを削除
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.analyticsDataDeleted)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );
  }
}
