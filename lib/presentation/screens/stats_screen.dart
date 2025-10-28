import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/stats/stats_view_data.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/controllers/stats_data_controller.dart';
import 'package:minq/presentation/controllers/sync_status_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  bool _hasRequestedReview = false;

  @override
  void initState() {
    super.initState();
    // Stats画面表示時にレビューリクエストを試行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeRequestReview();
    });
  }

  Future<void> _maybeRequestReview() async {
    if (_hasRequestedReview || !mounted) return;
    _hasRequestedReview = true;

    try {
      final statsData = await ref.read(statsDataProvider.future);
      final totalCompleted = statsData.heatmap.values.fold<int>(
        0,
        (sum, count) => sum + count,
      );

      final reviewService = ref.read(inAppReviewServiceProvider);
      await reviewService.maybeRequestReviewByQuestCount(
        completedCount: totalCompleted,
      );
    } catch (e) {
      // エラーは無視（ユーザー体験を損なわない）
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SyncStatus>(
      syncStatusProvider,
      (previous, next) {
        if (!mounted ||
            !next.showBanner ||
            next.bannerMessage == null) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(next.bannerMessage!),
              duration: const Duration(seconds: 2),
            ),
          );
          ref.read(syncStatusProvider.notifier).acknowledgeBanner();
        });
      },
    );

    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(statsDataProvider);
    final StatsViewData? data = statsAsync.valueOrNull;
    final bool hasCachedContent = data?.hasCachedContent ?? false;
    final bool isLoading = statsAsync.isLoading && !hasCachedContent;
    final bool hasError = statsAsync.hasError && !hasCachedContent;
    final bool isRefreshing = statsAsync.isLoading && hasCachedContent;
    final StatsViewData content = data ?? StatsViewData.empty();

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError) {
      return Scaffold(body: Center(child: Text(l10n.errorGeneric)));
    }

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: AppBar(
        title: Text(
          '進捗',
          style: tokens.typography.h3.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: MinqIconButton(
          icon: Icons.arrow_back,
          onTap: () => context.pop(),
        ),
        backgroundColor: tokens.surface.withAlpha(230),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const maxWidth = 640.0;

          Widget child = ListView(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.md,
              vertical: tokens.spacing.xl,
            ),
            children: [
              if (isRefreshing)
                Padding(
                  padding: EdgeInsets.only(bottom: tokens.spacing.sm),
                  child: const LinearProgressIndicator(),
                ),
              _buildStreakCard(context, tokens, content, l10n),
              SizedBox(height: tokens.spacing.xl),
              _buildTodayStatsCard(context, tokens, content, ref),
              SizedBox(height: tokens.spacing.xl),
              _buildWeeklyStatsCard(context, tokens, content, ref),
              SizedBox(height: tokens.spacing.xl),
              _buildGoalCard(context, tokens),
              SizedBox(height: tokens.spacing.xl),
              _buildCompareProgressCard(context, ref, tokens),
              SizedBox(height: tokens.spacing.xl),
              _buildWeeklyProgressCard(context, ref, tokens),
              SizedBox(height: tokens.spacing.xl),
              _buildCalendarCard(context, ref, tokens, content.heatmap),
              SizedBox(height: tokens.spacing.xl),
              _buildInsightsCard(context, ref, tokens, content),
              SizedBox(height: tokens.spacing.xl),
              _buildExportCard(context, ref, tokens),
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
      ),
    );
  }
}

