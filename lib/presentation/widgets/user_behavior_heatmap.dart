import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

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
    final tokens = MinqTheme.of(context);
    final focusColor = tokens.accentSecondary;
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
        defaultColor: tokens.surface,
        textColor: tokens.onSurface,
        onClick: (value) => onDateSelected?.call(value),
        showText: false,
        scrollable: true,
        colorsets: {
          1: focusColor.withAlpha((255 * 0.25).round()),
          3: focusColor.withAlpha((255 * 0.5).round()),
          5: focusColor.withAlpha((255 * 0.7).round()),
          7: focusColor,
        },
      ),
    );
  }
}
