import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/onboarding/progressive_hint_service.dart';
import 'package:minq/core/onboarding/progressive_onboarding.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/repositories/quest_log_repository.dart';
import 'package:minq/data/repositories/user_repository.dart';

/// プログレッシブオンボーディングコントローラー
/// ユーザーの進捗に基づいてレベルアップを管理
class ProgressiveOnboardingController extends StateNotifier<AsyncValue<ProgressiveOnboarding>> {
  final QuestLogRepository _questLogRepository;
  final UserRepository _userRepository;
  final Ref _ref;

  ProgressiveOnboardingController(
    this._questLogRepository,
    this._userRepository,
    this._ref,
  ) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final service = ProgressiveOnboarding();

      // ユーザーの現在のレベルを復元
      final uid = _ref.read(uidProvider);
      if (uid != null) {
        final userData = await _userRepository.getUser(uid);
        if (userData != null && userData.onboardingLevel != null) {
          // 保存されたレベルを復元
          for (int i = 1; i < userData.onboardingLevel!; i++) {
            service.levelUp();
          }
        }
      }

      state = AsyncValue.data(service);

      // レベルアップチェックを開始
      _checkForLevelUp();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// レベルアップ可能かチェック
  Future<void> _checkForLevelUp() async {
    final currentState = state;
    if (!currentState.hasValue) return;

    final service = currentState.value!;
    final uid = _ref.read(uidProvider);
    if (uid == null) return;

    try {
      // ユーザーの統計を取得
      final stats = await _getUserStats(uid);

      // レベルアップ可能かチェック
      final canLevelUp = service.canLevelUp(
        questsCompleted: stats.questsCompleted,
        daysUsed: stats.daysUsed,
        currentStreak: stats.currentStreak,
      );

      if (canLevelUp) {
        await _performLevelUp(service, uid);
      }
    } catch (e) {
      // エラーは無視（バックグラウンド処理のため）
    }
  }

  /// レベルアップを実行
  Future<void> _performLevelUp(ProgressiveOnboarding service, String uid) async {
    final oldLevel = service.currentLevel;
    service.levelUp();
    final newLevel = service.currentLevel;

    // レベルをFirestoreに保存
    await _userRepository.updateUser(uid, {
      'onboardingLevel': newLevel,
      'lastLevelUpAt': DateTime.now().toIso8601String(),
    });

    // 状態を更新
    state = AsyncValue.data(service);

    // レベルアップイベントを発火
    _ref.read(levelUpEventProvider.notifier).state = LevelUpEvent(
      oldLevel: oldLevel,
      newLevel: newLevel,
      levelInfo: service.getLevel(newLevel)!,
    );
  }

  /// ユーザー統計を取得
  Future<UserStats> _getUserStats(String uid) async {
    // クエスト完了数を取得
    final questLogs = await _questLogRepository.getQuestLogs(uid);
    final questsCompleted = questLogs.length;

    // 使用日数を計算
    final firstLogDate = questLogs.isEmpty
        ? DateTime.now()
        : questLogs.map((log) => log.completedAt).reduce((a, b) => a.isBefore(b) ? a : b);
    final daysUsed = DateTime.now().difference(firstLogDate).inDays + 1;

    // 現在のストリークを計算
    final currentStreak = _calculateCurrentStreak(questLogs);

    return UserStats(
      questsCompleted: questsCompleted,
      daysUsed: daysUsed,
      currentStreak: currentStreak,
    );
  }

