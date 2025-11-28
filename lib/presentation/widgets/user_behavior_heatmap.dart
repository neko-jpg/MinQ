import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class UserBehaviorHeatmap extends StatelessWidget {
  const UserBehaviorHeatmap({
    super.key,
    required this.dataset,
    this.startDate,
    this.endDate,
    this.onDateSelected,
  });

  final Map<DateTime, int> dataset;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusColor = theme.colorScheme.secondary;
    return Semantics(
      label: '週間達成ヒートマップ',
      child: HeatMap(
        datasets: dataset,
        startDate:
            startDate ?? DateTime.now().subtract(const Duration(days: 90)),
        endDate: endDate ?? DateTime.now(),
        size: 32,
        borderRadius: 12,
        margin: const EdgeInsets.all(4),
        colorMode: ColorMode.opacity,
        defaultColor: theme.colorScheme.surfaceContainerHighest,
        textColor: theme.colorScheme.onSurface,
        onClick: (value) => onDateSelected?.call(value),
        showText: false,
        scrollable: true,
        colorsets: {
          1: focusColor.withValues(alpha: 0.25),
          3: focusColor.withValues(alpha: 0.5),
          5: focusColor.withValues(alpha: 0.7),
          7: focusColor,
        },
      ),
    );
  }
}
