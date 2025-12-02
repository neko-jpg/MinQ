import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';

class UserContext {
  final DateTime now;
  final List<QuestLog> recentLogs;
  final int currentStreak;

  UserContext({
    required this.now,
    required this.recentLogs,
    required this.currentStreak,
  });
}

class ScoredQuest {
  final Quest quest;
  final double score;
  final List<String> reasons;

  ScoredQuest(this.quest, this.score, this.reasons);
}

abstract class RecommendationRule {
  double get weight;
  double evaluate(Quest quest, UserContext context);
  String? getReason(double score);
}

class RecencyRule implements RecommendationRule {
  @override
  double get weight => 1.0;

  @override
  double evaluate(Quest quest, UserContext context) {
    // Logic: Higher score if not done recently (but not too long ago)
    // Placeholder implementation
    return 0.5;
  }

  @override
  String? getReason(double score) {
    if (score > 0.8) return "しばらく行っていません";
    return null;
  }
}

class RecommendationEngine {
  final List<RecommendationRule> _rules = [
    RecencyRule(),
    // Add more rules here (StreakRule, TimeOfDayRule, etc.)
  ];

  List<ScoredQuest> recommend(List<Quest> quests, UserContext context) {
    final scored = quests.map((quest) {
      double totalScore = 0;
      final reasons = <String>[];

      for (final rule in _rules) {
        final score = rule.evaluate(quest, context);
        totalScore += score * rule.weight;
        final reason = rule.getReason(score);
        if (reason != null) {
          reasons.add(reason);
        }
      }

      return ScoredQuest(quest, totalScore, reasons);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }
}
