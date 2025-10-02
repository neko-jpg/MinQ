import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final heatmapData = ref.watch(heatmapDataProvider);
    final streakAsync = ref.watch(streakProvider);

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
            error: (error, stack) => Center(child: Text(l10n.errorGeneric)),
            data: (data) {
              Widget child = ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing(4),
                  vertical: tokens.spacing(6),
                ),
                children: [
                  _buildStreakCard(context, tokens, streakAsync, l10n),
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
Widget _buildStreakCard(
  BuildContext context,
  MinqTheme tokens,
  AsyncValue<int> streakAsync,
  AppLocalizations l10n,
) {
  Widget buildContent(int streak) {
    final streakText = '$streak';
    final streakDescription = l10n.streakDayCount(streak);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '現在の連続日数',
          style: tokens.typeScale.bodyMedium.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing(2)),
        Semantics(
          label: streakDescription,
          value: streakDescription,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                size: tokens.spacing(12),
                color: tokens.brandPrimary,
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(
                streakText,
                style: tokens.typeScale.h1.copyWith(color: tokens.textPrimary),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spacing(2)),
        Text(
          streakDescription,
          style: tokens.typeScale.bodyMedium.copyWith(color: tokens.textMuted),
        ),
      ],
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
      padding: EdgeInsets.all(tokens.spacing(6)),
      child: streakAsync.when(
        data: buildContent,
        loading: () => SizedBox(
          height: tokens.spacing(20),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: tokens.accentError),
            SizedBox(height: tokens.spacing(2)),
            Text(
              '連続日数を取得できませんでした',
              style:
                  tokens.typeScale.bodySmall.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
    child: ListTile(
      onTap: () => _showGoalBottomSheet(context, tokens),
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(4),
        vertical: tokens.spacing(2),
      ),
      leading: Container(
        width: tokens.spacing(10),
        height: tokens.spacing(10),
        decoration: BoxDecoration(
          color: tokens.brandPrimary.withOpacity(0.12),
          borderRadius: tokens.cornerLarge(),
        ),
        child: Icon(Icons.flag, color: tokens.brandPrimary, size: tokens.spacing(6)),
      ),
      title: Text(
        '目標設定',
        style: tokens.typeScale.h4.copyWith(color: tokens.textPrimary),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: tokens.spacing(1)),
        child: Text(
          '今月の目標: 5日継続',
          style: tokens.typeScale.bodySmall.copyWith(color: tokens.textMuted),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '編集する',
            style: tokens.typeScale.bodySmall.copyWith(color: tokens.brandPrimary),
          ),
          SizedBox(width: tokens.spacing(1)),
          Icon(Icons.chevron_right, color: tokens.brandPrimary),
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
    required this.value,
    required this.unit,
    required this.progress,
    required this.color,
    required this.icon,
    required this.semanticsLabel,
  });

  final String label;
  final double value;
  final String unit;
  final double progress;
  final Color color;
  final IconData icon;
  final String semanticsLabel;
}

class _RingMetric {
  const _RingMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.progress,
    this.delta,
  });

  final String label;
  final double value;
  final String unit;
  final double progress;
  final double? delta;
}

