import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class TimePickerWidget extends StatefulWidget {
  final String title;
  final TimeOfDay currentTime;
  final ValueChanged<TimeOfDay>? onChanged;

  const TimePickerWidget({
    super.key,
    required this.title,
    required this.currentTime,
    this.onChanged,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.currentTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);

    return AlertDialog(
      title: Text(
        widget.title,
        style: theme.typography.h5.copyWith(
          color: theme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current Time Display
          Container(
            padding: EdgeInsets.all(theme.spacing.lg),
            decoration: BoxDecoration(
              color: theme.surfaceAlt,
              borderRadius: theme.cornerMedium(),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  color: theme.brandPrimary,
                  size: 24,
                ),
                SizedBox(width: theme.spacing.md),
                Text(
                  _selectedTime.format(context),
                  style: theme.typography.h3.copyWith(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: theme.spacing.lg),

          // Time Picker Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: theme.brandPrimary,
                          onPrimary: theme.primaryForeground,
                          surface: theme.surface,
                          onSurface: theme.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
              icon: const Icon(Icons.schedule),
              label: const Text('時間を変更'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.brandPrimary,
                foregroundColor: theme.primaryForeground,
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.lg,
                  vertical: theme.spacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: theme.cornerMedium(),
                ),
              ),
            ),
          ),

          SizedBox(height: theme.spacing.md),

          // Quick Time Options
          Text(
            'よく使う時間',
            style: theme.typography.bodyMedium.copyWith(
              color: theme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: theme.spacing.sm),

          Wrap(
            spacing: theme.spacing.sm,
            runSpacing: theme.spacing.sm,
            children: [
              _buildQuickTimeChip(theme, const TimeOfDay(hour: 7, minute: 0), '7:00'),
              _buildQuickTimeChip(theme, const TimeOfDay(hour: 8, minute: 0), '8:00'),
              _buildQuickTimeChip(theme, const TimeOfDay(hour: 9, minute: 0), '9:00'),
              _buildQuickTimeChip(theme, const TimeOfDay(hour: 18, minute: 0), '18:00'),
              _buildQuickTimeChip(theme, const TimeOfDay(hour: 19, minute: 0), '19:00'),
              _buildQuickTimeChip(theme, const TimeOfDay(hour: 20, minute: 0), '20:00'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'キャンセル',
            style: theme.typography.button.copyWith(
              color: theme.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            widget.onChanged?.call(_selectedTime);
            Navigator.of(context).pop();
          },
          child: Text(
            '適用',
            style: theme.typography.button.copyWith(
              color: theme.brandPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTimeChip(MinqTheme theme, TimeOfDay time, String label) {
    final isSelected = time.hour == _selectedTime.hour && time.minute == _selectedTime.minute;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTime = time;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.brandPrimary : theme.surfaceAlt,
          borderRadius: theme.cornerSmall(),
          border: Border.all(
            color: isSelected ? theme.brandPrimary : theme.border,
          ),
        ),
        child: Text(
          label,
          style: theme.typography.bodyMedium.copyWith(
            color: isSelected ? theme.primaryForeground : theme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}