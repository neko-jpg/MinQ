import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/subscription/subscription_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// サブスクリプション画面
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final currentPlan = ref.watch(currentPlanProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('プレミアムプラン')),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing.md),
        children: [
          if (isPremium) _buildCurrentPlanCard(context, currentPlan),
          if (!isPremium) _buildUpgradeHeader(context),
          SizedBox(height: tokens.spacing.lg),
          _buildFeaturesList(context),
          SizedBox(height: tokens.spacing.lg),
          _buildPricingCards(context, ref),
          SizedBox(height: tokens.spacing.lg),
          if (isPremium) _buildManageSubscription(context),
          if (!isPremium) _buildRestoreButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(BuildContext context, SubscriptionPlan plan) {
    final tokens = context.tokens;
    return Card(
      color: tokens.brandPrimary.withAlpha(26),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 48,
              color: tokens.brandPrimary,
            ),
            SizedBox(height: tokens.spacing.sm),
            Text('プレミアム会員', style: tokens.typography.h2),
            SizedBox(height: tokens.spacing.xs),
            Text(_getPlanName(plan), style: tokens.typography.body),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeHeader(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Icon(
          Icons.workspace_premium,
          size: 64,
          color: tokens.brandPrimary,
        ),
        SizedBox(height: tokens.spacing.md),
        Text(
          'プレミアムで\nもっと便利に',
          textAlign: TextAlign.center,
          style: tokens.typography.h1,
        ),
        SizedBox(height: tokens.spacing.sm),
        Text(
          '広告なし・無制限のクエスト・高度な統計',
          textAlign: TextAlign.center,
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final tokens = context.tokens;
    final features = [
      _FeatureItem(
        icon: Icons.block,
        title: '広告非表示',
        description: '広告なしで快適に利用',
      ),
      _FeatureItem(
        icon: Icons.all_inclusive,
        title: '無制限のクエスト',
        description: 'クエストを無制限に作成',
      ),
      _FeatureItem(
        icon: Icons.analytics,
        title: '高度な統計',
        description: '詳細なグラフと分析',
      ),
      _FeatureItem(
        icon: Icons.palette,
        title: 'カスタムテーマ',
        description: 'お好みのカラーテーマ',
      ),
      _FeatureItem(
        icon: Icons.support_agent,
        title: '優先サポート',
        description: '優先的にサポート対応',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('プレミアム機能', style: tokens.typography.h2),
        SizedBox(height: tokens.spacing.md),
        ...features.map((feature) => _buildFeatureItem(context, feature)),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, _FeatureItem feature) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.brandPrimary.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              color: tokens.brandPrimary,
            ),
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.title, style: tokens.typography.h4),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  feature.description,
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

  Widget _buildPricingCards(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('プランを選択', style: tokens.typography.h2),
        SizedBox(height: tokens.spacing.md),
        _buildPricingCard(
          context,
          ref,
          plan: SubscriptionPlan.premiumYearly,
          title: '年間プラン',
          price: '¥4,800',
          period: '年',
          savings: '2ヶ月分お得',
          isRecommended: true,
        ),
        SizedBox(height: tokens.spacing.md),
        _buildPricingCard(
          context,
          ref,
          plan: SubscriptionPlan.premiumMonthly,
          title: '月間プラン',
          price: '¥480',
          period: '月',
        ),
      ],
    );
  }

  Widget _buildPricingCard(
    BuildContext context,
    WidgetRef ref, {
    required SubscriptionPlan plan,
    required String title,
    required String price,
    required String period,
    String? savings,
    bool isRecommended = false,
  }) {
    final tokens = context.tokens;
    return Card(
      elevation: isRecommended ? 4 : 1,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.sm,
                  vertical: tokens.spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: tokens.brandPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'おすすめ',
                  style: tokens.typography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isRecommended) SizedBox(height: tokens.spacing.sm),
            Text(title, style: tokens.typography.h3),
            SizedBox(height: tokens.spacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: tokens.typography.h1.copyWith(
                    color: tokens.brandPrimary,
                  ),
                ),
                SizedBox(width: tokens.spacing.xs),
                Padding(
                  padding: EdgeInsets.only(bottom: tokens.spacing.xs),
                  child: Text(
                    '/ $period',
                    style: tokens.typography.body
                        .copyWith(color: tokens.textMuted),
                  ),
                ),
              ],
            ),
            if (savings != null) ...[
              SizedBox(height: tokens.spacing.xs),
              Text(
                savings,
                style: tokens.typography.caption.copyWith(
                  color: tokens.accentSuccess,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            SizedBox(height: tokens.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePurchase(context, ref, plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRecommended ? tokens.brandPrimary : null,
                ),
                child: const Text('購入する'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageSubscription(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Text('サブスクリプションの管理', style: tokens.typography.h3),
        SizedBox(height: tokens.spacing.sm),
        Text(
          'サブスクリプションのキャンセルや変更は、\nApp Store / Google Play Storeの設定から行えます。',
          textAlign: TextAlign.center,
          style: tokens.typography.caption.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.md),
        OutlinedButton(
          onPressed: () {
            // TODO: ストアの設定画面を開く
          },
          child: const Text('設定を開く'),
        ),
      ],
    );
  }

  Widget _buildRestoreButton(BuildContext context, WidgetRef ref) {
    return Center(
      child: TextButton(
        onPressed: () => _handleRestore(context, ref),
        child: const Text('購入を復元'),
      ),
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan plan,
  ) async {
    // ローディング表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = ref.read(subscriptionServiceProvider);
      final success = await service.purchase(plan);

      if (!context.mounted) return;
      Navigator.pop(context); // ローディングを閉じる

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('購入が完了しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // 画面を閉じる
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('購入に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // ローディングを閉じる
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    // ローディング表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = ref.read(subscriptionServiceProvider);
      final success = await service.restore();

      if (!context.mounted) return;
      Navigator.pop(context); // ローディングを閉じる

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('購入を復元しました'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('復元する購入が見つかりませんでした')));
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // ローディングを閉じる
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _getPlanName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return '無料プラン';
      case SubscriptionPlan.premiumMonthly:
        return '月間プラン';
      case SubscriptionPlan.premiumYearly:
        return '年間プラン';
    }
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
