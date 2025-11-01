import 'package:flutter/material.dart';
import 'package:minq/domain/premium/premium_plan.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';

class PremiumPlanCard extends StatelessWidget {
  final PremiumPlan plan;
  final BillingCycle billingCycle;
  final bool isCurrentPlan;
  final VoidCallback onSubscribe;

  const PremiumPlanCard({
    super.key,
    required this.plan,
    required this.billingCycle,
    required this.isCurrentPlan,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final price =
        billingCycle == BillingCycle.monthly
            ? plan.monthlyPrice
            : plan.yearlyPrice;

    final monthlyPrice =
        billingCycle == BillingCycle.yearly
            ? plan.yearlyPrice / 12
            : plan.monthlyPrice;

    return Container(
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              plan.isPopular
                  ? context.colorTokens.primary
                  : context.colorTokens.border,
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: [
          if (plan.isPopular)
            BoxShadow(
              color: context.colorTokens.primary.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildPricing(context, price, monthlyPrice),
                const SizedBox(height: 24),
                _buildFeatures(context),
                const SizedBox(height: 24),
                _buildActionButton(context),
              ],
            ),
          ),
          if (plan.isPopular) _buildPopularBadge(context),
          if (plan.discountPercentage != null) _buildDiscountBadge(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                plan.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (plan.isFamilyPlan)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.colorTokens.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.family_restroom,
                  size: 16,
                  color: context.colorTokens.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Family',
                  style: TextStyle(
                    color: context.colorTokens.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        if (plan.isStudentPlan)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.colorTokens.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school, size: 16, color: context.colorTokens.info),
                const SizedBox(width: 4),
                Text(
                  'Student',
                  style: TextStyle(
                    color: context.colorTokens.info,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPricing(
    BuildContext context,
    double price,
    double monthlyPrice,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: context.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorTokens.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '/${billingCycle == BillingCycle.monthly ? 'month' : 'year'}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorTokens.textSecondary,
              ),
            ),
          ],
        ),
        if (billingCycle == BillingCycle.yearly) ...[
          const SizedBox(height: 4),
          Text(
            '\$${monthlyPrice.toStringAsFixed(2)}/month when billed annually',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorTokens.textMuted,
            ),
          ),
        ],
        if (plan.discountPercentage != null) ...[
          const SizedBox(height: 4),
          Text(
            '${plan.discountPercentage!.toInt()}% off regular price',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorTokens.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features included:',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...plan.features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: context.colorTokens.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(feature, style: context.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (isCurrentPlan) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.colorTokens.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colorTokens.success),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: context.colorTokens.success,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Current Plan',
              style: TextStyle(
                color: context.colorTokens.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onSubscribe,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              plan.isPopular
                  ? context.colorTokens.primary
                  : context.colorTokens.surface,
          foregroundColor:
              plan.isPopular ? Colors.white : context.colorTokens.primary,
          side:
              plan.isPopular
                  ? null
                  : BorderSide(color: context.colorTokens.primary),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: plan.isPopular ? 2 : 0,
        ),
        child: Text(
          plan.isPopular ? 'Get Premium' : 'Choose Plan',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPopularBadge(BuildContext context) {
    return Positioned(
      top: -1,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colorTokens.primary,
              context.colorTokens.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 16, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Most Popular',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountBadge(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.colorTokens.warning,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${plan.discountPercentage!.toInt()}% OFF',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
