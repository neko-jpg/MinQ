import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/notification_service.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/notification/notification_sound_profile.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/policy_documents.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;
  int _versionTapCount = 0;
  bool _developerOptionsUnlocked = false;

  @override
  void initState() {
    super.initState();
    _checkDeveloperMode();
  }

  Future<void> _checkDeveloperMode() async {
    final prefs = ref.read(localPreferencesServiceProvider);
    final unlocked = await prefs.isDummyDataModeEnabled();
    if (mounted) {
      setState(() {
        _developerOptionsUnlocked = unlocked;
      });
    }
  }

  void _handleVersionTap(BuildContext context) {
    if (_developerOptionsUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('開発者向けオプションは既に有効です')),
      );
      return;
    }

    setState(() {
      _versionTapCount++;
    });

    if (_versionTapCount >= 7) {
      _unlockDeveloperOptions(context);
    } else if (_versionTapCount >= 4) {
      final remaining = 7 - _versionTapCount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('あと$remaining回タップすると開発者向けオプションが有効になります')),
      );
    }
  }

  Future<void> _unlockDeveloperOptions(BuildContext context) async {
    final prefs = ref.read(localPreferencesServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    await prefs.setDummyDataMode(true);
    if (mounted) {
      setState(() {
        _developerOptionsUnlocked = true;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('おめでとうございます！開発者向けオプションが有効になりました。')),
      );
    }
  }

  Future<void> _showSoundProfileSheet(
    BuildContext context,
    NotificationSoundProfile current,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _SoundProfileSheet(currentProfile: current);
      },
    );
  }

  Map<String, dynamic> _questToExportMap(Quest quest) {
    return {
      'id': quest.id,
      'owner': quest.owner,
      'title': quest.title,
      'category': quest.category,
      'estimatedMinutes': quest.estimatedMinutes,
      'status': quest.status.name,
      'iconKey': quest.iconKey,
      'createdAt': quest.createdAt.toIso8601String(),
      'deletedAt': quest.deletedAt?.toIso8601String(),
      'completionCount': 0,
      'isActive': quest.status == QuestStatus.active,
    };
  }

  Map<String, dynamic> _logToExportMap(QuestLog log) {
    return {
      'id': log.id,
      'uid': log.uid,
      'questId': log.questId,
      'completedAt': log.ts.toIso8601String(),
      'proofType': log.proofType.name,
      'proofValue': log.proofValue,
      'note': log.proofValue ?? '',
      'synced': log.synced,
    };
  }

  Future<void> _exportData(BuildContext context) async {
    if (_isExporting) return;

    final exportService = ref.read(dataExportServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (exportService == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('エクスポート機能は現在ご利用いただけません。')),
      );
      return;
    }

    final uid = ref.read(uidProvider);
    if (uid == null || uid.isEmpty) {
      FeedbackMessenger.showErrorToast(context, 'サインインしてからエクスポートをご利用ください。');
      return;
    }

    setState(() => _isExporting = true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ExportProgressDialog(),
    );

    if (!mounted) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    String? failureMessage;

    try {
      final questRepository = ref.read(questRepositoryProvider);
      final logRepository = ref.read(questLogRepositoryProvider);
      final localUser = await ref.read(localUserProvider.future);

      final quests = await questRepository.getQuestsForOwner(uid);
      final logs = await logRepository.getLogsForUser(uid);
      final heatmap = await logRepository.getHeatmapData(uid);
      final currentStreak = await logRepository.calculateStreak(uid);
      final longestStreak = await logRepository.calculateLongestStreak(uid);
      final weeklyRate = await logRepository.calculateWeeklyCompletionRate(uid);

      final sortedHeatmapEntries =
          heatmap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      final heatmapPayload = <String, int>{
        for (final entry in sortedHeatmapEntries)
          entry.key.toIso8601String(): entry.value,
      };

      final stats = <String, dynamic>{
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'weeklyCompletionRate': weeklyRate,
        'totalLogs': logs.length,
        'generatedAt': DateTime.now().toIso8601String(),
        'heatmap': heatmapPayload,
      };

      final metadata = <String, dynamic>{
        'uid': uid,
        if (localUser != null) ...{
          'notificationTimes': localUser.notificationTimes,
          'privacy': localUser.privacy,
          'pairId': localUser.pairId,
        },
      };

      final exportFile = await exportService.exportDataZip(
        quests: quests.map(_questToExportMap).toList(),
        logs: logs.map(_logToExportMap).toList(),
        stats: stats,
        metadata: metadata,
      );

      await exportService.shareFile(exportFile);

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('データのエクスポートが完了しました。共有シートから保存または送信できます。'),
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Data export failed: $error\n$stackTrace');
      failureMessage = 'データのエクスポートに失敗しました。時間をおいて再試行してください。';
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage)),
        );
      }
    } finally {
      if (mounted) {
        if (navigator.canPop()) {
          navigator.pop();
        }
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final selectedSoundProfile = ref.watch(
      selectedNotificationSoundProfileProvider,
    );
    final navigation = ref.read(navigationUseCaseProvider);

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: tokens.typography.h4.copyWith(
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
        backgroundColor: tokens.surface.withAlpha(204),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing.md),
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
                  final messenger = ScaffoldMessenger.of(context);
                  if (value) {
                    await notifier.scheduleRecurringReminders(
                      NotificationService.defaultReminderTimes,
                    );
                    messenger.showSnackBar(
                      const SnackBar(content: Text('通知を有効にしました')),
                    );
                  } else {
                    await notifier.cancelAll();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('通知を停止しました')),
                    );
                  }
                },
              ),
              _SettingsTile(
                title: l10n.settingsNotificationTime,
                onTap: navigation.goToNotificationSettings,
              ),
              _SettingsTile(
                title: l10n.settingsProfile,
                onTap: () => navigation.goToProfile(),
              ),
              _SettingsTile(
                title: '友達招待',
                subtitle: '友達を招待してボーナスポイントをゲット',
                onTap: navigation.goToReferral,
              ),
              _SettingsTile(
                title: 'タイムカプセル',
                subtitle: '未来の自分へメッセージを送ろう',
                onTap: navigation.goToTimeCapsule,
              ),
              _SettingsTile(
                title: 'ムード追跡',
                subtitle: '気分を記録して習慣との関係を分析',
                onTap: navigation.goToMoodTracking,
              ),
              _SettingsTile(
                title: 'ストリーク保護',
                subtitle: 'ストリークの保護と回復機能',
                onTap:
                    () =>
                        navigation.goToStreakRecovery(1), // TODO: 適切なquestIdを渡す
              ),
              _SettingsTile(
                title: 'イベント',
                subtitle: '期間限定チャレンジと季節イベント',
                onTap: navigation.goToEvents,
              ),
              _SettingsTile(
                title: 'AIコーチ',
                subtitle: 'リアルタイムコーチング設定',
                onTap: navigation.goToAICoachSettings,
              ),
              _SettingsTile(
                title: 'ライブアクティビティ',
                subtitle: 'リアルタイム活動表示設定',
                onTap: navigation.goToLiveActivitySettings,
              ),
              _SettingsTile(
                title: 'ハビットストーリー',
                subtitle: 'AI自動生成ストーリー',
                onTap: navigation.goToHabitStory,
              ),
              _SettingsTile(
                title: 'ハビットバトル',
                subtitle: '習慣継続で対戦',
                onTap: navigation.goToBattle,
              ),
              _SettingsTile(
                title: 'パーソナリティ診断',
                subtitle: 'AI習慣DNA分析',
                onTap: navigation.goToPersonalityDiagnosis,
              ),
              _SettingsTile(
                title: '週次AI分析レポート',
                subtitle: '毎週の詳細分析と改善提案',
                onTap: navigation.goToWeeklyReport,
              ),
              _SettingsTile(
                title: 'ハビットコミュニティ',
                subtitle: 'ギルドで仲間と協力',
                onTap: navigation.goToGuild,
              ),
              selectedSoundProfile.when(
                data:
                    (profile) => _SettingsTile(
                      title: '通知サウンド',
                      subtitle: profile.label,
                      onTap: () => _showSoundProfileSheet(context, profile),
                    ),
                loading:
                    () => const _SettingsTile(
                      title: '通知サウンド',
                      subtitle: '読み込み中…',
                      isStatic: true,
                      staticValue: '',
                    ),
                error:
                    (_, __) => _SettingsTile(
                      title: '通知サウンド',
                      subtitle: '読み込みに失敗しました',
                      onTap:
                          () => ref.invalidate(
                            selectedNotificationSoundProfileProvider,
                          ),
                    ),
              ),
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
              _SettingsTile(
                title: l10n.settingsExportData,
                subtitle: _isExporting ? 'エクスポート中…' : 'Zipファイルでバックアップを共有できます',
                isDownload: true,
                onTap: _isExporting ? null : () => _exportData(context),
                showProgress: _isExporting,
              ),
              _SettingsTile(
                title: l10n.settingsDeleteAccount,
                isDelete: true,
                onTap: navigation.goToAccountDeletion,
              ),
            ],
          ),

          _SettingsSection(
            title: 'サポート',
            tiles: [
              _SettingsTile(
                title: 'ヘルプセンター',
                subtitle: 'よくある質問と使い方ガイド',
                onTap: navigation.goToHelpCenter,
              ),
              _SettingsTile(
                title: 'お問い合わせ',
                subtitle: 'バグ報告や機能要望はこちら',
                onTap: navigation.goToBugReport,
              ),
            ],
          ),
          _SettingsSection(
            title: l10n.settingsSectionAbout,
            tiles: [
              _SettingsTile(
                title: 'アプリを評価する',
                subtitle: 'App Storeでレビューを書く',
                onTap: () async {
                  final reviewService = ref.read(inAppReviewServiceProvider);
                  await reviewService.openStoreListing();
                },
              ),
              _SettingsTile(
                title: l10n.settingsTermsOfService,
                onTap: () => navigation.goToPolicy(PolicyDocumentId.terms),
              ),
              _SettingsTile(
                title: l10n.settingsPrivacyPolicy,
                onTap: () => navigation.goToPolicy(PolicyDocumentId.privacy),
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
                    final messenger = ScaffoldMessenger.of(context);
                    ref.read(dummyDataModeProvider.notifier).state = value;
                    ref
                        .read(localPreferencesServiceProvider)
                        .setDummyDataMode(value);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'ダミーデータモードを有効にしました' : 'ダミーデータモードを無効にしました',
                        ),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  title: l10n.settingsSocialSharingDemo,
                  subtitle: l10n.settingsSocialSharingDemoSubtitle,
                  onTap: navigation.goToSocialSharingDemo,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SoundProfileSheet extends ConsumerStatefulWidget {
  const _SoundProfileSheet({required this.currentProfile});

  final NotificationSoundProfile currentProfile;

  @override
  ConsumerState<_SoundProfileSheet> createState() => _SoundProfileSheetState();
}

class _SoundProfileSheetState extends ConsumerState<_SoundProfileSheet> {
  late String _selectedProfileId;

  @override
  void initState() {
    super.initState();
    _selectedProfileId = widget.currentProfile.id;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final profiles = ref.watch(notificationSoundProfilesProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '通知サウンドを選択',
              style: tokens.typography.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: tokens.textPrimary,
              ),
            ),
            SizedBox(height: tokens.spacing.md),
            RadioGroup<String>(
              groupValue: _selectedProfileId,
              onChanged: (String? value) async {
                if (value == null) return;
                setState(() {
                  _selectedProfileId = value;
                });
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await ref
                    .read(notificationServiceProvider)
                    .updateReminderSoundProfile(value);

                if (mounted) {
                  final selectedProfile =
                      profiles.firstWhere((p) => p.id == value);
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content:
                          Text('${selectedProfile.label}を通知音に設定しました。'),
                    ),
                  );
                  ref.invalidate(
                    selectedNotificationSoundProfileProvider,
                  );
                }
              },
              child: Column(
                children: profiles.map((profile) {
                  return RadioListTile<String>(
                    value: profile.id,
                    title: Text(profile.label),
                    subtitle: Text(profile.description),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
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
      padding: EdgeInsets.only(bottom: tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: tokens.spacing.sm,
              bottom: tokens.spacing.md,
            ),
            child: Text(
              title,
              style: tokens.typography.h4.copyWith(
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
    this.showProgress = false,
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
  final bool showProgress;

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
      shadowColor: tokens.surface.withAlpha(25),
      color: tokens.surface,
      margin: EdgeInsets.symmetric(vertical: tokens.spacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radius.xl)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: tokens.typography.body.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Padding(
                        padding: EdgeInsets.only(top: tokens.spacing.xs),
                        child: Text(
                          widget.subtitle!,
                          style: tokens.typography.caption.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.showProgress)
                SizedBox(
                  width: tokens.spacing.lg,
                  height: tokens.spacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      tokens.brandPrimary,
                    ),
                  ),
                )
              else if (widget.isSwitch)
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
                  style: tokens.typography.body.copyWith(color: tokens.textMuted),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: tokens.textMuted,
                  size: tokens.spacing.md,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportProgressDialog extends StatelessWidget {
  const _ExportProgressDialog();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Dialog(
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radius.lg)),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
            ),
            SizedBox(height: tokens.spacing.md),
            Text(
              'エクスポート準備中…',
              style: tokens.typography.body.copyWith(color: tokens.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
