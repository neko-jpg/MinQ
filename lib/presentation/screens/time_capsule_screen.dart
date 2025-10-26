import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/monetization/subscription_manager.dart';
import 'package:minq/core/time_capsule/time_capsule_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/time_capsule/time_capsule.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/screens/subscription_premium_screen.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/time_capsule_card.dart';

class TimeCapsuleScreen extends ConsumerStatefulWidget {
  const TimeCapsuleScreen({super.key});

  @override
  ConsumerState<TimeCapsuleScreen> createState() => _TimeCapsuleScreenState();
}

class _TimeCapsuleScreenState extends ConsumerState<TimeCapsuleScreen>
    with TickerProviderStateMixin {
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
    final subscriptionManager = ref.watch(subscriptionManagerProvider);
    final hasAccess = subscriptionManager.hasFeatureAccess(PremiumFeature.premiumThemes);

    if (!hasAccess) {
      return _buildPremiumRequiredScreen(context, tokens);
    }

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'タイムカプセル',
          style: tokens.typography.h3.copyWith(color: tokens.textPrimary),
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
          tabs: const [Tab(text: '作成'), Tab(text: '一覧')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_CreateTimeCapsuleTab(), _TimeCapsuleListTab()],
      ),
    );
  }

  Widget _buildPremiumRequiredScreen(BuildContext context, MinqTheme tokens) {
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'タイムカプセル',
          style: tokens.typography.h3.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: tokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.workspace_premium,
                size: 80,
                color: tokens.brandPrimary,
              ),
              SizedBox(height: tokens.spacing.lg),
              Text(
                'プレミアム機能',
                style: tokens.typography.h2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: tokens.spacing.md),
              Text(
                'タイムカプセル機能はプレミアムプランでご利用いただけます。\n未来の自分にメッセージを送って、成長を記録しましょう。',
                style: tokens.typography.body.copyWith(
                  color: tokens.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.spacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionPremiumScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: tokens.spacing.lg),
                  ),
                  child: Text(
                    'プレミアムプランを見る',
                    style: tokens.typography.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateTimeCapsuleTab extends ConsumerStatefulWidget {
  const _CreateTimeCapsuleTab();

  @override
  ConsumerState<_CreateTimeCapsuleTab> createState() =>
      _CreateTimeCapsuleTabState();
}

class _CreateTimeCapsuleTabState extends ConsumerState<_CreateTimeCapsuleTab> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _predictionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 365));
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _predictionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now.add(const Duration(days: 30)); // 最低30日後
    final lastDate = now.add(const Duration(days: 365 * 5)); // 最大5年後

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: '配信日を選択',
      cancelText: 'キャンセル',
      confirmText: '決定',
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _createTimeCapsule() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = ref.read(uidProvider);
    if (uid == null) {
      FeedbackMessenger.showErrorSnackBar(context, 'ユーザーがサインインしていません');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(timeCapsuleServiceProvider);

      // AI予測メッセージを生成（簡易版）
      final prediction = _generateAIPrediction(_messageController.text);

      await service.createTimeCapsule(
        userId: uid,
        message: _messageController.text,
        prediction: prediction,
        deliveryDate: _selectedDate,
      );

      if (mounted) {
        FeedbackMessenger.showSuccessToast(context, 'タイムカプセルを作成しました！');

        // フォームをリセット
        _messageController.clear();
        _predictionController.clear();
        setState(() {
          _selectedDate = DateTime.now().add(const Duration(days: 365));
        });
      }
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(context, 'タイムカプセルの作成に失敗しました');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _generateAIPrediction(String message) {
    // 簡易的なAI予測メッセージ生成
    // 実際の実装では、TensorFlow Lite AIを使用
    final predictions = [
      'あなたの努力が実を結び、素晴らしい成果を上げていることでしょう。',
      '新しいスキルを身につけ、より自信に満ちた自分になっているはずです。',
      '困難を乗り越え、以前よりも強くなった自分を発見するでしょう。',
      '目標に向かって着実に歩み続け、理想の自分に近づいているでしょう。',
      '多くの経験を積み、より豊かな人生を送っていることでしょう。',
    ];

    return predictions[DateTime.now().millisecond % predictions.length];
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 説明カード
            Card(
              elevation: 0,
              color: tokens.brandPrimary.withAlpha(26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radius.lg),
              ),
              child: Padding(
                padding: EdgeInsets.all(tokens.spacing.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.schedule_send,
                      size: 48,
                      color: tokens.brandPrimary,
                    ),
                    SizedBox(height: tokens.spacing.md),
                    Text(
                      '未来の自分へメッセージを送ろう',
                      style: tokens.typography.h3.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: tokens.spacing.md),
                    Text(
                      '今の気持ちや目標を未来の自分に伝えましょう。\nAIがあなたの未来を予測してくれます。',
                      style: tokens.typography.body.copyWith(
                        color: tokens.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: tokens.spacing.xl),

            // メッセージ入力
            Text(
              '未来の自分へのメッセージ',
              style: tokens.typography.body.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing.md),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '例：1年後の自分へ。今は毎日瞑想を続けています。きっと心が穏やかになっているでしょうね...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
                filled: true,
                fillColor: tokens.surface,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'メッセージを入力してください';
                }
                if (value.trim().length < 10) {
                  return 'メッセージは10文字以上で入力してください';
                }
                return null;
              },
            ),

            SizedBox(height: tokens.spacing.lg),

            // 配信日選択
            Text(
              '配信日',
              style: tokens.typography.body.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing.md),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: EdgeInsets.all(tokens.spacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(color: tokens.border),
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                  color: tokens.surface,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: tokens.brandPrimary),
                    SizedBox(width: tokens.spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                            style: tokens.typography.body.copyWith(
                              color: tokens.textPrimary,
                            ),
                          ),
                          Text(
                            '${DateTime.now().difference(_selectedDate).inDays.abs()}日後に配信',
                            style: tokens.typography.caption.copyWith(
                              color: tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: tokens.textMuted,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: tokens.spacing.xl),

            // 作成ボタン
            MinqPrimaryButton(
              label: 'タイムカプセルを作成',
              icon: Icons.send,
              onPressed: _isLoading ? null : _createTimeCapsule,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeCapsuleListTab extends ConsumerWidget {
  const _TimeCapsuleListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    // TODO: 実際のデータ取得プロバイダーを実装
    // final capsulesAsync = ref.watch(userTimeCapsuleProvider);

    return Padding(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        children: [
          // 統計カード
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(timeCapsuleStatsProvider);
              
              return statsAsync.when(
                data: (stats) => Card(
                  elevation: 0,
                  color: tokens.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    side: BorderSide(color: tokens.border),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: Icons.schedule_send,
                            label: '送信済み',
                            value: '${stats.pending}',
                            color: tokens.brandPrimary,
                          ),
                        ),
                        Container(width: 1, height: 40, color: tokens.border),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.mail,
                            label: '配信済み',
                            value: '${stats.delivered}',
                            color: tokens.encouragement,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => Card(
                  elevation: 0,
                  color: tokens.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    side: BorderSide(color: tokens.border),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacing.lg),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  elevation: 0,
                  color: tokens.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    side: BorderSide(color: tokens.border),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: Icons.schedule_send,
                            label: '送信済み',
                            value: '-',
                            color: tokens.brandPrimary,
                          ),
                        ),
                        Container(width: 1, height: 40, color: tokens.border),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.mail,
                            label: '配信済み',
                            value: '-',
                            color: tokens.encouragement,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: tokens.spacing.lg),

          // タイムカプセル一覧
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final timeCapsuleAsync = ref.watch(timeCapsuleListProvider);
                
                return timeCapsuleAsync.when(
                  data: (timeCapsules) {
                    if (timeCapsules.isEmpty) {
                      return _buildEmptyState(tokens);
                    }
                    
                    return ListView.builder(
                      itemCount: timeCapsules.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: tokens.spacing.md),
                          child: TimeCapsuleCard(
                            capsule: timeCapsules[index],
                            onTap: () => _showTimeCapsuleDetail(
                              context,
                              timeCapsules[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: tokens.textMuted,
                        ),
                        SizedBox(height: tokens.spacing.md),
                        Text(
                          'タイムカプセルを読み込めませんでした',
                          style: tokens.typography.body.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                        SizedBox(height: tokens.spacing.md),
                        ElevatedButton(
                          onPressed: () => ref.refresh(timeCapsuleListProvider),
                          child: const Text('再試行'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTimeCapsuleDetail(BuildContext context, TimeCapsule capsule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TimeCapsuleDetailSheet(capsule: capsule),
    );
  }

  Widget _buildEmptyState(MinqTheme tokens) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            'まだタイムカプセルがありません',
            style: tokens.typography.h4.copyWith(
              color: tokens.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            '未来の自分へメッセージを送ってみませんか？',
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.spacing.lg),
          ElevatedButton.icon(
            onPressed: () => _showCreateTimeCapsuleDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('タイムカプセルを作成'),
          ),
        ],
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
        SizedBox(height: tokens.spacing.xs),
        Text(
          value,
          style: tokens.typography.h2.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: tokens.typography.caption.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }
}

class _TimeCapsuleDetailSheet extends StatelessWidget {
  const _TimeCapsuleDetailSheet({required this.capsule});

  final TimeCapsule capsule;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDelivered = capsule.deliveryDate.isBefore(DateTime.now());

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radius.xl),
        ),
      ),
      child: Column(
        children: [
          // ハンドル
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: tokens.spacing.md),
            decoration: BoxDecoration(
              color: tokens.border,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
          ),

          // ヘッダー
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isDelivered ? '配信済みタイムカプセル' : 'タイムカプセル',
                    style: tokens.typography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Divider(color: tokens.border),

          // コンテンツ
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 作成日・配信日
                  _InfoRow(
                    icon: Icons.create,
                    label: '作成日',
                    value:
                        '${capsule.createdAt.year}年${capsule.createdAt.month}月${capsule.createdAt.day}日',
                  ),
                  SizedBox(height: tokens.spacing.md),
                  _InfoRow(
                    icon: Icons.schedule,
                    label: '配信日',
                    value:
                        '${capsule.deliveryDate.year}年${capsule.deliveryDate.month}月${capsule.deliveryDate.day}日',
                  ),

                  SizedBox(height: tokens.spacing.lg),

                  // メッセージ
                  Text(
                    '過去の自分からのメッセージ',
                    style: tokens.typography.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.md),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(tokens.spacing.lg),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(tokens.radius.lg),
                      border: Border.all(color: tokens.border),
                    ),
                    child: Text(
                      capsule.message,
                      style: tokens.typography.body.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),

                  SizedBox(height: tokens.spacing.lg),

                  // AI予測
                  Text(
                    'AIの予測',
                    style: tokens.typography.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.md),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(tokens.spacing.lg),
                    decoration: BoxDecoration(
                      color: tokens.brandPrimary.withAlpha(26),
                      borderRadius: BorderRadius.circular(tokens.radius.lg),
                      border: Border.all(
                        color: tokens.brandPrimary.withAlpha(77),
                      ),
                    ),
                    child: Text(
                      capsule.prediction,
                      style: tokens.typography.body.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),

                  if (isDelivered) ...[
                    SizedBox(height: tokens.spacing.lg),
                    MinqPrimaryButton(
                      label: 'SNSでシェア',
                      icon: Icons.share,
                      onPressed: () => _shareTimeCapsule(context, capsule),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareTimeCapsule(
    BuildContext context,
    TimeCapsule capsule,
  ) async {
    // TODO: SNS共有機能を実装
    FeedbackMessenger.showInfoToast(context, 'SNS共有機能は準備中です');
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Icon(icon, size: 16, color: tokens.textMuted),
        SizedBox(width: tokens.spacing.sm),
        Text(
          label,
          style: tokens.typography.caption.copyWith(color: tokens.textMuted),
        ),
        SizedBox(width: tokens.spacing.sm),
        Expanded(
          child: Text(
            value,
            style: tokens.typography.caption.copyWith(color: tokens.textPrimary),
          ),
        ),
      ],
    );
  }
}
