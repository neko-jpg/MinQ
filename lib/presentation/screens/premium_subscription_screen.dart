import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/domain/premium/premium_plan.dart';
import 'package:minq/presentation/widgets/common/loading_overlay.dart';
import 'package:minq/presentation/widgets/premium/premium_feature_list.dart';
import 'package:minq/presentation/widgets/premium/premium_plan_card.dart';
import 'package:minq/presentation/widgets/premium/subscription_benefits.dart';

class PremiumSubscriptionScreen extends ConsumerStatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  ConsumerState<PremiumSubscriptionScreen> createState() => _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends ConsumerState<PremiumSubscriptionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  BillingCycle _selectedBillingCycle = BillingCycle.yearly;
  bool _isLoading = false;

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
    final availablePlansAsync = ref.watch(availablePlansProvider);
    final currentTierAsync = ref.watch(currentTierProvider);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeroSection(context),
                  _buildBillingCycleToggle(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            availablePlansAsync.when(
              data: (plans) => currentTierAsync.when(
                data: (currentTier) => _buildPlansList(context, plans, currentTier),
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => const SliverToBoxAdapter(
                  child: Center(child: Text('Error loading current tier')),
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => const SliverToBoxAdapter(
                child: Center(child: Text('Error loading plans')),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const SubscriptionBenefits(),
                  const SizedBox(height: 32),
                  const PremiumFeatureList(),
                  const SizedBox(height: 32),
                  _buildFooter(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: context.colorTokens.surface,
      foregroundColor: context.colorTokens.textPrimary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Premium',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colorTokens.primary,
                  context.colorTokens.secondary,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Unlock Your Full Potential',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Get unlimited access to all premium features and take your habit building to the next level',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBillingCycleToggle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: context.colorTokens.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: context.colorTokens.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: context.colorTokens.textSecondary,
        dividerColor: Colors.transparent,
        onTap: (index) {
          setState(() {
            _selectedBillingCycle = index == 0 ? BillingCycle.monthly : BillingCycle.yearly;
          });
        },
        tabs: [
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Monthly'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Yearly'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.colorTokens.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Save 17%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildPlansList(BuildContext context, List<PremiumPlan> plans, PremiumTier currentTier) {
    final filteredPlans = plans.where((plan) => 
      plan.tier != PremiumTier.free && 
      plan.tier != currentTier
    ).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final plan = filteredPlans[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PremiumPlanCard(
                plan: plan,
                billingCycle: _selectedBillingCycle,
                isCurrentPlan: plan.tier == currentTier,
                onSubscribe: () => _handleSubscribe(plan),
              ),
            );
          },
          childCount: filteredPlans.length,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _showTermsOfService(),
                child: const Text('Terms of Service'),
              ),
              TextButton(
                onPressed: () => _showPrivacyPolicy(),
                child: const Text('Privacy Policy'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Cancel anytime. No hidden fees.',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorTokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe(PremiumPlan plan) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Show subscription options
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildSubscriptionBottomSheet(plan),
      );

      if (result == true) {
        // Simulate subscription process
        await Future.delayed(const Duration(seconds: 2));
        
        final subscription = PremiumSubscription(
          id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'current_user',
          planId: plan.id,
          tier: plan.tier,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(
            _selectedBillingCycle == BillingCycle.monthly
                ? const Duration(days: 30)
                : const Duration(days: 365),
          ),
          status: SubscriptionStatus.active,
          billingCycle: _selectedBillingCycle,
          autoRenew: true,
        );

        await ref.read(premiumServiceProvider).activateSubscription(subscription);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome to ${plan.name}! 🎉'),
              backgroundColor: context.colorTokens.success,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Subscription failed. Please try again.'),
            backgroundColor: context.colorTokens.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSubscriptionBottomSheet(PremiumPlan plan) {
    final price = _selectedBillingCycle == BillingCycle.monthly 
        ? plan.monthlyPrice 
        : plan.yearlyPrice;
    
    return Container(
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorTokens.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Subscribe to ${plan.name}',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorTokens.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedBillingCycle.name.toUpperCase()} PLAN',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorTokens.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedBillingCycle == BillingCycle.yearly)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colorTokens.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Save 17%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorTokens.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Subscription',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service content would go here...\n\n'
            'This is a placeholder for the actual terms of service.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy content would go here...\n\n'
            'This is a placeholder for the actual privacy policy.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}