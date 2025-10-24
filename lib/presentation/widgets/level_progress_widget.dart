import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/onboarding/progressive_onboarding.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/feature_lock_widget.dart';

/// レベル進捗表示ウィジェット
/// 現在のレベルと次のレベルまでの進捗を表示
class LevelProgressWidget extends ConsumerWidget {
  final bool isCompact;
  final VoidCallback? onTap;

  const LevelProgressWidget({super.key, this.isCompact = false, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final onboarding = ref.watch(progressiveOnboardingProvider);

    return onboarding.when(
      data: (service) => _buildProgressWidget(context, tokens, service),
      loading: () => _buildLoadingWidget(tokens),
      error: (_, __) => _buildErrorWidget(tokens),
    );
  }

  Widget _buildProgressWidget(
    BuildContext context,
    MinqTheme tokens,
    ProgressiveOnboarding service,
  ) {
    // TODO: 実際のユーザーデータを取得
    final progress = service.getProgress(
      questsCompleted: 12,
      daysUsed: 6,
      currentStreak: 3,
    );

    final currentLevelInfo = service.getLevel(progress.currentLevel);
    final nextLevelInfo =
        progress.nextLevel != null
            ? service.getLevel(progress.nextLevel!)
            : null;

    if (isCompact) {
      return _buildCompactWidget(context, tokens, progress, currentLevelInfo);
    }

    return _buildFullWidget(
      context,
      tokens,
      progress,
      currentLevelInfo,
      nextLevelInfo,
    );
  }

  Widget _buildCompactWidget(
    BuildContext context,
    MinqTheme tokens,
    OnboardingProgress progress,
    OnboardingLevel? currentLevelInfo,
  ) {
    return GestureDetector(
      onTap: onTap ?? () => _showLevelDetails(context, progress),
      child: Container(
        padding: EdgeInsets.all(tokens.spacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              tokens.brandPrimary.withAlpha((255 * 0.1).round()),
              Colors.purple.withAlpha((255 * 0.1).round()),
            ],
          ),
          borderRadius: BorderRadius.circular(tokens.radius.md),
          border:
              Border.all(color: tokens.brandPrimary.withAlpha((255 * 0.3).round())),
        ),
        child: Row(
          children: [
            // レベルアイコン
            Container(
              width: tokens.spacing.xl,
              height: tokens.spacing.xl,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tokens.brandPrimary, Colors.purple.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${progress.currentLevel}',
                  style: tokens.typography.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(width: tokens.spacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentLevelInfo?.title ?? 'レベル${progress.currentLevel}',
                    style: tokens.typography.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: tokens.spacing.xs),

                  if (!progress.isMaxLevel) ...[
                    LinearProgressIndicator(
                      value: progress.progress,
                      backgroundColor: tokens.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        tokens.brandPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      '次のレベルまで ${((1 - progress.progress) * 100).toInt()}%',
                      style:
                          tokens.typography.caption.copyWith(color: tokens.textMuted),
                    ),
                  ] else
                    Text(
                      '最高レベル達成！',
                      style: tokens.typography.caption.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildFullWidget(
    BuildContext context,
    MinqTheme tokens,
    OnboardingProgress progress,
    OnboardingLevel? currentLevelInfo,
    OnboardingLevel? nextLevelInfo,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.brandPrimary.withAlpha((255 * 0.1).round()),
            Colors.purple.withAlpha((255 * 0.1).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border:
            Border.all(color: tokens.brandPrimary.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Icon(
                Icons.star,
                color: tokens.brandPrimary,
                size: tokens.spacing.lg,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                'あなたのレベル',
                style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (onTap != null)
                GestureDetector(
                  onTap: onTap,
                  child: Icon(
                    Icons.info_outline,
                    size: tokens.spacing.md,
                    color: tokens.textMuted,
                  ),
                ),
            ],
          ),

          SizedBox(height: tokens.spacing.lg),

          // 現在のレベル
          Row(
            children: [
              Container(
                width: tokens.spacing.xl * 2,
                height: tokens.spacing.xl * 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tokens.brandPrimary, Colors.purple.shade600],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          tokens.brandPrimary.withAlpha((255 * 0.3).round()),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${progress.currentLevel}',
                    style: tokens.typography.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(width: tokens.spacing.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentLevelInfo?.title ?? 'レベル${progress.currentLevel}',
                      style: tokens.typography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      currentLevelInfo?.description ?? '',
                      style: tokens.typography.body.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.lg),

          if (!progress.isMaxLevel && nextLevelInfo != null) ...[
            // 次のレベルへの進捗
            _buildNextLevelSection(tokens, progress, nextLevelInfo),
          ] else ...[
            // 最高レベル達成
            _buildMaxLevelSection(tokens),
          ],
        ],
      ),
    );
  }

  Widget _buildNextLevelSection(
    MinqTheme tokens,
    OnboardingProgress progress,
    OnboardingLevel nextLevelInfo,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '次のレベル: ${nextLevelInfo.title}',
              style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${(progress.progress * 100).toInt()}%',
              style: tokens.typography.h3.copyWith(
                color: tokens.brandPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        SizedBox(height: tokens.spacing.sm),

        // 進捗バー
        Container(
          height: tokens.spacing.sm,
          decoration: BoxDecoration(
            color: tokens.border,
            borderRadius: BorderRadius.circular(tokens.radius.sm),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tokens.brandPrimary, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
            ),
          ),
        ),

        SizedBox(height: tokens.spacing.md),

        // 詳細進捗
        if (progress.questProgress != null ||
            progress.daysProgress != null ||
            progress.streakProgress != null)
          _buildDetailedProgress(tokens, progress),

        SizedBox(height: tokens.spacing.md),

        // 解放される機能プレビュー
        _buildUnlockPreview(tokens, nextLevelInfo),
      ],
    );
  }

  Widget _buildDetailedProgress(
    MinqTheme tokens,
    OnboardingProgress progress,
  ) {
    return Row(
      children: [
        if (progress.questProgress != null)
          Expanded(
            child: _buildProgressItem(
              tokens,
              'クエスト',
              progress.questProgress!,
              Icons.task_alt,
            ),
          ),

        if (progress.daysProgress != null) ...[
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: _buildProgressItem(
              tokens,
              '使用日数',
              progress.daysProgress!,
              Icons.calendar_today,
            ),
          ),
        ],

        if (progress.streakProgress != null) ...[
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: _buildProgressItem(
              tokens,
              'ストリーク',
              progress.streakProgress!,
              Icons.local_fire_department,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressItem(
    MinqTheme tokens,
    String label,
    double progress,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: tokens.spacing.lg,
            color: progress >= 1.0 ? Colors.green : tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            label,
            style: tokens.typography.caption.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: tokens.typography.caption.copyWith(
              color: progress >= 1.0 ? Colors.green : tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockPreview(MinqTheme tokens, OnboardingLevel nextLevelInfo) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: Colors.green.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_open,
                color: Colors.green,
                size: tokens.spacing.lg,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                '解放される機能',
                style: tokens.typography.body.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.sm),

          Wrap(
            spacing: tokens.spacing.sm,
            runSpacing: tokens.spacing.xs,
            children:
                nextLevelInfo.unlockedFeatures.map((feature) {
                  final featureInfo = _getFeatureDisplayName(feature);
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.sm,
                      vertical: tokens.spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha((255 * 0.2).round()),
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                    ),
                    child: Text(
                      featureInfo,
                      style: tokens.typography.caption.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMaxLevelSection(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withAlpha((255 * 0.2).round()),
            Colors.orange.withAlpha((255 * 0.2).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: tokens.spacing.xl,
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '最高レベル達成！',
                  style: tokens.typography.h3.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  'すべての機能が解放されました。素晴らしい！',
                  style: tokens.typography.body.copyWith(
                    color: Colors.amber.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: tokens.textMuted,
            size: tokens.spacing.lg,
          ),
          SizedBox(width: tokens.spacing.md),
          Text(
            'レベル情報を読み込めませんでした',
            style: tokens.typography.body.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }

  void _showLevelDetails(BuildContext context, OnboardingProgress progress) {
    // TODO: レベル詳細画面を表示
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('レベル詳細'),
            content: Text(
              '現在レベル: ${progress.currentLevel}\n進捗: ${(progress.progress * 100).toInt()}%',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ],
          ),
    );
  }

  String _getFeatureDisplayName(String featureId) {
    return switch (featureId) {
      'quest_create' => 'クエスト作成',
      'quest_complete' => 'クエスト完了',
      'basic_stats' => '基本統計',
      'notifications' => '通知',
      'streak_tracking' => 'ストリーク',
      'weekly_stats' => '週間統計',
      'pair_feature' => 'ペア機能',
      'advanced_stats' => '高度な統計',
      'export_data' => 'データエクスポート',
      'tags' => 'タグ',
      'achievements' => '実績',
      'events' => 'イベント',
      'templates' => 'テンプレート',
      'timer' => 'タイマー',
      'advanced_customization' => 'カスタマイズ',
      _ => featureId,
    };
  }
}
