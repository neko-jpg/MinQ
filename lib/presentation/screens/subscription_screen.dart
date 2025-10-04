import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/subscription/subscription_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/theme/spacing_system.dart';
import 'package:minq/presentation/theme/typography_system.dart';

/// 繧ｵ繝悶せ繧ｯ繝ｪ繝励す繝ｧ繝ｳ逕ｻ髱｢
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlan = ref.watch(currentPlanProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('繝励Ξ繝溘い繝繝励Λ繝ｳ')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (isPremium) _buildCurrentPlanCard(context, currentPlan),
          if (!isPremium) _buildUpgradeHeader(context),
          const SizedBox(height: AppSpacing.lg),
          _buildFeaturesList(context),
          const SizedBox(height: AppSpacing.lg),
          _buildPricingCards(context, ref),
          const SizedBox(height: AppSpacing.lg),
          if (isPremium) _buildManageSubscription(context),
          if (!isPremium) _buildRestoreButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(BuildContext context, SubscriptionPlan plan) {
    final tokens = context.tokens;
    return Card(
      color: tokens.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 48, color: tokens.brandPrimary),
            const SizedBox(height: AppSpacing.sm),
            Text('繝励Ξ繝溘い繝莨壼藤', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(_getPlanName(plan), style: AppTypography.body),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeHeader(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.workspace_premium, size: 64, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: AppSpacing.md),
        Text('繝励Ξ繝溘い繝縺ｧ\n繧ゅ▲縺ｨ萓ｿ蛻ｩ縺ｫ', textAlign: TextAlign.center, style: AppTypography.h1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '蠎・相縺ｪ縺励・辟｡蛻ｶ髯舌・繧ｯ繧ｨ繧ｹ繝医・鬮伜ｺｦ縺ｪ邨ｱ險・,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      _FeatureItem(icon: Icons.block, title: '蠎・相髱櫁｡ｨ遉ｺ', description: '蠎・相縺ｪ縺励〒蠢ｫ驕ｩ縺ｫ蛻ｩ逕ｨ'),
      _FeatureItem(icon: Icons.all_inclusive, title: '辟｡蛻ｶ髯舌・繧ｯ繧ｨ繧ｹ繝・, description: '繧ｯ繧ｨ繧ｹ繝医ｒ辟｡蛻ｶ髯舌↓菴懈・'),
      _FeatureItem(icon: Icons.analytics, title: '鬮伜ｺｦ縺ｪ邨ｱ險・, description: '隧ｳ邏ｰ縺ｪ繧ｰ繝ｩ繝輔→蛻・梵'),
      _FeatureItem(icon: Icons.palette, title: '繧ｫ繧ｹ繧ｿ繝繝・・繝・, description: '縺雁･ｽ縺ｿ縺ｮ繧ｫ繝ｩ繝ｼ繝・・繝・),
      _FeatureItem(icon: Icons.support_agent, title: '蜆ｪ蜈医し繝昴・繝・, description: '蜆ｪ蜈育噪縺ｫ繧ｵ繝昴・繝亥ｯｾ蠢・),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('繝励Ξ繝溘い繝讖溯・', style: AppTypography.h2),
        const SizedBox(height: AppSpacing.md),
        ...features.map((feature) => _buildFeatureItem(context, feature)),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, _FeatureItem feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.title, style: AppTypography.h4),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  feature.description,
                  style: AppTypography.caption.copyWith(color: Colors.grey),
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
        Text('繝励Λ繝ｳ繧帝∈謚・, style: AppTypography.h2),
        const SizedBox(height: AppSpacing.md),
        _buildPricingCard(
          context,
          ref,
          plan: SubscriptionPlan.premiumYearly,
          title: '蟷ｴ髢薙・繝ｩ繝ｳ',
          price: 'ﾂ･4,800',
          period: '蟷ｴ',
          savings: '2繝ｶ譛亥・縺雁ｾ・,
          isRecommended: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPricingCard(
          context,
          ref,
          plan: SubscriptionPlan.premiumMonthly,
          title: '譛磯俣繝励Λ繝ｳ',
          price: 'ﾂ･480',
          period: '譛・,
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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '縺翫☆縺吶ａ',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isRecommended) const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTypography.h1.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text('/ $period', style: AppTypography.body.copyWith(color: Colors.grey)),
                ),
              ],
            ),
            if (savings != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                savings,
                style: AppTypography.caption.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePurchase(context, ref, plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRecommended ? Theme.of(context).colorScheme.primary : null,
                ),
                child: const Text('雉ｼ蜈･縺吶ｋ'),
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
        Text('繧ｵ繝悶せ繧ｯ繝ｪ繝励す繝ｧ繝ｳ縺ｮ邂｡逅・, style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '繧ｵ繝悶せ繧ｯ繝ｪ繝励す繝ｧ繝ｳ縺ｮ繧ｭ繝｣繝ｳ繧ｻ繝ｫ繧・､画峩縺ｯ縲―nApp Store / Google Play Store縺ｮ險ｭ螳壹°繧芽｡後∴縺ｾ縺吶・,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () {
            // TODO: 繧ｹ繝医い縺ｮ險ｭ螳夂判髱｢繧帝幕縺・
          },
          child: const Text('險ｭ螳壹ｒ髢九￥'),
        ),
      ],
    );
  }

  Widget _buildRestoreButton(BuildContext context, WidgetRef ref) {
    return Center(
      child: TextButton(onPressed: () => _handleRestore(context, ref), child: const Text('雉ｼ蜈･繧貞ｾｩ蜈・)),
    );
  }

  Future<void> _handlePurchase(BuildContext context, WidgetRef ref, SubscriptionPlan plan) async {
    // 繝ｭ繝ｼ繝・ぅ繝ｳ繧ｰ陦ｨ遉ｺ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = ref.read(subscriptionServiceProvider);
      final success = await service.purchase(plan);

      if (!context.mounted) return;
      Navigator.pop(context); // 繝ｭ繝ｼ繝・ぅ繝ｳ繧ｰ繧帝哩縺倥ｋ

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('雉ｼ蜈･縺悟ｮ御ｺ・＠縺ｾ縺励◆'), backgroundColor: Colors.green));
        Navigator.pop(context); // 逕ｻ髱｢繧帝哩縺倥ｋ
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('雉ｼ蜈･縺ｫ螟ｱ謨励＠縺ｾ縺励◆'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // 繝ｭ繝ｼ繝・ぅ繝ｳ繧ｰ繧帝哩縺倥ｋ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('繧ｨ繝ｩ繝ｼ縺檎匱逕溘＠縺ｾ縺励◆: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    // 繝ｭ繝ｼ繝・ぅ繝ｳ繧ｰ陦ｨ遉ｺ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = ref.read(subscriptionServiceProvider);
      final success = await service.restore();

      if (!context.mounted) return;
      Navigator.pop(context); // 繝ｭ繝ｼ繝・ぅ繝ｳ繧ｰ繧帝哩縺倥ｋ

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('雉ｼ蜈･繧貞ｾｩ蜈・＠縺ｾ縺励◆'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('蠕ｩ蜈・☆繧玖ｳｼ蜈･縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ縺ｧ縺励◆')));
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // 繝ｭ繝ｼ繝・ぅ繝ｳ繧ｰ繧帝哩縺倥ｋ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('繧ｨ繝ｩ繝ｼ縺檎匱逕溘＠縺ｾ縺励◆: $e'), backgroundColor: Colors.red));
    }
  }

  String _getPlanName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return '辟｡譁吶・繝ｩ繝ｳ';
      case SubscriptionPlan.premiumMonthly:
        return '譛磯俣繝励Λ繝ｳ';
      case SubscriptionPlan.premiumYearly:
        return '蟷ｴ髢薙・繝ｩ繝ｳ';
    }
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  _FeatureItem({required this.icon, required this.title, required this.description});
}
