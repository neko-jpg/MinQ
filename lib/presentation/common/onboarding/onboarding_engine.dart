import 'package:flutter/material.dart';
import 'package:minq/presentation/common/onboarding/interactive_tour.dart';
import 'package:minq/presentation/common/onboarding/onboarding_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 繧ｳ繝ｳ繝・く繧ｹ繝井ｾ晏ｭ倥・繧ｬ繧､繝芽｡ｨ遉ｺ繧堤ｮ｡逅・☆繧九が繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ繧ｨ繝ｳ繧ｸ繝ｳ
class OnboardingEngine {
  static const String _keyPrefix = 'onboarding_';
  static const String _keyOnboardingCompleted = '${_keyPrefix}completed';
  static const String _keyViewedTooltips = '${_keyPrefix}viewed_tooltips';
  static const String _keyCurrentStep = '${_keyPrefix}current_step';

  static OnboardingEngine? _instance;
  static OnboardingEngine get instance => _instance ??= OnboardingEngine._();
  
  OnboardingEngine._();

  /// 繧ｪ繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ縺悟ｮ御ｺ・＠縺ｦ縺・ｋ縺九メ繧ｧ繝・け
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// 繧ｪ繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ螳御ｺ・ｒ繝槭・繧ｯ
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  /// 迚ｹ螳壹・繝・・繝ｫ繝√ャ繝励′陦ｨ遉ｺ貂医∩縺九メ繧ｧ繝・け
  static Future<bool> hasSeenTooltip(String tooltipId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedTooltips = prefs.getStringList(_keyViewedTooltips) ?? [];
    return viewedTooltips.contains(tooltipId);
  }

  /// 繝・・繝ｫ繝√ャ繝励ｒ陦ｨ遉ｺ貂医∩縺ｨ縺励※繝槭・繧ｯ
  static Future<void> markTooltipSeen(String tooltipId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedTooltips = prefs.getStringList(_keyViewedTooltips) ?? [];
    if (!viewedTooltips.contains(tooltipId)) {
      viewedTooltips.add(tooltipId);
      await prefs.setStringList(_keyViewedTooltips, viewedTooltips);
    }
  }

  /// 迴ｾ蝨ｨ縺ｮ繧ｪ繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ繧ｹ繝・ャ繝励ｒ蜿門ｾ・
  static Future<int> getCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentStep) ?? 0;
  }

  /// 繧ｪ繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ繧ｹ繝・ャ繝励ｒ譖ｴ譁ｰ
  static Future<void> updateStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentStep, step);
  }

  /// 繧ｳ繝ｳ繝・く繧ｹ繝井ｾ晏ｭ倥・繧ｬ繧､繝峨ｒ陦ｨ遉ｺ
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

  /// 繝ｦ繝ｼ繧ｶ繝ｼ縺ｮ騾ｲ謐励↓蠢懊§縺溘ヲ繝ｳ繝医ｒ陦ｨ遉ｺ
  static Future<void> showProgressiveHint(UserProgress progress) async {
    if (await hasCompletedOnboarding()) return;

    if (progress.totalQuests == 0) {
      // 蛻晏屓繝ｦ繝ｼ繧ｶ繝ｼ蜷代￠縺ｮ繧ｯ繧ｨ繧ｹ繝井ｽ懈・繝偵Φ繝・
      await _showFirstQuestHint();
    } else if (progress.completedQuests == 0) {
      // 蛻晏屓螳御ｺ・ヲ繝ｳ繝・
      await _showFirstCompletionHint();
    } else if (progress.currentStreak >= 3) {
      // 騾｣邯夐＃謌舌ヲ繝ｳ繝・
      await _showStreakHint();
    }
  }

  /// 繧､繝ｳ繧ｿ繝ｩ繧ｯ繝・ぅ繝悶ヤ繧｢繝ｼ繧帝幕蟋・
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

  // 繝励Λ繧､繝吶・繝医Γ繧ｽ繝・ラ
  static Future<void> _showHomeScreenGuide(BuildContext context) async {
    const tooltipId = 'home_screen_guide';
    if (await hasSeenTooltip(tooltipId)) return;

    // 繝帙・繝逕ｻ髱｢縺ｮ繧ｬ繧､繝峨ｒ陦ｨ遉ｺ
    await _showOverlayGuide(
      context,
      tooltipId,
      '繝帙・繝逕ｻ髱｢縺ｸ繧医≧縺薙◎・・,
      '縺薙％縺御ｻ頑律縺ｮ繧ｯ繧ｨ繧ｹ繝井ｸ隕ｧ縺ｧ縺吶ゅ∪縺壹・譁ｰ縺励＞繧ｯ繧ｨ繧ｹ繝医ｒ霑ｽ蜉縺励※縺ｿ縺ｾ縺励ｇ縺・・,
      targetKey: 'quest_list',
    );
  }

  static Future<void> _showQuestCreationGuide(BuildContext context) async {
    const tooltipId = 'quest_creation_guide';
    if (await hasSeenTooltip(tooltipId)) return;

    await _showOverlayGuide(
      context,
      tooltipId,
      '繧ｯ繧ｨ繧ｹ繝医ｒ菴懈・縺励∪縺励ｇ縺・,
      '縺薙％縺九ｉ閾ｪ蛻・・繧ｯ繧ｨ繧ｹ繝医ｒ菴懈・縺ｧ縺阪∪縺吶ゆｾ具ｼ壹梧ｯ取悃繧ｸ繝ｧ繧ｮ繝ｳ繧ｰ縲・,
      targetKey: 'create_quest_fab',
    );
  }

  static Future<void> _showStatsScreenGuide(BuildContext context) async {
    const tooltipId = 'stats_screen_guide';
    if (await hasSeenTooltip(tooltipId)) return;

    await _showOverlayGuide(
      context,
      tooltipId,
      '騾ｲ謐励ｒ遒ｺ隱阪＠縺ｾ縺励ｇ縺・,
      '縺薙％縺ｧ邯咏ｶ夊ｨ倬鹸繧・＃謌千憾豕√ｒ遒ｺ隱阪〒縺阪∪縺吶・,
      targetKey: 'stats_progress',
    );
  }

  static Future<void> _showPairScreenGuide(BuildContext context) async {
    const tooltipId = 'pair_screen_guide';
    if (await hasSeenTooltip(tooltipId)) return;

    await _showOverlayGuide(
      context,
      tooltipId,
      '繝壹い縺ｨ荳邱偵↓鬆大ｼｵ繧翫∪縺励ｇ縺・,
      '繝壹い縺ｨ蜉ｱ縺ｾ縺怜粋縺・↑縺後ｉ鄙呈・蛹悶↓蜿悶ｊ邨・ａ縺ｾ縺吶・,
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
    // 螳溯｣・・蠕後〒霑ｽ蜉
  }

  static Future<void> _showFirstCompletionHint() async {
    // 螳溯｣・・蠕後〒霑ｽ蜉
  }

  static Future<void> _showStreakHint() async {
    // 螳溯｣・・蠕後〒霑ｽ蜉
  }
}

/// 繝ｦ繝ｼ繧ｶ繝ｼ縺ｮ騾ｲ謐玲ュ蝣ｱ
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

/// 繝・い繝ｼ繧ｹ繝・ャ繝励・螳夂ｾｩ
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