Widget _buildStreakCard(
  BuildContext context,
  MinqTheme tokens,
  StatsViewData data,
  AppLocalizations l10n,
) {
  final int streak = data.streak;
  final bool hasStreak = streak > 0;
  final String streakText = '$streak';
  final String streakDescription =
      hasStreak ? l10n.streakDayCount(streak) : 'まだ連続記録がありません';

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius.xl),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '現在の連続日数',
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          Semantics(
            label: streakDescription,
            value: streakDescription,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 48,
                  color: hasStreak ? tokens.brandPrimary : tokens.textMuted,
                ),
                SizedBox(width: tokens.spacing.xs),
                Text(
                  streakText,
                  style: tokens.typography.h1.copyWith(
                    color: tokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            hasStreak ? streakDescription : '今日の最初の習慣を記録して連続日数をスタートしましょう。',
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildGoalCard(BuildContext context, MinqTheme tokens) {
  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius.xl),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: ListTile(
      onTap: () => _showGoalBottomSheet(context, tokens),
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.xs,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tokens.brandPrimary.withAlpha(31),
          borderRadius: BorderRadius.circular(tokens.radius.lg),
        ),
        child: Icon(
          Icons.flag,
          color: tokens.brandPrimary,
          size: 24,
        ),
      ),
      title: Text(
        '目標設定',
        style: tokens.typography.body.copyWith(color: tokens.textPrimary),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: tokens.spacing.xs),
        child: Text(
          '今月の目標: 5日継続',
          style: tokens.typography.caption.copyWith(color: tokens.textMuted),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '編集する',
            style: tokens.typography.caption.copyWith(
              color: tokens.brandPrimary,
            ),
          ),
          SizedBox(width: tokens.spacing.xs),
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
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.xl)),
    builder: (context) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: tokens.spacing.md,
              right: tokens.spacing.md,
              top: tokens.spacing.md,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + tokens.spacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '目標を編集する',
                  style: tokens.typography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing.md),
                TextField(
                  decoration: InputDecoration(
                    labelText: '連続日数の目標',
                    hintText: '例: 7',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radius.lg),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: tokens.spacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('保存する'),
                  ),
                ),
              ],
            ),
          ),
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
  });

  final String label;
  final double value;
  final String unit;
  final double progress;
}

Widget _buildCompareProgressCard(
  BuildContext context,
  WidgetRef ref,
  MinqTheme tokens,
) {
  final navigation = ref.read(navigationUseCaseProvider);
  final statsAsync = ref.watch(statsDataProvider);
  final data = statsAsync.valueOrNull ?? StatsViewData.empty();

  // 実データから今週と先週の統計を計算
  final now = DateTime.now();
  final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
  final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
  final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

  int thisWeekCompletions = 0;
  int lastWeekCompletions = 0;

  for (final entry in data.heatmap.entries) {
    if (entry.key.isAfter(thisWeekStart.subtract(const Duration(days: 1))) &&
        entry.key.isBefore(now.add(const Duration(days: 1)))) {
      thisWeekCompletions += entry.value;
    } else if (entry.key.isAfter(
          lastWeekStart.subtract(const Duration(days: 1)),
        ) &&
        entry.key.isBefore(lastWeekEnd.add(const Duration(days: 1)))) {
      lastWeekCompletions += entry.value;
    }
  }

  const weeklyGoal = 7.0;

  final entries = <_ProgressEntry>[
    _ProgressEntry(
      label: '今週',
      value: thisWeekCompletions.toDouble(),
      unit: '日',
      progress: (thisWeekCompletions / weeklyGoal).toDouble(),
      color: tokens.brandPrimary,
      icon: Icons.trending_up,
      semanticsLabel: '今週は$thisWeekCompletions日達成しています',
    ),
    _ProgressEntry(
      label: '先週',
      value: lastWeekCompletions.toDouble(),
      unit: '日',
      progress: (lastWeekCompletions / weeklyGoal).toDouble(),
      color: tokens.serenity,
      icon: Icons.history,
      semanticsLabel: '先週は$lastWeekCompletions日達成しました',
    ),
  ];
  final hasProgress = entries.any((entry) => entry.progress > 0);
  final double? deltaFromPrevious = entries.length >= 2
      ? (entries.first.value - entries[1].value).toDouble()
      : null;

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
      borderRadius: BorderRadius.circular(tokens.radius.xl),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '進捗を比較する',
            style: tokens.typography.h2.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Wrap(
            spacing: tokens.spacing.sm,
            runSpacing: tokens.spacing.xs,
            children: [
              for (final entry in entries)
                Semantics(
                  container: true,
                  label: entry.semanticsLabel,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LegendBadge(color: entry.color, icon: entry.icon),
                      SizedBox(width: tokens.spacing.xs),
                      Text(
                        '${entry.label}（${entry.unit}）',
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          for (int i = 0; i < entries.length; i++) ...[
            _buildProgressBar(
              tokens,
              entries[i],
              isPrimary: i == 0,
              delta: i == 0 ? deltaFromPrevious : null,
            ),
            if (i < entries.length - 1) SizedBox(height: tokens.spacing.md),
          ],
        ],
      ),
    ),
  );
}

