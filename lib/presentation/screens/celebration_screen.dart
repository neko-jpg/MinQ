import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class CelebrationScreen extends ConsumerStatefulWidget {
  const CelebrationScreen({super.key});

  @override
  ConsumerState<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends ConsumerState<CelebrationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pingController;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePostCelebrationFlows();
    });
  }

  Future<void> _handlePostCelebrationFlows() async {
    await _maybeRequestNotificationPermission();
    if (!mounted) return;
    await _maybeTriggerInAppReview();
  }

  Future<void> _maybeRequestNotificationPermission() async {
    final notificationService = ref.read(notificationServiceProvider);
    final shouldShow = await notificationService.shouldRequestPermission();

    if (!shouldShow || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.read(localPreferencesServiceProvider);
    final hasEducated = await prefs.hasShownNotificationEducation();
    final tokens = context.tokens;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => _NotificationEducationDialog(
            l10n: l10n,
            tokens: tokens,
            showEducation: !hasEducated,
          ),
    );

    if (!mounted) return;

    if (!hasEducated) {
      await prefs.markNotificationEducationShown();
    }

    if (result == true) {
      final granted = await notificationService.requestPermission();
      if (mounted) {
        ref.read(notificationPermissionProvider.notifier).state = granted;
      }
      if (!granted) {
        await notificationService.recordPermissionRequestTimestamp();
      }
    } else {
      await notificationService.recordPermissionRequestTimestamp();
    }
  }

  Future<void> _maybeTriggerInAppReview() async {
    try {
      final currentStreak = await ref.read(streakProvider.future);
      if (mounted) {
        await ref
            .read(inAppReviewServiceProvider)
            .maybeRequestReview(currentStreak: currentStreak);
      }
    } catch (error) {
      logger.debug('In-app review trigger skipped', 
        data: {'error': error.toString()});
    }
  }

  Future<void> _shareAchievement() async {
    try {
      final streak = await ref.read(streakProvider.future);
      final totalCompleted = await ref.read(
        todayCompletionCountProvider.future,
      );
      final shareService = ref.read(shareServiceProvider);

      await shareService.shareAchievementWithOgp(
        questTitle: 'クエスト達成',
        currentStreak: streak,
        totalCompleted: totalCompleted,
      );
    } catch (error) {
      logger.error('Share failed', 
        data: {'error': error.toString()});
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('共有に失敗しました')));
      }
    }
  }

  @override
  void dispose() {
    _pingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final streak = ref.watch(streakProvider).asData?.value ?? 0;
    final longestStreak = ref.watch(longestStreakProvider).asData?.value ?? 0;
    final isLongestStreak = streak > 0 && streak >= longestStreak;

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              const Spacer(flex: 2),
              _buildCelebrationContent(tokens, isLongestStreak, streak, l10n),
              const Spacer(),
              _buildRewardCard(tokens, l10n),
              const Spacer(),
              _buildDoneButton(context, tokens, l10n),
            ],
          ),
          _buildCloseButton(context, tokens),
        ],
      ),
    );
  }

  Widget _buildCelebrationContent(
    MinqTheme tokens,
    bool isLongest,
    int streak,
    AppLocalizations l10n,
  ) {
    final titleText =
        isLongest
            ? l10n.celebrationNewLongestStreak
            : l10n.celebrationStreakMessage(streak);
    final subtitleText =
        isLongest
            ? l10n.celebrationLongestSubtitle
            : l10n.celebrationKeepGoingSubtitle;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 288,
            height: 288,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _PingAnimation(
                  controller: _pingController,
                  isLongest: isLongest,
                ),
                Text(
                  isLongest ? '🏆' : '🎉',
                  style: const TextStyle(fontSize: 72),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.spacing.lg),
          Text(
            titleText,
            style: tokens.typography.h1.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            subtitleText,
            style: tokens.typography.bodyLarge.copyWith(color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(MinqTheme tokens, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: tokens.spacing.sm),
            child: Text(
              l10n.celebrationRewardTitle,
              style: tokens.typography.h5.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Material(
            color: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(tokens.radius.lg),
            child: InkWell(
              onTap: () {
                /* TODO: Implement reward action */
              },
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              child: Container(
                padding: EdgeInsets.all(tokens.spacing.lg),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: tokens.spacing.xxl * 2,
                      height: tokens.spacing.xxl * 2,
                      decoration: BoxDecoration(
                        color: tokens.brandPrimary.withAlpha((255 * 0.2).round()),
                        borderRadius: BorderRadius.circular(tokens.radius.lg),
                      ),
                      child: Icon(
                        Icons.self_improvement,
                        color: tokens.brandPrimary,
                        size: tokens.spacing.xl,
                      ),
                    ),
                    SizedBox(width: tokens.spacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.celebrationRewardName,
                            style: tokens.typography.h5.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: tokens.spacing.xs),
                          Text(
                            l10n.celebrationRewardDescription,
                            style: tokens.typography.body.copyWith(
                              color: tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: tokens.spacing.lg,
                      color: tokens.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(
    BuildContext context,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.lg,
        tokens.spacing.lg,
        tokens.spacing.lg,
        tokens.spacing.xl,
      ),
      child: Column(
        children: [
          // 共有ボタン
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _shareAchievement(),
              icon: const Icon(Icons.share),
              label: const Text('達成を共有する'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: tokens.cornerFull(),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          // 完了ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ref.read(navigationUseCaseProvider).goHome(),
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.brandPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: tokens.spacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: tokens.cornerFull(),
                ),
              ),
              child: Text(
                l10n.celebrationDone,
                style: tokens.typography.h5.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context, MinqTheme tokens) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: tokens.spacing.sm,
      child: IconButton(
        icon: Container(
          width: tokens.spacing.xxl,
          height: tokens.spacing.xxl,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            shape: BoxShape.circle,
            backgroundBlendMode: BlendMode.overlay,
          ),
          child: const Icon(Icons.close, color: Colors.white),
        ),
        onPressed: () => ref.read(navigationUseCaseProvider).goHome(),
      ),
    );
  }
}

class _NotificationEducationDialog extends StatelessWidget {
  const _NotificationEducationDialog({
    required this.l10n,
    required this.tokens,
    required this.showEducation,
  });

  final AppLocalizations l10n;
  final MinqTheme tokens;
  final bool showEducation;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(l10n.notificationPermissionDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationPermissionDialogMessage,
            style: tokens.typography.body.copyWith(color: tokens.textPrimary),
          ),
          if (showEducation) ...[
            SizedBox(height: tokens.spacing.md),
            Text(
              l10n.notificationPermissionDialogBenefitsHeading,
              style: tokens.typography.body.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing.sm),
            _DialogBullet(
              text: l10n.notificationPermissionDialogBenefitReminders,
              tokens: tokens,
            ),
            _DialogBullet(
              text: l10n.notificationPermissionDialogBenefitPair,
              tokens: tokens,
            ),
            _DialogBullet(
              text: l10n.notificationPermissionDialogBenefitGoal,
              tokens: tokens,
            ),
          ],
          SizedBox(height: tokens.spacing.md),
          Text(
            l10n.notificationPermissionDialogFooter,
            style: tokens.typography.caption.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.later),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.enable),
        ),
      ],
    );
  }
}

class _DialogBullet extends StatelessWidget {
  const _DialogBullet({required this.text, required this.tokens});

  final String text;
  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: tokens.typography.body.copyWith(color: tokens.brandPrimary),
          ),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Text(
              text,
              style: tokens.typography.body.copyWith(color: tokens.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PingAnimation extends AnimatedWidget {
  final AnimationController controller;
  final bool isLongest;

  const _PingAnimation({required this.controller, this.isLongest = false})
    : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    final color = isLongest ? Colors.amber.shade400 : tokens.brandPrimary;

    return Opacity(
      opacity: 1.0 - animation.value,
      child: Container(
        width: 288 * animation.value,
        height: 288 * animation.value,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(77),
        ),
      ),
    );
  }
}
