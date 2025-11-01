import 'package:flutter/material.dart';
import 'package:minq/domain/notification/notification_settings.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/l10n/l10n.dart';

/// カテゴリ別通知設定カード
class CategorySettingsCard extends StatelessWidget {
  final NotificationCategory category;
  final CategoryNotificationSettings settings;
  final ValueChanged<CategoryNotificationSettings> onSettingsChanged;

  const CategorySettingsCard({
    super.key,
    required this.category,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      child: ExpansionTile(
        leading: _getCategoryIcon(category),
        title: Text(
          _getCategoryDisplayName(category, l10n),
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          settings.enabled ? l10n.enabled : l10n.disabled,
          style: theme.textTheme.bodySmall?.copyWith(
            color:
                settings.enabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: settings.enabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(enabled: value));
          },
        ),
        children:
            settings.enabled
                ? [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 通知頻度
                        Text(
                          l10n.notificationFrequency,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<NotificationFrequency>(
                          initialValue: settings.frequency,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items:
                              NotificationFrequency.values.map((frequency) {
                                return DropdownMenuItem(
                                  value: frequency,
                                  child: Text(
                                    _getFrequencyDisplayName(frequency, l10n),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              onSettingsChanged(
                                settings.copyWith(frequency: value),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // 音・振動・バッジ設定
                        Text(
                          l10n.notificationOptions,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),

                        CheckboxListTile(
                          title: Text(l10n.sound),
                          subtitle: Text(l10n.soundDescription),
                          value: settings.sound,
                          onChanged: (value) {
                            if (value != null) {
                              onSettingsChanged(
                                settings.copyWith(sound: value),
                              );
                            }
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),

                        CheckboxListTile(
                          title: Text(l10n.vibration),
                          subtitle: Text(l10n.vibrationDescription),
                          value: settings.vibration,
                          onChanged: (value) {
                            if (value != null) {
                              onSettingsChanged(
                                settings.copyWith(vibration: value),
                              );
                            }
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),

                        CheckboxListTile(
                          title: Text(l10n.badge),
                          subtitle: Text(l10n.badgeDescription),
                          value: settings.badge,
                          onChanged: (value) {
                            if (value != null) {
                              onSettingsChanged(
                                settings.copyWith(badge: value),
                              );
                            }
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),

                        CheckboxListTile(
                          title: Text(l10n.lockScreen),
                          subtitle: Text(l10n.lockScreenDescription),
                          value: settings.lockScreen,
                          onChanged: (value) {
                            if (value != null) {
                              onSettingsChanged(
                                settings.copyWith(lockScreen: value),
                              );
                            }
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ]
                : [],
      ),
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

  String _getFrequencyDisplayName(
    NotificationFrequency frequency,
    AppLocalizations l10n,
  ) {
    switch (frequency) {
      case NotificationFrequency.immediate:
        return l10n.immediate;
      case NotificationFrequency.hourly:
        return l10n.hourly;
      case NotificationFrequency.threeHours:
        return l10n.threeHours;
      case NotificationFrequency.daily:
        return l10n.daily;
    }
  }
}
