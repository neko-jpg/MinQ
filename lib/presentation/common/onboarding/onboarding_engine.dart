import 'package:flutter/material.dart';
import 'package:minq/presentation/common/onboarding/interactive_tour.dart';
import 'package:minq/presentation/common/onboarding/onboarding_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// コンチE��スト依存�Eガイド表示を管琁E��るオンボ�EチE��ングエンジン
class OnboardingEngine {
  static const String _keyPrefix = 'onboarding_';
  static const String _keyOnboardingCompleted = '${_keyPrefix}completed';
  static const String _keyViewedTooltips = '${_keyPrefix}viewed_tooltips';
  static const String _keyCurrentStep = '${_keyPrefix}current_step';

  static OnboardingEngine? _instance;
  static OnboardingEngine get instance => _instance ??= OnboardingEngine._();
  
  OnboardingEngine._();

  /// オンボ�EチE��ングが完亁E��てぁE��かチェチE��
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// オンボ�EチE��ング完亁E��マ�Eク
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  /// 特定�EチE�Eルチップが表示済みかチェチE��
  static Future<bool> hasSeenTooltip(String tooltipId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedTooltips = prefs.getStringList(_keyViewedTooltips) ?? [];
    return viewedTooltips.contains(tooltipId);
  }

  /// チE�Eルチップを表示済みとしてマ�Eク
  static Future<void> markTooltipSeen(String tooltipId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedTooltips = prefs.getStringList(_keyViewedTooltips) ?? [];
    if (!viewedTooltips.contains(tooltipId)) {
      viewedTooltips.add(tooltipId);
      await prefs.setStringList(_keyViewedTooltips, viewedTooltips);
    }
  }

  /// 現在のオンボ�EチE��ングスチE��プを取征E
  static Future<int> getCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentStep) ?? 0;
  }

  /// オンボ�EチE��ングスチE��プを更新
  static Future<void> updateStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentStep, step);
  }

  /// コンチE��スト依存�Eガイドを表示
  static Future<void> showContextualGuide(
    String screenId, 
    BuildContext context,
  ) async {
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
      // 初回ユーザー向けのクエスト作�EヒンチE
      await _showFirstQuestHint();
    } else if (progress.completedQuests == 0) {
      // 初回完亁E��ンチE
      await _showFirstCompletionHint();
    } else if (progress.currentStreak >= 3) {
      // 連続達成ヒンチE
      await _showStreakHint();
    }
  }

  /// インタラクチE��ブツアーを開姁E
  static Future<void> startInteractiveTour(
    BuildContext context,
    List<TourStep> steps,
  ) async {
    if (await hasCompletedOnboarding()) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InteractiveTourScreen(steps: steps),
      ),
    );
  }

  // プライベ�EトメソチE��
  static Future<void> _showHomeScreenGuide(BuildContext context) async {
    const tooltipId = 'home_screen_guide';
    if (await hasSeenTooltip(tooltipId)) return;

    // ホ�Eム画面のガイドを表示
    await _showOverlayGuide(
      context,
      tooltipId,
      'ホ�Eム画面へようこそ�E�E,
      'ここが今日のクエスト一覧です。まず�E新しいクエストを追加してみましょぁE��E,
      targetKey: 'quest_list',
    );
  }

  static Future<void> _showQuestCreationGuide(BuildContext context) async {
    const tooltipId = 'quest_creation_guide';
    if (await hasSeenTooltip(tooltipId)) return;

    await _showOverlayGuide(
      context,
      tooltipId,
      'クエストを作�EしましょぁE,
      'ここから自刁E�Eクエストを作�Eできます。例：「毎朝ジョギング、E,
      targetKey: 'create_quest_fab',
    );
  }

  static Future<void> _showStatsScreenGuide(BuildContext context) async {
    const tooltipId = 'stats_screen_guide';
    if (await hasSeenTooltip(tooltipId)) return;

    await _showOverlayGuide(
      context,
      tooltipId,
      '進捗を確認しましょぁE,
      'ここで継続記録めE��成状況を確認できます、E,
      targetKey: 'stats_progress',
    );
  }

  static Future<void> _showPairScreenGuide(BuildContext context) async {
    const tooltipId = 'pair_screen_guide';
    if (await hasSeenTooltip(tooltipId)) return;

    await _showOverlayGuide(
      context,
      tooltipId,
      'ペアと一緒に頑張りましょぁE,
      'ペアと励まし合ぁE��がら習�E化に取り絁E��ます、E,
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
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => OnboardingOverlay(
        title: title,
        description: description,
        targetKey: targetKey,
        onDismiss: () async {
          await markTooltipSeen(tooltipId);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  static Future<void> _showFirstQuestHint() async {
    // 実裁E�E後で追加
  }

  static Future<void> _showFirstCompletionHint() async {
    // 実裁E�E後で追加
  }

  static Future<void> _showStreakHint() async {
    // 実裁E�E後で追加
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

/// チE��ースチE��プ�E定義
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