import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final heatmapData = ref.watch(heatmapDataProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          '進捗',
          style:
              tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: MinqIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
        backgroundColor: tokens.background.withOpacity(0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const maxWidth = 640.0;

          return heatmapData.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('エラー: $error')),
            data: (data) {
              Widget child = ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing(4),
                  vertical: tokens.spacing(6),
                ),
                children: [
                  _buildStreakCard(context, tokens),
                  SizedBox(height: tokens.spacing(6)),
                  _buildGoalCard(context, ref, tokens),
                  SizedBox(height: tokens.spacing(6)),
                  _buildCompareProgressCard(context, ref, tokens),
                  SizedBox(height: tokens.spacing(6)),
                  _buildWeeklyProgressCard(context, ref, tokens),
                  SizedBox(height: tokens.spacing(6)),
                  _buildCalendarCard(context, ref, tokens, data),
                ],
              );

              if (constraints.maxWidth > maxWidth) {
                child = Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxWidth),
                    child: child,
                  ),
                );
              }

              return child;
            },
          );
        },
      ),
    );
  }
}
Widget _buildStreakCard(BuildContext context, MinqTheme tokens) {
  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing(6)),
      child: Column(
        children: [
          Text('現在の連続日数', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
          SizedBox(height: tokens.spacing(2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department, size: tokens.spacing(12), color: tokens.brandPrimary),
              SizedBox(width: tokens.spacing(2)),
              Text(
                '21',
                style: tokens.displayMedium.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing(2)),
          Text('日', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        ],
      ),
    ),
  );
}

Widget _buildGoalCard(BuildContext context, WidgetRef ref, MinqTheme tokens) {
  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: tokens.cornerLarge(),
            onTap: () => _showGoalBottomSheet(context, tokens),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing(2),
                vertical: tokens.spacing(2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '目標設定',
                        style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: tokens.spacing(2)),
                      Text(
                        '今月の目標: 5日継続',
                        style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, color: tokens.textMuted),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            'タップして達成目標を編集できます。',
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    ),
  );
}

void _showGoalBottomSheet(BuildContext context, MinqTheme tokens) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: tokens.spacing(4),
          right: tokens.spacing(4),
          top: tokens.spacing(4),
          bottom: MediaQuery.of(context).viewInsets.bottom + tokens.spacing(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('目標を編集する', style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: tokens.spacing(4)),
            TextField(
              decoration: InputDecoration(
                labelText: '連続日数の目標',
                hintText: '例: 7',
                border: OutlineInputBorder(borderRadius: tokens.cornerLarge()),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: tokens.spacing(4)),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('保存する'),
            ),
          ],
        ),
      );
    },
  );
}
class _ProgressEntry {
  const _ProgressEntry({
    required this.label,
    required this.valueLabel,
    required this.progress,
    this.deltaLabel,
  });

  final String label;
  final String valueLabel;
  final double progress;
  final String? deltaLabel;
}

Widget _buildCompareProgressCard(BuildContext context, WidgetRef ref, MinqTheme tokens) {
  final navigation = ref.read(navigationUseCaseProvider);
  final entries = <_ProgressEntry>[
    const _ProgressEntry(label: '今週', valueLabel: '5/7日', progress: 0.71, deltaLabel: null),
    const _ProgressEntry(label: '先週', valueLabel: '6/7日', progress: 0.85, deltaLabel: '−1日'),
  ];
  final hasProgress = entries.any((entry) => entry.progress > 0);

  if (!hasProgress) {
    return _buildZeroChart(
      tokens,
      message: 'まだ比較できる進捗データがありません。',
      actionLabel: '記録する',
      onAction: () => navigation.goToQuests(),
    );
  }

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('進捗を比較する', style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
          SizedBox(height: tokens.spacing(4)),
          for (int i = 0; i < entries.length; i++) ...[
            _buildProgressBar(tokens, entries[i], isPrimary: i == 0),
            if (i < entries.length - 1) SizedBox(height: tokens.spacing(4)),
          ],
        ],
      ),
    ),
  );
}

