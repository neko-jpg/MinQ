import 'dart:math';

import 'package:collection/collection.dart';

import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';

class QuestRecommendation {
  QuestRecommendation({
    required this.quest,
    required this.score,
    required this.recommendedFor,
    required this.reason,
  });

  final Quest quest;
  final double score;
  final DateTime recommendedFor;
  final String reason;
}

class QuestRecommendationService {
  const QuestRecommendationService();

  List<QuestRecommendation> recommend({
    required List<Quest> quests,
    required List<QuestLog> logs,
    required DateTime now,
    int limit = 5,
  }) {
    if (quests.isEmpty) return const [];

    final completionsByQuest = _buildCompletionMap(logs);
    final streakByQuest = _buildStreakMap(logs);
    final categoryCounts = <String, int>{};
    for (final quest in quests) {
      categoryCounts.update(
        quest.category,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    final scored =
        quests.map((quest) {
          final completionRate =
              completionsByQuest[quest.id]?.completionRate ?? 0;
          final streak = streakByQuest[quest.id] ?? 0;
          final recencyBoost = _recencyWeight(
            completionsByQuest[quest.id]?.lastCompletedAt,
            now,
          );
          final baseScore =
              (1 - completionRate) * 0.6 + recencyBoost + streak * 0.05;
          final variance = _categoryDiversityWeight(
            quest.category,
            categoryCounts,
          );
          final totalScore = max(0.0, baseScore + variance);
          final reason = _buildReason(
            quest: quest,
            completionRate: completionRate,
            streak: streak,
            recencyBoost: recencyBoost,
          );
          return QuestRecommendation(
            quest: quest,
            score: totalScore,
            recommendedFor: now,
            reason: reason,
          );
        }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).toList();
  }

  Map<int, _QuestCompletionSummary> _buildCompletionMap(List<QuestLog> logs) {
    final grouped = groupBy(logs, (QuestLog log) => log.questId);
    return grouped.map((key, entries) {
      entries.sort((a, b) => a.ts.compareTo(b.ts));
      final completedDays =
          entries
              .map((e) => DateTime.utc(e.ts.year, e.ts.month, e.ts.day))
              .toSet();
      final firstTs = entries.first.ts;
      final lastTs = entries.last.ts;
      final summary = _QuestCompletionSummary(
        totalCompletions: entries.length,
        uniqueDays: completedDays.length,
        firstCompletedAt: firstTs,
        lastCompletedAt: lastTs,
      );
      return MapEntry(key, summary);
    });
  }

  Map<int, int> _buildStreakMap(List<QuestLog> logs) {
    final streaks = <int, int>{};
    final grouped = groupBy(logs, (QuestLog log) => log.questId);
    for (final entry in grouped.entries) {
      final sorted = entry.value.sortedBy((log) => log.ts);
      var streak = 0;
      DateTime? previousDay;
      for (final log in sorted) {
        final day = DateTime.utc(log.ts.year, log.ts.month, log.ts.day);
        if (previousDay == null || day.difference(previousDay).inDays == 1) {
          streak += 1;
        } else if (day == previousDay) {
          // Same day does not break streak.
        } else {
          streak = 1;
        }
        previousDay = day;
      }
      streaks[entry.key] = streak;
    }
    return streaks;
  }

  double _recencyWeight(DateTime? lastCompletedAt, DateTime now) {
    if (lastCompletedAt == null) return 0.4; // Encourage new quests.
    final days = now.difference(lastCompletedAt).inDays;
    if (days <= 0) return 0;
    return min(0.4, days * 0.05);
  }

  double _categoryDiversityWeight(
    String category,
    Map<String, int> categoryCounts,
  ) {
    final totalCategories = categoryCounts.length;
    if (totalCategories <= 1) {
      return 0;
    }
    final occurrences = categoryCounts[category] ?? 0;
    if (occurrences == 0) return 0.2;
    final average =
        categoryCounts.values.fold<int>(0, (prev, value) => prev + value) /
        categoryCounts.values.length;
    if (occurrences > average) {
      return -0.1;
    }
    return 0.1;
  }

  String _buildReason({
    required Quest quest,
    required double completionRate,
    required int streak,
    required double recencyBoost,
  }) {
    final buffer = StringBuffer();
    if (completionRate < 0.3) {
      buffer.write('まだ習慣化の余地があります。');
    } else if (recencyBoost > 0.2) {
      buffer.write('しばらく取り組めていません。');
    } else {
      buffer.write('チームの連続達成が伸びています。');
    }
    if (streak >= 3) {
      buffer.write(' 現在$streak日連続で達成しています。');
    }
    return buffer.toString();
  }
}

class _QuestCompletionSummary {
  _QuestCompletionSummary({
    required this.totalCompletions,
    required this.uniqueDays,
    required this.firstCompletedAt,
    required this.lastCompletedAt,
  });

  final int totalCompletions;
  final int uniqueDays;
  final DateTime firstCompletedAt;
  final DateTime lastCompletedAt;

  double get completionRate {
    if (uniqueDays == 0) return 0;
    final span = lastCompletedAt.difference(firstCompletedAt).inDays + 1;
    if (span <= 0) return 0;
    return totalCompletions / span;
  }
}
