import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/onboarding/progressive_onboarding.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// 機能ロックウィジェット
/// ロックされた機能を表示し、解放条件を説明
class FeatureLockWidget extends ConsumerWidget {
  final String featureId;
  final Widget child;
  final String? customMessage;
  final VoidCallback? onTap;

  const FeatureLockWidget({
    super.key,
    required this.featureId,
    required this.child,
    this.customMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final onboarding = ref.watch(progressiveOnboardingProvider);

    return onboarding.when(
      data: (service) {
        final isUnlocked = service.isFeatureUnlocked(featureId);

        if (isUnlocked) {
          return child;
        }

        return _buildLockedFeature(context, tokens, service);
      },
      loading: () => _buildLoadingState(tokens),
      error: (_, __) => child, // エラー時は機能を表示
    );
  }

  Widget _buildLockedFeature(
    BuildContext context,
    MinqTheme tokens,
    ProgressiveOnboarding service,
  ) {
    final requiredLevel = _getRequiredLevel(featureId);
    final currentLevel = service.currentLevel;

    return GestureDetector(
      onTap: onTap ?? () => _showUnlockDialog(context, tokens, requiredLevel),
      child: Stack(
        children: [
          // 元のウィジェットを薄く表示
          Opacity(opacity: 0.3, child: IgnorePointer(child: child)),

          // ロックオーバーレイ
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((255 * 0.7).round()),
                borderRadius: BorderRadius.circular(tokens.radius.md),
                border: Border.all(
                  color: Colors.orange.withAlpha((255 * 0.5).round()),
                  width: 2,
                ),
              ),
              child: _buildLockContent(tokens, requiredLevel, currentLevel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockContent(
    MinqTheme tokens,
    int requiredLevel,
    int currentLevel,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ロックアイコン
          Container(
            width: tokens.spacing.xl,
            height: tokens.spacing.xl,
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha((255 * 0.2).round()),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Icon(
              Icons.lock,
              color: Colors.orange,
              size: tokens.spacing.lg,
            ),
          ),

          SizedBox(height: tokens.spacing.sm),

          // レベル要件
          Text(
            'レベル$requiredLevel で解放',
            style: tokens.typography.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: tokens.spacing.xs),

          // 現在のレベル
          Text(
            '現在: レベル$currentLevel',
            style: tokens.typography.caption.copyWith(
              color: Colors.white.withAlpha((255 * 0.8).round()),
            ),
          ),

          SizedBox(height: tokens.spacing.sm),

          // タップヒント
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.md,
              vertical: tokens.spacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha((255 * 0.2).round()),
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            child: Text(
              'タップで詳細',
              style: tokens.typography.caption.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(MinqTheme tokens) {
    return Stack(
      children: [
        Opacity(opacity: 0.5, child: child),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((255 * 0.3).round()),
              borderRadius: BorderRadius.circular(tokens.radius.md),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }

  void _showUnlockDialog(
    BuildContext context,
    MinqTheme tokens,
    int requiredLevel,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => FeatureUnlockDialog(
            featureId: featureId,
            requiredLevel: requiredLevel,
            customMessage: customMessage,
          ),
    );
  }

  int _getRequiredLevel(String featureId) {
    return switch (featureId) {
      'quest_create' || 'quest_complete' || 'basic_stats' => 1,
      'notifications' || 'streak_tracking' || 'weekly_stats' => 2,
      'pair_feature' || 'advanced_stats' || 'export_data' || 'tags' => 3,
      'achievements' ||
      'events' ||
      'templates' ||
      'timer' ||
      'advanced_customization' => 4,
      _ => 1,
    };
  }
}

/// 機能解放ダイアログ
class FeatureUnlockDialog extends ConsumerWidget {
  final String featureId;
  final int requiredLevel;
  final String? customMessage;

  const FeatureUnlockDialog({
    super.key,
    required this.featureId,
    required this.requiredLevel,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final onboarding = ref.watch(progressiveOnboardingProvider);

    return onboarding.when(
      data: (service) => _buildDialog(context, tokens, service),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildErrorDialog(context, tokens),
    );
  }

  Widget _buildDialog(
    BuildContext context,
    MinqTheme tokens,
    ProgressiveOnboarding service,
  ) {
    final levelInfo = service.getLevel(requiredLevel);
    final progress = service.getProgress(
      questsCompleted: 10, // TODO: 実際の値を取得
      daysUsed: 5,
      currentStreak: 2,
    );

    return Dialog(
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.orange,
                  size: tokens.spacing.xl,
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Text(
                    '機能がロックされています',
                    style: tokens.typography.h2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            SizedBox(height: tokens.spacing.lg),

            // 機能情報
            _buildFeatureInfo(tokens),

            SizedBox(height: tokens.spacing.lg),

            // レベル要件
            if (levelInfo != null) _buildLevelRequirement(tokens, levelInfo),

            SizedBox(height: tokens.spacing.lg),

            // 進捗表示
            _buildProgressSection(tokens, progress),

            SizedBox(height: tokens.spacing.xl),

            // アクションボタン
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context).close),
                  ),
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: 進捗画面に遷移
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.brandPrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.of(context).progress),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureInfo(MinqTheme tokens) {
    final featureInfo = _getFeatureInfo(featureId);

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Row(
        children: [
          Container(
            width: tokens.spacing.xl,
            height: tokens.spacing.xl,
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha((255 * 0.1).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(
              featureInfo.icon,
              color: Colors.orange,
              size: tokens.spacing.lg,
            ),
          ),

          SizedBox(width: tokens.spacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  featureInfo.name,
                  style: tokens.typography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  featureInfo.description,
                  style: tokens.typography.body.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelRequirement(MinqTheme tokens, OnboardingLevel levelInfo) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: Colors.orange.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange, size: tokens.spacing.md),
              SizedBox(width: tokens.spacing.sm),
              Text(
                'レベル$requiredLevel: ${levelInfo.title}',
                style: tokens.typography.h3.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.sm),

          Text(levelInfo.description, style: tokens.typography.body),

          SizedBox(height: tokens.spacing.md),

          Text(
            '解放条件:',
            style: tokens.typography.body.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: tokens.spacing.xs),

          _buildRequirementItem(
            tokens,
            Icons.task_alt,
            'クエスト${levelInfo.requirements.minQuestsCompleted}個完了',
          ),

          _buildRequirementItem(
            tokens,
            Icons.calendar_today,
            '${levelInfo.requirements.minDaysUsed}日間使用',
          ),

          if (levelInfo.requirements.minStreak > 0)
            _buildRequirementItem(
              tokens,
              Icons.local_fire_department,
              '${levelInfo.requirements.minStreak}日連続記録',
            ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(MinqTheme tokens, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.xs),
      child: Row(
        children: [
          Icon(icon, size: tokens.spacing.lg, color: tokens.textMuted),
          SizedBox(width: tokens.spacing.sm),
          Text(
            text,
            style: tokens.typography.caption.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(MinqTheme tokens, OnboardingProgress progress) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '現在の進捗',
            style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: tokens.spacing.md),

          if (progress.questProgress != null)
            _buildProgressBar(
              tokens,
              'クエスト完了',
              progress.questProgress!,
              Icons.task_alt,
            ),

          if (progress.daysProgress != null)
            _buildProgressBar(
              tokens,
              '使用日数',
              progress.daysProgress!,
              Icons.calendar_today,
            ),

          if (progress.streakProgress != null)
            _buildProgressBar(
              tokens,
              '連続記録',
              progress.streakProgress!,
              Icons.local_fire_department,
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    MinqTheme tokens,
    String label,
    double progress,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: tokens.spacing.lg, color: tokens.textMuted),
              SizedBox(width: tokens.spacing.sm),
              Text(
                label,
                style: tokens.typography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: tokens.typography.caption.copyWith(
                  color: tokens.textMuted,
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.xs),

          LinearProgressIndicator(
            value: progress,
            backgroundColor: tokens.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : tokens.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDialog(BuildContext context, MinqTheme tokens) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: tokens.spacing.xl * 2,
              color: tokens.textMuted,
            ),
            SizedBox(height: tokens.spacing.lg),
            Text(
              AppLocalizations.of(context).errorOccurred,
              style: tokens.typography.h3,
            ),
            SizedBox(height: tokens.spacing.lg),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).close),
            ),
          ],
        ),
      ),
    );
  }

  FeatureInfo _getFeatureInfo(String featureId) {
    return switch (featureId) {
      'pair_feature' => const FeatureInfo(
        name: 'ペア機能',
        description: '友達と一緒に習慣形成を楽しめます',
        icon: Icons.people,
      ),
      'achievements' => const FeatureInfo(
        name: '実績システム',
        description: 'バッジや称号を獲得して達成感を味わえます',
        icon: Icons.emoji_events,
      ),
      'events' => const FeatureInfo(
        name: 'イベント機能',
        description: '特別なチャレンジに参加できます',
        icon: Icons.event,
      ),
      'templates' => const FeatureInfo(
        name: 'テンプレート',
        description: '習慣のテンプレートを使って簡単に開始',
        icon: Icons.description_outlined,
      ),
      'timer' => const FeatureInfo(
        name: 'タイマー機能',
        description: '集中時間を測定して生産性を向上',
        icon: Icons.timer,
      ),
      _ => const FeatureInfo(
        name: '新機能',
        description: '新しい機能が利用できます',
        icon: Icons.star,
      ),
    };
  }
}

/// 機能情報
class FeatureInfo {
  final String name;
  final String description;
  final IconData icon;

  const FeatureInfo({
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// プログレッシブオンボーディングプロバイダー
final progressiveOnboardingProvider = FutureProvider<ProgressiveOnboarding>((
  ref,
) async {
  // TODO: 実際のユーザーデータを取得してレベルを設定
  return ProgressiveOnboarding();
});
