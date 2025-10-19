import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/subscription/subscription_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// サブスクリプション画面
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlan = ref.watch(currentPlanProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プレミアムプラン'),
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          if (isPremium) _buildCurrentPlanCard(context, currentPlan),
          if (!isPremium) _buildUpgradeHeader(context),
          SizedBox(height: AppSpacing.lg),
          _buildFeaturesList(context),
          SizedBox(height: AppSpacing.lg),
          _buildPricingCards(context, ref),
          SizedBox(height: AppSpacing.lg),
          if (isPremium) _buildManageSubscription(context),
          if (!isPremium) _buildRestoreButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(BuildContext context, SubscriptionPlan plan) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'プレミアム会員',
              style: AppTypography.h2,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              _getPlanName(plan),
              style: AppTypography.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeHeader(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.workspace_premium,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'プレミアムで\nもっと便利に',
          textAlign: TextAlign.center,
          style: AppTypography.h1,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          '広告なし・無制限のクエスト・高度な統計',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
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
        Text(
          'プレミアム機能',
          style: AppTypography.h2,
        ),
        SizedBox(height: AppSpacing.md),
        ...features.map((feature) => _buildFeatureItem(context, feature)),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, _FeatureItem feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: AppTypography.h4,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  feature.description,
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCards(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'プランを選択',
          style: AppTypography.h2,
        ),
        SizedBox(height: AppSpacing.md),
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
        SizedBox(height: AppSpacing.md),
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
    return Card(
      elevation: isRecommended ? 4 : 1,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'おすすめ',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isRecommended) SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.h3,
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTypography.h1.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    '/ $period',
                    style: AppTypography.body.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            if (savings != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                savings,
                style: AppTypography.caption.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePurchase(context, ref, plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRecommended
                      ? Theme.of(context).colorScheme.primary
                      : null,
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
    return Column(
      children: [
        Text(
          'サブスクリプションの管理',
          style: AppTypography.h3,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'サブスクリプションのキャンセルや変更は、\nApp Store / Google Play Storeの設定から行えます。',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(
            color: Colors.grey,
          ),
        ),
        SizedBox(height: AppSpacing.md),
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
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
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
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    // ローディング表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('復元する購入が見つかりませんでした'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // ローディングを閉じる
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
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
