/// スマート提案サービス
class SmartSuggestionService {
  /// 最適な通知時刻を提案
  Future<List<TimeOfDay>> suggestNotificationTimes({
    required String questId,
    required List<CompletionRecord> completionHistory,
    int suggestionCount = 3,
  }) async {
    if (completionHistory.isEmpty) {
      return _getDefaultSuggestions();
    }

    // 完了時刻の分布を分析
    final timeDistribution = _analyzeTimeDistribution(completionHistory);

    // 最も頻繁に完了している時間帯を抽出
    final suggestions = _extractTopTimes(timeDistribution, suggestionCount);

    return suggestions;
  }

  /// 時刻分布を分析
  Map<int, int> _analyzeTimeDistribution(List<CompletionRecord> records) {
    final distribution = <int, int>{};

    for (final record in records) {
      final hour = record.completedAt.hour;
      distribution[hour] = (distribution[hour] ?? 0) + 1;
    }

    return distribution;
  }

  /// 上位の時刻を抽出
  List<TimeOfDay> _extractTopTimes(Map<int, int> distribution, int count) {
    final sorted =
        distribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(count)
        .map((e) => TimeOfDay(hour: e.key, minute: 0))
        .toList();
  }

  /// デフォルトの提案
  List<TimeOfDay> _getDefaultSuggestions() {
    return [
      const TimeOfDay(hour: 7, minute: 0), // 朝
      const TimeOfDay(hour: 12, minute: 0), // 昼
      const TimeOfDay(hour: 20, minute: 0), // 夜
    ];
  }

  /// 最適なクエスト順序を提案
  Future<List<String>> suggestQuestOrder({
    required List<QuestWithStats> quests,
  }) async {
    // 優先度スコアを計算
    final scored =
        quests.map((quest) {
          final score = _calculatePriorityScore(quest);
          return _ScoredQuest(quest.id, score);
        }).toList();

    // スコアでソート
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.map((s) => s.questId).toList();
  }

  /// 優先度スコアを計算
  double _calculatePriorityScore(QuestWithStats quest) {
    double score = 0.0;

    // 連続日数が長いほど優先
    score += quest.currentStreak * 10.0;

    // 達成率が高いほど優先
    score += quest.achievementRate * 50.0;

    // 期限が近いほど優先
    if (quest.deadline != null) {
      final daysUntilDeadline =
          quest.deadline!.difference(DateTime.now()).inDays;
      if (daysUntilDeadline <= 7) {
        score += (7 - daysUntilDeadline) * 20.0;
      }
    }

    return score;
  }
}

/// 完了記録
class CompletionRecord {
  final DateTime completedAt;
  final String questId;

  const CompletionRecord({required this.completedAt, required this.questId});
}

/// 統計付きクエスト
class QuestWithStats {
  final String id;
  final String title;
  final int currentStreak;
  final double achievementRate;
  final DateTime? deadline;

  const QuestWithStats({
    required this.id,
    required this.title,
    required this.currentStreak,
    required this.achievementRate,
    this.deadline,
  });
}

class _ScoredQuest {
  final String questId;
  final double score;

  _ScoredQuest(this.questId, this.score);
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});
}
