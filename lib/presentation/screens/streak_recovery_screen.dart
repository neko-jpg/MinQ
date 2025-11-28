import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/streak/streak_recovery_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class StreakRecoveryScreen extends ConsumerStatefulWidget {
  const StreakRecoveryScreen({super.key, required this.questId});

  final int questId;

  @override
  ConsumerState<StreakRecoveryScreen> createState() =>
      _StreakRecoveryScreenState();
}

class _StreakRecoveryScreenState extends ConsumerState<StreakRecoveryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'ストリーク保護・回復',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: tokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '回復'), Tab(text: '保護'), Tab(text: '統計')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RecoveryTab(questId: widget.questId),
          _ProtectionTab(questId: widget.questId),
          _StatsTab(questId: widget.questId),
        ],
      ),
    );
  }
}

class _RecoveryTab extends ConsumerStatefulWidget {
  const _RecoveryTab({required this.questId});

  final int questId;

  @override
  ConsumerState<_RecoveryTab> createState() => _RecoveryTabState();
}

class _RecoveryTabState extends ConsumerState<_RecoveryTab> {
  bool _isRecovering = false;
  bool _isPurchasing = false;
  bool _isWatchingAd = false;

  Future<void> _recoverStreak() async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    setState(() {
      _isRecovering = true;
    });

