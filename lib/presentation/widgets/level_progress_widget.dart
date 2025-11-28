import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/onboarding/progressive_onboarding.dart';
import 'package:minq/presentation/screens/onboarding/level_up_screen.dart';
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
        padding: EdgeInsets.all(tokens.spacing(3)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              tokens.brandPrimary.withValues(alpha: 0.1),
              Colors.purple.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: tokens.cornerMedium(),
          border: Border.all(color: tokens.brandPrimary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // レベルアイコン
            Container(
              width: tokens.spacing(10),
              height: tokens.spacing(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tokens.brandPrimary, Colors.purple.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${progress.currentLevel}',
                  style: tokens.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(width: tokens.spacing(3)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentLevelInfo?.title ?? 'レベル${progress.currentLevel}',
                    style: tokens.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: tokens.spacing(1)),

                  if (!progress.isMaxLevel) ...[
                    LinearProgressIndicator(
                      value: progress.progress,
                      backgroundColor: tokens.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        tokens.brandPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(1)),
                    Text(
                      '次のレベルまで ${((1 - progress.progress) * 100).toInt()}%',
                      style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                    ),
                  ] else
                    Text(
                      '最高レベル達成！',
                      style: tokens.bodySmall.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: tokens.spacing(4),
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
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.brandPrimary.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.brandPrimary.withValues(alpha: 0.3)),
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
                size: tokens.spacing(6),
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(
                'あなたのレベル',
                style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (onTap != null)
                GestureDetector(
                  onTap: onTap,
                  child: Icon(
                    Icons.info_outline,
                    size: tokens.spacing(5),
                    color: tokens.textMuted,
                  ),
                ),
            ],
          ),

          SizedBox(height: tokens.spacing(4)),

          // 現在のレベル
          Row(
            children: [
              Container(
                width: tokens.spacing(16),
                height: tokens.spacing(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tokens.brandPrimary, Colors.purple.shade600],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: tokens.brandPrimary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${progress.currentLevel}',
                    style: tokens.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(width: tokens.spacing(4)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentLevelInfo?.title ?? 'レベル${progress.currentLevel}',
                      style: tokens.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(1)),
                    Text(
                      currentLevelInfo?.description ?? '',
                      style: tokens.bodyMedium.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing(4)),

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
              style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${(progress.progress * 100).toInt()}%',
              style: tokens.titleMedium.copyWith(
                color: tokens.brandPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        SizedBox(height: tokens.spacing(2)),

        // 進捗バー
        Container(
          height: tokens.spacing(2),
          decoration: BoxDecoration(
            color: tokens.border,
            borderRadius: tokens.cornerSmall(),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tokens.brandPrimary, Colors.purple.shade600],
                ),
                borderRadius: tokens.cornerSmall(),
              ),
            ),
          ),
        ),

        SizedBox(height: tokens.spacing(3)),

        // 詳細進捗
        if (progress.questProgress != null ||
            progress.daysProgress != null ||
            progress.streakProgress != null)
          _buildDetailedProgress(tokens, progress),

        SizedBox(height: tokens.spacing(3)),

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
          SizedBox(width: tokens.spacing(2)),
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
          SizedBox(width: tokens.spacing(2)),
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
      padding: EdgeInsets.all(tokens.spacing(2)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerSmall(),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: tokens.spacing(4),
            color: progress >= 1.0 ? Colors.green : tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing(1)),
          Text(
            label,
            style: tokens.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: tokens.bodySmall.copyWith(
              color: progress >= 1.0 ? Colors.green : tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockPreview(MinqTheme tokens, OnboardingLevel nextLevelInfo) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: tokens.cornerMedium(),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_open,
                color: Colors.green,
                size: tokens.spacing(4),
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(
                '解放される機能',
                style: tokens.bodyMedium.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing(2)),

          Wrap(
            spacing: tokens.spacing(2),
            runSpacing: tokens.spacing(1),
            children:
                nextLevelInfo.unlockedFeatures.map((feature) {
                  final featureInfo = _getFeatureDisplayName(feature);
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing(2),
                      vertical: tokens.spacing(1),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: tokens.cornerSmall(),
                    ),
                    child: Text(
                      featureInfo,
                      style: tokens.bodySmall.copyWith(
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
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.2),
            Colors.orange.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: tokens.cornerMedium(),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: tokens.spacing(8),
          ),
          SizedBox(width: tokens.spacing(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '最高レベル達成！',
                  style: tokens.titleMedium.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing(1)),
                Text(
                  'すべての機能が解放されました。素晴らしい！',
                  style: tokens.bodyMedium.copyWith(
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
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: tokens.cornerLarge(),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: tokens.cornerLarge(),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: tokens.textMuted,
            size: tokens.spacing(6),
          ),
          SizedBox(width: tokens.spacing(3)),
          Text(
            'レベル情報を読み込めませんでした',
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
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
