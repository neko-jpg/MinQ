import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/domain/premium/premium_plan.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';
import 'package:minq/presentation/widgets/common/loading_overlay.dart';

class PremiumFeaturesOverviewScreen extends ConsumerStatefulWidget {
  const PremiumFeaturesOverviewScreen({super.key});

  @override
  ConsumerState<PremiumFeaturesOverviewScreen> createState() =>
      _PremiumFeaturesOverviewScreenState();
}

class _PremiumFeaturesOverviewScreenState
    extends ConsumerState<PremiumFeaturesOverviewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTierAsync = ref.watch(currentTierProvider);
    final activeBenefitsAsync = ref.watch(activeBenefitsProvider);
    final usageStatsAsync = ref.watch(premiumUsageStatsProvider);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  currentTierAsync.when(
                    data: (tier) => _buildCurrentPlanHeader(context, tier),
                    loading: () => _buildLoadingHeader(),
                    error: (error, stack) => _buildErrorHeader(),
                  ),
                  const SizedBox(height: 24),
                  _buildTabBar(context),
                ],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeaturesTab(context),
                  activeBenefitsAsync.when(
                    data: (benefits) => _buildBenefitsTab(context, benefits),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stack) =>
                            const Center(child: Text('Error loading benefits')),
                  ),
                  usageStatsAsync.when(
                    data: (stats) => _buildUsageTab(context, stats),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stack) => const Center(
                          child: Text('Error loading usage stats'),
                        ),
                  ),
                  _buildManageTab(context),
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
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Premium Features',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildCurrentPlanHeader(BuildContext context, PremiumTier tier) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colorTokens.primary, context.colorTokens.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(_getTierIcon(tier), size: 48, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Current Plan: ${tier.displayName}',
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getTierDescription(tier),
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha((255 * 0.9).round()),
            ),
            textAlign: TextAlign.center,
          ),
          if (tier == PremiumTier.free) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToSubscription(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: context.colorTokens.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Upgrade Now'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: context.colorTokens.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorHeader() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colorTokens.error.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorTokens.error),
      ),
      child: Text(
        'Error loading plan information',
        style: TextStyle(color: context.colorTokens.error),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
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
        tabs: const [
          Tab(text: 'Features'),
          Tab(text: 'Benefits'),
          Tab(text: 'Usage'),
          Tab(text: 'Manage'),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab(BuildContext context) {
    final features = [
      _FeatureInfo(
        icon: Icons.all_inclusive,
        title: 'Unlimited Quests',
        description: 'Create as many quests as you need without limits',
        isPremium: true,
        tier: PremiumTier.premium,
      ),
      const _FeatureInfo(
        icon: Icons.smart_toy,
        title: 'Priority AI Coach',
        description: 'Faster response times and advanced AI insights',
        isPremium: true,
        tier: PremiumTier.basic,
      ),
      const _FeatureInfo(
        icon: Icons.analytics,
        title: 'Advanced Analytics',
        description: 'Detailed insights, predictions, and custom dashboards',
        isPremium: true,
        tier: PremiumTier.premium,
      ),
      const _FeatureInfo(
        icon: Icons.palette,
        title: 'Premium Themes',
        description: 'Exclusive themes and animations',
        isPremium: true,
        tier: PremiumTier.basic,
      ),
      const _FeatureInfo(
        icon: Icons.download,
        title: 'Data Export',
        description: 'Export your data in CSV, PDF, and JSON formats',
        isPremium: true,
        tier: PremiumTier.premium,
      ),
      const _FeatureInfo(
        icon: Icons.cloud_upload,
        title: 'Cloud Backup',
        description: 'Automatic backup and restore across devices',
        isPremium: true,
        tier: PremiumTier.premium,
      ),
      const _FeatureInfo(
        icon: Icons.family_restroom,
        title: 'Family Sharing',
        description: 'Share with up to 6 family members',
        isPremium: true,
        tier: PremiumTier.family,
      ),
      const _FeatureInfo(
        icon: Icons.tune,
        title: 'Advanced Customization',
        description: 'Customize every aspect of the app interface',
        isPremium: true,
        tier: PremiumTier.premium,
      ),
      const _FeatureInfo(
        icon: Icons.support_agent,
        title: 'Priority Support',
        description: 'Get priority customer support and beta access',
        isPremium: true,
        tier: PremiumTier.premium,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(context, feature);
      },
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureInfo feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              feature.isPremium
                  ? context.colorTokens.primary.withAlpha((255 * 0.3).round())
                  : context.colorTokens.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  feature.isPremium
                      ? context.colorTokens.primary.withAlpha((255 * 0.1).round())
                      : context.colorTokens.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              color:
                  feature.isPremium
                      ? context.colorTokens.primary
                      : context.colorTokens.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        feature.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (feature.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorTokens.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          feature.tier.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsTab(
    BuildContext context,
    List<PremiumBenefit> benefits,
  ) {
    if (benefits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: 64,
              color: context.colorTokens.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No Premium Benefits',
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colorTokens.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to premium to unlock exclusive benefits',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorTokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _navigateToSubscription(),
              child: const Text('Upgrade Now'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return _buildBenefitCard(context, benefit);
      },
    );
  }

  Widget _buildBenefitCard(BuildContext context, PremiumBenefit benefit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorTokens.success.withAlpha((255 * 0.3).round())),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colorTokens.success.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getBenefitIcon(benefit.icon),
              color: context.colorTokens.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        benefit.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: context.colorTokens.success,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  benefit.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorTokens.textSecondary,
                  ),
                ),
                if (benefit.badgeText != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorTokens.warning.withAlpha((255 * 0.1).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      benefit.badgeText!,
                      style: TextStyle(
                        color: context.colorTokens.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTab(BuildContext context, PremiumUsageStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usage Statistics',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildUsageCard(
            context,
            'Quests Created',
            '${stats.questsCreated}',
            stats.questLimit == -1 ? 'Unlimited' : '/ ${stats.questLimit}',
            Icons.task_alt,
            stats.questLimit == -1
                ? 1.0
                : stats.questsCreated / stats.questLimit,
          ),
          const SizedBox(height: 16),
          _buildUsageCard(
            context,
            'AI Coach Interactions',
            '${stats.aiCoachInteractions}',
            'this month',
            Icons.smart_toy,
            null,
          ),
          const SizedBox(height: 16),
          _buildUsageCard(
            context,
            'Data Exports',
            '${stats.dataExports}',
            'total',
            Icons.download,
            null,
          ),
          const SizedBox(height: 16),
          _buildUsageCard(
            context,
            'Backups Created',
            '${stats.backupsCreated}',
            'total',
            Icons.cloud_upload,
            null,
          ),
          const SizedBox(height: 16),
          _buildUsageCard(
            context,
            'Storage Used',
            '${stats.storageUsed.toStringAsFixed(1)} GB',
            '/ ${stats.storageLimit.toStringAsFixed(0)} GB',
            Icons.storage,
            stats.storageUsed / stats.storageLimit,
          ),
          if (stats.familyMembersActive > 0) ...[
            const SizedBox(height: 16),
            _buildUsageCard(
              context,
              'Family Members',
              '${stats.familyMembersActive}',
              'active',
              Icons.family_restroom,
              null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    double? progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.colorTokens.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          value,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colorTokens.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subtitle,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: context.colorTokens.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8
                    ? context.colorTokens.warning
                    : context.colorTokens.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManageTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Subscription',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildManageOption(
            context,
            'Upgrade Plan',
            'Change to a higher tier plan',
            Icons.upgrade,
            () => _navigateToSubscription(),
          ),
          _buildManageOption(
            context,
            'Family Management',
            'Manage family members and invitations',
            Icons.family_restroom,
            () => _navigateToFamilyManagement(),
          ),
          _buildManageOption(
            context,
            'Student Verification',
            'Verify student status for discount',
            Icons.school,
            () => _navigateToStudentVerification(),
          ),
          _buildManageOption(
            context,
            'Data Export',
            'Export your data and progress',
            Icons.download,
            () => _navigateToDataExport(),
          ),
          _buildManageOption(
            context,
            'Backup Management',
            'Manage your cloud backups',
            Icons.cloud_upload,
            () => _navigateToBackupManagement(),
          ),
          _buildManageOption(
            context,
            'Premium Themes',
            'Browse and apply premium themes',
            Icons.palette,
            () => _navigateToPremiumThemes(),
          ),
          _buildManageOption(
            context,
            'Advanced Customization',
            'Customize app appearance and behavior',
            Icons.tune,
            () => _navigateToAdvancedCustomization(),
          ),
          const SizedBox(height: 32),
          _buildDangerZone(context),
        ],
      ),
    );
  }

  Widget _buildManageOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.colorTokens.primary.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: context.colorTokens.primary),
        ),
        title: Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: context.colorTokens.surface,
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorTokens.error.withAlpha((255 * 0.05).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorTokens.error.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorTokens.error,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.cancel, color: context.colorTokens.error),
            title: Text(
              'Cancel Subscription',
              style: TextStyle(color: context.colorTokens.error),
            ),
            subtitle: const Text('Cancel your premium subscription'),
            onTap: () => _showCancelSubscriptionDialog(),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  IconData _getTierIcon(PremiumTier tier) {
    switch (tier) {
      case PremiumTier.free:
        return Icons.person;
      case PremiumTier.basic:
        return Icons.star_outline;
      case PremiumTier.premium:
        return Icons.star;
      case PremiumTier.family:
        return Icons.family_restroom;
      case PremiumTier.student:
        return Icons.school;
    }
  }

  String _getTierDescription(PremiumTier tier) {
    switch (tier) {
      case PremiumTier.free:
        return 'Basic features with limited functionality';
      case PremiumTier.basic:
        return 'Essential premium features for habit building';
      case PremiumTier.premium:
        return 'Full access to all premium features';
      case PremiumTier.family:
        return 'Premium features for the whole family';
      case PremiumTier.student:
        return 'Premium features with student discount';
    }
  }

  IconData _getBenefitIcon(String iconName) {
    switch (iconName) {
      case 'infinity':
        return Icons.all_inclusive;
      case 'robot':
        return Icons.smart_toy;
      case 'chart':
        return Icons.analytics;
      case 'download':
        return Icons.download;
      case 'cloud':
        return Icons.cloud_upload;
      case 'family':
        return Icons.family_restroom;
      default:
        return Icons.star;
    }
  }

  void _navigateToSubscription() {
    context.push('/premium/subscription');
  }

  void _navigateToFamilyManagement() {
    context.push('/premium/family');
  }

  void _navigateToStudentVerification() {
    context.push('/premium/student');
  }

  void _navigateToDataExport() {
    context.push('/premium/export');
  }

  void _navigateToBackupManagement() {
    context.push('/premium/backup');
  }

  void _navigateToPremiumThemes() {
    context.push('/premium/themes');
  }

  void _navigateToAdvancedCustomization() {
    context.push('/premium/customization');
  }

  void _showCancelSubscriptionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Subscription'),
            content: const Text(
              'Are you sure you want to cancel your premium subscription? '
              'You will lose access to all premium features at the end of your current billing period.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Keep Subscription'),
              ),
              TextButton(
                onPressed: () => _cancelSubscription(),
                style: TextButton.styleFrom(
                  foregroundColor: context.colorTokens.error,
                ),
                child: const Text('Cancel Subscription'),
              ),
            ],
          ),
    );
  }

  Future<void> _cancelSubscription() async {
    Navigator.of(context).pop();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(premiumServiceProvider)
          .cancelSubscription('User requested cancellation');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Subscription cancelled successfully'),
            backgroundColor: context.colorTokens.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to cancel subscription'),
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
}

class _FeatureInfo {
  final IconData icon;
  final String title;
  final String description;
  final bool isPremium;
  final PremiumTier tier;

  const _FeatureInfo({
    required this.icon,
    required this.title,
    required this.description,
    required this.isPremium,
    required this.tier,
  });
}
