import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/referral_service.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/points_display_widget.dart';
import 'package:share_plus/share_plus.dart';

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

      setState(() {
        _inviteLink = link;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(context, '招待リンクの生成に失敗しました');
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [_buildInviteTab(tokens), _buildHistoryTab(tokens)],
              ),
    );
  }

  Widget _buildInviteTab(MinqTokens tokens) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダーカード
          _buildHeaderCard(tokens),

          SizedBox(height: tokens.spacing(6)),

          // 招待リンクカード
          _buildInviteLinkCard(tokens),

          SizedBox(height: tokens.spacing(6)),

          // 招待方法
          _buildInviteMethods(tokens),

          SizedBox(height: tokens.spacing(6)),

          // 報酬説明
          _buildRewardExplanation(tokens),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(MinqTokens tokens) {
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
                  size: tokens.spacing(16),
                  color: tokens.textMuted,
                ),
                SizedBox(height: tokens.spacing(4)),
                Text(
                  'データの読み込みに失敗しました',
                  style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                ),
                SizedBox(height: tokens.spacing(4)),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('再試行'),
                ),
              ],
            ),
          );
        }

        final stats = snapshot.data!;
        return _buildHistoryContent(tokens, stats);
      },
    );
  }

  Widget _buildHeaderCard(MinqTokens tokens) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing(6)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tokens.brandPrimary, tokens.brandPrimary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: tokens.cornerLarge(),
        boxShadow: [
          BoxShadow(
            color: tokens.brandPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.people, size: tokens.spacing(16), color: Colors.white),
          SizedBox(height: tokens.spacing(3)),
          Text(
            '友達を招待しよう！',
            style: tokens.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            '友達が登録すると、あなたも友達も\n特別なボーナスポイントがもらえます！',
            style: tokens.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInviteLinkCard(MinqTokens tokens) {
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
            'あなたの招待リンク',
            style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing(3)),

          // リンク表示
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(tokens.spacing(3)),
            decoration: BoxDecoration(
              color: tokens.surfaceVariant,
              borderRadius: tokens.cornerMedium(),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _inviteLink ?? 'リンク生成中...',
                    style: tokens.bodyMedium,
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

          SizedBox(height: tokens.spacing(3)),

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

  Widget _buildInviteMethods(MinqTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '招待方法',
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tokens.spacing(3)),

        // LINE招待
        _buildInviteMethodCard(
          tokens,
          icon: Icons.chat,
          title: 'LINEで招待',
          description: 'LINEで友達に招待メッセージを送信',
          color: Colors.green,
          onTap: _shareToLine,
        ),

        SizedBox(height: tokens.spacing(3)),

        // Twitter招待
        _buildInviteMethodCard(
          tokens,
          icon: Icons.share,
          title: 'SNSで招待',
          description: 'Twitter、Instagram等で招待リンクをシェア',
          color: Colors.blue,
          onTap: _shareToSocial,
        ),

        SizedBox(height: tokens.spacing(3)),

        // その他の方法
        _buildInviteMethodCard(
          tokens,
          icon: Icons.more_horiz,
          title: 'その他の方法',
          description: 'メール、SMS等で招待リンクを送信',
          color: Colors.orange,
          onTap: _shareGeneral,
        ),
      ],
    );
  }

  Widget _buildInviteMethodCard(
    MinqTokens tokens, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(tokens.spacing(4)),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: tokens.cornerMedium(),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [
            Container(
              width: tokens.spacing(12),
              height: tokens.spacing(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: tokens.cornerMedium(),
              ),
              child: Icon(icon, color: color, size: tokens.spacing(6)),
            ),
            SizedBox(width: tokens.spacing(3)),
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
                    style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: tokens.spacing(4),
              color: tokens.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardExplanation(MinqTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber.shade700,
                size: tokens.spacing(6),
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(
                '招待報酬',
                style: tokens.titleMedium.copyWith(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing(3)),

          _buildRewardItem(tokens, '友達が登録完了', '500ポイント', 'あなたと友達の両方がもらえます'),

          SizedBox(height: tokens.spacing(2)),

          _buildRewardItem(tokens, '友達が初回クエスト完了', '1000ポイント', 'さらにボーナスポイント！'),

          SizedBox(height: tokens.spacing(2)),

          _buildRewardItem(tokens, '友達が7日継続', '2000ポイント', '継続ボーナスで大量ポイント！'),
        ],
      ),
    );
  }

  Widget _buildRewardItem(
    MinqTokens tokens,
    String condition,
    String reward,
    String description,
  ) {
    return Row(
      children: [
        Container(
          width: tokens.spacing(2),
          height: tokens.spacing(2),
          decoration: BoxDecoration(
            color: Colors.amber.shade700,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: tokens.spacing(3)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    condition,
                    style: tokens.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    reward,
                    style: tokens.bodyMedium.copyWith(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                description,
                style: tokens.bodySmall.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryContent(MinqTokens tokens, ReferralStats stats) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 統計カード
          _buildStatsCards(tokens, stats),

          SizedBox(height: tokens.spacing(6)),

          // 成功率表示
          _buildConversionRate(tokens, stats),

          SizedBox(height: tokens.spacing(6)),

          // 最近の招待履歴
          Text(
            '招待履歴',
            style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing(3)),

          if (stats.totalReferrals == 0)
            _buildEmptyHistory(tokens)
          else
            _buildHistoryList(tokens, stats),
        ],
      ),
    );
  }

  Widget _buildStatsCards(MinqTokens tokens, ReferralStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            tokens,
            '総招待数',
            '${stats.totalReferrals}人',
            Icons.people_outline,
            Colors.blue,
          ),
        ),
        SizedBox(width: tokens.spacing(3)),
        Expanded(
          child: _buildStatCard(
            tokens,
            '成功数',
            '${stats.completedReferrals + stats.rewardedReferrals}人',
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        SizedBox(width: tokens.spacing(3)),
        Expanded(
          child: _buildStatCard(
            tokens,
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
    MinqTokens tokens,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerMedium(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: tokens.spacing(6)),
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
            title,
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversionRate(MinqTokens tokens, ReferralStats stats) {
    final rate = (stats.conversionRate * 100).toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerMedium(),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: Colors.green, size: tokens.spacing(6)),
          SizedBox(width: tokens.spacing(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '成功率',
                  style: tokens.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$rate%',
                  style: tokens.titleLarge.copyWith(
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

  Widget _buildEmptyHistory(MinqTokens tokens) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing(8)),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: tokens.spacing(16),
            color: tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing(4)),
          Text(
            'まだ招待履歴がありません',
            style: tokens.titleMedium.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            '友達を招待して、一緒にMinQを楽しみましょう！',
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(MinqTokens tokens, ReferralStats stats) {
    // 実際の履歴データを表示する場合は、ここでFirestoreから取得
    return Column(
      children: [
        _buildHistoryItem(
          tokens,
          'pending',
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        _buildHistoryItem(
          tokens,
          'completed',
          DateTime.now().subtract(const Duration(days: 3)),
        ),
        _buildHistoryItem(
          tokens,
          'rewarded',
          DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(MinqTokens tokens, String status, DateTime date) {
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
      margin: EdgeInsets.only(bottom: tokens.spacing(3)),
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerMedium(),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: tokens.spacing(10),
            height: tokens.spacing(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: tokens.spacing(5),
            ),
          ),
          SizedBox(width: tokens.spacing(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: tokens.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.spacing(1)),
                Text(
                  '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
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