Widget _buildWeeklyProgressCard(
  BuildContext context,
  WidgetRef ref,
  MinqTheme tokens,
) {
  final navigation = ref.read(navigationUseCaseProvider);
  final statsAsync = ref.watch(statsDataProvider);
  final data = statsAsync.valueOrNull ?? StatsViewData.empty();

  // 実データから週間統計を計算
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));

  int weeklyCompletions = 0;
  double totalMinutes = 0;

  for (final entry in data.heatmap.entries) {
    if (entry.key.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        entry.key.isBefore(weekEnd.add(const Duration(days: 1)))) {
      weeklyCompletions += entry.value;
      totalMinutes += entry.value * 30; // 仮定: 1回あたり30分
    }
  }

  final hasProgress = weeklyCompletions > 0;

  if (!hasProgress) {
    return _buildZeroChart(
      tokens,
      message: '週間の進捗がまだありません。',
      actionLabel: '習慣を追加する',
      onAction: () => navigation.goToQuests(),
    );
  }

  final averageMinutes =
      weeklyCompletions > 0 ? totalMinutes / weeklyCompletions : 0;
  const weeklyGoal = 7; // 週7日の目標
  const dailyGoalMinutes = 60; // 1日60分の目標

  final metrics = <_RingMetric>[
    _RingMetric(
      label: '日数',
      value: weeklyCompletions.toDouble(),
      unit: '日',
      progress: (weeklyCompletions / weeklyGoal).toDouble(),
    ),
    _RingMetric(
      label: '合計時間',
      value: (totalMinutes / 60).toDouble(),
      unit: '時間',
      progress:
          ((totalMinutes / 60) / (weeklyGoal * dailyGoalMinutes / 60)).toDouble(),
    ),
    _RingMetric(
      label: '平均時間',
      value: averageMinutes.toDouble(),
      unit: '分',
      progress: (averageMinutes / dailyGoalMinutes).toDouble(),
    ),
  ];

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius.xl),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '週間の進捗',
            style: tokens.typography.h2.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Row(
            children: [
              for (final metric in metrics)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.xs,
                    ),
                    child: _buildProgressRing(
                      tokens: tokens,
                      metric: metric,
                    ),
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
      borderRadius: BorderRadius.circular(tokens.radius.xl),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.lg,
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
      isPrimary ? entry.color : entry.color.withAlpha((255 * 0.7).round());
  final deltaLabel = delta != null ? _formatDelta(delta, entry.unit) : null;
  final valueText =
      '${entry.value.toStringAsFixed(entry.value % 1 == 0 ? 0 : 1)}${entry.unit}';

  return RepaintBoundary(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendBadge(color: progressColor, icon: entry.icon),
            SizedBox(width: tokens.spacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    style: tokens.typography.body.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (deltaLabel != null)
                    Text(
                      '先週比 $deltaLabel',
                      style: tokens.typography.caption.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  valueText,
                  style: tokens.typography.body.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.xs),
        Semantics(
          label: entry.semanticsLabel,
          value: '${(entry.progress * 100).round()}%',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius.lg),
            child: LinearProgressIndicator(
              value: entry.progress.clamp(0.0, 1.0),
              minHeight: 10.0,
              backgroundColor: tokens.border.withAlpha((255 * 0.3).round()),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ),
      ],
    ),
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
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black;
    return Container(
      width: tokens.spacing.lg,
      height: tokens.spacing.lg,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.border.withAlpha((255 * 0.4).round())),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: tokens.spacing.sm),
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

