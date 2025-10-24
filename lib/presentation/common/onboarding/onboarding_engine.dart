import 'package:flutter/material.dart';
import 'package:minq/presentation/common/onboarding/interactive_tour.dart';
import 'package:minq/presentation/common/onboarding/onboarding_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// コンテキスト依存のガイド表示を管理するオンボーディングエンジン
class OnboardingEngine {
  static const String _keyPrefix = 'onboarding_';
  static const String _keyOnboardingCompleted = '${_keyPrefix}completed';
  static const String _keyViewedTooltips = '${_keyPrefix}viewed_tooltips';
  static const String _keyCurrentStep = '${_keyPrefix}current_step';

  static OnboardingEngine? _instance;
  static OnboardingEngine get instance => _instance ??= OnboardingEngine._();

  OnboardingEngine._();

  /// オンボーディングが完了しているかチェック
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// オンボーディング完了をマーク
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  /// 特定のツールチップが表示済みかチェック
  static Future<bool> hasSeenTooltip(String tooltipId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedTooltips = prefs.getStringList(_keyViewedTooltips) ?? [];
    return viewedTooltips.contains(tooltipId);
  }

  /// ツールチップを表示済みとしてマーク
  static Future<void> markTooltipSeen(String tooltipId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedTooltips = prefs.getStringList(_keyViewedTooltips) ?? [];
    if (!viewedTooltips.contains(tooltipId)) {
      viewedTooltips.add(tooltipId);
      await prefs.setStringList(_keyViewedTooltips, viewedTooltips);
    }
  }

  /// 現在のオンボーディングステップを取得
  static Future<int> getCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentStep) ?? 0;
  }

  /// オンボーディングステップを更新
  static Future<void> updateStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentStep, step);
  }

  /// コンテキスト依存のガイドを表示
  static Future<void> showContextualGuide(
    String screenId,
    BuildContext context,
  ) async {
    if (!context.mounted) return;
    if (await hasCompletedOnboarding()) return;

    switch (screenId) {
      case 'home':
        await _showHomeScreenGuide(context);
        break;
      case 'quest_creation':
        await _showQuestCreationGuide(context);
        break;
      case 'stats':
        await _showStatsScreenGuide(context);
        break;
      case 'pair':
        await _showPairScreenGuide(context);
        break;
    }
  }

  /// ユーザーの進捗に応じたヒントを表示
  static Future<void> showProgressiveHint(UserProgress progress) async {
    if (await hasCompletedOnboarding()) return;

    if (progress.totalQuests == 0) {
      // 初回ユーザー向けのクエスト作成ヒント
      await _showFirstQuestHint();
    } else if (progress.completedQuests == 0) {
      // 初回完了ヒント
      await _showFirstCompletionHint();
    } else if (progress.currentStreak >= 3) {
      // 連続達成ヒント
      await _showStreakHint();
    }
  }

  /// インタラクティブツアーを開始
  static Future<void> startInteractiveTour(
    BuildContext context,
    List<TourStep> steps,
  ) async {
    if (!context.mounted) return;
    if (await hasCompletedOnOnboarding()) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InteractiveTourScreen(steps: steps),
      ),
    );
  }

  // プライベートメソッド
  static Future<void> _showHomeScreenGuide(BuildContext context) async {
    const tooltipId = 'home_screen_guide';
    if (!context.mounted) return;
    if (await hasSeenTooltip(tooltipId)) return;

    // ホーム画面のガイドを表示
    await _showOverlayGuide(
      context,
      tooltipId,
      'ホーム画面へようこそ！',
      'ここが今日のクエスト一覧です。まずは新しいクエストを追加してみましょう。',
      targetKey: 'quest_list',
    );
  }

  static Future<void> _showQuestCreationGuide(BuildContext context) async {
    const tooltipId = 'quest_creation_guide';
    if (!context.mounted) return;
    if (await hasSeenTooltip(tooltipId)) return;

    await _showOverlayGuide(
      context,
      tooltipId,
      'クエストを作成しましょう',
      'ここから自分のクエストを作成できます。例：「毎朝ジョギング」',
      targetKey: 'create_quest_fab',
    );
  }

  static Future<void> _showStatsScreenGuide(BuildContext context) async {
    const tooltipId = 'stats_screen_guide';
    if (!context.mounted) return;
    if (await hasSeenTooltip(tooltipId)) return;

    await _showOverlayGuide(
      context,
      tooltipId,
      '進捗を確認しましょう',
      'ここで継続記録や達成状況を確認できます。',
      targetKey: 'stats_progress',
    );
  }

  static Future<void> _showPairScreenGuide(BuildContext context) async {
    const tooltipId = 'pair_screen_guide';
    if (!context.mounted) return;
    if (await hasSeenTooltip(tooltipId)) return;

    await _showOverlayGuide(
      context,
      tooltipId,
      'ペアと一緒に頑張りましょう',
      'ペアと励まし合いながら習慣化に取り組めます。',
      targetKey: 'pair_matching',
    );
  }

  static Future<void> _showOverlayGuide(
    BuildContext context,
    String tooltipId,
    String title,
    String description, {
    String? targetKey,
  }) async {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => OnboardingOverlay(
            title: title,
            description: description,
            targetKey: targetKey,
            onDismiss: () async {
              await markTooltipSeen(tooltipId);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
    );
  }

  static Future<void> _showFirstQuestHint() async {
    // 実装は後で追加
  }

  static Future<void> _showFirstCompletionHint() async {
    // 実装は後で追加
  }

  static Future<void> _showStreakHint() async {
    // 実装は後で追加
  }
}

/// ユーザーの進捗情報
class UserProgress {
  final int totalQuests;
  final int completedQuests;
  final int currentStreak;
  final int bestStreak;

  const UserProgress({
    required this.totalQuests,
    required this.completedQuests,
    required this.currentStreak,
    required this.bestStreak,
  });
}

/// ツアーステップの定義
class TourStep {
  final String title;
  final String description;
  final String? targetKey;
  final Widget? customWidget;
  final VoidCallback? onNext;

  const TourStep({
    required this.title,
    required this.description,
    this.targetKey,
    this.customWidget,
    this.onNext,
  });
}