Widget _buildWeeklyProgressCard(BuildContext context, WidgetRef ref, MinqTheme tokens) {
  final navigation = ref.read(navigationUseCaseProvider);
  final hasProgress = true; // Replace with actual data when available

  if (!hasProgress) {
    return _buildZeroChart(
      tokens,
      message: '週間の進捗がまだありません。',
      actionLabel: '習慣を追加する',
      onAction: () => navigation.goToQuests(),
    );
  }

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('週間の進捗', style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
          SizedBox(height: tokens.spacing(4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressRing(tokens, '5/7', '日数', 0.71),
              _buildProgressRing(tokens, '4.2h', '合計時間', 0.6),
              _buildProgressRing(tokens, '32m', '平均時間', 0.75),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildZeroChart(
  MinqTheme tokens, {
  required String message,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(4),
        vertical: tokens.spacing(6),
      ),
      child: MinqEmptyState(
        icon: Icons.insights_outlined,
        title: 'データがありません',
        message: message,
        actionArea: ElevatedButton(
          onPressed: onAction,
          child: Text(actionLabel),
        ),
      ),
    ),
  );
}

Widget _buildProgressBar(MinqTheme tokens, _ProgressEntry entry, {bool isPrimary = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(entry.label, style: tokens.bodyMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
          Text(entry.valueLabel, style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
        ],
      ),
      SizedBox(height: tokens.spacing(2)),
      LinearProgressIndicator(
        value: entry.progress.clamp(0.0, 1.0),
        backgroundColor: tokens.background,
        color: isPrimary ? tokens.brandPrimary : tokens.brandPrimary.withOpacity(0.6),
        minHeight: 8,
        borderRadius: tokens.cornerLarge(),
      ),
      if (entry.deltaLabel != null)
        Padding(
          padding: EdgeInsets.only(top: tokens.spacing(2)),
          child: Row(
            children: [
              Icon(
                entry.deltaLabel!.startsWith('−') ? Icons.arrow_downward : Icons.arrow_upward,
                size: 16,
                color: entry.deltaLabel!.startsWith('−') ? Colors.red.shade400 : tokens.accentSuccess,
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(entry.deltaLabel!, style: tokens.bodySmall.copyWith(color: entry.deltaLabel!.startsWith('−') ? Colors.red.shade400 : tokens.accentSuccess)),
            ],
          ),
        ),
    ],
  );
}
Widget _buildProgressRing(MinqTheme tokens, String value, String label, double progress) {
  final hasProgress = progress > 0;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: 1,
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.border.withOpacity(0.3)),
              backgroundColor: Colors.transparent,
            ),
            if (hasProgress)
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
                backgroundColor: Colors.transparent,
              ),
            Padding(
              padding: EdgeInsets.all(tokens.spacing(2)),
              child: hasProgress
                  ? Text(
                      value,
                      style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_empty, size: tokens.spacing(6), color: tokens.textMuted),
                        SizedBox(height: tokens.spacing(2)),
                        Text('未計測', style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
                      ],
                    ),
            ),
          ],
        ),
      ),
      SizedBox(height: tokens.spacing(2)),
      Text(label, style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
    ],
  );
}
Widget _buildCalendarCard(
  BuildContext context,
  WidgetRef ref,
  MinqTheme tokens,
  Map<DateTime, int> data,
) {
  final navigation = ref.read(navigationUseCaseProvider);
  final now = DateTime.now();
  final monthName = DateFormat.MMMM('ja').format(now);
  final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
  final firstDayOfMonth = DateTime(now.year, now.month, 1);
  final weekdayOfFirstDay = firstDayOfMonth.weekday;
  final hasData = data.values.any((value) => value > 0);

  if (!hasData) {
    return _buildZeroChart(
      tokens,
      message: 'カレンダーに表示できる記録がまだありません。',
      actionLabel: '今日の習慣を記録する',
      onAction: () => navigation.goToQuests(),
    );
  }

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: tokens.cornerXLarge(),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
