import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';

class DailyFocusRecommendation {
  DailyFocusRecommendation({
    required this.quest,
    required this.confidence,
    required this.headline,
    required this.rationale,
    required this.supportingFacts,
    required this.completions7Days,
    required this.completions30Days,
    this.lastCompletedAt,
  });

  final Quest quest;
  final double confidence;
  final String headline;
  final String rationale;
  final List<String> supportingFacts;
  final int completions7Days;
  final int completions30Days;
  final DateTime? lastCompletedAt;
}

class DailyFocusService {
  DailyFocusRecommendation? recommend({
    required List<Quest> quests,
    required List<QuestLog> logs,
    required DateTime now,
  }) {
    if (quests.isEmpty) {
      return null;
    }

    final completionsByQuest = <int, List<DateTime>>{};
    for (final log in logs) {
      completionsByQuest
          .putIfAbsent(log.questId, () => <DateTime>[])
          .add(log.ts.toLocal());
    }

    final recommendations = <_ScoredRecommendation>[];
    for (final quest in quests) {
      final completions = completionsByQuest[quest.id] ?? <DateTime>[];
      completions.sort((a, b) => b.compareTo(a));

      final lastCompletedAt = completions.firstOrNull;
      final daysSinceLast =
          lastCompletedAt != null
              ? now.difference(lastCompletedAt).inDays
              : null;
      final completions7 =
          completions.where((date) => now.difference(date).inDays < 7).length;
      final completions30 =
          completions.where((date) => now.difference(date).inDays < 30).length;

      double score = 0.4;
      final reasons = <String>[];

      if (lastCompletedAt == null) {
        score += 0.38;
        reasons.add('まだ記録がないので、今日がスタートに最適です。');
      } else if (daysSinceLast != null) {
        if (daysSinceLast >= 10) {
          score += 0.32;
          reasons.add('最後の記録から$daysSinceLast日経過しています。リズムを取り戻しましょう。');
        } else if (daysSinceLast >= 5) {
          score += 0.24;
          reasons.add('前回から$daysSinceLast日空いています。継続のチャンスです。');
        } else if (daysSinceLast >= 2) {
          score += 0.12;
          reasons.add('$daysSinceLast日間お休みしています。軽く再開してみましょう。');
        } else {
          score += 0.05;
          reasons.add('直近でも継続できているので勢いを保ちましょう。');
        }

        if (completions7 == 0) {
          score += 0.14;
          reasons.add('直近1週間で記録がない習慣です。今日こそ実行しましょう。');
        }
      }

      if (completions30 >= 6) {
        score += 0.04;
        reasons.add('30日間で$completions30回取り組んでいます。習慣を強化しましょう。');
      }

      final confidence = score.clamp(0.0, 0.99);
      final facts = <String>[];
      if (lastCompletedAt != null) {
        final formatted = DateFormat('M/d').format(lastCompletedAt);
        final gap = daysSinceLast!;
        facts.add('前回の記録: $formatted (${gap == 0 ? '今日' : '$gap日前'})');
      } else {
        facts.add('まだ記録がありません');
      }
      facts.add('直近7日: $completions7回');
      facts.add('直近30日: $completions30回');

      final headline = _buildHeadline(lastCompletedAt, daysSinceLast);
      final rationale =
          reasons.isEmpty ? '進捗データから今日の優先クエストを提案しました。' : reasons.join(' ');

      recommendations.add(
        _ScoredRecommendation(
          DailyFocusRecommendation(
            quest: quest,
            confidence: confidence,
            headline: headline,
            rationale: rationale,
            supportingFacts: facts,
            completions7Days: completions7,
            completions30Days: completions30,
            lastCompletedAt: lastCompletedAt,
          ),
          confidence: confidence,
          daysSinceLastCompletion: daysSinceLast ?? 999,
        ),
      );
    }

    if (recommendations.isEmpty) {
      return null;
    }

    recommendations.sort((a, b) {
      final scoreCompare = b.confidence.compareTo(a.confidence);
      if (scoreCompare != 0) {
        return scoreCompare;
      }
      return b.daysSinceLastCompletion.compareTo(a.daysSinceLastCompletion);
    });

    return recommendations.first.recommendation;
  }

  String _buildHeadline(DateTime? lastCompletedAt, int? daysSinceLast) {
    if (lastCompletedAt == null) {
      return '今日が初めての挑戦にぴったり';
    }

    if (daysSinceLast != null && daysSinceLast >= 7) {
      return 'リズムを取り戻す絶好のタイミング';
    }
    if (daysSinceLast != null && daysSinceLast >= 3) {
      return '少し間が空いたのでウォームアップ';
    }
    return '勢いを活かして継続しましょう';
  }
}

class _ScoredRecommendation {
  _ScoredRecommendation(
    this.recommendation, {
    required this.confidence,
    required this.daysSinceLastCompletion,
  });

  final DailyFocusRecommendation recommendation;
  final double confidence;
  final int daysSinceLastCompletion;
}
