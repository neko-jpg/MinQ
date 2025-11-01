import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// スマート通知設定画面
/// AI通知の設定と分析を表示
class SmartNotificationSettingsScreen extends ConsumerStatefulWidget {
  const SmartNotificationSettingsScreen({super.key});

  @override
  ConsumerState<SmartNotificationSettingsScreen> createState() =>
      _SmartNotificationSettingsScreenState();
}

class _SmartNotificationSettingsScreenState
    extends ConsumerState<SmartNotificationSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
      setState(() {
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
          style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: tokens.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '設定'), Tab(text: '分析'), Tab(text: 'A/Bテスト')],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildSettingsTab(),
                  _buildAnalyticsTab(),
                  _buildABTestTab(),
                ],
              ),
    );
  }

  Widget _buildSettingsTab() {
    final tokens = context.tokens;
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI通知設定
          _buildAINotificationSettings(),
          SizedBox(height: tokens.spacing.lg),
          // 最適時刻設定
          _buildOptimalTimingSettings(),
          SizedBox(height: tokens.spacing.lg),
          // パーソナライゼーション設定
          _buildPersonalizationSettings(),
          SizedBox(height: tokens.spacing.lg),
          // 再エンゲージメント設定
          _buildReEngagementSettings(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return _buildNoDataState('まだ分析データがありません');
  }

  Widget _buildABTestTab() {
    final tokens = context.tokens;
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A/Bテスト管理',
            style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing.md),
          // 実行中のテスト
          _buildActiveTests(),
          SizedBox(height: tokens.spacing.lg),
          // テスト結果
          _buildTestResults(),
          SizedBox(height: tokens.spacing.lg),
          // 新しいテストを作成
          _buildCreateTestSection(),
        ],
      ),
    );
  }

  Widget _buildAINotificationSettings() {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
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
                size: tokens.spacing.lg,
              ),
              SizedBox(width: tokens.spacing.xs),
              Text(
                'AI通知設定',
                style: tokens.typography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
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

  Widget _buildOptimalTimingSettings() {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
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
                size: tokens.spacing.lg,
              ),
              SizedBox(width: tokens.spacing.xs),
              Text(
                '最適時刻設定',
                style: tokens.typography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
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
              items:
                  [1, 2, 3, 4, 5].map((count) {
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

  Widget _buildPersonalizationSettings() {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.purple, size: tokens.spacing.lg),
              SizedBox(width: tokens.spacing.xs),
              Text(
                'パーソナライゼーション',
                style: tokens.typography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
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

  Widget _buildReEngagementSettings() {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.refresh, color: Colors.green, size: tokens.spacing.lg),
              SizedBox(width: tokens.spacing.xs),
              Text(
                '再エンゲージメント',
                style: tokens.typography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
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
              items:
                  [1, 2, 3, 5, 7].map((days) {
                    return DropdownMenuItem(
                      value: days,
                      child: Text('$days日後'),
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

  Widget _buildActiveTests() {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '実行中のテスト',
            style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing.md),
          // モックテスト
          _buildTestItem('メッセージトーン比較', '励まし vs データ重視', '実行中', Colors.green),
          _buildTestItem('送信タイミング最適化', '朝9時 vs 夕方6時', '分析中', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildTestResults() {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '過去のテスト結果',
            style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing.md),
          _buildTestItem('絵文字使用効果', '絵文字あり: 65% vs なし: 45%', '完了', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildTestItem(
    String title,
    String description,
    String status,
    Color statusColor,
  ) {
    final tokens = context.tokens;
    return Container(
      margin: EdgeInsets.only(bottom: tokens.spacing.sm),
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tokens.typography.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  description,
                  style: tokens.typography.caption.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.xs,
              vertical: tokens.spacing.xs,
            ),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(51),
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            child: Text(
              status,
              style: tokens.typography.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTestSection() {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '新しいテストを作成',
            style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing.md),
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

  Widget _buildNoDataState(String message) {
    final tokens = context.tokens;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: tokens.spacing.xl,
            color: tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            message,
            style: tokens.typography.h4.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }

  void _recalculateOptimalTime() {
    // TODO: 最適時刻を再計算
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('最適時刻を再計算中...')));
  }
}
