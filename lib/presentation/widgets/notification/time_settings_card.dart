import 'package:flutter/material.dart';

import 'package:minq/domain/notification/notification_settings.dart';
import 'package:minq/l10n/l10n.dart';

/// 時間帯設定カード
class TimeSettingsCard extends StatelessWidget {
  final TimeBasedNotificationSettings settings;
  final ValueChanged<TimeBasedNotificationSettings> onSettingsChanged;

  const TimeSettingsCard({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(l10n.enableTimeBasedControl),
              subtitle: Text(l10n.enableTimeBasedControlDescription),
              value: settings.enabled,
              onChanged: (value) {
                onSettingsChanged(settings.copyWith(enabled: value));
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            if (settings.enabled) ...[
              const Divider(),
              
              // 就寝時間設定
              Text(
                l10n.sleepTime,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: _TimeSlotSelector(
                      label: l10n.sleepTimeRange,
                      timeSlot: settings.sleepTime,
                      onChanged: (timeSlot) {
                        onSettingsChanged(settings.copyWith(sleepTime: timeSlot));
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 勤務時間設定
              Text(
                l10n.workTime,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: _TimeSlotSelector(
                      label: l10n.workTimeRange,
                      timeSlot: settings.workTime,
                      onChanged: (timeSlot) {
                        onSettingsChanged(settings.copyWith(workTime: timeSlot));
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // その他のオプション
              CheckboxListTile(
                title: Text(l10n.respectSystemDnd),
                subtitle: Text(l10n.respectSystemDndDescription),
                value: settings.respectSystemDnd,
                onChanged: (value) {
                  if (value != null) {
                    onSettingsChanged(settings.copyWith(respectSystemDnd: value));
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              
              CheckboxListTile(
                title: Text(l10n.weekendMode),
                subtitle: Text(l10n.weekendModeDescription),
                value: settings.weekendMode,
                onChanged: (value) {
                  if (value != null) {
                    onSettingsChanged(settings.copyWith(weekendMode: value));
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              
              if (settings.weekendMode) ...[
                const SizedBox(height: 8),
                
                // 週末就寝時間
                Text(
                  l10n.weekendSleepTime,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                
                _TimeSlotSelector(
                  label: l10n.weekendSleepTimeRange,
                  timeSlot: settings.weekendSleepTime,
                  onChanged: (timeSlot) {
                    onSettingsChanged(settings.copyWith(weekendSleepTime: timeSlot));
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 週末勤務時間
                Text(
                  l10n.weekendWorkTime,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                
                _TimeSlotSelector(
                  label: l10n.weekendWorkTimeRange,
                  timeSlot: settings.weekendWorkTime,
                  onChanged: (timeSlot) {
                    onSettingsChanged(settings.copyWith(weekendWorkTime: timeSlot));
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// 時間帯選択ウィジェット
class _TimeSlotSelector extends StatelessWidget {
  final String label;
  final TimeSlot? timeSlot;
  final ValueChanged<TimeSlot?> onChanged;

  const _TimeSlotSelector({
    required this.label,
    required this.timeSlot,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Switch(
              value: timeSlot != null,
              onChanged: (enabled) {
                if (enabled) {
                  onChanged(const TimeSlot(
                    startHour: 22,
                    startMinute: 0,
                    endHour: 7,
                    endMinute: 0,
                  ));
                } else {
                  onChanged(null);
                }
              },
            ),
          ],
        ),
        
        if (timeSlot != null) ...[
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _TimePickerButton(
                  label: l10n.startTime,
                  time: TimeOfDay(
                    hour: timeSlot!.startHour,
                    minute: timeSlot!.startMinute,
                  ),
                  onChanged: (time) {
                    onChanged(timeSlot!.copyWith(
                      startHour: time.hour,
                      startMinute: time.minute,
                    ));
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: _TimePickerButton(
                  label: l10n.endTime,
                  time: TimeOfDay(
                    hour: timeSlot!.endHour,
                    minute: timeSlot!.endMinute,
                  ),
                  onChanged: (time) {
                    onChanged(timeSlot!.copyWith(
                      endHour: time.hour,
                      endMinute: time.minute,
                    ));
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 時間選択ボタン
class _TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        
        OutlinedButton(
          onPressed: () async {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: time,
            );
            
            if (selectedTime != null) {
              onChanged(selectedTime);
            }
          },
          child: Text(
            time.format(context),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}