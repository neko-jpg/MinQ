import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/onboarding/progressive_hint_service.dart';
import 'package:minq/core/onboarding/progressive_onboarding.dart';
import 'package:minq/presentation/controllers/progressive_onboarding_controller.dart';

/// プログレッシブオンボーディング統合サービス
/// ヒント表示、レベル管理、機能解放を統合的に管理
class ProgressiveOnboardingIntegration {
  static const ProgressiveOnboardingIntegration _instance =
      ProgressiveOnboardingIntegration._();
  static ProgressiveOnboardingIntegration get instance => _instance;

  const ProgressiveOnboardingIntegration._();

  /// クエスト作成時の処理
  static Future<void> onQuestCreated(
    BuildContext context,
    WidgetRef ref, {
    bool isFirstQuest = false,
  }) async {
    if (!context.mounted) return;

    final controller = ref.read(
      progressiveOnboardingControllerProvider.notifier,
    );

    // 初回クエスト作成ヒントを表示
    if (isFirstQuest) {
      await controller.onQuestCreated(context);
    }

    // レベルアップチェック
    await controller.checkLevelUp();
  }

  /// クエスト完了時の処理
  static Future<void> onQuestCompleted(
    BuildContext context,
    WidgetRef ref, {
    required int totalCompleted,
    required int currentStreak,
  }) async {
    if (!context.mounted) return;

    final controller = ref.read(
      progressiveOnboardingControllerProvider.notifier,
    );

    // 完了ヒントを表示
    await controller.onQuestCompleted(context, totalCompleted);

    // ストリークヒントを表示
    if (currentStreak >= 3) {
      await controller.onStreakAchieved(context, currentStreak);
    }

    // レベルアップチェック
    await controller.checkLevelUp();
  }

  /// 週次目標達成時の処理
  static Future<void> onWeeklyGoalAchieved(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!context.mounted) return;

    await ProgressiveHintService.showWeeklyGoalHint(context);

    final controller = ref.read(
      progressiveOnboardingControllerProvider.notifier,
    );
    await controller.checkLevelUp();
  }

  /// 機能解放時の処理
  static Future<void> onFeatureUnlocked(
    BuildContext context,
    WidgetRef ref,
    String featureId,
  ) async {
    if (!context.mounted) return;

    switch (featureId) {
      case FeatureIds.pairFeature:
        await ProgressiveHintService.showPairFeatureUnlockHint(context);
        break;
      case FeatureIds.advancedStats:
        await ProgressiveHintService.showAdvancedStatsUnlockHint(context);
        break;
      case FeatureIds.achievements:
        await ProgressiveHintService.showAchievementsUnlockHint(context);
        break;
    }
  }

  /// 画面表示時の処理
  static Future<void> onScreenDisplayed(
    BuildContext context,
    WidgetRef ref,
    String screenId,
  ) async {
    if (!context.mounted) return;

    final controller = ref.read(
      progressiveOnboardingControllerProvider.notifier,
    );

    // 画面固有のヒントを表示
    switch (screenId) {
      case 'home':
        await controller.showProgressHints(context);
        break;
      case 'stats':
        // 統計画面では高度な統計機能の解放をチェック
        if (controller.isFeatureUnlocked(FeatureIds.advancedStats)) {
          await ProgressiveHintService.showAdvancedStatsUnlockHint(context);
        }
        break;
      case 'pair':
        // ペア画面ではペア機能の解放をチェック
        if (controller.isFeatureUnlocked(FeatureIds.pairFeature)) {
          await ProgressiveHintService.showPairFeatureUnlockHint(context);
        }
        break;
      case 'achievements':
        // 実績画面では実績機能の解放をチェック
        if (controller.isFeatureUnlocked(FeatureIds.achievements)) {
          await ProgressiveHintService.showAchievementsUnlockHint(context);
        }
        break;
    }
  }

  /// 機能がロックされているかチェック
  static bool isFeatureLocked(WidgetRef ref, String featureId) {
    final controller = ref.read(
      progressiveOnboardingControllerProvider.notifier,
    );
    return !controller.isFeatureUnlocked(featureId);
  }

  /// 機能解放のヒントを取得
  static String getFeatureUnlockHint(String featureId) {
    return FeatureLockMessages.getUnlockHint(featureId);
  }

  /// デバッグ用: ヒントをリセット
  static Future<void> resetAllHints() async {
    await ProgressiveHintService.resetAllHints();
  }

  /// デバッグ用: 特定のヒントをリセット
  static Future<void> resetHint(String hintId) async {
    await ProgressiveHintService.resetHint(hintId);
  }

  /// スナックバー形式でヒントを表示
  static Future<void> showQuickHint(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) async {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// プログレッシブオンボーディング統合プロバイダー
final progressiveOnboardingIntegrationProvider =
    Provider<ProgressiveOnboardingIntegration>(
      (ref) => ProgressiveOnboardingIntegration.instance,
    );

/// 機能ロック状態プロバイダー
final featureLockStateProvider = Provider.family<bool, String>((
  ref,
  featureId,
) {
  final controller = ref.read(progressiveOnboardingControllerProvider.notifier);
  return !controller.isFeatureUnlocked(featureId);
});

/// 機能ロックメッセージプロバイダー
final featureLockMessageProvider = Provider.family<String, String>((
  ref,
  featureId,
) {
  final onboardingState = ref.read(progressiveOnboardingControllerProvider);

  return onboardingState.when(
    data: (onboarding) {
      // 必要なレベルを計算
      int requiredLevel = 1;
      for (int i = 1; i <= 4; i++) {
        final level = onboarding.getLevel(i);
        if (level != null && level.unlockedFeatures.contains(featureId)) {
          requiredLevel = i;
          break;
        }
      }

      return FeatureLockMessages.getMessage(featureId, requiredLevel);
    },
    loading: () => '機能を確認中...',
    error: (_, __) => '機能の確認に失敗しました',
  );
});
