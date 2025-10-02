/// 実績システム
class AchievementSystem {
  final List<Achievement> _achievements = [];
  final Map<String, AchievementProgress> _progress = {};

  AchievementSystem() {
    _initializeAchievements();
  }

  void _initializeAchievements() {
    _achievements.addAll([
      // ストリーク系
      Achievement(
        id: 'streak_3',
        title: '3日連続',
        description: '3日連続でクエストを完了',
        icon: '🔥',
        category: AchievementCategory.streak,
        requirement: 3,
      ),
      Achievement(
        id: 'streak_7',
        title: '1週間連続',
        description: '7日連続でクエストを完了',
        icon: '🔥',
        category: AchievementCategory.streak,
        requirement: 7,
      ),
      Achievement(
        id: 'streak_30',
        title: '1ヶ月連続',
        description: '30日連続でクエストを完了',
        icon: '🔥',
        category: AchievementCategory.streak,
        requirement: 30,
      ),
      // 完了数系
      Achievement(
        id: 'complete_10',
        title: '初心者',
        description: '10個のクエストを完了',
        icon: '⭐',
        category: AchievementCategory.completion,
        requirement: 10,
      ),
      Achievement(
        id: 'complete_50',
        title: '中級者',
        description: '50個のクエストを完了',
        icon: '⭐',
        category: AchievementCategory.completion,
        requirement: 50,
      ),
      Achievement(
        id: 'complete_100',
        title: '上級者',
        description: '100個のクエストを完了',
        icon: '⭐',
        category: AchievementCategory.completion,
        requirement: 100,
      ),
    ]);
  }

  /// 進捗を更新
  void updateProgress(String achievementId, int current) {
    _progress[achievementId] = AchievementProgress(
      achievementId: achievementId,
      current: current,
      unlocked: false,
    );

    _checkUnlock(achievementId);
  }

  /// アンロックをチェック
  void _checkUnlock(String achievementId) {
    final achievement = _achievements.firstWhere((a) => a.id == achievementId);
    final progress = _progress[achievementId];

    if (progress != null && progress.current >= achievement.requirement) {
      _progress[achievementId] = progress.copyWith(unlocked: true);
    }
  }

  /// 全実績を取得
  List<Achievement> getAllAchievements() => _achievements;

  /// アンロック済み実績を取得
  List<Achievement> getUnlockedAchievements() {
    return _achievements.where((a) {
      final progress = _progress[a.id];
      return progress?.unlocked ?? false;
    }).toList();
  }
}

/// 実績
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final int requirement;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.requirement,
  });
}

/// 実績カテゴリー
enum AchievementCategory {
  streak,
  completion,
  social,
  special,
}

/// 実績進捗
class AchievementProgress {
  final String achievementId;
  final int current;
  final bool unlocked;

  const AchievementProgress({
    required this.achievementId,
    required this.current,
    required this.unlocked,
  });

  AchievementProgress copyWith({
    String? achievementId,
    int? current,
    bool? unlocked,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      current: current ?? this.current,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}

/// 週次チャレンジ
class WeeklyChallenge {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final DateTime startDate;
  final DateTime endDate;

  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    required this.startDate,
    required this.endDate,
  });
}
