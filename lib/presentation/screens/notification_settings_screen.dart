import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/domain/notification/notification_settings.dart';
import 'package:minq/l10n/l10n.dart';
import 'package:minq/presentation/providers/notification_providers.dart';
import 'package:minq/presentation/widgets/notification/analytics_card.dart';
import 'package:minq/presentation/widgets/notification/category_settings_card.dart';
import 'package:minq/presentation/widgets/notification/smart_settings_card.dart';
import 'package:minq/presentation/widgets/notification/time_settings_card.dart';

/// 通知設定画面
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notificationSettings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => context.push('/notification-analytics'),
            tooltip: l10n.notificationAnalytics,
          ),
        ],
      ),
      body: notificationSettings.when(
        data: (settings) => _buildSettingsContent(context, ref, settings, l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingSettings,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(notificationSettingsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // グローバル設定
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.globalSettings,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(l10n.enableNotifications),
                    subtitle: Text(l10n.enableNotificationsDescription),
                    value: settings.globalEnabled,
                    onChanged: (value) {
                      ref.read(notificationSettingsProvider.notifier).updateGlobalEnabled(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // カテゴリ別設定
          Text(
            l10n.categorySettings,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.categorySettingsDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          
          ...NotificationCategory.values.map((category) {
            final categorySettings = settings.categorySettings[category] ??
                CategoryNotificationSettings(category: category);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CategorySettingsCard(
                category: category,
                settings: categorySettings,
                onSettingsChanged: (newSettings) {
                  ref.read(notificationSettingsProvider.notifier)
                      .updateCategorySettings(category, newSettings);
                },
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // 時間帯設定
          Text(
            l10n.timeSettings,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.timeSettingsDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          
          TimeSettingsCard(
            settings: settings.timeSettings,
            onSettingsChanged: (newSettings) {
              ref.read(notificationSettingsProvider.notifier)
                  .updateTimeSettings(newSettings);
            },
          ),
          
          const SizedBox(height: 24),
          
          // スマート通知設定
          Text(
            l10n.smartSettings,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.smartSettingsDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          
          SmartSettingsCard(
            settings: settings.smartSettings,
            onSettingsChanged: (newSettings) {
              ref.read(notificationSettingsProvider.notifier)
                  .updateSmartSettings(newSettings);
            },
          ),
          
          const SizedBox(height: 24),
          
          // 分析設定
          Text(
            l10n.analyticsSettings,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.analyticsSettingsDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          
          AnalyticsCard(
            settings: settings.analyticsSettings,
            onSettingsChanged: (newSettings) {
              ref.read(notificationSettingsProvider.notifier)
                  .updateAnalyticsSettings(newSettings);
            },
          ),
          
          const SizedBox(height: 24),
          
          // アクションボタン
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showResetDialog(context, ref, l10n),
                  child: Text(l10n.resetToDefaults),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _testNotification(context, ref, l10n),
                  child: Text(l10n.testNotification),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettings),
        content: Text(l10n.resetSettingsConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(notificationSettingsProvider.notifier).resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsReset)),
              );
            },
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  void _testNotification(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    ref.read(notificationServiceProvider).scheduleNotification(
      id: 'test_notification',
      title: l10n.testNotificationTitle,
      body: l10n.testNotificationBody,
      category: NotificationCategory.system,
      userId: 'current_user', // 実際のユーザーIDを使用
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.testNotificationSent)),
    );
  }
}