  /// 現在のストリークを計算
  int _calculateCurrentStreak(List<dynamic> questLogs) {
    if (questLogs.isEmpty) return 0;

    // 日付ごとにグループ化
    final dateGroups = <String, int>{};
    for (final log in questLogs) {
      final date = DateTime.parse(log.completedAt.toString());
      final dateKey = '${date.year}-${date.month}-${date.day}';
      dateGroups[dateKey] = (dateGroups[dateKey] ?? 0) + 1;
    }

    // 連続日数を計算
    final sortedDates = dateGroups.keys.toList()..sort();
    if (sortedDates.isEmpty) return 0;

    int streak = 1;
    for (int i = sortedDates.length - 2; i >= 0; i--) {
      final currentDate = DateTime.parse(sortedDates[i + 1]);
      final previousDate = DateTime.parse(sortedDates[i]);

      if (currentDate.difference(previousDate).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// 手動でレベルアップチェックを実行
  Future<void> checkLevelUp() async {
    await _checkForLevelUp();
  }

  /// 進捗に応じたヒントを表示
  Future<void> showProgressHints(BuildContext context) async {
    if (!context.mounted) return;

    final uid = _ref.read(uidProvider);
    if (uid == null) return;

    try {
      final stats = await _getUserStats(uid);
      
      // 初回クエスト作成ヒント
      if (stats.questsCompleted == 0) {
        await ProgressiveHintService.showFirstQuestHint(context);
        return;
      }

      // 初回完了ヒント
      if (stats.questsCompleted == 1) {
        await ProgressiveHintService.showFirstCompletionHint(context);
        return;
      }

      // ストリークヒント
      if (stats.currentStreak >= 3) {
        await ProgressiveHintService.showStreakHint(context, stats.currentStreak);
        return;
      }

      // 週次目標達成ヒント（7日以上使用）
      if (stats.daysUsed >= 7) {
        await ProgressiveHintService.showWeeklyGoalHint(context);
        return;
      }

      // 機能解放ヒント
      final currentState = state;
      if (currentState.hasValue) {
        final service = currentState.value!;
        await _checkFeatureUnlockHints(context, service, stats);
      }
    } catch (e) {
      // エラーは無視（バックグラウンド処理のため）
    }
  }

  /// 機能解放ヒントをチェック
  Future<void> _checkFeatureUnlockHints(
    BuildContext context,
    ProgressiveOnboarding service,
    UserStats stats,
  ) async {
    // ペア機能解放ヒント
    if (service.isFeatureUnlocked(FeatureIds.pairFeature)) {
      await ProgressiveHintService.showPairFeatureUnlockHint(context);
      return;
    }

    // 高度な統計解放ヒント
    if (service.isFeatureUnlocked(FeatureIds.advancedStats)) {
      await ProgressiveHintService.showAdvancedStatsUnlockHint(context);
      return;
    }

    // 実績機能解放ヒント
    if (service.isFeatureUnlocked(FeatureIds.achievements)) {
      await ProgressiveHintService.showAchievementsUnlockHint(context);
      return;
    }
  }

  /// クエスト作成時のヒント表示
  Future<void> onQuestCreated(BuildContext context) async {
    if (!context.mounted) return;
    await ProgressiveHintService.showFirstQuestHint(context);
  }

  /// クエスト完了時のヒント表示
  Future<void> onQuestCompleted(BuildContext context, int totalCompleted) async {
    if (!context.mounted) return;
    
    if (totalCompleted == 1) {
      await ProgressiveHintService.showFirstCompletionHint(context);
    }
  }

  /// ストリーク達成時のヒント表示
  Future<void> onStreakAchieved(BuildContext context, int streakDays) async {
    if (!context.mounted) return;
    
    if (streakDays >= 3) {
      await ProgressiveHintService.showStreakHint(context, streakDays);
    }
  }

  /// 機能がアンロックされているかチェック
  bool isFeatureUnlocked(String featureId) {
    final currentState = state;
    if (!currentState.hasValue) return false;

    return currentState.value!.isFeatureUnlocked(featureId);
  }

  /// 進捗を取得
  OnboardingProgress? getProgress() {
    final currentState = state;
    if (!currentState.hasValue) return null;

    final uid = _ref.read(uidProvider);
    if (uid == null) return null;

    // TODO: 実際の統計を非同期で取得
    return currentState.value!.getProgress(
      questsCompleted: 10, // 仮の値
      daysUsed: 5,
      currentStreak: 2,
    );
  }
}

/// ユーザー統計
class UserStats {
  final int questsCompleted;
  final int daysUsed;
  final int currentStreak;

  const UserStats({
    required this.questsCompleted,
    required this.daysUsed,
    required this.currentStreak,
  });
}

/// レベルアップイベント
class LevelUpEvent {
  final int oldLevel;
  final int newLevel;
  final OnboardingLevel levelInfo;

  const LevelUpEvent({
    required this.oldLevel,
    required this.newLevel,
    required this.levelInfo,
  });
}

/// プロバイダー定義
final progressiveOnboardingControllerProvider =
    StateNotifierProvider<ProgressiveOnboardingController, AsyncValue<ProgressiveOnboarding>>((ref) {
  return ProgressiveOnboardingController(
    ref.watch(questLogRepositoryProvider),
    ref.watch(userRepositoryProvider),
    ref,
  );
});

/// レベルアップイベントプロバイダー
final levelUpEventProvider = StateProvider<LevelUpEvent?>((ref) => null);

/// 機能アンロック状態プロバイダー
final featureUnlockProvider = Provider.family<bool, String>((ref, featureId) {
  final controller = ref.watch(progressiveOnboardingControllerProvider.notifier);
  return controller.isFeatureUnlocked(featureId);
});

/// 進捗プロバイダー
final onboardingProgressProvider = Provider<OnboardingProgress?>((ref) {
  final controller = ref.watch(progressiveOnboardingControllerProvider.notifier);
  return controller.getProgress();
});