Widget _buildCompareProgressCard(BuildContext context, WidgetRef ref, MinqTheme tokens) {
  final navigation = ref.read(navigationUseCaseProvider);
  final entries = <_ProgressEntry>[
    _ProgressEntry(
      label: '今週',
      value: 5,
      unit: '日',
      progress: 0.71,
      color: tokens.brandPrimary,
      icon: Icons.trending_up,
      semanticsLabel: '今週は5日達成しています',
    ),
    _ProgressEntry(
      label: '先週',
      value: 6,
      unit: '日',
      progress: 0.86,
      color: tokens.serenity,
      icon: Icons.history,
      semanticsLabel: '先週は6日達成しました',
    ),
  ];
  final hasProgress = entries.any((entry) => entry.progress > 0);
  final double? deltaFromPrevious =
      entries.length >= 2 ? entries.first.value - entries[1].value : null;

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
          SizedBox(height: tokens.spacing(3)),
          Wrap(
            spacing: tokens.spacing(3),
            runSpacing: tokens.spacing(2),
            children: [
              for (final entry in entries)
                Semantics(
                  container: true,
                  label: entry.semanticsLabel,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LegendBadge(color: entry.color, icon: entry.icon),
                      SizedBox(width: tokens.spacing(1.5)),
                      Text(
                        '${entry.label}（${entry.unit}）',
                        style: tokens.typeScale.bodySmall.copyWith(color: tokens.textMuted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: tokens.spacing(4)),
          for (int i = 0; i < entries.length; i++) ...[
            _buildProgressBar(
              tokens,
              entries[i],
              isPrimary: i == 0,
              delta: i == 0 ? deltaFromPrevious : null,
            ),
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

  final metrics = <_RingMetric>[
    const _RingMetric(label: '日数', value: 5, unit: '日', progress: 0.71, delta: 1),
    const _RingMetric(label: '合計時間', value: 4.2, unit: '時間', progress: 0.6, delta: -0.3),
    const _RingMetric(label: '平均時間', value: 32, unit: '分', progress: 0.75, delta: 2),
  ];

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
            children: [
              for (final metric in metrics)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spacing(2)),
                    child: _buildProgressRing(tokens, metric),
                  ),
                ),
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

Widget _buildProgressBar(
  MinqTheme tokens,
  _ProgressEntry entry, {
  bool isPrimary = false,
  double? delta,
}) {
  final progressColor =
      isPrimary ? entry.color : entry.color.withOpacity(0.7);
  final deltaLabel = delta != null ? _formatDelta(delta, entry.unit) : null;
  final valueText = '${entry.value.toStringAsFixed(entry.value % 1 == 0 ? 0 : 1)}${entry.unit}';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          _LegendBadge(color: progressColor, icon: entry.icon),
          SizedBox(width: tokens.spacing(2)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.label,
                  style: tokens.typeScale.bodyMedium.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (deltaLabel != null)
                  Text(
                    '先週比 $deltaLabel',
                    style: tokens.typeScale.bodySmall
                        .copyWith(color: tokens.textMuted),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valueText,
                style: tokens.typeScale.bodyMedium.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: tokens.spacing(2)),
      Semantics(
        label: entry.semanticsLabel,
        value: '${(entry.progress * 100).round()}%',
        child: ClipRRect(
          borderRadius: tokens.cornerLarge(),
          child: LinearProgressIndicator(
            value: entry.progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: tokens.border.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ),
    ],
  );
}

class _LegendBadge extends StatelessWidget {
  const _LegendBadge({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final Color iconColor =
        tokens.ensureAccessibleOnBackground(tokens.textPrimary, color);
    return Container(
      width: tokens.spacing(6),
      height: tokens.spacing(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: tokens.cornerMedium(),
        border: Border.all(color: tokens.border.withOpacity(0.4)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: tokens.spacing(3.5)),
    );
  }
}

String _formatDelta(double delta, String unit) {
  if (delta > 0) {
    return '▲${delta.toStringAsFixed(delta.abs() < 1 ? 1 : 0)}$unit';
  }
  if (delta < 0) {
    return '▼${delta.abs().toStringAsFixed(delta.abs() < 1 ? 1 : 0)}$unit';
  }
  return '±0$unit';
}
Widget _buildProgressRing(MinqTheme tokens, _RingMetric metric) {
  final hasProgress = metric.progress > 0;
  final valueText =
      '${metric.value.toStringAsFixed(metric.value % 1 == 0 ? 0 : 1)}${metric.unit}';
  final deltaLabel =
      metric.delta != null ? _formatDelta(metric.delta!, metric.unit) : null;
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
                value: metric.progress.clamp(0.0, 1.0),
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
                backgroundColor: Colors.transparent,
              ),
            Padding(
              padding: EdgeInsets.all(tokens.spacing(2)),
              child: hasProgress
                  ? Text(
                      valueText,
                      style: tokens.typeScale.bodyMedium
                          .copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold),
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
      Text(
        metric.label,
        style: tokens.typeScale.bodySmall.copyWith(
          color: tokens.textMuted,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
      if (deltaLabel != null) ...[
        SizedBox(height: tokens.spacing(1)),
        Text(
          '先週比 $deltaLabel',
          style: tokens.typeScale.bodySmall.copyWith(color: tokens.textMuted),
        ),
      ],
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
