import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 30);

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime, ValueChanged<TimeOfDay> onTimeChanged) async {
    final newTime = await showTimePicker(context: context, initialTime: initialTime);
    if (newTime != null) {
      setState(() => onTimeChanged(newTime));
    }
  }

  Future<void> _saveSettings() async {
    final times = [
      '${_morningTime.hour.toString().padLeft(2, '0')}:${_morningTime.minute.toString().padLeft(2, '0')}',
      '${_eveningTime.hour.toString().padLeft(2, '0')}:${_eveningTime.minute.toString().padLeft(2, '0')}',
    ];
    await ref.read(notificationServiceProvider).scheduleRecurringReminders(times);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('通知時間を保存しました！')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(
        title: Text('通知時間', style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing(4)),
        children: [
          _TimePickerTile(
            tokens: tokens,
            label: '朝のリマインダー',
            time: _morningTime,
            onTap: () => _selectTime(context, _morningTime, (time) => _morningTime = time),
          ),
          SizedBox(height: tokens.spacing(4)),
          _TimePickerTile(
            tokens: tokens,
            label: '夜のリマインダー',
            time: _eveningTime,
            onTap: () => _selectTime(context, _eveningTime, (time) => _eveningTime = time),
          ),
          SizedBox(height: tokens.spacing(8)),
          MinqPrimaryButton(label: '保存', onPressed: _saveSettings),
        ],
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({
    required this.tokens,
    required this.label,
    required this.time,
    required this.onTap,
  });

  final MinqTheme tokens;
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
      shadowColor: tokens.background.withOpacity(0.1),
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        title: Text(label, style: tokens.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        trailing: Text(
          time.format(context),
          style: tokens.titleMedium.copyWith(color: tokens.brandPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
