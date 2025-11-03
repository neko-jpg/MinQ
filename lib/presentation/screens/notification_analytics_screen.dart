import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/l10n/l10n.dart';
import 'package:minq/presentation/providers/notification_providers.dart';
import 'package:minq/presentation/widgets/notification/category_performance_chart.dart';
import 'package:minq/presentation/widgets/notification/notification_metrics_card.dart';
import 'package:minq/presentation/widgets/notification/optimal_timing_chart.dart';

/// 通知分析画面
class NotificationAnalyticsScreen extends ConsumerStatefulWidget {
  const NotificationAnalyticsScreen({super.key});

  @override
  ConsumerState<NotificationAnalyticsScreen> createState() =>
      _NotificationAnalyticsScreenState();
}

class _NotificationAnalyticsScreenState
    extends ConsumerState<NotificationAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final String _selectedUserId = 'current_user'; // 実際の実装では現在のユーザーIDを使用

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationAnalytics),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _showDateRangePicker(context, l10n),
            tooltip: 'Select Date Range',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context, l10n),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        const Icon(Icons.download),
                        const SizedBox(width: 8),
                        Text(l10n.exportData),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        const Icon(Icons.refresh),
                        const SizedBox(width: 8),
                        Text(l10n.retry),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Timing', icon: Icon(Icons.schedule)),
            Tab(text: 'Categories', icon: Icon(Icons.category)),
            Tab(text: 'Insights', icon: Icon(Icons.psychology)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context, l10n),
          _buildTimingTab(context, l10n),
          _buildCategoriesTab(context, l10n),
          _buildInsightsTab(context, l10n),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, AppLocalizations l10n) {
    final allMetrics = ref.watch(
      allCategoryMetricsProvider(
        AllMetricsParams(
          userId: _selectedUserId,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );

    return allMetrics.when(
      data:
          (metrics) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 期間表示
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Period: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 全体統計
                _buildOverallStats(context, metrics, l10n),

                const SizedBox(height: 16),

                // カテゴリ別メトリクス
                Text(
                  'Category Performance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),

                ...metrics.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NotificationMetricsCard(
                      category: entry.key,
                      metrics: entry.value,
                    ),
                  );
                }),
              ],
            ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load analytics data',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      () => ref.refresh(
                        allCategoryMetricsProvider(
                          AllMetricsParams(
                            userId: _selectedUserId,
                            startDate: _startDate,
                            endDate: _endDate,
                          ),
                        ),
                      ),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildOverallStats(
    BuildContext context,
    Map<NotificationCategory, NotificationMetrics> metrics,
    AppLocalizations l10n,
  ) {
    final totalSent = metrics.values.fold(0, (sum, m) => sum + m.totalSent);
    final totalOpened = metrics.values.fold(0, (sum, m) => sum + m.totalOpened);
    final totalConverted = metrics.values.fold(
      0,
      (sum, m) => sum + m.totalConverted,
    );

    final overallOpenRate = totalSent > 0 ? (totalOpened / totalSent) : 0.0;
    final overallConversionRate =
        totalOpened > 0 ? (totalConverted / totalOpened) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Performance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Sent',
                    totalSent.toString(),
                    Icons.send,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Opened',
                    totalOpened.toString(),
                    Icons.open_in_new,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Open Rate',
                    '${(overallOpenRate * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Conversion Rate',
                    '${(overallConversionRate * 100).toStringAsFixed(1)}%',
                    Icons.star,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimingTab(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Optimal Timing Analysis',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // 各カテゴリの最適タイミング分析
          ...NotificationCategory.values.map((category) {
            final analysis = ref.watch(
              optimalTimingAnalysisProvider(
                OptimalTimingParams(
                  userId: _selectedUserId,
                  category: category,
                ),
              ),
            );

            return analysis.when(
              data:
                  (data) =>
                      data != null
                          ? Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: OptimalTimingChart(
                              category: category,
                              analysis: data,
                            ),
                          )
                          : const SizedBox.shrink(),
              loading:
                  () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              error: (error, stack) => const SizedBox.shrink(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(BuildContext context, AppLocalizations l10n) {
    final allMetrics = ref.watch(
      allCategoryMetricsProvider(
        AllMetricsParams(
          userId: _selectedUserId,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );

    return allMetrics.when(
      data:
          (metrics) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Performance Comparison',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                CategoryPerformanceChart(metrics: metrics),

                const SizedBox(height: 24),

                Text(
                  'Detailed Category Metrics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                ...metrics.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NotificationMetricsCard(
                      category: entry.key,
                      metrics: entry.value,
                      showDetails: true,
                    ),
                  );
                }),
              ],
            ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              Center(child: Text('Error loading category data: $error')),
    );
  }

  Widget _buildInsightsTab(BuildContext context, AppLocalizations l10n) {
    final behaviorAnalysis = ref.watch(
      behaviorPatternAnalysisProvider(_selectedUserId),
    );

    return behaviorAnalysis.when(
      data:
          (analysis) =>
              analysis != null
                  ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Behavior Insights',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        _buildInsightCard(
                          context,
                          'Active Hours',
                          analysis.activeHours.join(', '),
                          Icons.schedule,
                          'Times when you are most active in the app',
                        ),

                        const SizedBox(height: 12),

                        _buildInsightCard(
                          context,
                          'Preferred Categories',
                          analysis.preferredCategories.join(', '),
                          Icons.favorite,
                          'Notification types you engage with most',
                        ),

                        const SizedBox(height: 12),

                        _buildInsightCard(
                          context,
                          'Engagement Trend',
                          '${(analysis.engagementTrend * 100).toStringAsFixed(1)}%',
                          Icons.trending_up,
                          'Overall engagement with notifications',
                        ),

                        const SizedBox(height: 12),

                        _buildInsightCard(
                          context,
                          'Responsiveness Score',
                          '${(analysis.responsiveness * 100).toStringAsFixed(1)}%',
                          Icons.speed,
                          'How quickly you respond to notifications',
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Recommendations',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        _buildRecommendations(context, analysis),
                      ],
                    ),
                  )
                  : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Not enough data for insights',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use the app for a few more days to see personalized insights',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              Center(child: Text('Error loading insights: $error')),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    String description,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(
    BuildContext context,
    BehaviorPatternAnalysis analysis,
  ) {
    final recommendations = <String>[];

    if (analysis.engagementTrend < 0.3) {
      recommendations.add(
        'Consider reducing notification frequency to avoid fatigue',
      );
    }

    if (analysis.responsiveness < 0.5) {
      recommendations.add('Try enabling smart notifications for better timing');
    }

    if (analysis.activeHours.length < 3) {
      recommendations.add(
        'Notifications during ${analysis.activeHours.join(', ')} might be most effective',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'Your notification engagement is excellent! Keep it up.',
      );
    }

    return Column(
      children:
          recommendations.map((recommendation) {
            return Card(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha((255 * 0.3).round()),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  void _showDateRangePicker(BuildContext context, AppLocalizations l10n) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _handleMenuAction(
    String action,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    switch (action) {
      case 'export':
        _exportAnalyticsData(context, l10n);
        break;
      case 'refresh':
        _refreshData();
        break;
    }
  }

  void _exportAnalyticsData(BuildContext context, AppLocalizations l10n) {
    // 実際の実装では分析データをエクスポート
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.dataExported)));
  }

  void _refreshData() {
    ref.invalidate(allCategoryMetricsProvider);
    ref.invalidate(behaviorPatternAnalysisProvider);
    for (final _ in NotificationCategory.values) {
      ref.invalidate(optimalTimingAnalysisProvider);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
