import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/config/feature_flags.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/common/policy_documents.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _dataSync = false;
  bool _showHelpBanner = true;
  bool _deletionRequested = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      final prefs = ref.read(localPreferencesServiceProvider);
      final enabled = await prefs.isCloudBackupEnabled();
      if (!mounted) {
        return;
      }
      setState(() => _dataSync = enabled);
    });
  }

  Future<void> _showDataExportSheet(BuildContext context) async {
    final tokens = context.tokens;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerExtraLarge()),
      builder: (BuildContext sheetContext) {
        final sheetTokens = sheetContext.tokens;
        return Padding(
          padding: EdgeInsets.all(sheetTokens.spacing(5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'データエクスポート申請 / Data export request',
                style: sheetTokens.titleSmall
                    .copyWith(color: sheetTokens.textPrimary),
              ),
              SizedBox(height: sheetTokens.spacing(3)),
              Text(
                '設定から申請すると、24時間以内に登録メールアドレスへ暗号化されたダウンロードリンクを送信します。リンクは7日間有効で、パスコードはアプリ内通知で案内します。',
                style: sheetTokens.bodySmall
                    .copyWith(color: sheetTokens.textPrimary),
              ),
              SizedBox(height: sheetTokens.spacing(3)),
              Text(
                'Requesting an export delivers an encrypted download link to your email within 24 hours. The link remains valid for 7 days and the passcode arrives via in-app notification.',
                style: sheetTokens.bodySmall
                    .copyWith(color: sheetTokens.textMuted),
              ),
              SizedBox(height: sheetTokens.spacing(4)),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: sheetTokens.brandPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeletion(BuildContext context) async {
    final tokens = context.tokens;

    final bool confirmed = await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: tokens.surface,
          shape:
              RoundedRectangleBorder(borderRadius: tokens.cornerExtraLarge()),
          builder: (BuildContext sheetContext) {
            final sheetTokens = sheetContext.tokens;
            return Padding(
              padding: EdgeInsets.all(sheetTokens.spacing(5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'アカウント削除の最終確認',
                    style: sheetTokens.titleSmall
                        .copyWith(color: sheetTokens.textPrimary),
                  ),
                  SizedBox(height: sheetTokens.spacing(3)),
                  Text(
                    '削除を申請すると、全データは24時間以内にアクセス不能となり、30日以内に完全削除されます。進行中のクエストやペアは即時停止されます。',
                    style: sheetTokens.bodySmall
                        .copyWith(color: sheetTokens.textPrimary),
                  ),
                  SizedBox(height: sheetTokens.spacing(3)),
                  Text(
                    'Requesting deletion disables your account within 24 hours and permanently removes all personal data within 30 days. Active quests and pair connections will pause immediately.',
                    style: sheetTokens.bodySmall
                        .copyWith(color: sheetTokens.textMuted),
                  ),
                  SizedBox(height: sheetTokens.spacing(5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        child: const Text('キャンセル'),
                      ),
                      SizedBox(width: sheetTokens.spacing(2)),
                      FilledButton.tonal(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade700,
                        ),
                        child: const Text('削除を申請する'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ) ??
        false;

    if (!mounted || !confirmed) {
      return;
    }

    setState(() {
      _deletionRequested = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: tokens.brandPrimary,
        content: const Text(
          'Deletion request received. You can undo within 24 hours via the email link.',
        ),
      ),
    );
  }

  String _languageLabel(Locale? locale) {
    if (locale == null) {
      return 'System default (自動)';
    }
    switch (locale.languageCode) {
      case 'ja':
        return '日本語';
      case 'en':
        return 'English';
      default:
        return locale.toLanguageTag();
    }
  }

  Future<void> _showLanguageSheet(BuildContext context) async {
    final tokens = context.tokens;
    final current = ref.read(appLocaleControllerProvider);
    final controller = ref.read(appLocaleControllerProvider.notifier);

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerExtraLarge()),
      builder: (BuildContext sheetContext) {
        final sheetTokens = sheetContext.tokens;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('System default (自動)'),
              leading: Radio<String>(
                value: 'system',
                groupValue: current == null ? 'system' : current.languageCode,
                onChanged: (value) => Navigator.of(sheetContext).pop(value),
              ),
              onTap: () => Navigator.of(sheetContext).pop('system'),
            ),
            ListTile(
              title: const Text('日本語'),
              leading: Radio<String>(
                value: 'ja',
                groupValue: current?.languageCode,
                onChanged: (value) => Navigator.of(sheetContext).pop(value),
              ),
              onTap: () => Navigator.of(sheetContext).pop('ja'),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: current?.languageCode,
                onChanged: (value) => Navigator.of(sheetContext).pop(value),
              ),
              onTap: () => Navigator.of(sheetContext).pop('en'),
            ),
            SizedBox(height: sheetTokens.spacing(2)),
          ],
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    switch (selected) {
      case 'system':
        await controller.setLocale(null);
        break;
      case 'ja':
        await controller.setLocale(const Locale('ja'));
        break;
      case 'en':
        await controller.setLocale(const Locale('en'));
        break;
    }
  }

  Future<void> _onToggleBackup(BuildContext context, bool value) async {
    setState(() => _dataSync = value);
    await ref.read(localPreferencesServiceProvider).setCloudBackupEnabled(value);
    if (!mounted) {
      return;
    }
    if (value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cloud backup enabled. Google Sign-In will attach on next launch.'),
        ),
      );
    }
  }

  Future<void> _showBackupSheet(BuildContext context) async {
    final tokens = context.tokens;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerExtraLarge()),
      builder: (BuildContext sheetContext) {
        final sheetTokens = sheetContext.tokens;
        return Padding(
          padding: EdgeInsets.all(sheetTokens.spacing(5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '機種変更ガイド / Device transfer',
                style: sheetTokens.titleSmall
                    .copyWith(color: sheetTokens.textPrimary),
              ),
              SizedBox(height: sheetTokens.spacing(3)),
              Text(
                '1. Cloud backupを有効にしてGoogle連携すると、Isarログが暗号化バックアップされます。\n'
                '2. 新端末で同じGoogleアカウントにログインすると同期が自動で再開します。\n'
                '3. 万が一失敗した場合はデータエクスポート申請から手動で復元できます。',
                style: sheetTokens.bodySmall
                    .copyWith(color: sheetTokens.textPrimary),
              ),
              SizedBox(height: sheetTokens.spacing(3)),
              Text(
                'Enable cloud backup under Privacy & Data before switching devices. We encrypt the local Isar snapshot and rehydrate it during first launch.',
                style: sheetTokens.bodySmall
                    .copyWith(color: sheetTokens.textMuted),
              ),
              SizedBox(height: sheetTokens.spacing(4)),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('OK'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDonationSheet(BuildContext context, FeatureFlags flags) async {
    final tokens = context.tokens;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerExtraLarge()),
      builder: (BuildContext sheetContext) {
        final sheetTokens = sheetContext.tokens;
        return Padding(
          padding: EdgeInsets.all(sheetTokens.spacing(5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Support MinQ',
                style: sheetTokens.titleSmall
                    .copyWith(color: sheetTokens.textPrimary),
              ),
              SizedBox(height: sheetTokens.spacing(3)),
              Text(
                flags.donationExperimentVariant == 'subscription'
                    ? '月額プラン（¥300/月）で開発とサーバ費を支援できます。いつでも設定から解約できます。'
                    : 'コーヒー一杯分の寄付（¥500）でサーバ費とデザイナーへの謝礼を賄えます。匿名決済に対応しています。',
                style: sheetTokens.bodySmall
                    .copyWith(color: sheetTokens.textPrimary),
              ),
              SizedBox(height: sheetTokens.spacing(3)),
              Text(
                'Payments are processed via Stripe. A receipt will be emailed instantly and refunds are available within 7 days.',
                style: sheetTokens.bodySmall
                    .copyWith(color: sheetTokens.textMuted),
              ),
              SizedBox(height: sheetTokens.spacing(4)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Later'),
                  ),
                  SizedBox(width: sheetTokens.spacing(2)),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('We will send donation instructions via email shortly.'),
                        ),
                      );
                    },
                    child: Text(
                      flags.donationExperimentVariant == 'subscription'
                          ? 'Start free trial'
                          : 'Donate now',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAppIconSheet(BuildContext context, FeatureFlags flags) async {
    final tokens = context.tokens;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerExtraLarge()),
      builder: (BuildContext sheetContext) {
        final sheetTokens = sheetContext.tokens;
        final variant = flags.appIconVariant;
        return Padding(
          padding: EdgeInsets.all(sheetTokens.spacing(5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'App Icon Experiment',
                style: sheetTokens.titleSmall
                    .copyWith(color: sheetTokens.textPrimary),
              ),
              SizedBox(height: sheetTokens.spacing(3)),
              Text(
                variant == 'bold'
                    ? 'Bold variant emphasises electric blue background with centred M glyph for improved Play Store CTR.'
                    : 'Classic variant keeps the white background with subtle gradient halo for consistency with onboarding.',
                style: sheetTokens.bodySmall
                    .copyWith(color: sheetTokens.textPrimary),
              ),
              SizedBox(height: sheetTokens.spacing(3)),
              Text(
                'The chosen icon is applied during the next build pipeline run via Flutter launcher icons.',
                style: sheetTokens.bodySmall
                    .copyWith(color: sheetTokens.textMuted),
              ),
              SizedBox(height: sheetTokens.spacing(4)),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Understood'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _appIconColor(String variant, MinqTheme tokens) {
    switch (variant) {
      case 'bold':
        return tokens.brandPrimary;
      case 'night':
        return Colors.indigo.shade900;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const hasScheduledReminders = false;
    const hasBlockedUsers = false;
    final flags = ref.watch(featureFlagsProvider);
    final locale = ref.watch(appLocaleControllerProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing(5)),
        children: <Widget>[
          if (_showHelpBanner)
            Card(
              elevation: 0,
              margin: EdgeInsets.only(bottom: tokens.spacing(4)),
              color: tokens.brandPrimary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: tokens.cornerLarge()),
              child: ListTile(
                leading: Icon(Icons.info_outline, color: tokens.brandPrimary),
                title: Text(
                  '通知のタイミングやデータ連携など、アプリの挙動をカスタマイズできます。',
                  style: tokens.bodySmall
                      .copyWith(color: tokens.textPrimary),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: tokens.textPrimary),
                  onPressed: () => setState(() => _showHelpBanner = false),
                ),
              ),
            ),
          if (!hasScheduledReminders)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing(4)),
              child: MinqEmptyState(
                icon: Icons.notifications_off_outlined,
                title: '通知時間が未設定です',
                message: '朝・夜など、自分がチェックしやすいタイミングを登録すると、ミスせず続けられます。',
                actionLabel: '通知時間を設定',
                onAction: () {},
              ),
            ),
          _SettingsSection(
            title: 'Language & Region',
            tiles: <Widget>[
              _SettingsTile(
                title: 'App Language',
                subtitle: _languageLabel(locale),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: tokens.spacing(4),
                  color: tokens.textMuted,
                ),
                onTap: () => _showLanguageSheet(context),
              ),
            ],
          ),
          _SettingsSection(
            title: 'General Settings',
            tiles: <Widget>[
              _SettingsTile(
                title: 'Push Notifications',
                subtitle: 'Reminders & partner updates',
                trailing: Switch(
                  value: _pushNotifications,
                  onChanged:
                      (bool value) =>
                          setState(() => _pushNotifications = value),
                  activeColor: tokens.brandPrimary,
                ),
              ),
              _SettingsTile(
                title: 'Notification Times',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: tokens.spacing(4),
                  color: tokens.textMuted,
                ),
                onTap: () {},
              ),
              _SettingsTile(
                title: 'Sounds',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: tokens.spacing(4),
                  color: tokens.textMuted,
                ),
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'Privacy & Data',
            tiles: <Widget>[
              if (!hasBlockedUsers)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing(2),
                    vertical: tokens.spacing(2),
                  ),
                  child: MinqEmptyState(
                    icon: Icons.shield_outlined,
                    title: 'ブロック中のユーザーはありません',
                    message: '困ったときは各Pair画面のメニューから通報・ブロックできます。',
                  ),
                ),
              _SettingsTile(
                title: 'Data Sync',
                subtitle: 'Keep data synced across devices',
                trailing: Switch(
                  value: _dataSync,
                  onChanged: (bool value) => _onToggleBackup(context, value),
                  activeColor: tokens.brandPrimary,
                ),
              ),
              _SettingsTile(
                title: 'Device Transfer Guide',
                subtitle: 'Step-by-step backup & restore',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: tokens.spacing(4),
                  color: tokens.textMuted,
                ),
                onTap: () => _showBackupSheet(context),
              ),
              _SettingsTile(
                title: 'Manage Blocked Users',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: tokens.spacing(4),
                  color: tokens.textMuted,
                ),
                onTap: () {},
              ),
              _SettingsTile(
                title: 'Export My Data',
                trailing: Icon(
                  Icons.download_outlined,
                  color: tokens.textMuted,
                ),
                onTap: () => _showDataExportSheet(context),
              ),
              if (_deletionRequested)
                Card(
                  elevation: 0,
                  margin: EdgeInsets.symmetric(
                    horizontal: tokens.spacing(1),
                    vertical: tokens.spacing(1),
                  ),
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: Icon(
                      Icons.verified_user_outlined,
                      color: Colors.red.shade400,
                    ),
                    title: Text(
                      'Deletion scheduled',
                      style: tokens.bodyMedium.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Your account will be disabled within 24 hours. Cancel anytime via the confirmation email.',
                      style: tokens.bodySmall
                          .copyWith(color: Colors.red.shade400),
                    ),
                  ),
                )
              else
                _SettingsTile(
                  title: 'Delete Account & Data',
                  titleColor: Colors.red.shade600,
                  trailing: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade600,
                  ),
                  onTap: () => _confirmDeletion(context),
                ),
            ],
          ),
          _SettingsSection(
            title: 'About MinQ',
            tiles: <Widget>[
              _SettingsTile(
                title: 'Support & FAQ',
                subtitle: 'Contact options and troubleshooting',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: tokens.spacing(4),
                  color: tokens.textMuted,
                ),
                onTap: () => context.go('/support'),
              ),
              _SettingsTile(
                title: 'Terms & Community',
                subtitle: '13+ policy and respectful conduct',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: tokens.spacing(4),
                  color: tokens.textMuted,
                ),
                onTap: () => context.go('/policy/${PolicyDocumentId.terms.name}'),
              ),
              _SettingsTile(
                title: 'Privacy Policy',
                subtitle: 'Data handling & export guidance',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: tokens.spacing(4),
                  color: tokens.textMuted,
                ),
                onTap: () => context.go('/policy/${PolicyDocumentId.privacy.name}'),
              ),
              _SettingsTile(
                title: 'Safety & Reporting SOP',
                subtitle: '24h initial response commitment',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: tokens.spacing(4),
                  color: tokens.textMuted,
                ),
                onTap: () => context.go('/policy/${PolicyDocumentId.community.name}'),
              ),
              _SettingsTile(
                title: 'Content Rights & Licenses',
                subtitle: 'Fonts, illustrations, and OSS credits',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: tokens.spacing(4),
                  color: tokens.textMuted,
                ),
                onTap: () => context.go('/policy/${PolicyDocumentId.licenses.name}'),
              ),
              const _SettingsTile(
                title: 'App Version',
                trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Growth Experiments',
            tiles: <Widget>[
              _ExperimentTile(
                title: 'Support MinQ',
                description: flags.donationExperimentVariant == 'subscription'
                    ? '試験的にサブスクリプションUIを表示しています。1ヶ月無料体験つき。'
                    : '寄付ボタンを一部ユーザーに表示中です。プロダクト改善に使われます。',
                actionLabel: flags.donationExperimentVariant == 'control'
                    ? 'No experiment active'
                    : (flags.donationExperimentVariant == 'subscription'
                        ? 'View subscription options'
                        : 'Open donation sheet'),
                onAction: flags.donationExperimentVariant == 'control'
                    ? null
                    : () => _showDonationSheet(context, flags),
              ),
              _AppIconPreviewTile(
                variant: flags.appIconVariant,
                color: _appIconColor(flags.appIconVariant, tokens),
                onTap: () => _showAppIconSheet(context, flags),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: tokens.spacing(2),
            top: tokens.spacing(6),
            bottom: tokens.spacing(2),
          ),
          child: Text(
            title,
            style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
          ),
        ),
        Column(children: tiles),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: tokens.spacing(1.5)),
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
        title: Text(
          title,
          style: tokens.bodyMedium.copyWith(
            color: titleColor ?? tokens.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle!,
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                )
                : null,
        trailing: trailing,
      ),
    );
  }
}

