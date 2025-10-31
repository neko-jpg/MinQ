import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/social/pair_system.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/pair/pair_connection.dart';
import 'package:minq/domain/pair/progress_share.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/charts/completion_trend_chart.dart';
import 'package:minq/presentation/widgets/polished_buttons.dart';

/// ペアダッシュボード画面
class PairDashboardScreen extends ConsumerStatefulWidget {
  final String pairId;

  const PairDashboardScreen({
    super.key,
    required this.pairId,
  });

  @override
  ConsumerState<PairDashboardScreen> createState() => _PairDashboardScreenState();
}

class _PairDashboardScreenState extends ConsumerState<PairDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  PairConnection? _pairConnection;
  UserComparisonData? _comparisonData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPairData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPairData() async {
    final pairSystem = ref.read(pairSystemProvider);
    final userId = ref.read(uidProvider);
    
    if (userId == null) return;

    try {
      final connection = await pairSystem.getConnection(widget.pairId);
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      final comparison = await pairSystem.getUserComparison(
        pairId: widget.pairId,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _pairConnection = connection;
        _comparisonData = comparison;
      });
    } catch (e) {
      // エラーハンドリング
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'ペアダッシュボード',
          style: tokens.typography.h4.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: tokens.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chat, color: tokens.primary),
            onPressed: () => context.push('/pair/${widget.pairId}/chat'),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: tokens.textPrimary),
            onPressed: () => _showPairSettings(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: tokens.primary,
          unselectedLabelColor: tokens.textSecondary,
          indicatorColor: tokens.primary,
          tabs: const [
            Tab(text: '概要'),
            Tab(text: '比較'),
            Tab(text: '進捗'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(tokens),
          _buildComparisonTab(tokens),
          _buildProgressTab(tokens),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(MinqTheme tokens) {
    if (_pairConnection == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final connection = _pairConnection!;
    final statistics = connection.statistics;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ペア情報カード
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(tokens.spacing.lg),
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
                    Container(
                      padding: EdgeInsets.all(tokens.spacing.sm),
                      decoration: BoxDecoration(
                        color: tokens.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(tokens.radius.md),
                      ),
                      child: Icon(
                        Icons.group,
                        color: tokens.primary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: tokens.spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ペア情報',
                            style: tokens.typography.h4.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'カテゴリ: ${_getCategoryName(connection.category)}',
                            style: tokens.typography.body.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.sm,
                        vertical: tokens.spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(tokens.radius.sm),
                      ),
                      child: Text(
                        'アクティブ',
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacing.lg),
                Text(
                  '開始日: ${_formatDate(connection.createdAt)}',
                  style: tokens.typography.body.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  '継続日数: ${DateTime.now().difference(connection.createdAt).inDays + 1}日',
                  style: tokens.typography.body.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: tokens.spacing.lg),

          // 統計カード
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  tokens,
                  '総メッセージ',
                  '${statistics.totalMessages}',
                  Icons.chat,
                  tokens.primary,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: _buildStatCard(
                  tokens,
                  '進捗共有',
                  '${statistics.totalProgressShares}',
                  Icons.trending_up,
                  tokens.success,
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.md),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  tokens,
                  '励まし',
                  '${statistics.totalEncouragements}',
                  Icons.favorite,
                  tokens.error,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: _buildStatCard(
                  tokens,
                  '共有ストリーク',
                  '${statistics.sharedStreakDays}日',
                  Icons.local_fire_department,
                  tokens.warning,
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.lg),

          // クイックアクション
          Text(
            'クイックアクション',
            style: tokens.typography.h4.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Row(
            children: [
              Expanded(
                child: PolishedSecondaryButton(
                  onPressed: () => context.push('/pair/${widget.pairId}/chat'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat, size: 20),
                      SizedBox(width: tokens.spacing.xs),
                      const Text('チャット'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: PolishedSecondaryButton(
                  onPressed: () => _shareProgress(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.share, size: 20),
                      SizedBox(width: tokens.spacing.xs),
                      const Text('進捗共有'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTab(MinqTheme tokens) {
    if (_comparisonData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final comparison = _comparisonData!;
    final userProgress = comparison.userProgress;
    final partnerProgress = comparison.partnerProgress;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '過去30日間の比較',
            style: tokens.typography.h4.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.lg),

          // 完了クエスト比較
          _buildComparisonCard(
            tokens,
            '完了クエスト',
            userProgress.completedQuests,
            partnerProgress.completedQuests,
            Icons.task_alt,
            tokens.primary,
          ),

          SizedBox(height: tokens.spacing.md),

          // ストリーク比較
          _buildComparisonCard(
            tokens,
            'ストリーク日数',
            userProgress.streakDays,
            partnerProgress.streakDays,
            Icons.local_fire_department,
            tokens.warning,
          ),

          SizedBox(height: tokens.spacing.md),

          // 平均スコア比較
          _buildComparisonCard(
            tokens,
            '平均スコア',
            userProgress.averageScore.round(),
            partnerProgress.averageScore.round(),
            Icons.star,
            tokens.success,
          ),

          SizedBox(height: tokens.spacing.lg),

          // 進捗チャート
          Container(
            padding: EdgeInsets.all(tokens.spacing.lg),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '進捗トレンド',
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.spacing.md),
                SizedBox(
                  height: 200,
                  child: CompletionTrendChart(
                    data: _generateChartData(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(MinqTheme tokens) {
    final pairSystem = ref.watch(pairSystemProvider);

    return StreamBuilder<List<ProgressShare>>(
      stream: pairSystem.getProgressSharesStream(widget.pairId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '進捗の読み込みに失敗しました',
              style: tokens.typography.body.copyWith(
                color: tokens.error,
              ),
            ),
          );
        }

        final progressShares = snapshot.data ?? [];

        if (progressShares.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 64,
                  color: tokens.textMuted,
                ),
                SizedBox(height: tokens.spacing.md),
                Text(
                  'まだ進捗共有がありません',
                  style: tokens.typography.body.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  '最初の進捗を共有してみましょう！',
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(tokens.spacing.lg),
          itemCount: progressShares.length,
          itemBuilder: (context, index) {
            final share = progressShares[index];
            return _buildProgressShareCard(tokens, share);
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    MinqTheme tokens,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: tokens.spacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            value,
            style: tokens.typography.h3.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    MinqTheme tokens,
    String title,
    int userValue,
    int partnerValue,
    IconData icon,
    Color color,
  ) {
    final total = userValue + partnerValue;
    final userPercentage = total > 0 ? userValue / total : 0.5;
    final partnerPercentage = total > 0 ? partnerValue / total : 0.5;

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
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
              Icon(icon, color: color, size: 24),
              SizedBox(width: tokens.spacing.sm),
              Text(
                title,
                style: tokens.typography.bodyMedium.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'あなた',
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    Text(
                      '$userValue',
                      style: tokens.typography.h3.copyWith(
                        color: tokens.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'パートナー',
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    Text(
                      '$partnerValue',
                      style: tokens.typography.h3.copyWith(
                        color: tokens.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          // プログレスバー
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: tokens.border,
            ),
            child: Row(
              children: [
                if (userPercentage > 0)
                  Expanded(
                    flex: (userPercentage * 100).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: tokens.primary,
                        borderRadius: BorderRadius.horizontal(
                          left: const Radius.circular(4),
                          right: partnerPercentage == 0 ? const Radius.circular(4) : Radius.zero,
                        ),
                      ),
                    ),
                  ),
                if (partnerPercentage > 0)
                  Expanded(
                    flex: (partnerPercentage * 100).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: tokens.secondary,
                        borderRadius: BorderRadius.horizontal(
                          left: userPercentage == 0 ? const Radius.circular(4) : Radius.zero,
                          right: const Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressShareCard(MinqTheme tokens, ProgressShare share) {
    return Container(
      margin: EdgeInsets.only(bottom: tokens.spacing.md),
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getProgressTypeIcon(share.type, tokens),
              SizedBox(width: tokens.spacing.sm),
              Expanded(
                child: Text(
                  share.title,
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatDate(share.timestamp),
                style: tokens.typography.bodySmall.copyWith(
                  color: tokens.textMuted,
                ),
              ),
            ],
          ),
          if (share.description != null) ...[
            SizedBox(height: tokens.spacing.sm),
            Text(
              share.description!,
              style: tokens.typography.body.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          ],
          if (share.score != null) ...[
            SizedBox(height: tokens.spacing.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.sm,
                vertical: tokens.spacing.xs,
              ),
              decoration: BoxDecoration(
                color: tokens.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
              child: Text(
                'スコア: ${share.score}',
                style: tokens.typography.bodySmall.copyWith(
                  color: tokens.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getProgressTypeIcon(ProgressShareType type, MinqTheme tokens) {
    switch (type) {
      case ProgressShareType.questCompleted:
        return Icon(Icons.task_alt, color: tokens.success, size: 20);
      case ProgressShareType.streakAchieved:
        return Icon(Icons.local_fire_department, color: tokens.warning, size: 20);
      case ProgressShareType.challengeCompleted:
        return Icon(Icons.emoji_events, color: tokens.primary, size: 20);
      case ProgressShareType.milestoneReached:
        return Icon(Icons.flag, color: tokens.secondary, size: 20);
      case ProgressShareType.encouragement:
        return Icon(Icons.favorite, color: tokens.error, size: 20);
    }
  }

  void _shareProgress() {
    // TODO: 進捗共有画面に遷移
  }

  void _showPairSettings() {
    // TODO: ペア設定画面を表示
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'fitness':
        return 'フィットネス';
      case 'learning':
        return '学習';
      case 'wellbeing':
        return 'ウェルビーイング';
      case 'productivity':
        return '生産性';
      case 'creativity':
        return '創造性';
      default:
        return 'その他';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  List<Map<String, dynamic>> _generateChartData() {
    // TODO: 実際のデータを生成
    return [];
  }
}