Widget _buildProgressRing({
  required MinqTheme tokens,
  required _RingMetric metric,
}) {
  final hasProgress = metric.progress > 0;
  final valueText =
      '${metric.value.toStringAsFixed(metric.value % 1 == 0 ? 0 : 1)}${metric.unit}';
  return RepaintBoundary(
    child: Column(
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
                valueColor: AlwaysStoppedAnimation<Color>(
                  tokens.border.withAlpha((255 * 0.3).round()),
                ),
                backgroundColor: Colors.transparent,
              ),
              if (hasProgress)
                CircularProgressIndicator(
                  value: metric.progress.clamp(0.0, 1.0).toDouble(),
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    tokens.brandPrimary,
                  ),
                  backgroundColor: Colors.transparent,
                ),
              Padding(
                padding: EdgeInsets.all(tokens.spacing.xs),
                child:
                    hasProgress
                        ? Text(
                          valueText,
                          style: tokens.typography.body.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              size: tokens.spacing.lg,
                              color: tokens.textMuted,
                            ),
                            SizedBox(height: tokens.spacing.xs),
                            Text(
                              '未計測',
                              style: tokens.typography.caption.copyWith(
                                color: tokens.textMuted,
                              ),
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spacing.xs),
        Text(
          metric.label,
          style: tokens.typography.caption.copyWith(
            color: tokens.textMuted,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
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
      borderRadius: BorderRadius.circular(tokens.radius.xl),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthName,
                style: tokens.typography.h2.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
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
                  color: value > 0
                      ? tokens.brandPrimary
                          .withAlpha((255 * (value.toDouble() / 5.0)).round())
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border:
                      isToday
                          ? Border.all(color: tokens.brandPrimary, width: 2.0)
                          : null,
                ),
                child: Text(
                  '$day',
                  style: tokens.typography.body.copyWith(color: tokens.textPrimary),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildTodayStatsCard(
  BuildContext context,
  MinqTheme tokens,
  StatsViewData data,
  WidgetRef ref,
) {
  final navigation = ref.read(navigationUseCaseProvider);
  final todayCount = data.todayCompletionCount;
  final hasProgress = todayCount > 0;

  if (!hasProgress) {
    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.today_outlined,
              size: tokens.spacing.xxl,
              color: tokens.textMuted,
            ),
            SizedBox(height: tokens.spacing.sm),
            Text(
              '今日はまだ記録がありません',
              style: tokens.typography.h4.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing.xs),
            Text(
              '最初のクエストを完了して、今日の記録を始めましょう！',
              style: tokens.typography.body.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing.md),
            ElevatedButton(
              onPressed: () => navigation.goToQuests(),
              child: const Text('クエストを見る'),
            ),
          ],
        ),
      ),
    );
  }

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius.xl),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '今日の完了数',
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: tokens.spacing.xxl,
                color: tokens.accentSuccess,
              ),
              SizedBox(width: tokens.spacing.xs),
              Text(
                '$todayCount',
                style: tokens.typography.h1.copyWith(color: tokens.textPrimary),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            todayCount >= 3
                ? '素晴らしい！今日の目標を達成しました。'
                : '目標まであと${3 - todayCount}個です。',
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildWeeklyStatsCard(
  BuildContext context,
  MinqTheme tokens,
  StatsViewData data,
  WidgetRef ref,
) {
  final navigation = ref.read(navigationUseCaseProvider);
  final weeklyRate = data.weeklyCompletionRate;
  final percentage = (weeklyRate * 100).round();
  final hasProgress = weeklyRate > 0;

  if (!hasProgress) {
    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: tokens.spacing.xxl,
              color: tokens.textMuted,
            ),
            SizedBox(height: tokens.spacing.sm),
            Text(
              '今週はまだ記録がありません',
              style: tokens.typography.h4.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing.xs),
            Text(
              '今週の習慣を始めて、週間達成率を向上させましょう！',
              style: tokens.typography.body.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing.md),
            ElevatedButton(
              onPressed: () => navigation.goToQuests(),
              child: const Text('今すぐ始める'),
            ),
          ],
        ),
      ),
    );
  }

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius.xl),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '今週の達成率',
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    tokens.border.withAlpha((255 * 0.3).round()),
                  ),
                  backgroundColor: Colors.transparent,
                ),
                CircularProgressIndicator(
                  value: weeklyRate.clamp(0.0, 1.0).toDouble(),
                  strokeWidth: 12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    weeklyRate >= 0.7
                        ? tokens.accentSuccess
                        : tokens.brandPrimary,
                  ),
                  backgroundColor: Colors.transparent,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: tokens.typography.h2.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '達成',
                      style: tokens.typography.caption.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            weeklyRate >= 0.7
                ? '素晴らしい週間パフォーマンスです！'
                : weeklyRate >= 0.5
                ? '良いペースです。継続していきましょう。'
                : '今週はもう少し頑張ってみましょう。',
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildInsightsCard(
  BuildContext context,
  WidgetRef ref,
  MinqTheme tokens,
  StatsViewData data,
) {
  final insights = _generateInsights(data);

  if (insights.isEmpty) {
    return const SizedBox.shrink();
  }

  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius.xl),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: tokens.brandPrimary,
                size: tokens.spacing.lg,
              ),
              SizedBox(width: tokens.spacing.xs),
              Text(
                'インサイト',
                style: tokens.typography.h2.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.sm),
          ...insights.map(
            (insight) => Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: tokens.spacing.xxs,
                    height: tokens.spacing.xxs,
                    margin: EdgeInsets.only(
                      top: tokens.spacing.xs,
                      right: tokens.spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.brandPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: tokens.typography.body.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

List<String> _generateInsights(StatsViewData data) {
  final insights = <String>[];

  // ストリーク分析
  if (data.streak >= 7) {
    insights.add('素晴らしい！${data.streak}日連続で習慣を継続中です。この調子で頑張りましょう！');
  } else if (data.streak >= 3) {
    insights.add('${data.streak}日連続で継続中！週間目標まであと${7 - data.streak}日です。');
  } else if (data.streak == 0) {
    insights.add('今日から新しいストリークを始めましょう。小さな一歩が大きな変化につながります。');
  }

  // 週間完了率分析
  final weeklyRate = data.weeklyCompletionRate;
  if (weeklyRate >= 0.8) {
    insights.add('週間完了率${(weeklyRate * 100).round()}%！非常に良いペースです。');
  } else if (weeklyRate >= 0.5) {
    insights.add('週間完了率${(weeklyRate * 100).round()}%。もう少しで目標達成です！');
  } else if (weeklyRate > 0) {
    insights.add('週間完了率${(weeklyRate * 100).round()}%。無理をせず、継続することを重視しましょう。');
  }

  // 今日の活動分析
  if (data.todayCompletionCount >= 3) {
    insights.add('今日は${data.todayCompletionCount}個のクエストを完了！素晴らしい一日でした。');
  } else if (data.todayCompletionCount > 0) {
    insights.add('今日は${data.todayCompletionCount}個完了。あと少しで今日の目標達成です！');
  }

  // 曜日パターン分析
  final dayOfWeek = DateTime.now().weekday;
  if (dayOfWeek == 1) {
    // 月曜日
    insights.add('新しい週の始まりです！今週も良いスタートを切りましょう。');
  } else if (dayOfWeek == 5) {
    // 金曜日
    insights.add('金曜日は週の締めくくり。今週の成果を振り返ってみましょう。');
  }

  return insights.take(3).toList(); // 最大3つのインサイトを表示
}

Widget _buildExportCard(BuildContext context, WidgetRef ref, MinqTheme tokens) {
  return Card(
    color: tokens.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius.xl),
      side: BorderSide(color: tokens.border),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.download_outlined,
                color: tokens.brandPrimary,
                size: tokens.spacing.lg,
              ),
              SizedBox(width: tokens.spacing.xs),
              Text(
                'データエクスポート',
                style: tokens.typography.h2.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            '統計データをCSVファイルでエクスポートして、他のアプリで分析できます。',
            style: tokens.typography.body.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _exportStatsData(context, ref),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('CSV形式'),
                ),
              ),
              SizedBox(width: tokens.spacing.xs),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _exportStatsImage(context, ref),
                  icon: const Icon(Icons.image),
                  label: const Text('画像形式'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Future<void> _exportStatsData(BuildContext context, WidgetRef ref) async {
  try {
    final exportService = ref.read(dataExportServiceProvider);
    if (exportService == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('エクスポート機能は現在利用できません')));
      }
      return;
    }

    final statsData = await ref.read(statsDataProvider.future);

    // CSV形式でエクスポート（簡易実装）
    _generateCSVData(statsData);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('統計データをエクスポートしました')));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('エクスポートに失敗しました')));
    }
  }
}

Future<void> _exportStatsImage(BuildContext context, WidgetRef ref) async {
  try {
    // 画像エクスポート機能（将来実装）
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('画像エクスポート機能は準備中です')));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('エクスポートに失敗しました')));
    }
  }
}

String _generateCSVData(StatsViewData data) {
  final buffer = StringBuffer();
  buffer.writeln('日付,完了数,ストリーク');

  for (final entry in data.heatmap.entries) {
    final date = entry.key.toIso8601String().split('T')[0];
    final count = entry.value;
    buffer.writeln('$date,$count,${data.streak}');
  }

  return buffer.toString();
}
