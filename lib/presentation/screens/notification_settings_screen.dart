import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/dialogs/discard_changes_dialog.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 30);
  final Set<int> _enabledWeekdays = {1, 2, 3, 4, 5}; // 平日デフォルト
  bool _notifyOnHolidays = false;
  late TimeOfDay _initialMorningTime;
  late TimeOfDay _initialEveningTime;
  late Set<int> _initialEnabledWeekdays;
  late bool _initialNotifyOnHolidays;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initialMorningTime = _morningTime;
    _initialEveningTime = _eveningTime;
    _initialEnabledWeekdays = Set<int>.from(_enabledWeekdays);
    _initialNotifyOnHolidays = _notifyOnHolidays;
  }

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay initialTime,
    ValueChanged<TimeOfDay> onTimeChanged,
  ) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (newTime != null) {
      setState(() => onTimeChanged(newTime));
      _updateUnsavedState();
    }
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_enabledWeekdays.contains(weekday)) {
        _enabledWeekdays.remove(weekday);
      } else {
        _enabledWeekdays.add(weekday);
      }
    });
    _updateUnsavedState();
  }

  Future<void> _saveSettings() async {
    final times = [
      '${_morningTime.hour.toString().padLeft(2, '0')}:${_morningTime.minute.toString().padLeft(2, '0')}',
      '${_eveningTime.hour.toString().padLeft(2, '0')}:${_eveningTime.minute.toString().padLeft(2, '0')}',
    ];
    await ref
        .read(notificationServiceProvider)
        .scheduleRecurringReminders(times);
    if (mounted) {
      setState(() {
        _initialMorningTime = _morningTime;
        _initialEveningTime = _eveningTime;
        _initialEnabledWeekdays = Set<int>.from(_enabledWeekdays);
        _initialNotifyOnHolidays = _notifyOnHolidays;
        _hasUnsavedChanges = false;
      });
      FeedbackMessenger.showSuccessToast(context, '通知時間を保存しました！');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          return;
        }
        await _handleBackRequest(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '通知時間',
            style: tokens.typography.h4.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackRequest(context),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(tokens.spacing.md),
          children: [
            _TimePickerTile(
              tokens: tokens,
              label: '朝のリマインダー',
              time: _morningTime,
              onTap:
                  () => _selectTime(
                    context,
                    _morningTime,
                    (time) => _morningTime = time,
                  ),
            ),
            SizedBox(height: tokens.spacing.md),
            _TimePickerTile(
              tokens: tokens,
              label: '夜のリマインダー',
              time: _eveningTime,
              onTap:
                  () => _selectTime(
                    context,
                    _eveningTime,
                    (time) => _eveningTime = time,
                  ),
            ),
            SizedBox(height: tokens.spacing.lg),
            Text(
              '通知する曜日',
              style: tokens.typography.h5.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing.sm),
            _WeekdaySelector(
              tokens: tokens,
              enabledWeekdays: _enabledWeekdays,
              onToggle: _toggleWeekday,
            ),
            SizedBox(height: tokens.spacing.md),
            SwitchListTile(
              title: Text('祝日も通知する', style: tokens.typography.bodyLarge),
              value: _notifyOnHolidays,
              onChanged: (value) {
                setState(() => _notifyOnHolidays = value);
                _updateUnsavedState();
              },
            ),
            SizedBox(height: tokens.spacing.xl),
            MinqPrimaryButton(label: '保存', onPressed: _saveSettings),
          ],
        ),
      ),
    );
  }

  void _updateUnsavedState() {
    final hasChanges = _computeHasUnsavedChanges();
    if (hasChanges != _hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = hasChanges);
    }
  }

  bool _computeHasUnsavedChanges() {
    final timeChanged =
        _morningTime != _initialMorningTime ||
        _eveningTime != _initialEveningTime;
    final weekdaysChanged =
        !_setEquals(_enabledWeekdays, _initialEnabledWeekdays);
    final holidayChanged = _notifyOnHolidays != _initialNotifyOnHolidays;
    return timeChanged || weekdaysChanged || holidayChanged;
  }

  Future<void> _handleBackRequest(BuildContext context) async {
    if (!_hasUnsavedChanges) {
      Navigator.of(context).pop();
      return;
    }

    final shouldLeave = await showDiscardChangesDialog(
      context,
      message: '保存していない通知設定があります。破棄して戻りますか？',
      discardLabel: '変更を破棄',
    );
    if (shouldLeave && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  bool _setEquals(Set<int> a, Set<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final value in a) {
      if (!b.contains(value)) {
        return false;
      }
    }
    return true;
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
      shadowColor: tokens.background.withAlpha((255 * 0.1).round()),
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        title: Text(
          label,
          style: tokens.typography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          time.format(context),
          style: tokens.typography.h4.copyWith(
            color: tokens.brandPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 曜日選択ウィジェット
class _WeekdaySelector extends StatelessWidget {
  final MinqTheme tokens;
  final Set<int> enabledWeekdays;
  final ValueChanged<int> onToggle;

  const _WeekdaySelector({
    required this.tokens,
    required this.enabledWeekdays,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const weekdayLabels = ['日', '月', '火', '水', '木', '金', '土'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final weekday = index; // 0=日曜, 6=土曜
        final isEnabled = enabledWeekdays.contains(weekday);

        return GestureDetector(
          onTap: () => onToggle(weekday),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isEnabled ? tokens.brandPrimary : tokens.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isEnabled ? tokens.brandPrimary : tokens.border,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                weekdayLabels[index],
                style: tokens.typography.body.copyWith(
                  color: isEnabled ? Colors.white : tokens.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