class _ExperimentTile extends StatelessWidget {
  const _ExperimentTile({
    required this.title,
    required this.description,
    required this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final enabled = onAction != null;

    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: tokens.spacing(1.5)),
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: tokens.bodyMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              description,
              style: tokens.bodySmall.copyWith(color: tokens.textMuted),
            ),
            SizedBox(height: tokens.spacing(3)),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: enabled ? onAction : null,
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppIconPreviewTile extends StatelessWidget {
  const _AppIconPreviewTile({
    required this.variant,
    required this.color,
    required this.onTap,
  });

  final String variant;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final foreground = variant == 'bold' || variant == 'night'
        ? Colors.white
        : tokens.brandPrimary;

    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: tokens.spacing(1.5)),
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.all(tokens.spacing(4)),
        leading: Container(
          width: tokens.spacing(12),
          height: tokens.spacing(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(tokens.spacing(3)),
            border: Border.all(color: tokens.brandPrimary.withValues(alpha: 0.2)),
          ),
          alignment: Alignment.center,
          child: Text(
            'M',
            style: tokens.titleLarge.copyWith(color: foreground),
          ),
        ),
        title: Text(
          'App Icon Variant',
          style: tokens.bodyMedium.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          switch (variant) {
            'bold' => 'Bold electric blue icon running in cohort B.',
            'night' => 'Midnight gradient variant for dark-mode appeal.',
            _ => 'Classic white backdrop icon served to control cohort.',
          },
          style: tokens.bodySmall.copyWith(color: tokens.textMuted),
        ),
        trailing: Icon(
          Icons.open_in_new,
          color: tokens.textMuted,
        ),
      ),
    );
  }
}
