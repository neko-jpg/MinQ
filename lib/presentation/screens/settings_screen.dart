import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/notification_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Settings', style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        backgroundColor: tokens.background.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing(4)),
        children: <Widget>[
          _SettingsSection(
            title: 'General Settings',
            tiles: [
              _SettingsTile(
                title: 'Push Notifications',
                subtitle: 'Reminders & partner updates',
                isSwitch: true,
                switchValue: true, // This should be driven by a provider in a real app
                onSwitchChanged: (value) async {
                  final notifier = ref.read(notificationServiceProvider);
                  if (value) {
                    await notifier.scheduleRecurringReminders(NotificationService.defaultReminderTimes);
                  } else {
                    await notifier.cancelAll();
                  }
                },
              ),
              _SettingsTile(title: 'Notification Times', onTap: () => context.push('/settings/notifications')),
              const _SettingsTile(title: 'Sounds'),
            ],
          ),
          const _SettingsSection(
            title: 'Privacy & Data',
            tiles: [
              _SettingsTile(title: 'Data Sync', subtitle: 'Keep data synced across devices', isSwitch: true, switchValue: false),
              _SettingsTile(title: 'Manage Blocked Users'),
              _SettingsTile(title: 'Export My Data', isDownload: true),
              _SettingsTile(title: 'Delete Account & Data', isDelete: true),
            ],
          ),
          _SettingsSection(
            title: 'About MinQ',
            tiles: [
              _SettingsTile(title: 'Terms of Service', onTap: () => context.push('/policy/terms')),
              _SettingsTile(title: 'Privacy Policy', onTap: () => context.push('/policy/privacy')),
              const _SettingsTile(title: 'App Version', isStatic: true, staticValue: '1.0.0'),
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
            padding: EdgeInsets.only(left: tokens.spacing(2), bottom: tokens.spacing(4)),
            child: Text(title, style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
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
    final titleColor = widget.isDelete ? Colors.red.shade500 : tokens.textPrimary;

    return Card(
      elevation: 1,
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
                    Text(widget.title, style: tokens.bodyLarge.copyWith(color: titleColor, fontWeight: FontWeight.w600)),
                    if (widget.subtitle != null)
                      Padding(
                        padding: EdgeInsets.only(top: tokens.spacing(1)),
                        child: Text(widget.subtitle!, style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
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
                  activeColor: Colors.white,
                  activeTrackColor: tokens.brandPrimary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: tokens.border,
                )
              else if (widget.isDelete)
                Icon(Icons.delete, color: titleColor)
              else if (widget.isDownload)
                Icon(Icons.download, color: tokens.textMuted)
              else if (widget.isStatic)
                Text(widget.staticValue ?? '', style: tokens.bodyMedium.copyWith(color: tokens.textMuted))
              else
                Icon(Icons.arrow_forward_ios, color: tokens.textMuted, size: tokens.spacing(4)),
            ],
          ),
        ),
      ),
    );
  }
}