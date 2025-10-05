import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/notification_service.dart';
import 'package:minq/data/services/operations_metrics_service.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/notification/notification_sound_profile.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/data/services/tip_jar_service.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/controllers/integration_settings_controller.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/controllers/usage_limit_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _developerOptionsUnlocked = kDebugMode;
  int _versionTapCount = 0;
  DateTime? _lastVersionTap;
  bool _isExporting = false;

  void _handleVersionTap(BuildContext context) {
    final now = DateTime.now();
    if (_lastVersionTap == null ||
        now.difference(_lastVersionTap!) > const Duration(seconds: 2)) {
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

  String _formatDuration(Duration duration) {
    if (duration.inHours >= 1) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      if (minutes == 0) return '${hours}時間';
      return '${hours}時間${minutes}分';
    }
    return '${duration.inMinutes}分';
  }

  Future<void> _showUsageLimitSheet(
    BuildContext context,
    UsageLimitViewState state,
  ) async {
    final tokens = context.tokens;
    final options = <Duration?>[
      null,
      const Duration(minutes: 30),
      const Duration(hours: 1),
      const Duration(hours: 2),
      const Duration(hours: 3),
    ];

    final selected = state.dailyLimit;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing(4)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1日の利用時間を設定',
                  style: tokens.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tokens.textPrimary,
                  ),
                ),
                SizedBox(height: tokens.spacing(3)),
                ...options.map((option) {
                  final isSelected =
                      (option == null && selected == null) ||
                      (option != null && option == selected);
                  final label =
                      option == null ? '制限なし' : _formatDuration(option);
                  return RadioListTile<Duration?>(
                    value: option,
                    groupValue: selected,
                    title: Text(label),
                    onChanged: (value) async {
                      Navigator.of(context).pop();
                      await ref
                          .read(usageLimitControllerProvider.notifier)
                          .setDailyLimit(value);
                      if (mounted) {
                        final message =
                            value == null
                                ? '利用時間制限をオフにしました。'
                                : '1日の利用時間を${_formatDuration(value)}に設定しました。';
                        FeedbackMessenger.showSuccessToast(context, message);
                      }
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSoundProfileSheet(
    BuildContext context,
    NotificationSoundProfile current,
  ) async {
    final tokens = context.tokens;
    final profiles = ref.read(notificationSoundProfilesProvider);
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing(4)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '通知サウンドを選択',
                  style: tokens.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tokens.textPrimary,
                  ),
                ),
                SizedBox(height: tokens.spacing(3)),
                ...profiles.map((profile) {
                  final isSelected = profile.id == current.id;
                  return RadioListTile<String>(
                    value: profile.id,
                    groupValue: current.id,
                    title: Text(profile.label),
                    subtitle: Text(profile.description),
                    onChanged: (value) async {
                      Navigator.of(context).pop();
                      await ref
                          .read(notificationServiceProvider)
                          .updateReminderSoundProfile(value!);
                      if (mounted) {
                        FeedbackMessenger.showSuccessToast(
                          context,
                          '${profile.label}を通知音に設定しました。',
                        );
                        ref.invalidate(
                          selectedNotificationSoundProfileProvider,
                        );
                      }
                    },
                    selected: isSelected,
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showWebhookEditor(
    BuildContext context,
    List<Uri> endpoints,
  ) async {
    final tokens = context.tokens;
    final controller = TextEditingController(
      text: endpoints.map((uri) => uri.toString()).join('\n'),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (BuildContext context) => Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + tokens.spacing(4),
              left: tokens.spacing(4),
              right: tokens.spacing(4),
              top: tokens.spacing(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'カスタムWebhookエンドポイント',
                  style: tokens.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tokens.textPrimary,
                  ),
                ),
                SizedBox(height: tokens.spacing(2)),
                Text(
                  '1行につき1つのURLを入力してください。クエスト完了時にPOSTリクエストを送信します。',
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                ),
                SizedBox(height: tokens.spacing(3)),
                TextField(
                  controller: controller,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'https://example.com/webhook',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: tokens.spacing(3)),
                FilledButton(
                  onPressed: () async {
                    final lines =
                        controller.text
                            .split('\n')
                            .map((line) => line.trim())
                            .where((line) => line.isNotEmpty)
                            .toList();
                    await ref
                        .read(webhookDispatchServiceProvider)
                        .saveEndpoints(lines);
                    if (mounted) {
                      Navigator.of(context).pop();
                      FeedbackMessenger.showSuccessToast(
                        context,
                        'Webhookエンドポイントを更新しました。',
                      );
                      ref.invalidate(webhookEndpointsProvider);
                    }
                  },
                  child: const Text('保存する'),
                ),
              ],
            ),
          ),
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

    final uid = ref.read(uidProvider);
    if (uid == null || uid.isEmpty) {
      FeedbackMessenger.showErrorToast(context, 'サインインしてからエクスポートをご利用ください。');
      return;
    }

    setState(() => _isExporting = true);

    if (!mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ExportProgressDialog(),
    );

    var exportCompleted = false;
    String? failureMessage;

    try {
      final questRepository = ref.read(questRepositoryProvider);
      final logRepository = ref.read(questLogRepositoryProvider);
      final exportService = ref.read(dataExportServiceProvider);
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
      exportCompleted = true;
    } catch (error, stackTrace) {
      debugPrint('Data export failed: $error\n$stackTrace');
      failureMessage = 'データのエクスポートに失敗しました。時間をおいて再試行してください。';
    } finally {
      if (!mounted) return;
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
      }
      setState(() => _isExporting = false);
      if (!exportCompleted && failureMessage == null) {
        failureMessage = 'データのエクスポートに失敗しました。時間をおいて再試行してください。';
      }

      if (exportCompleted) {
        FeedbackMessenger.showSuccessToast(
          context,
          'データのエクスポートが完了しました。共有シートから保存または送信できます。',
        );
      } else if (failureMessage != null) {
        FeedbackMessenger.showErrorToast(context, failureMessage!);
      }
    }
  }

  Future<void> _showTipJar(BuildContext context) async {
    final service = ref.read(tipJarServiceProvider);
    if (service == null) {
      FeedbackMessenger.showInfoToast(context, '現在は投げ銭をご利用いただけません');
      return;
    }
    try {
      final options = await service.fetchTipOptions();
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        builder: (context) {
          final tokens = context.tokens;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MinQを応援する',
                    style: tokens.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  ...options.map(
                    (option) => ListTile(
                      title: Text(option.label),
                      subtitle: Text('¥${option.amount} の投げ銭'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () async {
                        final checkoutUrl = await service.createTipCheckout(
                          option.id,
                        );
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        final canLaunch = await canLaunchUrl(checkoutUrl);
                        if (canLaunch) {
                          await launchUrl(
                            checkoutUrl,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          FeedbackMessenger.showErrorToast(
                            context,
                            '購入ページを開けませんでした',
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (error) {
      if (!mounted) return;
      FeedbackMessenger.showErrorToast(context, '投げ銭プランの取得に失敗しました');
    }
  }

  Future<void> _openStripePortal(
    BuildContext context,
    String customerId,
  ) async {
    final service = ref.read(stripeBillingServiceProvider);
    if (service == null) {
      if (mounted) {
        FeedbackMessenger.showInfoToast(context, '現在は請求ポータルをご利用いただけません');
      }
      return;
    }
    try {
      final portalUrl = await service.createBillingPortalSession(
        customerId: customerId,
        returnUrl: Uri.parse('https://app.minq.example/settings'),
      );
      final launched = await launchUrl(
        portalUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        FeedbackMessenger.showErrorSnackBar(context, 'ブラウザでポータルを開けませんでした。');
      }
    } catch (error) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(context, '請求ポータルの起動に失敗しました。');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final opsSnapshot = ref.watch(operationsSnapshotProvider);
    final usageLimitState = ref.watch(usageLimitControllerProvider);
    final selectedSoundProfile = ref.watch(
      selectedNotificationSoundProfileProvider,
    );
    final webhookEndpoints = ref.watch(webhookEndpointsProvider);
    final stripeCustomerId = ref.watch(stripeCustomerIdProvider);
    final liveActivityToggle = ref.watch(liveActivityToggleProvider);
    final wearableSyncToggle = ref.watch(wearableSyncToggleProvider);
    final fitnessToggle = ref.watch(fitnessSyncToggleProvider);
    final menuBarToggle = ref.watch(menuBarTimerToggleProvider);
    final hasStripePortal = ref.watch(stripeBillingServiceProvider) != null;
    final hasTipJar = ref.watch(tipJarServiceProvider) != null;
    final navigation = ref.read(navigationUseCaseProvider);

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
                title: '利用時間制限',
                subtitle:
                    usageLimitState.isLoading
                        ? '読み込み中…'
                        : usageLimitState.dailyLimit == null
                        ? '制限なし'
                        : '今日 ${_formatDuration(usageLimitState.usedToday)} / ${_formatDuration(usageLimitState.dailyLimit!)}',
                onTap:
                    usageLimitState.isLoading
                        ? null
                        : () => _showUsageLimitSheet(context, usageLimitState),
              ),
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
                onTap: () => navigation.goToProfile(),
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
                onTap: () => context.push('/settings/delete-account'),
              ),
            ],
          ),
          _SettingsSection(
            title: '連携',
            tiles: [
              webhookEndpoints.when(
                data:
                    (endpoints) => _SettingsTile(
                      title: 'カスタムWebhook',
                      subtitle:
                          endpoints.isEmpty
                              ? '連携は未設定です'
                              : '${endpoints.length}件のエンドポイント',
                      onTap: () => _showWebhookEditor(context, endpoints),
                    ),
                loading:
                    () => const _SettingsTile(
                      title: 'カスタムWebhook',
                      subtitle: '読み込み中…',
                      isStatic: true,
                      staticValue: '',
                    ),
                error:
                    (_, __) => _SettingsTile(
                      title: 'カスタムWebhook',
                      subtitle: '読み込みに失敗しました。タップして再試行',
                      onTap: () => ref.invalidate(webhookEndpointsProvider),
                    ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'サブスクリプション',
            tiles: [
              stripeCustomerId.when(
                data:
                    (customerId) => _SettingsTile(
                      title: 'Stripe請求ポータル',
                      subtitle:
                          !hasStripePortal
                              ? '現在ご利用いただけません'
                              : customerId == null
                              ? '有効なサブスク情報がありません'
                              : '支払い方法や請求履歴を確認',
                      onTap:
                          !hasStripePortal || customerId == null
                              ? null
                              : () => _openStripePortal(context, customerId),
                    ),
                loading:
                    () => const _SettingsTile(
                      title: 'Stripe請求ポータル',
                      subtitle: '読み込み中…',
                      isStatic: true,
                      staticValue: '',
                    ),
                error:
                    (_, __) => _SettingsTile(
                      title: 'Stripe請求ポータル',
                      subtitle: '読み込みに失敗しました。タップして再試行',
                      onTap: () => ref.invalidate(stripeCustomerIdProvider),
                    ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'サポート',
            tiles: [
              _SettingsTile(
                title: 'GPT-4o サポートチャット',
                subtitle: '困ったことをAIサポートに質問',
                onTap: () => context.push(AppRoutes.support),
              ),
              _SettingsTile(
                title: '投げ銭で応援',
                subtitle: hasTipJar ? 'Sponsor Block広告の解除 & 開発支援' : '現在準備中です',
                onTap: hasTipJar ? () => _showTipJar(context) : null,
              ),
            ],
          ),
          _SettingsSection(
            title: '運用状況',
            tiles: [
              opsSnapshot.when<_SettingsTile>(
                data: (OperationsSnapshot snapshot) {
                  final double crashFreeRate = (snapshot.crashFreeRate * 100)
                      .clamp(0, 100);
                  final bool meetsTarget = snapshot.meetsCrashFreeTarget(0.995);
                  final String subtitle =
                      meetsTarget ? '目標達成中（99.5%以上）' : '目標を下回っています（99.5%未満）';
                  return _SettingsTile(
                    title: 'クラッシュフリー率',
                    subtitle: subtitle,
                    isStatic: true,
                    staticValue: '${crashFreeRate.toStringAsFixed(2)}%',
                    onTap: () => ref.invalidate(operationsSnapshotProvider),
                  );
                },
                loading:
                    () => const _SettingsTile(
                      title: 'クラッシュフリー率',
                      subtitle: '指標を計測中です…',
                      isStatic: true,
                      staticValue: '--',
                    ),
                error:
                    (error, _) => _SettingsTile(
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
                title: 'アプリを評価する',
                subtitle: 'App Storeでレビューを書く',
                onTap: () async {
                  final reviewService = ref.read(inAppReviewServiceProvider);
                  await reviewService.openStoreListing();
                },
              ),
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
              if (widget.showProgress)
                SizedBox(
                  width: tokens.spacing(6),
                  height: tokens.spacing(6),
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

class _ExportProgressDialog extends StatelessWidget {
  const _ExportProgressDialog();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Dialog(
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
            ),
            SizedBox(height: tokens.spacing(3)),
            Text(
              'エクスポート準備中…',
              style: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
