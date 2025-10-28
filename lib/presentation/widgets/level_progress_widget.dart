import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/onboarding/progressive_onboarding.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/widgets/feature_lock_widget.dart';

/// レベル進捗表示ウィジェット
/// 現在のレベルと次のレベルまでの進捗を表示
class LevelProgressWidget extends ConsumerWidget {
  final bool isCompact;
  final VoidCallback? onTap;

  const LevelProgressWidget({super.key, this.isCompact = false, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(progressiveOnboardingProvider);

    return onboarding.when(
      data: (service) => _buildProgressWidget(context, service),
      loading: () => _buildLoadingWidget(context),
      error: (_, __) => _buildErrorWidget(context),
    );
  }

  Widget _buildProgressWidget(
    BuildContext context,
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
      return _buildCompactWidget(context, progress, currentLevelInfo);
    }

    return _buildFullWidget(
      context,
      progress,
      currentLevelInfo,
      nextLevelInfo,
    );
  }

  Widget _buildCompactWidget(
    BuildContext context,
    OnboardingProgress progress,
    OnboardingLevel? currentLevelInfo,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: onTap ?? () => _showLevelDetails(context, progress),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withAlpha((255 * 0.1).round()),
              Colors.purple.withAlpha((255 * 0.1).round()),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: colorScheme.primary.withAlpha((255 * 0.3).round())),
        ),
        child: Row(
          children: [
            // レベルアイコン
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, Colors.purple.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${progress.currentLevel}',
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentLevelInfo?.title ?? 'レベル${progress.currentLevel}',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  if (!progress.isMaxLevel) ...[
                    LinearProgressIndicator(
                      value: progress.progress,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '次のレベルまで ${((1 - progress.progress) * 100).toInt()}%',
                      style:
                          textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ] else
                    Text(
                      '最高レベル達成！',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidget(
    BuildContext context,
    OnboardingProgress progress,
    OnboardingLevel? currentLevelInfo,
    OnboardingLevel? nextLevelInfo,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withAlpha((255 * 0.1).round()),
            Colors.purple.withAlpha((255 * 0.1).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: colorScheme.primary.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Icon(
                Icons.star,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'あなたのレベル',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (onTap != null)
                GestureDetector(
                  onTap: onTap,
                  child: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 現在のレベル
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, Colors.purple.shade600],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          colorScheme.primary.withAlpha((255 * 0.3).round()),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${progress.currentLevel}',
                    style: textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentLevelInfo?.title ?? 'レベル${progress.currentLevel}',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentLevelInfo?.description ?? '',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (!progress.isMaxLevel && nextLevelInfo != null) ...[
            // 次のレベルへの進捗
            _buildNextLevelSection(context, progress, nextLevelInfo),
          ] else ...[
            // 最高レベル達成
            _buildMaxLevelSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildNextLevelSection(
    BuildContext context,
    OnboardingProgress progress,
    OnboardingLevel nextLevelInfo,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '次のレベル: ${nextLevelInfo.title}',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${(progress.progress * 100).toInt()}%',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 進捗バー
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 詳細進捗
        if (progress.questProgress != null ||
            progress.daysProgress != null ||
            progress.streakProgress != null)
          _buildDetailedProgress(context, progress),

        const SizedBox(height: 12),

        // 解放される機能プレビュー
        _buildUnlockPreview(context, nextLevelInfo),
      ],
    );
  }

  Widget _buildDetailedProgress(
    BuildContext context,
    OnboardingProgress progress,
  ) {
    return Row(
      children: [
        if (progress.questProgress != null)
          Expanded(
            child: _buildProgressItem(
              context,
              'クエスト',
              progress.questProgress!,
              Icons.task_alt,
            ),
          ),

        if (progress.daysProgress != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _buildProgressItem(
              context,
              '使用日数',
              progress.daysProgress!,
              Icons.calendar_today,
            ),
          ),
        ],

        if (progress.streakProgress != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _buildProgressItem(
              context,
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
    BuildContext context,
    String label,
    double progress,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: progress >= 1.0 ? Colors.green : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: textTheme.bodySmall?.copyWith(
              color: progress >= 1.0 ? Colors.green : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockPreview(BuildContext context, OnboardingLevel nextLevelInfo) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_open,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '解放される機能',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                nextLevelInfo.unlockedFeatures.map((feature) {
                  final featureInfo = _getFeatureDisplayName(feature);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha((255 * 0.2).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      featureInfo,
                      style: textTheme.bodySmall?.copyWith(
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

  Widget _buildMaxLevelSection(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withAlpha((255 * 0.2).round()),
            Colors.orange.withAlpha((255 * 0.2).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '最高レベル達成！',
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'すべての機能が解放されました。素晴らしい！',
                  style: textTheme.bodyMedium?.copyWith(
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

  Widget _buildLoadingWidget(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'レベル情報を読み込めませんでした',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
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
            title: Text(AppLocalizations.of(context)!.levelDetails),
            content: Text(
              AppLocalizations.of(context)!.levelDetailsMessage
                .toString()
                .replaceAll('{level}', progress.currentLevel.toString())
                .replaceAll('{progress}', (progress.progress * 100).toInt().toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.close),
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
