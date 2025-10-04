/// プログレッシブオンボーディングシステム
/// 機能解放レベル制
class ProgressiveOnboarding {
  final Map<String, OnboardingLevel> _levels = {};
  int _currentLevel = 1;

  ProgressiveOnboarding() {
    _initializeLevels();
  }

  void _initializeLevels() {
    _levels.addAll({
      'level_1': const OnboardingLevel(
        level: 1,
        title: 'ビギナー',
        description: '基本機能を学ぼう',
        unlockedFeatures: [
          'quest_create',
          'quest_complete',
          'basic_stats',
        ],
        requirements: OnboardingRequirements(
          minQuestsCompleted: 0,
          minDaysUsed: 0,
        ),
      ),
      'level_2': const OnboardingLevel(
        level: 2,
        title: 'アクティブユーザー',
        description: '習慣を続けよう',
        unlockedFeatures: [
          'notifications',
          'streak_tracking',
          'weekly_stats',
        ],
        requirements: OnboardingRequirements(
          minQuestsCompleted: 5,
          minDaysUsed: 3,
        ),
      ),
      'level_3': const OnboardingLevel(
        level: 3,
        title: 'ハビットマスター',
        description: '高度な機能を使いこなそう',
        unlockedFeatures: [
          'pair_feature',
          'advanced_stats',
          'export_data',
          'tags',
        ],
        requirements: OnboardingRequirements(
          minQuestsCompleted: 15,
          minDaysUsed: 7,
          minStreak: 3,
        ),
      ),
      'level_4': const OnboardingLevel(
        level: 4,
        title: 'エキスパート',
        description: 'すべての機能を解放',
        unlockedFeatures: [
          'achievements',
          'events',
          'templates',
          'timer',
          'advanced_customization',
        ],
        requirements: OnboardingRequirements(
          minQuestsCompleted: 30,
          minDaysUsed: 14,
          minStreak: 7,
        ),
      ),
    });
  }

  /// 現在のレベルを取得
  int get currentLevel => _currentLevel;

  /// レベルアップ可能かチェック
  bool canLevelUp({
    required int questsCompleted,
    required int daysUsed,
    required int currentStreak,
  }) {
    final nextLevel = _levels['level_${_currentLevel + 1}'];
    if (nextLevel == null) return false;

    return nextLevel.requirements.isMet(
      questsCompleted: questsCompleted,
      daysUsed: daysUsed,
      currentStreak: currentStreak,
    );
  }

  /// レベルアップ
  void levelUp() {
    if (_currentLevel < _levels.length) {
      _currentLevel++;
    }
  }

  /// 機能がアンロックされているかチェック
  bool isFeatureUnlocked(String featureId) {
    for (int i = 1; i <= _currentLevel; i++) {
      final level = _levels['level_$i'];
      if (level != null && level.unlockedFeatures.contains(featureId)) {
        return true;
      }
    }
    return false;
  }

  /// 次のレベルまでの進捗を取得
  OnboardingProgress getProgress({
    required int questsCompleted,
    required int daysUsed,
    required int currentStreak,
  }) {
    final nextLevel = _levels['level_${_currentLevel + 1}'];
    if (nextLevel == null) {
      return OnboardingProgress(
        currentLevel: _currentLevel,
        nextLevel: null,
        progress: 1.0,
        isMaxLevel: true,
      );
    }

    final requirements = nextLevel.requirements;
    final questProgress = questsCompleted / requirements.minQuestsCompleted;
    final daysProgress = daysUsed / requirements.minDaysUsed;
    final streakProgress = requirements.minStreak > 0
        ? currentStreak / requirements.minStreak
        : 1.0;

    final overallProgress = (questProgress + daysProgress + streakProgress) / 3;

    return OnboardingProgress(
      currentLevel: _currentLevel,
      nextLevel: _currentLevel + 1,
      progress: overallProgress.clamp(0.0, 1.0),
      isMaxLevel: false,
      questProgress: questProgress.clamp(0.0, 1.0),
      daysProgress: daysProgress.clamp(0.0, 1.0),
      streakProgress: streakProgress.clamp(0.0, 1.0),
    );
  }

  /// レベル情報を取得
  OnboardingLevel? getLevel(int level) {
    return _levels['level_$level'];
  }

  /// すべてのレベルを取得
  List<OnboardingLevel> getAllLevels() {
    return List.generate(
      _levels.length,
      (index) => _levels['level_${index + 1}']!,
    );
  }
}

/// オンボーディングレベル
class OnboardingLevel {
  final int level;
  final String title;
  final String description;
  final List<String> unlockedFeatures;
  final OnboardingRequirements requirements;

  const OnboardingLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.unlockedFeatures,
    required this.requirements,
  });
}

/// オンボーディング要件
class OnboardingRequirements {
  final int minQuestsCompleted;
  final int minDaysUsed;
  final int minStreak;

  const OnboardingRequirements({
    required this.minQuestsCompleted,
    required this.minDaysUsed,
    this.minStreak = 0,
  });

  /// 要件を満たしているかチェック
  bool isMet({
    required int questsCompleted,
    required int daysUsed,
    required int currentStreak,
  }) {
    return questsCompleted >= minQuestsCompleted &&
           daysUsed >= minDaysUsed &&
           currentStreak >= minStreak;
  }
}

/// オンボーディング進捗
class OnboardingProgress {
  final int currentLevel;
  final int? nextLevel;
  final double progress;
  final bool isMaxLevel;
  final double? questProgress;
  final double? daysProgress;
  final double? streakProgress;

  const OnboardingProgress({
    required this.currentLevel,
    required this.nextLevel,
    required this.progress,
    required this.isMaxLevel,
    this.questProgress,
    this.daysProgress,
    this.streakProgress,
  });
}

/// 機能ID定義
class FeatureIds {
  const FeatureIds._();

  // レベル1
  static const questCreate = 'quest_create';
  static const questComplete = 'quest_complete';
  static const basicStats = 'basic_stats';

  // レベル2
  static const notifications = 'notifications';
  static const streakTracking = 'streak_tracking';
  static const weeklyStats = 'weekly_stats';

  // レベル3
  static const pairFeature = 'pair_feature';
  static const advancedStats = 'advanced_stats';
  static const exportData = 'export_data';
  static const tags = 'tags';

  // レベル4
  static const achievements = 'achievements';
  static const events = 'events';
  static const templates = 'templates';
  static const timer = 'timer';
  static const advancedCustomization = 'advanced_customization';
}

/// 機能ロックメッセージ
class FeatureLockMessages {
  const FeatureLockMessages._();

  static String getMessage(String featureId, int requiredLevel) {
    return 'この機能はレベル$requiredLevelで解放されます';
  }

  static String getUnlockHint(String featureId) {
    return switch (featureId) {
      FeatureIds.pairFeature => 'クエストを15個完了して7日間使用すると解放されます',
      FeatureIds.achievements => 'クエストを30個完了して14日間使用すると解放されます',
      FeatureIds.events => 'クエストを30個完了して14日間使用すると解放されます',
      _ => 'もっとアプリを使って解放しましょう',
    };
  }
}
