import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/xp_system.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/gamification/xp_transaction.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/screens/xp_history_screen.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// 強化されたレベル進捗ウィジェット（要件48）
/// XPシステムと統合されたレベル表示とアニメーション
class EnhancedLevelProgressWidget extends ConsumerWidget {
  final bool isCompact;
  final VoidCallback? onTap;
  final bool showXPDetails;
  final bool showAnimation;

  const EnhancedLevelProgressWidget({
    super.key,
    this.isCompact = false,
    this.onTap,
    this.showXPDetails = true,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(uidProvider);
    
    if (uid == null) {
      return _buildLoginPrompt(tokens, l10n);
    }

    final xpSystem = ref.watch(xpSystemProvider);
    
    return FutureBuilder<UserLevelProgress>(
      future: xpSystem.getUserLevelProgress(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget(tokens);
        }
        
        if (snapshot.hasError) {
          return _buildErrorWidget(tokens, l10n);
        }
        
        final progress = snapshot.data!;
        
        if (isCompact) {
          return _buildCompactWidget(context, progress, tokens, l10n);
        }
        
        return _buildFullWidget(context, progress, tokens, l10n);
      },
    );
  }

  Widget _buildCompactWidget(
    BuildContext context,
    UserLevelProgress progress,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: onTap ?? () => _showLevelDetails(context, progress),
      child: Container(
        padding: EdgeInsets.all(tokens.spacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              tokens.brandPrimary.withOpacity(0.1),
              tokens.brandSecondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(tokens.radius.lg),
          border: Border.all(
            color: tokens.brandPrimary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // レベルアイコン
            _buildLevelIcon(progress, tokens),
            
            SizedBox(width: tokens.spacing.md),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.currentLevelInfo.name,
                    style: tokens.typography.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: tokens.spacing.xs),
                  
                  if (!progress.isMaxLevel) ...[
                    _buildProgressBar(progress, tokens),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      '${progress.xpToNextLevel} XP to next level',
                      style: tokens.typography.caption.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ] else
                    Text(
                      l10n.maxLevelReached,
                      style: tokens.typography.caption.copyWith(
                        color: tokens.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            
            if (showXPDetails) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${progress.currentXP}',
                    style: tokens.typography.h4.copyWith(
                      color: tokens.brandPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'XP',
                    style: tokens.typography.caption.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ],
            
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: tokens.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidget(
    BuildContext context,
    UserLevelProgress progress,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.brandPrimary.withOpacity(0.1),
            tokens.brandSecondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(
          color: tokens.brandPrimary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: tokens.brandPrimary,
                size: 24,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                l10n.yourLevel,
                style: tokens.typography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (onTap != null)
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const XPHistoryScreen(),
                    ),
                  ),
                  child: Icon(
                    Icons.history,
                    size: 20,
                    color: tokens.textSecondary,
                  ),
                ),
            ],
          ),

          SizedBox(height: tokens.spacing.lg),

          // 現在のレベル
          Row(
            children: [
              _buildLevelIcon(progress, tokens, size: 80),
              
              SizedBox(width: tokens.spacing.lg),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.currentLevelInfo.name,
                      style: tokens.typography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      progress.currentLevelInfo.description,
                      style: tokens.typography.body.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    if (showXPDetails)
                      _buildXPDisplay(progress, tokens, l10n),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.lg),

          if (!progress.isMaxLevel && progress.nextLevelInfo != null) ...[
            // 次のレベルへの進捗
            _buildNextLevelSection(context, progress, tokens, l10n),
          ] else ...[
            // 最高レベル達成
            _buildMaxLevelSection(context, tokens, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelIcon(UserLevelProgress progress, MinqTheme tokens, {double size = 64}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.brandPrimary,
            tokens.brandSecondary,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: tokens.brandPrimary.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${progress.currentLevel}',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(UserLevelProgress progress, MinqTheme tokens) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.progressToNextLevel,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tokens.brandPrimary,
                tokens.brandSecondary,
              ],
            ),
            borderRadius: BorderRadius.circular(tokens.radius.sm),
          ),
        ),
      ),
    );
  }

  Widget _buildXPDisplay(UserLevelProgress progress, MinqTheme tokens, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            color: tokens.brandPrimary,
            size: 16,
          ),
          SizedBox(width: tokens.spacing.xs),
          Text(
            '${progress.currentXP} XP',
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextLevelSection(
    BuildContext context,
    UserLevelProgress progress,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    final nextLevel = progress.nextLevelInfo!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${l10n.nextLevel}: ${nextLevel.name}',
              style: tokens.typography.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress.progressToNextLevel * 100).toInt()}%',
              style: tokens.typography.h4.copyWith(
                color: tokens.brandPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        SizedBox(height: tokens.spacing.sm),

        // 進捗バー
        _buildProgressBar(progress, tokens),

        SizedBox(height: tokens.spacing.sm),

        Text(
          '${progress.xpToNextLevel} XP ${l10n.remaining}',
          style: tokens.typography.bodySmall.copyWith(
            color: tokens.textSecondary,
          ),
        ),

        SizedBox(height: tokens.spacing.md),

        // 解放される機能プレビュー
        _buildUnlockPreview(context, nextLevel, tokens, l10n),
      ],
    );
  }

  Widget _buildUnlockPreview(
    BuildContext context,
    LevelInfo nextLevel,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    if (nextLevel.unlockedFeatures.isEmpty && nextLevel.rewards.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(
          color: tokens.success.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_open,
                color: tokens.success,
                size: 20,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                l10n.unlockRewards,
                style: tokens.typography.body.copyWith(
                  color: tokens.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.sm),

          Wrap(
            spacing: tokens.spacing.xs,
            runSpacing: tokens.spacing.xs,
            children: [
              ...nextLevel.rewards.map((reward) => _buildRewardChip(reward, tokens)),
              ...nextLevel.unlockedFeatures.map((feature) => 
                _buildFeatureChip(feature, tokens, l10n)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardChip(String reward, MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.success.withOpacity(0.2),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Text(
        reward,
        style: tokens.typography.caption.copyWith(
          color: tokens.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String feature, MinqTheme tokens, AppLocalizations l10n) {
    final featureName = _getFeatureDisplayName(feature, l10n);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.info.withOpacity(0.2),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Text(
        featureName,
        style: tokens.typography.caption.copyWith(
          color: tokens.info,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMaxLevelSection(BuildContext context, MinqTheme tokens, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.2),
            Colors.orange.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 32,
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.maxLevelReached,
                  style: tokens.typography.h4.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  l10n.allFeaturesUnlocked,
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

  Widget _buildErrorWidget(MinqTheme tokens, AppLocalizations l10n) {
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
            color: tokens.error,
            size: 24,
          ),
          SizedBox(width: tokens.spacing.md),
          Text(
            l10n.errorLoadingLevel,
            style: tokens.typography.body.copyWith(
              color: tokens.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(MinqTheme tokens, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            color: tokens.textMuted,
            size: 24,
          ),
          SizedBox(width: tokens.spacing.md),
          Text(
            l10n.pleaseLogin,
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelDetails(BuildContext context, UserLevelProgress progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${AppLocalizations.of(context).level} ${progress.currentLevel}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(progress.currentLevelInfo.name),
            const SizedBox(height: 8),
            Text(progress.currentLevelInfo.description),
            const SizedBox(height: 16),
            Text('${AppLocalizations.of(context).currentXP}: ${progress.currentXP}'),
            if (!progress.isMaxLevel)
              Text('${AppLocalizations.of(context).xpToNext}: ${progress.xpToNextLevel}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).close),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const XPHistoryScreen(),
                ),
              );
            },
            child: Text(AppLocalizations.of(context).viewHistory),
          ),
        ],
      ),
    );
  }

  String _getFeatureDisplayName(String featureId, AppLocalizations l10n) {
    return switch (featureId) {
      'quest_create' => l10n.questCreation,
      'quest_complete' => l10n.questCompletion,
      'basic_stats' => l10n.basicStats,
      'notifications' => l10n.notifications,
      'streak_tracking' => l10n.streakTracking,
      'weekly_stats' => l10n.weeklyStats,
      'pair_feature' => l10n.pairFeature,
      'advanced_stats' => l10n.advancedStats,
      'export_data' => l10n.dataExport,
      'tags' => l10n.tags,
      'achievements' => l10n.achievements,
      'events' => l10n.events,
      'templates' => l10n.templates,
      'timer' => l10n.timer,
      'advanced_customization' => l10n.advancedCustomization,
      _ => featureId,
    };
  }
}