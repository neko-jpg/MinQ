import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  bool _showHelpBanner = true;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final heatmapAsync = ref.watch(heatmapDataProvider);
    final logsAsync = ref.watch(recentLogsProvider);
    final streakAsync = ref.watch(streakProvider);
    final longestAsync = ref.watch(longestStreakProvider);
    final todayAsync = ref.watch(todayCompletionCountProvider);
    final questsAsync = ref.watch(allQuestsProvider);

    final asyncValues = <AsyncValue<dynamic>>[
      heatmapAsync,
      logsAsync,
      streakAsync,
      longestAsync,
      todayAsync,
      questsAsync,
    ];

    final hasLoading = asyncValues.any((value) => value.isLoading);
    final errorValue = asyncValues.firstWhereOrNull((value) => value.hasError);

    if (hasLoading) {
      return Scaffold(
        backgroundColor: tokens.background,
        appBar: _buildAppBar(tokens),
        body: _StatsSkeleton(tokens: tokens),
      );
    }

    if (errorValue != null) {
      return Scaffold(
        backgroundColor: tokens.background,
        appBar: _buildAppBar(tokens),
        body: Center(
          child: MinqEmptyState(
            icon: Icons.error_outline,
            title: '統計の読み込みに失敗しました',
            message: '${errorValue.error}',
            actionLabel: '再試行',
            onAction: () {
              ref.invalidate(heatmapDataProvider);
              ref.invalidate(recentLogsProvider);
              ref.invalidate(streakProvider);
              ref.invalidate(longestStreakProvider);
              ref.invalidate(todayCompletionCountProvider);
              ref.invalidate(allQuestsProvider);
            },
          ),
        ),
      );
    }

    final heatmapData = heatmapAsync.value ?? <DateTime, int>{};
    final logs = logsAsync.value ?? <QuestLog>[];
    final streak = streakAsync.value ?? 0;
    final longestStreak = longestAsync.value ?? 0;
    final todayCount = todayAsync.value ?? 0;
    final quests = questsAsync.value ?? <Quest>[];

    final hasActivity = heatmapData.isNotEmpty || logs.isNotEmpty;
    final weeklySummaries = _computeWeeklySummaries(logs);
    final categorySummaries = _computeCategorySummaries(logs, quests);
    final comparison = _computeSelfComparison(logs);
    final questLookup = {for (final quest in quests) quest.id: quest};

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: _buildAppBar(tokens),
      body: !hasActivity
          ? Center(
              child: MinqEmptyState(
                icon: Icons.insights_outlined,
                title: 'まだRecordがありません',
                message: 'Recordすると、ストリークやヒートマップで成長が見えるようになります。',
                actionLabel: '最初のRecordをする',
                onAction: () => context.go('/quests'),
              ),
            )
          : ListView(
              padding: EdgeInsets.all(tokens.spacing(5)),
              children: <Widget>[
                if (_showHelpBanner)
                  Card(
                    elevation: 0,
                    color: tokens.brandPrimary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: tokens.cornerLarge(),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.info_outline, color: tokens.brandPrimary),
                      title: Text(
                        '毎日のRecordをヒートマップで振り返り、ストリークを伸ばすモチベーションにしよう。',
                        style: tokens.bodySmall.copyWith(color: tokens.textPrimary),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: tokens.textPrimary),
                        onPressed: () => setState(() => _showHelpBanner = false),
                      ),
                    ),
                  ),
                _buildSummaryRow(tokens, streak, longestStreak, todayCount),
                if (heatmapData.isNotEmpty) ...<Widget>[
                  SizedBox(height: tokens.spacing(6)),
                  _buildHeatmapCard(tokens, heatmapData),
                ],
                if (weeklySummaries.isNotEmpty) ...<Widget>[
                  SizedBox(height: tokens.spacing(6)),
                  _buildWeeklyTrend(tokens, weeklySummaries),
                ],
                if (categorySummaries.isNotEmpty) ...<Widget>[
                  SizedBox(height: tokens.spacing(6)),
                  _buildCategoryBreakdown(tokens, categorySummaries),
                ],
                SizedBox(height: tokens.spacing(6)),
                _buildSelfComparison(tokens, comparison),
                if (logs.isNotEmpty) ...<Widget>[
                  SizedBox(height: tokens.spacing(6)),
                  _buildRecentLogs(tokens, logs.take(5).toList(), questLookup),
                ],
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(MinqTheme tokens) {
    return AppBar(
      title: Text(
        'Progress',
        style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    );
  }

  Widget _buildSummaryRow(
    MinqTheme tokens,
    int streak,
    int longest,
    int todayCount,
  ) {
    final summaryItems = <_SummaryStat>[\
      _SummaryStat('Current streak', '$streak days', Icons.local_fire_department),
      _SummaryStat('Longest streak', '$longest days', Icons.star_outline),
      _SummaryStat('Today', '$todayCount / 3 quests', Icons.task_alt),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: summaryItems
                .map((item) => _SummaryTile(item: item, tokens: tokens))
                .toList(),
          );
        }
        return Row(
          children: summaryItems
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spacing(1.5)),
                    child: _SummaryTile(item: item, tokens: tokens),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildHeatmapCard(
    MinqTheme tokens,
    Map<DateTime, int> heatmapData,
  ) {
    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      shadowColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Activity Heatmap',
                  style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
                ),
                Text('Last 30 days', style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
              ],
            ),
            SizedBox(height: tokens.spacing(4)),
            HeatMap(
              datasets: heatmapData,
              colorMode: ColorMode.opacity,
              showText: false,
              scrollable: true,
              colorsets: <int, Color>{1: tokens.brandPrimary},
              defaultColor: tokens.brandPrimary.withValues(alpha: 0.05),
              borderRadius: 8,
              margin: EdgeInsets.all(tokens.spacing(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTrend(MinqTheme tokens, List<_WeeklySummary> summaries) {
    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Weekly trend',
              style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing(3)),
            ...summaries.map((summary) {
              final ratio = summary.total == 0
                  ? 0.0
                  : (summary.completed / summary.total).clamp(0.0, 1.0);
              return Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing(1.5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          summary.label,
                          style:
                              tokens.bodySmall.copyWith(color: tokens.textMuted),
                        ),
                        Text(
                          '${summary.completed} of ${summary.total}',
                          style:
                              tokens.bodySmall.copyWith(color: tokens.textPrimary),
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacing(1)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(tokens.spacing(1)),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: tokens.spacing(1.5),
                        backgroundColor:
                            tokens.brandPrimary.withValues(alpha: 0.12),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    MinqTheme tokens,
    List<_CategorySummary> categories,
  ) {
    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Category focus',
              style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing(3)),
            ...categories.map((category) {
              final ratio = category.total == 0
                  ? 0.0
                  : (category.completed / category.total).clamp(0.0, 1.0);
              return Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing(1.5)),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            category.label,
                            style: tokens.bodyMedium
                                .copyWith(color: tokens.textPrimary),
                          ),
                          SizedBox(height: tokens.spacing(1)),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(tokens.spacing(1)),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: tokens.spacing(1.5),
                              backgroundColor: tokens.brandPrimary
                                  .withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  tokens.accentSuccess),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: tokens.spacing(3)),
                    Text(
                      '${category.completed}/${category.total}',
                      style:
                          tokens.bodySmall.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfComparison(MinqTheme tokens, _ComparisonSnapshot comparison) {
    final delta = comparison.difference;
    final deltaText = delta == 0
        ? '±0'
        : delta > 0
            ? '+$delta'
            : '$delta';
    final Color deltaColor;
    if (delta > 0) {
      deltaColor = tokens.accentSuccess;
    } else if (delta < 0) {
      deltaColor = Colors.redAccent;
    } else {
      deltaColor = tokens.textMuted;
    }

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Last 7 days vs previous',
              style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing(3)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Last 7 days',
                        style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
                    SizedBox(height: tokens.spacing(1)),
                    Text(
                      '${comparison.current}',
                      style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text('Previous 7 days',
                        style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
                    SizedBox(height: tokens.spacing(1)),
                    Text(
                      '${comparison.previous}',
                      style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: tokens.spacing(3)),
            Row(
              children: <Widget>[
                Icon(
                  delta == 0
                      ? Icons.trending_flat
                      : delta > 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                  color: deltaColor,
                ),
                SizedBox(width: tokens.spacing(1)),
                Text(
                  '$deltaText completions',
                  style: tokens.bodyMedium.copyWith(color: deltaColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLogs(
    MinqTheme tokens,
    List<QuestLog> logs,
    Map<int, Quest> questLookup,
  ) {
    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Recent completions',
              style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing(3)),
            ...logs.map((log) {
              final quest = questLookup[log.questId];
              final label = quest?.title ?? 'Quest #${log.questId}';
              final time = log.ts.toLocal();
              final timeLabel = '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

              return Card(
                elevation: 0,
                margin: EdgeInsets.symmetric(vertical: tokens.spacing(1)),
                color: tokens.background,
                shape: RoundedRectangleBorder(
                    borderRadius: tokens.cornerMedium()),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tokens.brandPrimary.withValues(alpha: 0.12),
                    child: Icon(
                      log.proofType == ProofType.photo
                          ? Icons.photo_camera_outlined
                          : Icons.check_circle_outline,
                      color: tokens.brandPrimary,
                    ),
                  ),
                  title: Text(
                    label,
                    style: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
                  ),
                  subtitle: Text(
                    timeLabel,
                    style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<_WeeklySummary> _computeWeeklySummaries(List<QuestLog> logs) {
    if (logs.isEmpty) {
      return <_WeeklySummary>[];
    }

    final now = DateTime.now().toUtc();
    final startOfWeek = _truncateToWeek(now);
    final summaries = <_WeeklySummary>[];

    for (var i = 0; i < 4; i++) {
      final weekStart = startOfWeek.subtract(Duration(days: 7 * i));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final weeklyLogs = logs.where((log) {
        final ts = log.ts.toUtc();
        return !ts.isBefore(weekStart) && ts.isBefore(weekEnd);
      }).toList();
      if (weeklyLogs.isEmpty) {
        summaries.add(
          _WeeklySummary(
            label:
                '${weekStart.month}/${weekStart.day} – ${weekEnd.subtract(const Duration(days: 1)).month}/${weekEnd.subtract(const Duration(days: 1)).day}',
            completed: 0,
            total: 21,
          ),
        );
      } else {
        summaries.add(
          _WeeklySummary(
            label:
                '${weekStart.month}/${weekStart.day} – ${weekEnd.subtract(const Duration(days: 1)).month}/${weekEnd.subtract(const Duration(days: 1)).day}',
            completed: weeklyLogs.length,
            total: 21,
          ),
        );
      }
    }

    return summaries;
  }

  List<_CategorySummary> _computeCategorySummaries(
    List<QuestLog> logs,
    List<Quest> quests,
  ) {
    if (logs.isEmpty || quests.isEmpty) {
      return <_CategorySummary>[];
    }
    final questLookup = {for (final quest in quests) quest.id: quest};
    final totals = <String, int>{};
    final completions = <String, int>{};

    for (final quest in quests) {
      totals.update(quest.category, (value) => value + 1, ifAbsent: () => 1);
    }

    for (final log in logs) {
      final quest = questLookup[log.questId];
      final category = quest?.category ?? 'その他';
      completions.update(category, (value) => value + 1, ifAbsent: () => 1);
    }

    return completions.entries
        .map((entry) => _CategorySummary(
              label: entry.key,
              completed: entry.value,
              total: totals[entry.key] ?? entry.value,
            ))
        .toList()
      ..sort((a, b) => b.completed.compareTo(a.completed));
  }

  _ComparisonSnapshot _computeSelfComparison(List<QuestLog> logs) {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final currentWindowStart = today.subtract(const Duration(days: 6));
    final previousWindowStart = currentWindowStart.subtract(const Duration(days: 7));

    final current = logs
        .where((log) {
          final ts = log.ts.toUtc();
          return !ts.isBefore(currentWindowStart) && !ts.isAfter(today.add(const Duration(days: 1)));
        })
        .length;
    final previous = logs
        .where((log) {
          final ts = log.ts.toUtc();
          return !ts.isBefore(previousWindowStart) && ts.isBefore(currentWindowStart);
        })
        .length;

    return _ComparisonSnapshot(
      current: current,
      previous: previous,
      difference: current - previous,
    );
  }

  DateTime _truncateToWeek(DateTime date) {
    final weekday = date.weekday % 7; // 0 = Sunday
    return DateTime.utc(date.year, date.month, date.day).subtract(Duration(days: weekday));
  }
}

class _SummaryStat {
  const _SummaryStat(this.title, this.value, this.icon);

  final String title;
  final String value;
  final IconData icon;
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.item, required this.tokens});

  final _SummaryStat item;
  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: tokens.spacing(1.5)),
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: tokens.spacing(4),
          horizontal: tokens.spacing(4),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: tokens.brandPrimary.withValues(alpha: 0.12),
              child: Icon(item.icon, color: tokens.brandPrimary),
            ),
            SizedBox(width: tokens.spacing(3)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                ),
                SizedBox(height: tokens.spacing(1)),
                Text(
                  item.value,
                  style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklySummary {
  const _WeeklySummary({
    required this.label,
    required this.completed,
    required this.total,
  });

  final String label;
  final int completed;
  final int total;
}

class _CategorySummary {
  const _CategorySummary({
    required this.label,
    required this.completed,
    required this.total,
  });

  final String label;
  final int completed;
  final int total;
}

class _ComparisonSnapshot {
  const _ComparisonSnapshot({
    required this.current,
    required this.previous,
    required this.difference,
  });

  final int current;
  final int previous;
  final int difference;
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(tokens.spacing(5)),
      children: <Widget>[
        MinqSkeleton(
          height: tokens.spacing(12),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(4)),
        MinqSkeleton(
          height: tokens.spacing(24),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(4)),
        MinqSkeleton(
          height: tokens.spacing(30),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(4)),
        const MinqSkeletonLine(width: 160, height: 20),
        SizedBox(height: tokens.spacing(3)),
        const MinqSkeletonList(itemCount: 3, itemHeight: 64),
      ],
    );
  }
}
