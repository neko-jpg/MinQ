import 'package:flutter_test/flutter_test.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/domain/recommendation/recommendation_engine.dart';

void main() {
  group('RecommendationEngine', () {
    late RecommendationEngine engine;
    late DateTime now;
    late Quest questA;

    setUp(() {
      engine = RecommendationEngine();
      now = DateTime(2023, 10, 10, 8, 0); // 8:00 AM

      questA = Quest()
        ..id = 1
        ..title = 'Morning Routine'
        ..owner = 'user1';
    });

    test('recommends best time quest (±1h)', () {
      // QuestA done at 8:00 usually
      final logs = [
        QuestLog()..questId = 1..ts = DateTime(2023, 10, 9, 8, 0),
        QuestLog()..questId = 1..ts = DateTime(2023, 10, 8, 8, 0),
        QuestLog()..questId = 1..ts = DateTime(2023, 10, 7, 8, 0),
      ];

      final context = UserContext(now: now, allLogs: logs);
      final results = engine.recommend([questA], context);

      // Streak calculation:
      // Unique days: 9, 8, 7.
      // Today: 10. Yesterday: 9.
      // 9 matches yesterday.
      // 9->8 (1 day diff), 8->7 (1 day diff). Streak = 3.
      // Streak weight for 3+ is 1.3.

      // Time calculation:
      // Logs at 8. Now at 8. Diff 0. Best Time (2.5).

      expect(results.first.score, 100 * 2.5 * 1.3);
      expect(results.first.reasons, contains("今がベストタイミング"));
      expect(results.first.reasons, contains("3日連続！その調子"));
    });

    test('recommends good time quest (±3h)', () {
      // QuestA done at 6:00 usually. Now is 8:00. Diff 2 hours.
      final logs = [
        QuestLog()..questId = 1..ts = DateTime(2023, 10, 9, 6, 0),
      ];

      final context = UserContext(now: now, allLogs: logs);
      final results = engine.recommend([questA], context);

      // Base * GoodTime(1.5) * Streak(1)
      expect(results.first.score, 100 * 1.5 * 1.0);
      expect(results.first.reasons, contains("いつもの時間帯"));
    });

    test('recommends streak quest (7+ days)', () {
       // QuestA done for last 7 days including yesterday (3 to 9)
       final logs = List.generate(7, (i) {
         return QuestLog()..questId = 1..ts = DateTime(2023, 10, 9 - i, 8, 0);
       });

       final context = UserContext(now: now, allLogs: logs);
       final results = engine.recommend([questA], context);

       // Base * BestTime(2.5) * Streak(1.5)
       expect(results.first.score, 100 * 2.5 * 1.5);
       expect(results.first.reasons, contains("7日連続達成中！"));
    });

    test('boosts recency (3-7 days ago)', () {
       // QuestA done 4 days ago (Oct 6)
       final logs = [
         QuestLog()..questId = 1..ts = DateTime(2023, 10, 6, 8, 0)
       ];

       final context = UserContext(now: now, allLogs: logs);
       final results = engine.recommend([questA], context);

       // Time: 8am vs 8am -> Best Time (2.5)
       // Streak: Oct 6. Today Oct 10. Streak broken. Weight 1.0.
       // Recency: Diff 4 days. +30.

       expect(results.first.score, (100 * 2.5 * 1.0) + 30);
       expect(results.first.reasons, contains("そろそろ再開しませんか？"));
    });

    test('boosts recency (14+ days ago)', () {
       // QuestA done 15 days ago (Sep 25)
       final logs = [
         QuestLog()..questId = 1..ts = DateTime(2023, 9, 25, 8, 0)
       ];

       final context = UserContext(now: now, allLogs: logs);
       final results = engine.recommend([questA], context);

       expect(results.first.score, (100 * 2.5 * 1.0) + 10);
       expect(results.first.reasons, contains("久しぶりにどうですか？"));
    });
  });
}
