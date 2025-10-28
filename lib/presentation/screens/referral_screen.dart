import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/referral_service.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// リファラル画面
/// 友達招待機能とリファラル統計を表示
class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _inviteLink;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInviteLink();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInviteLink() async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    try {
      final referralService = ref.read(referralServiceProvider);
      final link = await referralService.generateInviteLink(userId: uid);

      if (mounted) {
        setState(() {
          _inviteLink = link;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // WidgetsBinding.instance.addPostFrameCallbackを使用してScaffoldが構築された後に実行
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            FeedbackMessenger.showErrorSnackBar(context, '招待リンクの生成に失敗しました');
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('友達招待'),
        backgroundColor: tokens.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '招待する'), Tab(text: '招待履歴')],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildInviteTab(), _buildHistoryTab()],
            ),
    );
  }

  Widget _buildInviteTab() {
    final tokens = context.tokens;
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダーカード
          _buildHeaderCard(),
          SizedBox(height: tokens.spacing.lg),
          // 招待リンクカード
          _buildInviteLinkCard(),
          SizedBox(height: tokens.spacing.lg),
          // 招待方法
          _buildInviteMethods(),
          SizedBox(height: tokens.spacing.lg),
          // 報酬説明
          _buildRewardExplanation(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final tokens = context.tokens;
    final uid = ref.watch(uidProvider);

    if (uid == null) {
      return const Center(child: Text('ログインが必要です'));
    }

    return FutureBuilder<ReferralStats>(
      future: _loadReferralStats(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: tokens.spacing.xl,
                  color: tokens.textMuted,
                ),
                SizedBox(height: tokens.spacing.md),
                Text(
                  'データの読み込みに失敗しました',
                  style: tokens.typography.bodyMedium
                      .copyWith(color: tokens.textMuted),
                ),
                SizedBox(height: tokens.spacing.md),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('再試行'),
                ),
              ],
            ),
          );
        }

        final stats = snapshot.data!;
        return _buildHistoryContent(stats);
      },
    );
  }

  Widget _buildHeaderCard() {
    final tokens = context.tokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.brandPrimary,
            tokens.brandPrimary.withAlpha(204)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        boxShadow: [
          BoxShadow(
            color: tokens.brandPrimary.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.people, size: tokens.spacing.xl, color: Colors.white),
          SizedBox(height: tokens.spacing.sm),
          Text(
            '友達を招待しよう！',
            style: tokens.typography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            '友達が登録すると、あなたも友達も\n特別なボーナスポイントがもらえます！',
            style: tokens.typography.body.copyWith(
              color: Colors.white.withAlpha(230),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInviteLinkCard() {
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
            'あなたの招待リンク',
            style:
                tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing.sm),

          // リンク表示
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(tokens.spacing.sm),
            decoration: BoxDecoration(
              color: tokens.surfaceVariant,
              borderRadius: BorderRadius.circular(tokens.radius.md),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _inviteLink ?? 'リンク生成中...',
                    style: tokens.typography.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: _inviteLink != null ? _copyInviteLink : null,
                  icon: const Icon(Icons.copy),
                  tooltip: 'コピー',
                ),
              ],
            ),
          ),

          SizedBox(height: tokens.spacing.sm),

          // シェアボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _inviteLink != null ? _shareInviteLink : null,
              icon: const Icon(Icons.share),
              label: const Text('招待リンクをシェア'),
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.brandPrimary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteMethods() {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '招待方法',
          style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tokens.spacing.sm),

        // LINE招待
        _buildInviteMethodCard(
          icon: Icons.chat,
          title: 'LINEで招待',
          description: 'LINEで友達に招待メッセージを送信',
          color: Colors.green,
          onTap: _shareToLine,
        ),

        SizedBox(height: tokens.spacing.sm),

        // Twitter招待
        _buildInviteMethodCard(
          icon: Icons.share,
          title: 'SNSで招待',
          description: 'Twitter、Instagram等で招待リンクをシェア',
          color: Colors.blue,
          onTap: _shareToSocial,
        ),

        SizedBox(height: tokens.spacing.sm),

        // その他の方法
        _buildInviteMethodCard(
          icon: Icons.more_horiz,
          title: 'その他の方法',
          description: 'メール、SMS等で招待リンクを送信',
          color: Colors.orange,
          onTap: _shareGeneral,
        ),
      ],
    );
  }

  Widget _buildInviteMethodCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final tokens = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(tokens.spacing.md),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radius.md),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [
            Container(
              width: tokens.spacing.xl,
              height: tokens.spacing.xl,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(tokens.radius.md),
              ),
              child: Icon(icon, color: color, size: tokens.spacing.lg),
            ),
            SizedBox(width: tokens.spacing.sm),
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
                    style: tokens.typography.caption
                        .copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: tokens.spacing.md,
              color: tokens.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardExplanation() {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(25),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: Colors.amber.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber.shade700,
                size: tokens.spacing.lg,
              ),
              SizedBox(width: tokens.spacing.xs),
              Text(
                '招待報酬',
                style: tokens.typography.h4.copyWith(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.sm),

          _buildRewardItem('友達が登録完了', '500ポイント', 'あなたと友達の両方がもらえます'),

          SizedBox(height: tokens.spacing.xs),

          _buildRewardItem('友達が初回クエスト完了', '1000ポイント', 'さらにボーナスポイント！'),

          SizedBox(height: tokens.spacing.xs),

          _buildRewardItem('友達が7日継続', '2000ポイント', '継続ボーナスで大量ポイント！'),
        ],
      ),
    );
  }

  Widget _buildRewardItem(
    String condition,
    String reward,
    String description,
  ) {
    final tokens = context.tokens;
    return Row(
      children: [
        Container(
          width: tokens.spacing.xs,
          height: tokens.spacing.xs,
          decoration: BoxDecoration(
            color: Colors.amber.shade700,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: tokens.spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    condition,
                    style: tokens.typography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    reward,
                    style: tokens.typography.body.copyWith(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                description,
                style: tokens.typography.caption
                    .copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryContent(ReferralStats stats) {
    final tokens = context.tokens;
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 統計カード
          _buildStatsCards(stats),

          SizedBox(height: tokens.spacing.lg),

          // 成功率表示
          _buildConversionRate(stats),

          SizedBox(height: tokens.spacing.lg),

          // 最近の招待履歴
          Text(
            '招待履歴',
            style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing.sm),

          if (stats.totalReferrals == 0)
            _buildEmptyHistory()
          else
            _buildHistoryList(stats),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ReferralStats stats) {
    final tokens = context.tokens;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '総招待数',
            '${stats.totalReferrals}人',
            Icons.people_outline,
            Colors.blue,
          ),
        ),
        SizedBox(width: tokens.spacing.sm),
        Expanded(
          child: _buildStatCard(
            '成功数',
            '${stats.completedReferrals + stats.rewardedReferrals}人',
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        SizedBox(width: tokens.spacing.sm),
        Expanded(
          child: _buildStatCard(
            '待機中',
            '${stats.pendingReferrals}人',
            Icons.schedule,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: tokens.spacing.lg),
          SizedBox(height: tokens.spacing.xs),
          Text(
            value,
            style: tokens.typography.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            title,
            style: tokens.typography.caption
                .copyWith(color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversionRate(ReferralStats stats) {
    final tokens = context.tokens;
    final rate = (stats.conversionRate * 100).toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: Colors.green, size: tokens.spacing.lg),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '成功率',
                  style: tokens.typography.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$rate%',
                  style: tokens.typography.h3.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    final tokens = context.tokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: tokens.spacing.xl,
            color: tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            'まだ招待履歴がありません',
            style:
                tokens.typography.h4.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            '友達を招待して、一緒にMinQを楽しみましょう！',
            style: tokens.typography.body
                .copyWith(color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(ReferralStats stats) {
    // 実際の履歴データを表示する場合は、ここでFirestoreから取得
    return Column(
      children: [
        _buildHistoryItem(
          'pending',
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        _buildHistoryItem(
          'completed',
          DateTime.now().subtract(const Duration(days: 3)),
        ),
        _buildHistoryItem(
          'rewarded',
          DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(String status, DateTime date) {
    final tokens = context.tokens;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = '登録完了';
        break;
      case 'rewarded':
        statusColor = Colors.amber;
        statusIcon = Icons.emoji_events;
        statusText = '報酬付与済み';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = '招待中';
    }

    return Container(
      margin: EdgeInsets.only(bottom: tokens.spacing.sm),
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: tokens.spacing.lg,
            height: tokens.spacing.lg,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: tokens.spacing.md,
            ),
          ),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: tokens.typography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: tokens.typography.caption
                      .copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // アクションメソッド
  void _copyInviteLink() {
    if (_inviteLink == null) return;

    Clipboard.setData(ClipboardData(text: _inviteLink!));
    FeedbackMessenger.showSuccessToast(context, '招待リンクをコピーしました');
  }

  void _shareInviteLink() {
    if (_inviteLink == null) return;

    final uid = ref.read(uidProvider);
    if (uid != null) {
      final referralService = ref.read(referralServiceProvider);
      referralService.shareInviteLink(userId: uid);
    }
  }

  void _shareToLine() {
    _shareInviteLink();
  }

  void _shareToSocial() {
    _shareInviteLink();
  }

  void _shareGeneral() {
    _shareInviteLink();
  }

  Future<ReferralStats> _loadReferralStats(String uid) async {
    try {
      final referralService = ref.read(referralServiceProvider);
      return await referralService.getReferralStats(uid);
    } catch (e) {
      // フォールバックデータ
      return ReferralStats(
        totalReferrals: 0,
        pendingReferrals: 0,
        completedReferrals: 0,
        rewardedReferrals: 0,
      );
    }
  }
}
