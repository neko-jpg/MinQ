import 'package:flutter/material.dart';
import 'package:minq/domain/notification/notification_settings.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/l10n/l10n.dart';

/// スマート通知設定カード
class SmartSettingsCard extends StatelessWidget {
  final SmartNotificationSettings settings;
  final ValueChanged<SmartNotificationSettings> onSettingsChanged;

  const SmartSettingsCard({
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
              title: Text(l10n.enableSmartNotifications),
              subtitle: Text(l10n.enableSmartNotificationsDescription),
              value: settings.enabled,
              onChanged: (value) {
                onSettingsChanged(settings.copyWith(enabled: value));
              },
              contentPadding: EdgeInsets.zero,
            ),

            if (settings.enabled) ...[
              const Divider(),

              // 行動パターン学習
              CheckboxListTile(
                title: Text(l10n.behaviorLearning),
                subtitle: Text(l10n.behaviorLearningDescription),
                value: settings.behaviorLearning,
                onChanged: (value) {
                  if (value != null) {
                    onSettingsChanged(
                      settings.copyWith(behaviorLearning: value),
                    );
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              // 適応的頻度調整
              CheckboxListTile(
                title: Text(l10n.adaptiveFrequency),
                subtitle: Text(l10n.adaptiveFrequencyDescription),
                value: settings.adaptiveFrequency,
                onChanged: (value) {
                  if (value != null) {
                    onSettingsChanged(
                      settings.copyWith(adaptiveFrequency: value),
                    );
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              // コンテキスト認識
              CheckboxListTile(
                title: Text(l10n.contextAware),
                subtitle: Text(l10n.contextAwareDescription),
                value: settings.contextAware,
                onChanged: (value) {
                  if (value != null) {
                    onSettingsChanged(settings.copyWith(contextAware: value));
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              // エンゲージメント最適化
              CheckboxListTile(
                title: Text(l10n.engagementOptimization),
                subtitle: Text(l10n.engagementOptimizationDescription),
                value: settings.engagementOptimization,
                onChanged: (value) {
                  if (value != null) {
                    onSettingsChanged(
                      settings.copyWith(engagementOptimization: value),
                    );
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),

              // 信頼度閾値
              Text(l10n.confidenceThreshold, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: settings.confidenceThreshold,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(settings.confidenceThreshold * 100).round()}%',
                      onChanged: (value) {
                        onSettingsChanged(
                          settings.copyWith(confidenceThreshold: value),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${(settings.confidenceThreshold * 100).round()}%',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              Text(
                l10n.confidenceThresholdDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),

              // 学習期間
              Text(l10n.learningPeriod, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: settings.learningPeriodDays.toDouble(),
                      min: 1.0,
                      max: 30.0,
                      divisions: 29,
                      label: l10n.daysCount(settings.learningPeriodDays),
                      onChanged: (value) {
                        onSettingsChanged(
                          settings.copyWith(learningPeriodDays: value.round()),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      l10n.daysCount(settings.learningPeriodDays),
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              Text(
                l10n.learningPeriodDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),

              // 学習データ管理
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showLearningDataDialog(context, l10n),
                      icon: const Icon(Icons.psychology_outlined),
                      label: Text(l10n.viewLearningData),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showResetLearningDialog(context, l10n),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.resetLearning),
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

  void _showLearningDataDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.learningDataTitle),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.learningDataDescription),
                  const SizedBox(height: 16),

                  // 学習統計の表示（実際の実装では実データを表示）
                  _buildLearningStatItem(
                    l10n.totalNotificationsSent,
                    '127',
                    Icons.send,
                  ),
                  _buildLearningStatItem(
                    l10n.totalNotificationsOpened,
                    '89',
                    Icons.open_in_new,
                  ),
                  _buildLearningStatItem(
                    l10n.averageOpenRate,
                    '70%',
                    Icons.trending_up,
                  ),
                  _buildLearningStatItem(
                    l10n.optimalTimeSlots,
                    '9:00, 13:00, 19:00',
                    Icons.schedule,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.close),
              ),
            ],
          ),
    );
  }

  Widget _buildLearningStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showResetLearningDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.resetLearningData),
            content: Text(l10n.resetLearningDataConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 実際の実装では学習データをリセット
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.learningDataReset)),
                  );
                },
                child: Text(l10n.reset),
              ),
            ],
          ),
    );
  }
}
