import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/onboarding/progressive_onboarding.dart';
import 'package:minq/presentation/controllers/progressive_onboarding_controller.dart';

/// プログレッシブオンボーディングウィジェット
/// ユーザーの進捗に応じてヒントを表示し、機能解放状態を管理
class ProgressiveOnboardingWidget extends ConsumerWidget {
  final Widget child;
  final String? screenId;

  const ProgressiveOnboardingWidget({
    super.key,
    required this.child,
    this.screenId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(progressiveOnboardingControllerProvider);
    
    return onboardingState.when(
      data: (onboarding) => _buildWithOnboarding(context, ref, onboarding),
      loading: () => child,
      error: (error, stack) => child,
    );
  }

  Widget _buildWithOnboarding(
    BuildContext context,
    WidgetRef ref,
    ProgressiveOnboarding onboarding,
  ) {
    // 画面表示時にヒントをチェック
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowHints(context, ref);
    });

    return Stack(
      children: [
        child,
        // レベルアップ通知
        _buildLevelUpNotification(context, ref),
        // 進捗インジケータ
        _buildProgressIndicator(context, ref, onboarding),
      ],
    );
  }

  /// ヒントをチェックして表示
  void _checkAndShowHints(BuildContext context, WidgetRef ref) {
    final controller = ref.read(progressiveOnboardingControllerProvider.notifier);
    
    // 画面固有のヒントを表示
    if (screenId != null) {
      switch (screenId) {
        case 'home':
          controller.showProgressHints(context);
          break;
        case 'create_quest':
          // クエスト作成画面では特別なヒントは表示しない
          break;
        case 'stats':
          // 統計画面では進捗ヒントを表示
          controller.showProgressHints(context);
          break;
      }
    }
  }

  /// レベルアップ通知を構築
  Widget _buildLevelUpNotification(BuildContext context, WidgetRef ref) {
    final levelUpEvent = ref.watch(levelUpEventProvider);
    
    if (levelUpEvent == null) {
      return const SizedBox.shrink();
    }

    // レベルアップアニメーションを表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLevelUpAnimation(context, levelUpEvent);
      // イベントをクリア
      ref.read(levelUpEventProvider.notifier).state = null;
    });

    return const SizedBox.shrink();
  }

  /// 進捗インジケータを構築
  Widget _buildProgressIndicator(
    BuildContext context,
    WidgetRef ref,
    ProgressiveOnboarding onboarding,
  ) {
    final progress = ref.watch(onboardingProgressProvider);
    
    if (progress == null || progress.isMaxLevel) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      right: 16,
      child: OnboardingProgressIndicator(
        progress: progress,
        onTap: () => _showProgressDetails(context, progress),
      ),
    );
  }

  /// レベルアップアニメーションを表示
  void _showLevelUpAnimation(BuildContext context, LevelUpEvent event) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpDialog(event: event),
    );
  }

  /// 進捗詳細を表示
  void _showProgressDetails(BuildContext context, OnboardingProgress progress) {
    showDialog(
      context: context,
      builder: (context) => OnboardingProgressDialog(progress: progress),
    );
  }
}

/// オンボーディング進捗インジケータ
class OnboardingProgressIndicator extends StatelessWidget {
  final OnboardingProgress progress;
  final VoidCallback? onTap;

  const OnboardingProgressIndicator({
    super.key,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Lv.${progress.currentLevel}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 40,
              height: 4,
              child: LinearProgressIndicator(
                value: progress.progress,
                backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// レベルアップダイアログ
class LevelUpDialog extends StatefulWidget {
  final LevelUpEvent event;

  const LevelUpDialog({
    super.key,
    required this.event,
  });

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // レベルアップアイコン
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // レベルアップテキスト
                  Text(
                    'レベルアップ！',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'レベル ${widget.event.oldLevel} → ${widget.event.newLevel}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // レベル情報
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.event.levelInfo.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.event.levelInfo.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        
                        // 解放された機能
                        if (widget.event.levelInfo.unlockedFeatures.isNotEmpty) ...[
                          Text(
                            '解放された機能:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...widget.event.levelInfo.unlockedFeatures.map(
                            (feature) => Text(
                              '• ${_getFeatureName(feature)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 閉じるボタン
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('続ける'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getFeatureName(String featureId) {
    return switch (featureId) {
      FeatureIds.pairFeature => 'ペア機能',
      FeatureIds.advancedStats => '高度な統計',
      FeatureIds.achievements => '実績システム',
      FeatureIds.notifications => '通知機能',
      FeatureIds.streakTracking => 'ストリーク追跡',
      FeatureIds.weeklyStats => '週次統計',
      FeatureIds.exportData => 'データエクスポート',
      FeatureIds.tags => 'タグ機能',
      FeatureIds.events => 'イベント機能',
      FeatureIds.templates => 'テンプレート機能',
      FeatureIds.timer => 'タイマー機能',
      FeatureIds.advancedCustomization => '高度なカスタマイズ',
      _ => featureId,
    };
  }
}

/// オンボーディング進捗ダイアログ
class OnboardingProgressDialog extends StatelessWidget {
  final OnboardingProgress progress;

  const OnboardingProgressDialog({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('進捗状況'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('現在のレベル: ${progress.currentLevel}'),
          if (!progress.isMaxLevel) ...[
            const SizedBox(height: 8),
            Text('次のレベル: ${progress.nextLevel}'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            const SizedBox(height: 8),
            Text('進捗: ${(progress.progress * 100).toInt()}%'),
          ] else ...[
            const SizedBox(height: 8),
            const Text('最大レベルに到達しました！'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}