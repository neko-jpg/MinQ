import 'package:flutter_test/flutter_test.dart';

import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/domain/recommendation/quest_recommendation_service.dart';

Quest createQuest({
  required int id,
  required String owner,
  required String title,
  required String category,
  QuestStatus status = QuestStatus.active,
  DateTime? createdAt,
}) {
  final quest = Quest()
    ..id = id
    ..owner = owner
    ..title = title
    ..category = category
    ..status = status
    ..estimatedMinutes = 15
    ..createdAt = createdAt ?? DateTime.utc(2024, 1, 1);
  return quest;
}

QuestLog createLog({
  required int questId,
  required DateTime ts,
}) {
  final log = QuestLog()
    ..id = questId
    ..questId = questId
    ..uid = 'user'
    ..ts = ts
    ..proofType = ProofType.check
    ..proofValue = null
    ..synced = true;
  return log;
}

void main() {
  group('QuestRecommendationService', () {
    final service = QuestRecommendationService();

    test('prioritises quests with low completion and stale recency', () {
      final quests = [
        createQuest(id: 1, owner: 'user', title: 'Read', category: 'mind'),
        createQuest(id: 2, owner: 'user', title: 'Run', category: 'body'),
      ];
      final logs = [
        createLog(questId: 1, ts: DateTime.utc(2024, 1, 5)),
        createLog(questId: 1, ts: DateTime.utc(2024, 1, 6)),
        createLog(questId: 2, ts: DateTime.utc(2024, 3, 1)),
      ];

      final results = service.recommend(
        quests: quests,
        logs: logs,
        now: DateTime.utc(2024, 3, 20),
        limit: 2,
      );

      expect(results, hasLength(2));
      expect(results.first.quest.id, 1);
      expect(results.first.score, greaterThan(results.last.score));
    });

    test('caps the number of recommendations', () {
      final quests = List.generate(
        6,
        (index) => createQuest(
          id: index + 1,
          owner: 'user',
          title: 'Quest ${index + 1}',
          category: index.isEven ? 'mind' : 'body',
        ),
      );

      final results = service.recommend(
        quests: quests,
        logs: const [],
        now: DateTime.utc(2024, 4, 1),
        limit: 3,
      );

      expect(results, hasLength(3));
    });
  });
}
