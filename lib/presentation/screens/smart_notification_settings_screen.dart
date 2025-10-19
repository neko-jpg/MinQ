import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:minq/core/notifications/smart_notification_service.dart';
import 'package:minq/core/notifications/re_engagement_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// スマート通知設定画面
/// AI通知の設定と分析を表示
class SmartNotificationSettingsScreen extends ConsumerStatefulWidget {
  const SmartNotificationSettingsScreen({super.key});

  @override
  ConsumerState<SmartNotificationSettingsScreen> createState() => _SmartNotificationSettingsScreenState();
}

class _SmartNotificationSettingsScreenState extends ConsumerState<SmartNotificationSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  NotificationAnalytics? _analytics;
  ReEngagementAnalytics? _reEngagementAnalytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    try {
      final smartService = ref.read(smartNotificationServiceProvider);
      final reEngagementService = ref.read(reEngagementServiceProvider);
      
      final analytics = await smartService.getNotificationAnalytics(uid);
      final reEngagementAnalytics = await reEngagementService.analyzeReEngagementEffectiveness();
      
      setState(() {
        _analytics = analytics;
        _reEngagementAnalytics = reEngagementAnalytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'スマート通知設定',
          style: tokens.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: tokens.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '設定'),
            Tab(text: '分析'),
            Tab(text: 'A/Bテスト'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSettingsTab(tokens),
                _buildAnalyticsTab(tokens),
                _buildABTestTab(tokens),
              ],
            ),
    );
  }

  Widget _buildSettingsTab(MinqTokens tokens) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI通知設定
          _buildAINotificationSettings(tokens),
          
          SizedBox(height: tokens.spacing(6)),
          
          // 最適時刻設定
          _buildOptimalTimingSettings(tokens),
          
          SizedBox(height: tokens.spacing(6)),
          
          // パーソナライゼーション設定
          _buildPersonalizationSettings(tokens),
          
          SizedBox(height: tokens.spacing(6)),
          
          // 再エンゲージメント設定
          _buildReEngagementSettings(tokens),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(MinqTokens tokens) {
    if (_analytics == null) {
      return _buildNoDataState(tokens, 'まだ分析データがありません');
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 通知効果サマリー
          _buildNotificationSummary(tokens, _analytics!),
          
          SizedBox(height: tokens.spacing(6)),
          
          // 開封率グラフ
          _buildOpenRateChart(tokens, _analytics!),
          
          SizedBox(height: tokens.spacing(6)),
          
          // 再エンゲージメント分析
          if (_reEngagementAnalytics != null)
            _buildReEngagementAnalysis(tokens, _reEngagementAnalytics!),
        ],
      ),
    );
  }

  Widget _buildABTestTab(MinqTokens tokens) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A/Bテスト管理',
            style: tokens.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          // 実行中のテスト
          _buildActiveTests(tokens),
          
          SizedBox(height: tokens.spacing(6)),
          
          // テスト結果
          _buildTestResults(tokens),
          
          SizedBox(height: tokens.spacing(6)),
          
          // 新しいテストを作成
          _buildCreateTestSection(tokens),
        ],
      ),
    );
  }

  Widget _buildAINotificationSettings(MinqTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: tokens.brandPrimary,
                size: tokens.spacing(6),
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(
                'AI通知設定',
                style: tokens.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          SwitchListTile(
            title: const Text('AI生成メッセージ'),
            subtitle: const Text('AIがパーソナライズされたメッセージを生成'),
            value: true, // TODO: 実際の設定値
            onChanged: (value) {
              // TODO: 設定を保存
            },
          ),
          
          SwitchListTile(
            title: const Text('失敗予測通知'),
            subtitle: const Text('習慣失敗のリスクが高い時に警告'),
            value: true, // TODO: 実際の設定値
            onChanged: (value) {
              // TODO: 設定を保存
            },
          ),
          
          SwitchListTile(
            title: const Text('励まし通知'),
            subtitle: const Text('成果に基づいて励ましメッセージを送信'),
            value: true, // TODO: 実際の設定値
            onChanged: (value) {
              // TODO: 設定を保存
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptimalTimingSettings(MinqTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.orange,
                size: tokens.spacing(6),
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(
                '最適時刻設定',
                style: tokens.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          SwitchListTile(
            title: const Text('自動最適化'),
            subtitle: const Text('AIがあなたの行動パターンから最適時刻を計算'),
            value: true, // TODO: 実際の設定値
            onChanged: (value) {
              // TODO: 設定を保存
            },
          ),
          
          ListTile(
            title: const Text('現在の最適時刻'),
            subtitle: const Text('朝 9:15（AI計算結果）'),
            trailing: TextButton(
              onPressed: () {
                // TODO: 最適時刻を再計算
                _recalculateOptimalTime();
              },
              child: const Text('再計算'),
            ),
          ),
          
          ListTile(
            title: const Text('通知頻度'),
            subtitle: const Text('1日最大3回'),
            trailing: DropdownButton<int>(
              value: 3,
              items: [1, 2, 3, 4, 5].map((count) {
                return DropdownMenuItem(
                  value: count,
                  child: Text('$count回'),
                );
              }).toList(),
              onChanged: (value) {
                // TODO: 頻度設定を保存
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizationSettings(MinqTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.purple,
                size: tokens.spacing(6),
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(
                'パーソナライゼーション',
                style: tokens.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          ListTile(
            title: const Text('メッセージトーン'),
            subtitle: const Text('励まし重視'),
            trailing: DropdownButton<String>(
              value: 'encouraging',
              items: const [
                DropdownMenuItem(value: 'encouraging', child: Text('励まし重視')),
                DropdownMenuItem(value: 'data_driven', child: Text('データ重視')),
                DropdownMenuItem(value: 'casual', child: Text('カジュアル')),
                DropdownMenuItem(value: 'formal', child: Text('フォーマル')),
              ],
              onChanged: (value) {
                // TODO: トーン設定を保存
              },
            ),
          ),
          
          SwitchListTile(
            title: const Text('絵文字使用'),
            subtitle: const Text('メッセージに絵文字を含める'),
            value: true, // TODO: 実際の設定値
            onChanged: (value) {
              // TODO: 設定を保存
            },
          ),
          
          SwitchListTile(
            title: const Text('名前呼びかけ'),
            subtitle: const Text('メッセージにあなたの名前を含める'),
            value: true, // TODO: 実際の設定値
            onChanged: (value) {
              // TODO: 設定を保存
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReEngagementSettings(MinqTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.refresh,
                color: Colors.green,
                size: tokens.spacing(6),
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(
                '再エンゲージメント',
                style: tokens.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          SwitchListTile(
            title: const Text('自動再エンゲージメント'),
            subtitle: const Text('非アクティブ時に自動で復帰を促す'),
            value: true, // TODO: 実際の設定値
            onChanged: (value) {
              // TODO: 設定を保存
            },
          ),
          
          ListTile(
            title: const Text('再エンゲージメント開始'),
            subtitle: const Text('2日間非アクティブ後'),
            trailing: DropdownButton<int>(
              value: 2,
              items: [1, 2, 3, 5, 7].map((days) {
                return DropdownMenuItem(
                  value: days,
                  child: Text('${days}日後'),
                );
              }).toList(),
              onChanged: (value) {
                // TODO: 設定を保存
              },
            ),
          ),
          
          ListTile(
            title: const Text('段階的アプローチ'),
            subtitle: const Text('優しい → 励まし → 価値提案'),
            trailing: const Icon(Icons.info_outline),
            onTap: () {
              // TODO: 詳細説明を表示
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSummary(MinqTokens tokens, NotificationAnalytics analytics) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '通知効果サマリー',
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  tokens,
                  '送信数',
                  '${analytics.totalSent}',
                  Icons.send,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  tokens,
                  '開封数',
                  '${analytics.totalOpened}',
                  Icons.mark_email_read,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  tokens,
                  '開封率',
                  '${(analytics.openRate * 100).toInt()}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  tokens,
                  'アクション',
                  '${analytics.totalActionTaken}',
                  Icons.touch_app,
                  Colors.purple,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  tokens,
                  'アクション率',
                  '${(analytics.actionRate * 100).toInt()}%',
                  Icons.analytics,
                  Colors.red,
                ),
              ),
              Expanded(
                child: Container(), // 空のスペース
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    MinqTokens tokens,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(3)),
      margin: EdgeInsets.all(tokens.spacing(1)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: tokens.cornerMedium(),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: tokens.spacing(6),
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            value,
            style: tokens.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing(1)),
          Text(
            label,
            style: tokens.bodySmall.copyWith(
              color: tokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOpenRateChart(MinqTokens tokens, NotificationAnalytics analytics) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '開封率推移',
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          SizedBox(
            height: tokens.spacing(60),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value * 100).toInt()}%',
                          style: tokens.bodySmall,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['月', '火', '水', '木', '金', '土', '日'];
                        return Text(
                          days[value.toInt() % 7],
                          style: tokens.bodySmall,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateMockChartData(),
                    isCurved: true,
                    color: tokens.brandPrimary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReEngagementAnalysis(MinqTokens tokens, ReEngagementAnalytics analytics) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '再エンゲージメント分析',
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  tokens,
                  '試行回数',
                  '${analytics.totalAttempts}',
                  Icons.send,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  tokens,
                  '復帰数',
                  '${analytics.estimatedReturns}',
                  Icons.person_add,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  tokens,
                  '復帰率',
                  '${(analytics.returnRate * 100).toInt()}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTests(MinqTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '実行中のテスト',
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          // モックテスト
          _buildTestItem(
            tokens,
            'メッセージトーン比較',
            '励まし vs データ重視',
            '実行中',
            Colors.green,
          ),
          
          _buildTestItem(
            tokens,
            '送信タイミング最適化',
            '朝9時 vs 夕方6時',
            '分析中',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults(MinqTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '過去のテスト結果',
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          _buildTestItem(
            tokens,
            '絵文字使用効果',
            '絵文字あり: 65% vs なし: 45%',
            '完了',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildTestItem(
    MinqTokens tokens,
    String title,
    String description,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: tokens.spacing(3)),
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: tokens.cornerMedium(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tokens.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing(1)),
                Text(
                  description,
                  style: tokens.bodySmall.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing(2),
              vertical: tokens.spacing(1),
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: tokens.cornerSmall(),
            ),
            child: Text(
              status,
              style: tokens.bodySmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTestSection(MinqTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '新しいテストを作成',
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          ElevatedButton.icon(
            onPressed: () {
              // TODO: テスト作成画面に遷移
            },
            icon: const Icon(Icons.add),
            label: const Text('A/Bテストを作成'),
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.brandPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(MinqTokens tokens, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: tokens.spacing(20),
            color: tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing(4)),
          Text(
            message,
            style: tokens.titleMedium.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateMockChartData() {
    // モックデータ（実際は過去7日間の開封率データ）
    return [
      const FlSpot(0, 0.6),
      const FlSpot(1, 0.65),
      const FlSpot(2, 0.7),
      const FlSpot(3, 0.68),
      const FlSpot(4, 0.72),
      const FlSpot(5, 0.75),
      const FlSpot(6, 0.78),
    ];
  }

  void _recalculateOptimalTime() {
    // TODO: 最適時刻を再計算
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('最適時刻を再計算中...')),
    );
  }
}