    try {
      final service = StreakRecoveryService();
      final success = await service.recoverStreak(
        userId: uid,
        questId: widget.questId.toString(),
      );

      if (mounted) {
        if (success) {
          FeedbackMessenger.showSuccessToast(context, 'ストリークを回復しました！');
        } else {
          FeedbackMessenger.showErrorSnackBar(context, 'ストリークの回復に失敗しました');
        }
      }
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(context, 'エラーが発生しました');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRecovering = false;
        });
      }
    }
  }

  Future<void> _purchaseTicket() async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    setState(() {
      _isPurchasing = true;
    });

    try {
      final service = StreakRecoveryService();
      final success = await service.purchaseRecoveryTicket(
        userId: uid,
        count: 1,
      );

      if (mounted) {
        if (success) {
          FeedbackMessenger.showSuccessToast(context, 'リカバリーチケットを購入しました！');
        } else {
          FeedbackMessenger.showErrorSnackBar(context, '購入に失敗しました');
        }
      }
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(context, 'エラーが発生しました');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _watchAdForTicket() async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    setState(() {
      _isWatchingAd = true;
    });

    try {
      final service = StreakRecoveryService();
      final success = await service.earnTicketByWatchingAd(userId: uid);

      if (mounted) {
        if (success) {
          FeedbackMessenger.showSuccessToast(context, '広告視聴でチケットを獲得しました！');
        } else {
          FeedbackMessenger.showErrorSnackBar(context, 'チケット獲得に失敗しました');
        }
      }
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(context, 'エラーが発生しました');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isWatchingAd = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final uid = ref.watch(uidProvider);

    if (uid == null) {
      return const Center(child: Text('ユーザーがサインインしていません'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ストリーク状況カード
          _StreakStatusCard(questId: widget.questId),

          SizedBox(height: tokens.spacing(4)),

          // リカバリーチケット情報
          _RecoveryTicketCard(userId: uid),

          SizedBox(height: tokens.spacing(4)),

          // ストリーク回復ボタン
          Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: tokens.cornerLarge(),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restore, color: tokens.encouragement),
                      SizedBox(width: tokens.spacing(2)),
                      Text(
                        'ストリーク回復',
                        style: tokens.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  Text(
                    'リカバリーチケットを使用してストリークを回復できます。\n24時間以内に1回まで使用可能です。',
                    style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                  ),
                  SizedBox(height: tokens.spacing(4)),
                  MinqPrimaryButton(
                    label: 'ストリークを回復する',
                    icon: Icons.restore,
                    onPressed: _isRecovering ? null : _recoverStreak,
                    isLoading: _isRecovering,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: tokens.spacing(4)),

          // チケット購入オプション
          Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: tokens.cornerLarge(),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_cart, color: tokens.brandPrimary),
                      SizedBox(width: tokens.spacing(2)),
                      Text(
                        'チケット購入',
                        style: tokens.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing(3)),

                  // 課金購入
                  _PurchaseOption(
                    icon: Icons.payment,
                    title: 'リカバリーチケット',
                    subtitle: '120円でチケット1枚',
                    buttonText: '購入する',
                    onPressed: _isPurchasing ? null : _purchaseTicket,
                    isLoading: _isPurchasing,
                    color: tokens.brandPrimary,
                  ),

                  SizedBox(height: tokens.spacing(3)),

                  // 広告視聴
                  _PurchaseOption(
                    icon: Icons.play_circle,
                    title: '広告視聴',
                    subtitle: '広告を見てチケット1枚獲得',
                    buttonText: '広告を見る',
                    onPressed: _isWatchingAd ? null : _watchAdForTicket,
                    isLoading: _isWatchingAd,
                    color: tokens.encouragement,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: tokens.spacing(4)),

          // 注意事項
          Card(
            elevation: 0,
            color: tokens.joyAccent.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: tokens.joyAccent),
                      SizedBox(width: tokens.spacing(2)),
                      Text(
                        '注意事項',
                        style: tokens.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  Text(
                    '• ストリーク回復は24時間以内に1回まで\n'
                    '• チケットは購入または広告視聴で獲得\n'
                    '• 回復後は通常通り習慣を継続してください',
                    style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionTab extends ConsumerWidget {
  const _ProtectionTab({required this.questId});

  final int questId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 保護設定カード
          Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: tokens.cornerLarge(),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield, color: tokens.brandPrimary),
                      SizedBox(width: tokens.spacing(2)),
                      Text(
                        'ストリーク保護設定',
                        style: tokens.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing(3)),
                  StreakProtectionWidget(questId: questId),
                ],
              ),
            ),
          ),

          SizedBox(height: tokens.spacing(4)),

          // 保護履歴
          _ProtectionHistoryCard(questId: questId),

          SizedBox(height: tokens.spacing(4)),

          // 保護のヒント
          Card(
            elevation: 0,
            color: tokens.serenity.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: tokens.serenity),
                      SizedBox(width: tokens.spacing(2)),
                      Text(
                        'ストリーク保護のコツ',
                        style: tokens.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing(3)),
                  const _ProtectionTip(
                    icon: Icons.pause_circle,
                    title: '一時停止',
                    description: '長期間の休暇や体調不良時に使用',
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  const _ProtectionTip(
                    icon: Icons.ac_unit,
                    title: '凍結日',
                    description: '特定の日だけスキップしたい時に使用',
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  const _ProtectionTip(
                    icon: Icons.weekend,
                    title: '週末スキップ',
                    description: '週末は自動的にスキップ（設定で変更可能）',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends ConsumerWidget {
  const _StatsTab({required this.questId});

  final int questId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 統計サマリー
          _StreakStatsCard(questId: questId),

          SizedBox(height: tokens.spacing(4)),

          // 月別統計
          _MonthlyStatsCard(questId: questId),

          SizedBox(height: tokens.spacing(4)),

          // 保護使用履歴
          _ProtectionUsageCard(questId: questId),
        ],
      ),
    );
  }
}

// 補助ウィジェット
class _StreakStatusCard extends StatelessWidget {
  const _StreakStatusCard({required this.questId});

  final int questId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      color: tokens.encouragement.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 48,
              color: tokens.encouragement,
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              '現在のストリーク',
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            ),
            Text(
              '7日', // TODO: 実際のデータを取得
              style: tokens.displayMedium.copyWith(
                color: tokens.encouragement,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              '最長記録: 15日',
              style: tokens.bodySmall.copyWith(color: tokens.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryTicketCard extends StatelessWidget {
  const _RecoveryTicketCard({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(tokens.spacing(3)),
              decoration: BoxDecoration(
                color: tokens.joyAccent.withValues(alpha: 0.1),
                borderRadius: tokens.cornerLarge(),
              ),
              child: Icon(
                Icons.confirmation_number,
                color: tokens.joyAccent,
                size: 32,
              ),
            ),
            SizedBox(width: tokens.spacing(4)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'リカバリーチケット',
                    style: tokens.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing(1)),
                  Text(
                    '所持数: 3枚', // TODO: 実際のデータを取得
                    style: tokens.titleLarge.copyWith(
                      color: tokens.joyAccent,
                      fontWeight: FontWeight.bold,
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
}

class _PurchaseOption extends StatelessWidget {
  const _PurchaseOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
    required this.isLoading,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        border: Border.all(color: tokens.border),
        borderRadius: tokens.cornerMedium(),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(tokens.spacing(2)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: tokens.cornerMedium(),
            ),
            child: Icon(icon, color: color),
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
                Text(
                  subtitle,
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          SizedBox(width: tokens.spacing(2)),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child:
                  isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                      : Text(buttonText, style: tokens.bodySmall),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionHistoryCard extends StatelessWidget {
  const _ProtectionHistoryCard({required this.questId});

  final int questId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '保護履歴',
              style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing(3)),
            // TODO: 実際の履歴データを表示
            Text(
              '履歴がありません',
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProtectionTip extends StatelessWidget {
  const _ProtectionTip({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Icon(icon, size: 20, color: tokens.serenity),
        SizedBox(width: tokens.spacing(2)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tokens.bodyMedium.copyWith(fontWeight: FontWeight.bold),
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
}

class _StreakStatsCard extends StatelessWidget {
  const _StreakStatsCard({required this.questId});

  final int questId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ストリーク統計',
              style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing(3)),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.local_fire_department,
                    label: '現在',
                    value: '7日',
                    color: tokens.encouragement,
                  ),
                ),
                Container(width: 1, height: 40, color: tokens.border),
                Expanded(
                  child: _StatItem(
                    icon: Icons.emoji_events,
                    label: '最長',
                    value: '15日',
                    color: tokens.joyAccent,
                  ),
                ),
                Container(width: 1, height: 40, color: tokens.border),
                Expanded(
                  child: _StatItem(
                    icon: Icons.check_circle,
                    label: '完了率',
                    value: '85%',
                    color: tokens.brandPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyStatsCard extends StatelessWidget {
  const _MonthlyStatsCard({required this.questId});

  final int questId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今月の統計',
              style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing(3)),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.done,
                    label: '完了',
                    value: '18日',
                    color: tokens.encouragement,
                  ),
                ),
                Container(width: 1, height: 40, color: tokens.border),
                Expanded(
                  child: _StatItem(
                    icon: Icons.skip_next,
                    label: 'スキップ',
                    value: '2日',
                    color: tokens.textMuted,
                  ),
                ),
                Container(width: 1, height: 40, color: tokens.border),
                Expanded(
                  child: _StatItem(
                    icon: Icons.pause,
                    label: '一時停止',
                    value: '0日',
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProtectionUsageCard extends StatelessWidget {
  const _ProtectionUsageCard({required this.questId});

  final int questId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '保護使用状況',
              style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing(3)),
            // TODO: 実際の使用状況データを表示
            Text(
              '今月の保護使用: 2回 / 3回',
              style: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing(2)),
            LinearProgressIndicator(
              value: 2 / 3,
              backgroundColor: tokens.border,
              valueColor: AlwaysStoppedAnimation(tokens.brandPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: tokens.spacing(1)),
        Text(
          value,
          style: tokens.titleLarge.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
      ],
    );
  }
}
