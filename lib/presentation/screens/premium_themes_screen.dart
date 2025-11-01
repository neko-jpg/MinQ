import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/core/premium/premium_themes_service.dart';
import 'package:minq/domain/premium/premium_plan.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';

class PremiumThemesScreen extends ConsumerStatefulWidget {
  const PremiumThemesScreen({super.key});

  @override
  ConsumerState<PremiumThemesScreen> createState() =>
      _PremiumThemesScreenState();
}

class _PremiumThemesScreenState extends ConsumerState<PremiumThemesScreen>
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
    final currentTierAsync = ref.watch(currentTierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Themes & Animations'),
        backgroundColor: context.colorTokens.surface,
        foregroundColor: context.colorTokens.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.colorTokens.primary,
          unselectedLabelColor: context.colorTokens.textSecondary,
          indicatorColor: context.colorTokens.primary,
          tabs: const [Tab(text: 'Themes'), Tab(text: 'Animations')],
        ),
      ),
      body: currentTierAsync.when(
        data:
            (tier) => TabBarView(
              controller: _tabController,
              children: [
                _buildThemesTab(context, tier),
                _buildAnimationsTab(context, tier),
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                const Center(child: Text('Error loading subscription status')),
      ),
    );
  }

  Widget _buildThemesTab(BuildContext context, PremiumTier currentTier) {
    final availableThemesAsync = ref.watch(availableThemesProvider);
    final currentThemeAsync = ref.watch(currentThemeProvider);

    return availableThemesAsync.when(
      data:
          (themes) => currentThemeAsync.when(
            data:
                (currentTheme) => _buildThemesList(
                  context,
                  themes,
                  currentTheme,
                  currentTier,
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) =>
                    const Center(child: Text('Error loading current theme')),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => const Center(child: Text('Error loading themes')),
    );
  }

  Widget _buildAnimationsTab(BuildContext context, PremiumTier currentTier) {
    final availableAnimationsAsync = ref.watch(availableAnimationsProvider);

    return availableAnimationsAsync.when(
      data:
          (animations) =>
              _buildAnimationsList(context, animations, currentTier),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              const Center(child: Text('Error loading animations')),
    );
  }

  Widget _buildThemesList(
    BuildContext context,
    List<PremiumTheme> themes,
    PremiumTheme? currentTheme,
    PremiumTier currentTier,
  ) {
    final groupedThemes = <ThemeCategory, List<PremiumTheme>>{};
    for (final theme in themes) {
      groupedThemes.putIfAbsent(theme.category, () => []).add(theme);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildThemesHeader(context),
        const SizedBox(height: 24),
        ...groupedThemes.entries.map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                child: Text(
                  _getCategoryDisplayName(entry.key),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: entry.value.length,
                itemBuilder: (context, index) {
                  final theme = entry.value[index];
                  final isSelected = currentTheme?.id == theme.id;
                  final canUse =
                      !theme.isPremium ||
                      currentTier.hasFeature(FeatureType.themes);

                  return _buildThemeCard(context, theme, isSelected, canUse);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationsList(
    BuildContext context,
    List<PremiumAnimation> animations,
    PremiumTier currentTier,
  ) {
    final groupedAnimations = <AnimationCategory, List<PremiumAnimation>>{};
    for (final animation in animations) {
      groupedAnimations
          .putIfAbsent(animation.category, () => [])
          .add(animation);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAnimationsHeader(context),
        const SizedBox(height: 24),
        ...groupedAnimations.entries.map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                child: Text(
                  _getAnimationCategoryDisplayName(entry.key),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...entry.value.map((animation) {
                final canUse =
                    !animation.isPremium ||
                    currentTier.hasFeature(FeatureType.themes);
                return FutureBuilder<bool>(
                  future: ref
                      .read(premiumThemesServiceProvider)
                      .isAnimationEnabled(animation.id),
                  builder: (context, snapshot) {
                    final isEnabled = snapshot.data ?? true;
                    return _buildAnimationCard(
                      context,
                      animation,
                      isEnabled,
                      canUse,
                    );
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemesHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Style',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personalize your MinQ experience with beautiful themes',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationsHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Animation Settings',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Customize animations and visual effects',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    PremiumTheme theme,
    bool isSelected,
    bool canUse,
  ) {
    return GestureDetector(
      onTap: canUse ? () => _selectTheme(theme) : () => _showPremiumRequired(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? context.colorTokens.primary
                    : context.colorTokens.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: context.colorTokens.primary.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient:
                          theme.gradientBackground ??
                          LinearGradient(
                            colors: [
                              theme.colorTokens.primary,
                              theme.colorTokens.secondary,
                            ],
                          ),
                    ),
                    child: Stack(
                      children: [
                        // Mock UI elements
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: theme.colorTokens.surface.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: 12,
                          right: 12,
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: theme.colorTokens.surface.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorTokens.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: theme.colorTokens.onPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colorTokens.surface,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          theme.description,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorTokens.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (theme.isPremium && !canUse)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: Colors.white, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.colorTokens.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationCard(
    BuildContext context,
    PremiumAnimation animation,
    bool isEnabled,
    bool canUse,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: context.colorTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorTokens.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colorTokens.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getAnimationIcon(animation.category),
                color: context.colorTokens.primary,
                size: 24,
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
                          animation.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (animation.isPremium && !canUse)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorTokens.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Premium',
                            style: TextStyle(
                              color: context.colorTokens.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    animation.description,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Switch(
              value: isEnabled && canUse,
              onChanged:
                  canUse ? (value) => _toggleAnimation(animation, value) : null,
              activeThumbColor: context.colorTokens.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTheme(PremiumTheme theme) async {
    final success = await ref
        .read(premiumThemesServiceProvider)
        .setTheme(theme.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Theme changed to ${theme.name}'),
          backgroundColor: context.colorTokens.success,
        ),
      );
      // Refresh the current theme
      ref.invalidate(currentThemeProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to change theme'),
          backgroundColor: context.colorTokens.error,
        ),
      );
    }
  }

  Future<void> _toggleAnimation(
    PremiumAnimation animation,
    bool enabled,
  ) async {
    final success = await ref
        .read(premiumThemesServiceProvider)
        .setAnimation(animation.id, enabled);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${animation.name} ${enabled ? 'enabled' : 'disabled'}',
          ),
          backgroundColor: context.colorTokens.success,
        ),
      );
      setState(() {}); // Refresh the animations list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update animation setting'),
          backgroundColor: context.colorTokens.error,
        ),
      );
    }
  }

  void _showPremiumRequired() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Premium Required'),
            content: const Text(
              'This theme is available for Premium subscribers only. Upgrade to unlock all themes and animations.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/premium');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorTokens.primary,
                ),
                child: const Text('Upgrade'),
              ),
            ],
          ),
    );
  }

  String _getCategoryDisplayName(ThemeCategory category) {
    switch (category) {
      case ThemeCategory.classic:
        return 'Classic';
      case ThemeCategory.minimal:
        return 'Minimal';
      case ThemeCategory.nature:
        return 'Nature';
      case ThemeCategory.futuristic:
        return 'Futuristic';
      case ThemeCategory.soft:
        return 'Soft';
    }
  }

  String _getAnimationCategoryDisplayName(AnimationCategory category) {
    switch (category) {
      case AnimationCategory.transitions:
        return 'Transitions';
      case AnimationCategory.effects:
        return 'Effects';
      case AnimationCategory.interactions:
        return 'Interactions';
      case AnimationCategory.loading:
        return 'Loading';
    }
  }

  IconData _getAnimationIcon(AnimationCategory category) {
    switch (category) {
      case AnimationCategory.transitions:
        return Icons.swap_horiz;
      case AnimationCategory.effects:
        return Icons.auto_awesome;
      case AnimationCategory.interactions:
        return Icons.touch_app;
      case AnimationCategory.loading:
        return Icons.hourglass_empty;
    }
  }
}
