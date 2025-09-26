import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/common/policy_documents.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _dataSync = false;
  bool _showHelpBanner = true;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const hasScheduledReminders = false;
    const hasBlockedUsers = false;

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
                  onChanged: (bool value) => setState(() => _dataSync = value),
                  activeColor: tokens.brandPrimary,
                ),
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
                onTap: () {},
              ),
              _SettingsTile(
                title: 'Delete Account & Data',
                titleColor: Colors.red.shade600,
                trailing: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade600,
                ),
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'About MinQ',
            tiles: <Widget>[
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
              const _SettingsTile(
                title: 'App Version',
                trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
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
