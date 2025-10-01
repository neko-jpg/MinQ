import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:intl/intl.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final heatmapData = ref.watch(heatmapDataProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Progress', style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: MinqIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
        backgroundColor: tokens.background.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: heatmapData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (data) => ListView(
          padding: EdgeInsets.all(tokens.spacing(4)),
          children: [
            _buildStreakCard(context, tokens),
            SizedBox(height: tokens.spacing(6)),
            _buildGoalCard(context, tokens),
            SizedBox(height: tokens.spacing(6)),
            _buildCompareProgressCard(context, tokens),
            SizedBox(height: tokens.spacing(6)),
            _buildWeeklyProgressCard(context, tokens),
            SizedBox(height: tokens.spacing(6)),
            _buildCalendarCard(context, tokens, data),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, MinqTheme tokens) {
    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          children: [
            Text('Current Streak', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
            SizedBox(height: tokens.spacing(2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department, size: tokens.spacing(12), color: tokens.brandPrimary),
                SizedBox(width: tokens.spacing(2)),
                Text('21', style: tokens.displayMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.w800)),
              ],
            ),
            SizedBox(height: tokens.spacing(1)),
            Text('days', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, MinqTheme tokens) {
    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Set Your Goal', style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Edit')),
              ],
            ),
            SizedBox(height: tokens.spacing(4)),
            Text(
              'Setting a goal can help you stay motivated. What do you want to achieve?',
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            ),
            SizedBox(height: tokens.spacing(6)),
            // TODO: Implement Goal Type Dropdown
            // TODO: Implement Goal Value Input
            SizedBox(height: tokens.spacing(6)),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.brandPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
              ),
              child: const Text('Set Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareProgressCard(BuildContext context, MinqTheme tokens) {
    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Compare Progress', style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
                // TODO: Implement Week/Month toggle
              ],
            ),
            SizedBox(height: tokens.spacing(6)),
            _buildProgressBar(tokens, 'This Week', '5/7 days', 0.71),
            SizedBox(height: tokens.spacing(4)),
            _buildProgressBar(tokens, 'Last Week', '6/7 days', 0.85, isLastWeek: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(MinqTheme tokens, String label, String value, double progress, {bool isLastWeek = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: tokens.bodyMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
            Text(value, style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
          ],
        ),
        SizedBox(height: tokens.spacing(2)),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: tokens.background,
          color: isLastWeek ? tokens.brandPrimary.withOpacity(0.7) : tokens.brandPrimary,
          minHeight: 8,
          borderRadius: tokens.cornerLarge(),
        ),
        if (isLastWeek)
          Padding(
            padding: EdgeInsets.only(top: tokens.spacing(2)),
            child: Row(
              children: [
                Icon(Icons.arrow_downward, size: 16, color: Colors.red.shade400),
                SizedBox(width: tokens.spacing(1)),
                Text('-1 day from last week', style: tokens.bodySmall.copyWith(color: Colors.red.shade400)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildWeeklyProgressCard(BuildContext context, MinqTheme tokens) {
    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weekly Progress', style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
                // TODO: Implement dropdown
              ],
            ),
            SizedBox(height: tokens.spacing(6)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressRing(tokens, '5/7', 'Days', 0.71),
                _buildProgressRing(tokens, '4.2h', 'Total Time', 0.6),
                _buildProgressRing(tokens, '32m', 'Avg. Time', 0.75),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRing(MinqTheme tokens, String value, String label, double progress) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: tokens.background,
                color: tokens.brandPrimary,
              ),
              Center(child: Text(value, style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold))), 
            ],
          ),
        ),
        SizedBox(height: tokens.spacing(2)),
        Text(label, style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
      ],
    );
  }

  Widget _buildCalendarCard(BuildContext context, MinqTheme tokens, Map<DateTime, int> data) {
    final now = DateTime.now();
    final monthName = DateFormat.MMMM().format(now);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday;

    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(monthName, style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
                  ],
                ),
              ],
            ),
            SizedBox(height: tokens.spacing(4)),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemCount: daysInMonth + weekdayOfFirstDay - 1,
              itemBuilder: (context, index) {
                if (index < weekdayOfFirstDay - 1) {
                  return const SizedBox.shrink();
                }
                final day = index - (weekdayOfFirstDay - 2);
                final date = DateTime(now.year, now.month, day);
                final value = data[DateUtils.dateOnly(date)] ?? 0;
                final isToday = DateUtils.isSameDay(date, now);

                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value > 0 ? tokens.brandPrimary.withOpacity(value / 5.0) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday ? Border.all(color: tokens.brandPrimary, width: 2) : null,
                  ),
                  child: Text(
                    '$day',
                    style: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}