import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';

class UserContext {
  final DateTime now;
  final List<QuestLog> allLogs;

  UserContext({
    required this.now,
    required this.allLogs,
  });
}

class ScoredQuest {
  final Quest quest;
  final double score;
  final List<String> reasons;
  final int currentStreak;

  ScoredQuest(this.quest, this.score, this.reasons, {this.currentStreak = 0});
}

class RecommendationEngine {
  // Base score for all quests
  static const double _baseScore = 100.0;

  List<ScoredQuest> recommend(List<Quest> quests, UserContext context) {
    // 1. Group logs by quest ID for efficient access
    final logsByQuest = <int, List<QuestLog>>{};
    for (final log in context.allLogs) {
      logsByQuest.putIfAbsent(log.questId, () => []).add(log);
    }

    final scored = quests.map((quest) {
      final logs = logsByQuest[quest.id] ?? [];

      // Calculate individual components
      final timeWeight = _calculateTimeWeight(logs, context.now);
      final streakInfo = _calculateStreakInfo(logs, context.now);
      final recencyBoost = _calculateRecencyBoost(logs, context.now);

      final totalScore = (_baseScore * timeWeight.value * streakInfo.weight) + recencyBoost.value;

      final reasons = <String>[];
      if (timeWeight.reason != null) reasons.add(timeWeight.reason!);
      if (streakInfo.reason != null) reasons.add(streakInfo.reason!);
      if (recencyBoost.reason != null) reasons.add(recencyBoost.reason!);

      return ScoredQuest(quest, totalScore, reasons, currentStreak: streakInfo.count);
    }).toList();

    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  _ScoreComponent _calculateTimeWeight(List<QuestLog> logs, DateTime now) {
    if (logs.isEmpty) {
       // New quest, give it a slight boost or neutral
       return _ScoreComponent(1.0, null);
    }

    // Find "usual time" (mode of hour)
    final hourCounts = <int, int>{};
    for (final log in logs) {
      final hour = log.ts.toLocal().hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    if (hourCounts.isEmpty) return _ScoreComponent(1.0, null);

    final bestHour = hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final currentHour = now.hour;

    // Circular difference (0-23)
    int diff = (currentHour - bestHour).abs();
    if (diff > 12) diff = 24 - diff;

    if (diff <= 1) {
      return _ScoreComponent(2.5, "今がベストタイミング"); // Best Time
    } else if (diff <= 3) {
      return _ScoreComponent(1.5, "いつもの時間帯"); // Good Time
    } else {
      return _ScoreComponent(0.5, null); // Off Time
    }
  }

  _StreakInfo _calculateStreakInfo(List<QuestLog> logs, DateTime now) {
    if (logs.isEmpty) return _StreakInfo(0, 1.0, null);

    // Calculate streak
    final uniqueDays = logs.map((log) {
      final d = log.ts.toLocal();
      return DateTime(d.year, d.month, d.day);
    }).toSet().toList()..sort((a, b) => b.compareTo(a));

    if (uniqueDays.isEmpty) return _StreakInfo(0, 1.0, null);

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int streak = 0;
    // Check if streak is active (completed today or yesterday)
    // We check the latest completion date
    final latestDate = uniqueDays.first;

    if (latestDate.isAtSameMomentAs(today) || latestDate.isAtSameMomentAs(yesterday)) {
       // It's active, let's count
       DateTime currentCheck = latestDate;
       streak = 1;

       for (int i = 1; i < uniqueDays.length; i++) {
         final prev = uniqueDays[i];
         if (currentCheck.difference(prev).inDays == 1) {
           streak++;
           currentCheck = prev;
         } else {
           break;
         }
       }
    }

    if (streak >= 7) {
      return _StreakInfo(streak, 1.5, "$streak日連続達成中！");
    } else if (streak >= 3) {
      return _StreakInfo(streak, 1.3, "$streak日連続！その調子");
    } else {
      return _StreakInfo(streak, 1.0, null);
    }
  }

  _ScoreComponent _calculateRecencyBoost(List<QuestLog> logs, DateTime now) {
    if (logs.isEmpty) return _ScoreComponent(0.0, null);

    // Find latest log
    final lastTs = logs.map((e) => e.ts).reduce((a, b) => a.isAfter(b) ? a : b);

    final diffDays = now.difference(lastTs).inDays;

    if (diffDays >= 3 && diffDays <= 7) {
      return _ScoreComponent(30.0, "そろそろ再開しませんか？");
    } else if (diffDays >= 14) {
      return _ScoreComponent(10.0, "久しぶりにどうですか？");
    }

    return _ScoreComponent(0.0, null);
  }
}

class _ScoreComponent {
  final double value;
  final String? reason;
  _ScoreComponent(this.value, this.reason);
}

class _StreakInfo {
  final int count;
  final double weight;
  final String? reason;
  _StreakInfo(this.count, this.weight, this.reason);
}
