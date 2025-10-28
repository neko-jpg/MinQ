import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/notification/notification_sound_profile.dart';
import 'package:minq/presentation/common/layout/responsive_layout.dart';
import 'package:minq/presentation/common/layout/safe_scaffold.dart';
import 'package:minq/presentation/common/policy_documents.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    // final prefs = ref.read(localPreferencesServiceProvider);
    // TODO: Load actual theme preference from storage
    setState(() {
      _isDarkMode = false; // Default to light mode for now
    });
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
    // TODO: Implement theme switching logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isDark ? 'ダークモードに切り替えました' : 'ライトモードに切り替えました'),
      ),
    );
  }

  void _showAdvancedSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AdvancedSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigation = ref.read(navigationUseCaseProvider);

    return SafeScaffold(
      backgroundColor: MinqTokens.background,
      appBar: AppBar(
        title: Text(
          '設定',
          style: MinqTokens.titleMedium.copyWith(
            color: MinqTokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Tooltip(
          message: '戻る',
          child: ResponsiveLayout.ensureTouchTarget(
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        actions: [
          ResponsiveLayout.ensureTouchTarget(
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'その他の設定',
              onPressed: () => _showAdvancedSettings(context),
            ),
          ),
        ],
        backgroundColor: Color.lerp(MinqTokens.surface, Colors.transparent, 0.2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeScrollView(
        enableResponsiveLayout: true,
        maxContentWidth: ResponsiveLayout.maxContentWidth,
        children: <Widget>[
          // Essential Settings - Reduced from 20+ to 8 core options
          _SettingsSection(
            title: '基本設定',
            tiles: [
              // 1. Profile Management (consolidated from multiple profile options)
              _EssentialSettingsTile(
                title: 'プロフィール管理',
                subtitle: 'ニックネーム、アバター、目標設定',
                icon: Icons.person_outline,
                onTap: () => navigation.goToProfileManagement(),
              ),

              // 2. Theme Toggle (prominent placement as requested)
              _EssentialSettingsTile(
                title: 'テーマ',
                subtitle: _isDarkMode ? 'ダークモード' : 'ライトモード',
                icon: _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                isSwitch: true,
                switchValue: _isDarkMode,
                onSwitchChanged: _toggleTheme,
              ),

              // 3. Notifications (consolidated notification settings)
              _EssentialSettingsTile(
                title: '通知設定',
                subtitle: '通知のオン・オフと時刻設定',
                icon: Icons.notifications_outlined,
                onTap: navigation.goToNotificationSettings,
              ),

              // 4. AI Coach Settings (consolidated AI options)
              _EssentialSettingsTile(
                title: 'AIコーチ設定',
                subtitle: 'コーチの性格と頻度を調整',
                icon: Icons.psychology_outlined,
                onTap: () {
                  // TODO: Navigate to consolidated AI coach settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AIコーチ設定は準備中です')),
                  );
                },
              ),
            ],
          ),

          // Support & Info - Reduced to essential support options
          _SettingsSection(
            title: 'サポート',
            tiles: [
              // 5. Help Center
              _EssentialSettingsTile(
                title: 'ヘルプセンター',
                subtitle: 'よくある質問と使い方ガイド',
                icon: Icons.help_outline,
                onTap: navigation.goToHelpCenter,
              ),

              // 6. Contact Support
              _EssentialSettingsTile(
                title: 'お問い合わせ',
                subtitle: 'バグ報告や機能要望',
                icon: Icons.feedback_outlined,
                onTap: navigation.goToBugReport,
              ),

              // 7. Rate App
              _EssentialSettingsTile(
                title: 'アプリを評価する',
                subtitle: 'App Storeでレビューを書く',
                icon: Icons.star_outline,
                onTap: () async {
                  final reviewService = ref.read(inAppReviewServiceProvider);
                  await reviewService.openStoreListing();
                },
              ),

              // 8. Privacy Policy (essential legal requirement)
              _EssentialSettingsTile(
                title: 'プライバシーポリシー',
                subtitle: 'データの取り扱いについて',
                icon: Icons.privacy_tip_outlined,
                onTap: () => navigation.goToPolicy(PolicyDocumentId.privacy),
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

  Future<void> _onProfileSelected(
    BuildContext context,
    List<NotificationSoundProfile> profiles,
    String value,
  ) async {
    setState(() {
      _selectedProfileId = value;
    });

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await ref
        .read(notificationServiceProvider)
        .updateReminderSoundProfile(value);

    if (!mounted) return;

    final selectedProfile = profiles.firstWhere((p) => p.id == value);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${selectedProfile.label}を通知音に設定しました。'),
      ),
    );
    ref.invalidate(selectedNotificationSoundProfileProvider);
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(notificationSoundProfilesProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(MinqTokens.spacing(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '通知サウンドを選択',
              style: MinqTokens.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: MinqTokens.textPrimary,
              ),
            ),
            SizedBox(height: MinqTokens.spacing(4)),
            RadioGroup<String>(
              groupValue: _selectedProfileId,
              onChanged: (value) async {
                if (value == null) return;
                await _onProfileSelected(context, profiles, value);
              },
              child: Column(
                children: profiles.map((profile) {
                  return ListTile(
                    title: Text(
                      profile.label,
                      style: MinqTokens.titleMedium.copyWith(
                        color: MinqTokens.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      profile.description,
                      style: MinqTokens.bodyMedium.copyWith(
                        color: MinqTokens.textSecondary,
                      ),
                    ),
                    leading: Radio<String>(
                      value: profile.id,
                    ),
                    onTap: () async {
                      await _onProfileSelected(context, profiles, profile.id);
                    },
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
    return Padding(
      padding: EdgeInsets.only(bottom: MinqTokens.spacing(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: MinqTokens.spacing(2),
              bottom: MinqTokens.spacing(4),
            ),
            child: Text(
              title,
              style: MinqTokens.titleLarge.copyWith(
                color: MinqTokens.textPrimary,
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

/// Essential settings tile with 44pt minimum touch targets and improved accessibility
class _EssentialSettingsTile extends StatefulWidget {
  const _EssentialSettingsTile({
    required this.title,
    this.subtitle,
    this.onTap,
    this.isSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final IconData? icon;

  @override
  State<_EssentialSettingsTile> createState() => _EssentialSettingsTileState();
}

class _EssentialSettingsTileState extends State<_EssentialSettingsTile> {
  late bool _currentSwitchValue;

  @override
  void initState() {
    super.initState();
    _currentSwitchValue = widget.switchValue;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: !widget.isSwitch,
      label: widget.title,
      hint: widget.subtitle,
      child: Card(
        elevation: 0,
        shadowColor: Colors.black.withAlpha(25),
        color: MinqTokens.surface,
        margin: EdgeInsets.symmetric(vertical: MinqTokens.spacing(2)),
        shape: RoundedRectangleBorder(
          borderRadius: MinqTokens.cornerMedium(),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.isSwitch ? null : widget.onTap,
          borderRadius: MinqTokens.cornerMedium(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 44, // Ensure 44pt minimum
            ),
            child: Padding(
              padding:
                  EdgeInsets.all(MinqTokens.spacing(4)), // Increased padding
              child: Row(
                children: [
                  // Icon container with proper sizing
                  if (widget.icon != null) ...[
                    Container(
                      width: 48, // Larger icon container
                      height: 48,
                      decoration: BoxDecoration(
                        color: MinqTokens.brandPrimary.withAlpha(25),
                        borderRadius: MinqTokens.cornerSmall(),
                      ),
                      child: Icon(
                        widget.icon,
                        color: MinqTokens.brandPrimary,
                        size: 24, // Larger icon size
                      ),
                    ),
                    SizedBox(width: MinqTokens.spacing(4)),
                  ],

                  // Content area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: MinqTokens.titleMedium.copyWith(
                            color: MinqTokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          SizedBox(height: MinqTokens.spacing(1)),
                          Text(
                            widget.subtitle!,
                            style: MinqTokens.bodyMedium.copyWith(
                              color: MinqTokens.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action area (switch or arrow)
                  if (widget.isSwitch)
                    Semantics(
                      label: '${widget.title}の切り替え',
                      child: Switch(
                        value: _currentSwitchValue,
                        onChanged: (value) {
                          setState(() => _currentSwitchValue = value);
                          widget.onSwitchChanged?.call(value);
                        },
                        thumbColor: const WidgetStatePropertyAll<Color>(
                          Colors.white,
                        ),
                        trackColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return MinqTokens.brandPrimary;
                          }
                          return Colors.grey.shade300;
                        }),
                      ),
                    )
                  else
                    const Icon(
                      Icons.chevron_right,
                      color: MinqTokens.textSecondary,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Keep the old _SettingsTile for backward compatibility in advanced settings
class _SettingsTile extends StatefulWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDelete = false,
    this.isStatic = false,
    this.staticValue,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDelete;
  final bool isStatic;
  final String? staticValue;
  final IconData? icon;

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  @override
  Widget build(BuildContext context) {
    final titleColor =
        widget.isDelete ? Colors.red : MinqTokens.textPrimary;

    return Card(
      elevation: 0,
      shadowColor: Colors.black.withAlpha(25),
      color: MinqTokens.surface,
      margin: EdgeInsets.symmetric(vertical: MinqTokens.spacing(2)),
      shape: RoundedRectangleBorder(
        borderRadius: MinqTokens.cornerMedium(),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 44,
          ),
          child: Padding(
            padding: EdgeInsets.all(MinqTokens.spacing(3)),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: MinqTokens.brandPrimary.withAlpha(25),
                      borderRadius: MinqTokens.cornerSmall(),
                    ),
                    child: Icon(
                      widget.icon,
                      color: MinqTokens.brandPrimary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: MinqTokens.spacing(3)),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: MinqTokens.bodyMedium.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.subtitle != null)
                        Padding(
                          padding: EdgeInsets.only(top: MinqTokens.spacing(1)),
                          child: Text(
                            widget.subtitle!,
                            style: MinqTokens.bodySmall.copyWith(
                              color: MinqTokens.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.isDelete)
                  Icon(Icons.delete, color: titleColor)
                else if (widget.isStatic)
                  Text(
                    widget.staticValue ?? '',
                    style: MinqTokens.bodyMedium.copyWith(
                      color: MinqTokens.textSecondary,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: MinqTokens.textSecondary,
                    size: MinqTokens.spacing(4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdvancedSettingsSheet extends ConsumerWidget {
  const _AdvancedSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigation = ref.read(navigationUseCaseProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.8,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: MinqTokens.surface,
            borderRadius: BorderRadius.vertical(
              top: MinqTokens.cornerLarge().topLeft,
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: MinqTokens.spacing(3)),
                decoration: BoxDecoration(
                  color: MinqTokens.textSecondary.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MinqTokens.spacing(3)),
                child: Row(
                  children: [
                    Text(
                      'その他の設定',
                      style: MinqTokens.titleMedium.copyWith(
                        color: MinqTokens.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ResponsiveLayout.ensureTouchTarget(
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              // Content - Reduced advanced options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(MinqTokens.spacing(3)),
                  children: [
                    // Advanced Features (previously hidden)
                    _SettingsSection(
                      title: '高度な機能',
                      tiles: [
                        _SettingsTile(
                          title: 'ギルド',
                          subtitle: 'コミュニティで習慣を継続',
                          icon: Icons.groups_outlined,
                          onTap: navigation.goToGuild,
                        ),
                        _SettingsTile(
                          title: 'ハビットバトル',
                          subtitle: '他のユーザーと習慣で対戦',
                          icon: Icons.sports_esports_outlined,
                          onTap: navigation.goToBattle,
                        ),
                        _SettingsTile(
                          title: 'ムード追跡',
                          subtitle: '気分と習慣の関係を分析',
                          icon: Icons.mood_outlined,
                          onTap: navigation.goToMoodTracking,
                        ),
                        _SettingsTile(
                          title: 'パーソナリティ診断',
                          subtitle: 'AIがあなたの習慣タイプを分析',
                          icon: Icons.psychology_outlined,
                          onTap: navigation.goToPersonalityDiagnosis,
                        ),
                        _SettingsTile(
                          title: '週次レポート',
                          subtitle: 'AIが生成する詳細な分析レポート',
                          icon: Icons.analytics_outlined,
                          onTap: navigation.goToWeeklyReport,
                        ),
                      ],
                    ),

                    // Premium Features (consolidated)
                    _SettingsSection(
                      title: 'プレミアム機能',
                      tiles: [
                        _SettingsTile(
                          title: '友達招待',
                          subtitle: '友達を招待してボーナスポイント',
                          icon: Icons.person_add_outlined,
                          onTap: navigation.goToReferral,
                        ),
                        _SettingsTile(
                          title: 'ストリーク回復',
                          subtitle: '習慣の継続記録を回復',
                          icon: Icons.restore_outlined,
                          onTap: () {
                            // Show streak recovery for a sample quest
                            navigation.goToStreakRecovery(1);
                          },
                        ),
                      ],
                    ),

                    // Advanced Settings (developer/power user options)
                    _SettingsSection(
                      title: '詳細設定',
                      tiles: [
                        _SettingsTile(
                          title: 'データエクスポート',
                          subtitle: 'バックアップファイルをダウンロード',
                          icon: Icons.download_outlined,
                          onTap: () {
                            // TODO: Implement data export
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('データエクスポート機能は準備中です')),
                            );
                          },
                        ),
                        _SettingsTile(
                          title: '利用規約',
                          subtitle: 'サービス利用規約を確認',
                          icon: Icons.description_outlined,
                          onTap: () =>
                              navigation.goToPolicy(PolicyDocumentId.terms),
                        ),
                        const _SettingsTile(
                          title: 'アプリバージョン',
                          subtitle: 'バージョン 1.0.0',
                          icon: Icons.info_outline,
                          isStatic: true,
                          staticValue: '',
                        ),
                        _SettingsTile(
                          title: 'アカウント削除',
                          subtitle: 'すべてのデータを完全に削除',
                          icon: Icons.delete_forever_outlined,
                          isDelete: true,
                          onTap: navigation.goToAccountDeletion,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
