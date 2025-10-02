import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/notification_service.dart';
import 'package:minq/data/services/operations_metrics_service.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:minq/presentation/routing/app_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _developerOptionsUnlocked = kDebugMode;
  int _versionTapCount = 0;
  DateTime? _lastVersionTap;

  void _handleVersionTap(BuildContext context) {
    final now = DateTime.now();
    if (_lastVersionTap == null || now.difference(_lastVersionTap!) > const Duration(seconds: 2)) {
      _versionTapCount = 0;
    }
    _lastVersionTap = now;
    _versionTapCount++;

    if (_developerOptionsUnlocked) {
      FeedbackMessenger.showInfoToast(context, '開発者向けオプションは表示中です');
      return;
    }

    final tapsRemaining = 5 - _versionTapCount;
    if (tapsRemaining > 0) {
      FeedbackMessenger.showInfoToast(
        context,
        '開発者向けオプションまであと${tapsRemaining}回タップ',
      );
      return;
    }

    setState(() {
      _developerOptionsUnlocked = true;
    });
    FeedbackMessenger.showSuccessToast(context, '開発者向けオプションを有効化しました');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final opsSnapshot = ref.watch(operationsSnapshotProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: tokens.titleMedium.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Tooltip(
          message: l10n.back,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        backgroundColor: tokens.background.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing(4)),
        children: <Widget>[
          _SettingsSection(
            title: l10n.settingsSectionGeneral,
            tiles: [
              _SettingsTile(
                title: l10n.settingsPushNotifications,
                subtitle: l10n.settingsPushNotificationsSubtitle,
                isSwitch: true,
                switchValue:
                    true, // This should be driven by a provider in a real app
                onSwitchChanged: (value) async {
                  final notifier = ref.read(notificationServiceProvider);
                  if (value) {
                    await notifier.scheduleRecurringReminders(
                      NotificationService.defaultReminderTimes,
                    );
                    if (context.mounted) {
                      FeedbackMessenger.showSuccessToast(context, '通知を有効にしました');
                    }
                  } else {
                    await notifier.cancelAll();
                    if (context.mounted) {
                      FeedbackMessenger.showInfoToast(context, '通知を停止しました');
                    }
                  }
                },
              ),
              _SettingsTile(
                title: l10n.settingsNotificationTime,
                onTap: () => context.push('/settings/notifications'),
              ),
              _SettingsTile(
                title: l10n.settingsProfile,
                onTap: () => context.push(AppRoutes.profileSettings),
              ),
              _SettingsTile(title: l10n.settingsSound),
            ],
          ),
          _SettingsSection(
            title: l10n.settingsSectionPrivacy,
            tiles: [
              _SettingsTile(
                title: l10n.settingsDataSync,
                subtitle: l10n.settingsDataSyncSubtitle,
                isSwitch: true,
                switchValue: false,
              ),
              _SettingsTile(title: l10n.settingsManageBlockedUsers),
              _SettingsTile(title: l10n.settingsExportData, isDownload: true),
              _SettingsTile(
                title: l10n.settingsDeleteAccount,
                isDelete: true,
                onTap: () => context.push('/settings/delete-account'),
              ),
            ],
          ),
          _SettingsSection(
            title: '運用状況',
            tiles: [
              opsSnapshot.when<_SettingsTile>(
                data: (OperationsSnapshot snapshot) {
                  final double crashFreeRate =
                      (snapshot.crashFreeRate * 100).clamp(0, 100);
                  final bool meetsTarget = snapshot.meetsCrashFreeTarget(0.995);
                  final String subtitle = meetsTarget
                      ? '目標達成中（99.5%以上）'
                      : '目標を下回っています（99.5%未満）';
                  return _SettingsTile(
                    title: 'クラッシュフリー率',
                    subtitle: subtitle,
                    isStatic: true,
                    staticValue: '${crashFreeRate.toStringAsFixed(2)}%',
                    onTap: () => ref.invalidate(operationsSnapshotProvider),
                  );
                },
                loading: () => const _SettingsTile(
                  title: 'クラッシュフリー率',
                  subtitle: '指標を計測中です…',
                  isStatic: true,
                  staticValue: '--',
                ),
                error: (error, _) => _SettingsTile(
                  title: 'クラッシュフリー率',
                  subtitle: '指標の読み込みに失敗しました。タップして再試行してください。',
                  isStatic: true,
                  staticValue: '--',
                  onTap: () => ref.invalidate(operationsSnapshotProvider),
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: l10n.settingsSectionAbout,
            tiles: [
              _SettingsTile(
                title: l10n.settingsTermsOfService,
                onTap: () => context.push('/policy/terms'),
              ),
              _SettingsTile(
                title: l10n.settingsPrivacyPolicy,
                onTap: () => context.push('/policy/privacy'),
              ),
              _SettingsTile(
                title: l10n.settingsAppVersion,
                isStatic: true,
                staticValue: '1.0.0',
                onTap: () => _handleVersionTap(context),
              ),
            ],
          ),
          if (_developerOptionsUnlocked)
            _SettingsSection(
              title: l10n.settingsSectionDeveloper,
              tiles: [
                _SettingsTile(
                  title: l10n.settingsUseDummyData,
                  subtitle: l10n.settingsUseDummyDataSubtitle,
                  isSwitch: true,
                  switchValue: ref.watch(dummyDataModeProvider),
                  onSwitchChanged: (value) {
                    ref.read(dummyDataModeProvider.notifier).state = value;
                    ref
                        .read(localPreferencesServiceProvider)
                        .setDummyDataMode(value);
                    FeedbackMessenger.showInfoToast(
                      context,
                      value ? 'ダミーデータモードを有効にしました' : 'ダミーデータモードを無効にしました',
                    );
                  },
                ),
                _SettingsTile(
                  title: l10n.settingsSocialSharingDemo,
                  subtitle: l10n.settingsSocialSharingDemoSubtitle,
                  onTap: () => context.push('/social-sharing-demo'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.tiles});

  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: tokens.spacing(2),
              bottom: tokens.spacing(4),
            ),
            child: Text(
              title,
              style: tokens.titleLarge.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...tiles,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatefulWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.onTap,
    this.isSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.isDelete = false,
    this.isDownload = false,
    this.isStatic = false,
    this.staticValue,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final bool isDelete;
  final bool isDownload;
  final bool isStatic;
  final String? staticValue;

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  late bool _currentSwitchValue;

  @override
  void initState() {
    super.initState();
    _currentSwitchValue = widget.switchValue;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final titleColor =
        widget.isDelete ? Colors.red.shade500 : tokens.textPrimary;

    return Card(
      elevation: 0,
      shadowColor: tokens.background.withOpacity(0.1),
      color: tokens.surface,
      margin: EdgeInsets.symmetric(vertical: tokens.spacing(2)),
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing(4)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: tokens.bodyLarge.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Padding(
                        padding: EdgeInsets.only(top: tokens.spacing(1)),
                        child: Text(
                          widget.subtitle!,
                          style: tokens.bodySmall.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.isSwitch)
                Switch(
                  value: _currentSwitchValue,
                  onChanged: (value) {
                    setState(() => _currentSwitchValue = value);
                    widget.onSwitchChanged?.call(value);
                  },
                  thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                  trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return tokens.brandPrimary;
                    }
                    return tokens.border;
                  }),
                )
              else if (widget.isDelete)
                Icon(Icons.delete, color: titleColor)
              else if (widget.isDownload)
                Icon(Icons.download, color: tokens.textMuted)
              else if (widget.isStatic)
                Text(
                  widget.staticValue ?? '',
                  style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: tokens.textMuted,
                  size: tokens.spacing(4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
