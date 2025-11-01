import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:minq/core/gamification/xp_system.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/gamification/xp_transaction.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/charts/xp_trend_chart.dart';

/// XP履歴と統計表示画面（要件34）
class XPHistoryScreen extends ConsumerStatefulWidget {
  const XPHistoryScreen({super.key});

  @override
  ConsumerState<XPHistoryScreen> createState() => _XPHistoryScreenState();
}

class _XPHistoryScreenState extends ConsumerState<XPHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(uidProvider);

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.xpHistory)),
        body: Center(child: Text(l10n.pleaseLogin)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.xpHistory),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: l10n.history), Tab(text: l10n.statistics)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(uid, tokens, l10n),
          _buildStatisticsTab(uid, tokens, l10n),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(String uid, MinqTheme tokens, AppLocalizations l10n) {
    final xpSystem = ref.watch(xpSystemProvider);

    return FutureBuilder<List<XPTransaction>>(
      future: xpSystem.getXPHistory(userId: uid, limit: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: tokens.error),
                SizedBox(height: tokens.spacing.md),
                Text(
                  l10n.errorLoadingData,
                  style: tokens.typography.body.copyWith(color: tokens.error),
                ),
              ],
            ),
          );
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: tokens.textMuted),
                SizedBox(height: tokens.spacing.md),
                Text(
                  l10n.noXPHistory,
                  style: tokens.typography.body.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(tokens.spacing.md),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionCard(transaction, tokens, l10n);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(
    XPTransaction transaction,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    final dateFormat = DateFormat('MM/dd HH:mm');

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing.sm),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Row(
          children: [
            // XPソースアイコン
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getSourceColor(transaction.source).withOpacity(0.1),
                borderRadius: BorderRadius.circular(tokens.radius.md),
              ),
              child: Icon(
                _getSourceIcon(transaction.source),
                color: _getSourceColor(transaction.source),
                size: 24,
              ),
            ),

            SizedBox(width: tokens.spacing.md),

            // 詳細情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.reason,
                    style: tokens.typography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    _getSourceDisplayName(transaction.source, l10n),
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    dateFormat.format(transaction.createdAt),
                    style: tokens.typography.caption.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // XP量
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${transaction.xpAmount}',
                  style: tokens.typography.h4.copyWith(
                    color: tokens.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'XP',
                  style: tokens.typography.caption.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
                if (transaction.multiplier != null &&
                    transaction.multiplier! > 1.0) ...[
                  SizedBox(height: tokens.spacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                    ),
                    child: Text(
                      '×${transaction.multiplier!.toStringAsFixed(1)}',
                      style: tokens.typography.caption.copyWith(
                        color: tokens.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(
    String uid,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    final xpSystem = ref.watch(xpSystemProvider);

    return FutureBuilder<XPAnalytics>(
      future: xpSystem.getDetailedXPAnalytics(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: tokens.error),
                SizedBox(height: tokens.spacing.md),
                Text(
                  l10n.errorLoadingData,
                  style: tokens.typography.body.copyWith(color: tokens.error),
                ),
              ],
            ),
          );
        }

        final analytics = snapshot.data!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 総合統計
              _buildOverallStatsEnhanced(analytics, tokens, l10n),

              SizedBox(height: tokens.spacing.lg),

              // 成長トレンド
              _buildGrowthTrendCard(analytics, tokens, l10n),

              SizedBox(height: tokens.spacing.lg),

              // XPトレンドチャート
              _buildXPTrendChart(uid, tokens, l10n),

              SizedBox(height: tokens.spacing.lg),

              // 時間帯・曜日別分析
              _buildTimeAnalysis(analytics, tokens, l10n),

              SizedBox(height: tokens.spacing.lg),

              // ソース別統計（拡張版）
              _buildSourceStatsEnhanced(analytics, tokens, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverallStats(
    Map<String, dynamic> stats,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.overallStatistics,
              style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n.totalXP,
                    '${stats['totalXP'] ?? 0}',
                    Icons.stars,
                    tokens.brandPrimary,
                    tokens,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    l10n.weeklyXP,
                    '${stats['weeklyXP'] ?? 0}',
                    Icons.calendar_view_week,
                    tokens.success,
                    tokens,
                  ),
                ),
              ],
            ),

            SizedBox(height: tokens.spacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n.monthlyXP,
                    '${stats['monthlyXP'] ?? 0}',
                    Icons.calendar_month,
                    tokens.info,
                    tokens,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    l10n.averageDaily,
                    '${(stats['averageXPPerDay'] ?? 0.0).toStringAsFixed(1)}',
                    Icons.trending_up,
                    tokens.warning,
                    tokens,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatsEnhanced(
    XPAnalytics analytics,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.overallStatistics,
              style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing.md),

            // 第1行
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n.totalXP,
                    '${analytics.totalXP}',
                    Icons.stars,
                    tokens.brandPrimary,
                    tokens,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '今日のXP',
                    '${analytics.todayXP}',
                    Icons.today,
                    tokens.success,
                    tokens,
                  ),
                ),
              ],
            ),

            SizedBox(height: tokens.spacing.md),

            // 第2行
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n.weeklyXP,
                    '${analytics.weeklyXP}',
                    Icons.calendar_view_week,
                    tokens.info,
                    tokens,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    l10n.monthlyXP,
                    '${analytics.monthlyXP}',
                    Icons.calendar_month,
                    tokens.warning,
                    tokens,
                  ),
                ),
              ],
            ),

            SizedBox(height: tokens.spacing.md),

            // 第3行
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n.averageDaily,
                    analytics.averageXPPerDay.toStringAsFixed(1),
                    Icons.trending_up,
                    Colors.purple,
                    tokens,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '平均/回',
                    analytics.averageXPPerTransaction.toStringAsFixed(1),
                    Icons.analytics,
                    Colors.teal,
                    tokens,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthTrendCard(
    XPAnalytics analytics,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    final trendIcon = switch (analytics.growthTrend) {
      GrowthTrend.increasing => Icons.trending_up,
      GrowthTrend.stable => Icons.trending_flat,
      GrowthTrend.decreasing => Icons.trending_down,
    };

    final trendColor = switch (analytics.growthTrend) {
      GrowthTrend.increasing => tokens.success,
      GrowthTrend.stable => tokens.warning,
      GrowthTrend.decreasing => tokens.error,
    };

    final trendText = switch (analytics.growthTrend) {
      GrowthTrend.increasing => '成長中',
      GrowthTrend.stable => '安定',
      GrowthTrend.decreasing => '減少傾向',
    };

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '成長トレンド',
              style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing.md),

            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(tokens.spacing.sm),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(tokens.radius.md),
                  ),
                  child: Icon(trendIcon, color: trendColor, size: 32),
                ),

                SizedBox(width: tokens.spacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trendText,
                        style: tokens.typography.h4.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: tokens.spacing.xs),
                      Text(
                        '最近7日間と前の7日間の比較',
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ストリークボーナス',
                      style: tokens.typography.caption.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    Text(
                      '${analytics.totalStreakBonus} XP',
                      style: tokens.typography.body.copyWith(
                        color: tokens.brandPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAnalysis(
    XPAnalytics analytics,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    final weekdays = ['月', '火', '水', '木', '金', '土', '日'];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '活動パターン分析',
              style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '最も活発な時間',
                    '${analytics.mostActiveHour}:00',
                    Icons.access_time,
                    tokens.brandPrimary,
                    tokens,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '最も活発な曜日',
                    weekdays[analytics.mostActiveWeekday - 1],
                    Icons.calendar_today,
                    tokens.success,
                    tokens,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceStatsEnhanced(
    XPAnalytics analytics,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    if (analytics.sourceAnalysis.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedSources =
        analytics.sourceAnalysis.entries.toList()
          ..sort((a, b) => b.value.totalXP.compareTo(a.value.totalXP));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'XPソース分析',
              style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing.md),

            ...sortedSources.take(5).map((entry) {
              final source = entry.key;
              final sourceData = entry.value;
              final percentage = (sourceData.totalXP / analytics.totalXP) * 100;

              return Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing.sm),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getSourceIcon(source),
                          color: _getSourceColor(source),
                          size: 20,
                        ),
                        SizedBox(width: tokens.spacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getSourceDisplayName(source, l10n),
                                style: tokens.typography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${sourceData.transactionCount}回 • 平均${sourceData.averageXP.toStringAsFixed(1)}XP',
                                style: tokens.typography.caption.copyWith(
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${sourceData.totalXP} XP',
                              style: tokens.typography.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: tokens.typography.caption.copyWith(
                                color: tokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: tokens.border,
                      valueColor: AlwaysStoppedAnimation(
                        _getSourceColor(source),
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

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    MinqTheme tokens,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: tokens.spacing.sm),
          Text(
            value,
            style: tokens.typography.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: tokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildXPTrendChart(
    String uid,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.xpTrend,
              style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing.md),
            SizedBox(height: 200, child: XPTrendChart(userId: uid)),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceStats(
    Map<String, dynamic> stats,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    final topSources = stats['topSources'] as Map<String, int>? ?? {};

    if (topSources.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.xpSources,
              style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing.md),

            ...topSources.entries.take(5).map((entry) {
              final source = XPSource.values.firstWhere(
                (s) => s.name == entry.key,
                orElse: () => XPSource.questComplete,
              );
              final percentage =
                  (entry.value / (stats['totalXP'] as int)) * 100;

              return Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing.sm),
                child: Row(
                  children: [
                    Icon(
                      _getSourceIcon(source),
                      color: _getSourceColor(source),
                      size: 20,
                    ),
                    SizedBox(width: tokens.spacing.sm),
                    Expanded(
                      child: Text(
                        _getSourceDisplayName(source, l10n),
                        style: tokens.typography.body,
                      ),
                    ),
                    Text(
                      '${entry.value} XP (${percentage.toStringAsFixed(1)}%)',
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.textSecondary,
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

  IconData _getSourceIcon(XPSource source) {
    switch (source) {
      case XPSource.questComplete:
        return Icons.task_alt;
      case XPSource.miniQuestComplete:
        return Icons.check_circle_outline;
      case XPSource.streakMilestone:
        return Icons.local_fire_department;
      case XPSource.challengeComplete:
        return Icons.emoji_events;
      case XPSource.weeklyGoal:
        return Icons.calendar_view_week;
      case XPSource.monthlyGoal:
        return Icons.calendar_month;
      case XPSource.earlyCompletion:
        return Icons.schedule;
      case XPSource.perfectCompletion:
        return Icons.star;
      case XPSource.comebackBonus:
        return Icons.refresh;
      case XPSource.weekendActivity:
        return Icons.weekend;
      case XPSource.specialEvent:
        return Icons.celebration;
    }
  }

  Color _getSourceColor(XPSource source) {
    final tokens = context.tokens;
    switch (source) {
      case XPSource.questComplete:
        return tokens.brandPrimary;
      case XPSource.miniQuestComplete:
        return tokens.success;
      case XPSource.streakMilestone:
        return tokens.warning;
      case XPSource.challengeComplete:
        return tokens.info;
      case XPSource.weeklyGoal:
        return Colors.purple;
      case XPSource.monthlyGoal:
        return Colors.indigo;
      case XPSource.earlyCompletion:
        return Colors.teal;
      case XPSource.perfectCompletion:
        return Colors.amber;
      case XPSource.comebackBonus:
        return Colors.green;
      case XPSource.weekendActivity:
        return Colors.orange;
      case XPSource.specialEvent:
        return Colors.pink;
    }
  }

  String _getSourceDisplayName(XPSource source, AppLocalizations l10n) {
    switch (source) {
      case XPSource.questComplete:
        return l10n.questComplete;
      case XPSource.miniQuestComplete:
        return l10n.miniQuestComplete;
      case XPSource.streakMilestone:
        return l10n.streakMilestone;
      case XPSource.challengeComplete:
        return l10n.challengeComplete;
      case XPSource.weeklyGoal:
        return l10n.weeklyGoal;
      case XPSource.monthlyGoal:
        return l10n.monthlyGoal;
      case XPSource.earlyCompletion:
        return l10n.earlyCompletion;
      case XPSource.perfectCompletion:
        return l10n.perfectCompletion;
      case XPSource.comebackBonus:
        return l10n.comebackBonus;
      case XPSource.weekendActivity:
        return l10n.weekendActivity;
      case XPSource.specialEvent:
        return l10n.specialEvent;
    }
  }
}
