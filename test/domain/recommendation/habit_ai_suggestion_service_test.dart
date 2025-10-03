import 'dart:math';

import 'package:minq/core/templates/quest_templates.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/domain/recommendation/habit_ai_suggestion_service.dart';
import 'package:test/test.dart';

void main() {
  group('HabitAiSuggestionService', () {
    late HabitAiSuggestionService service;

    setUp(() {
      service = HabitAiSuggestionService(random: Random(1));
    });

    test('returns starter templates when no user data is available', () {
      final suggestions = service.generateSuggestions(
        userQuests: const [],
        logs: const [],
        now: DateTime(2024, 1, 1),
        limit: 3,
      );

      expect(suggestions, hasLength(3));
      expect(suggestions.first.confidence, closeTo(0.55, 0.05));
      expect(
        suggestions.map((s) => s.headline),
        everyElement(isNotEmpty),
      );
    });

    test('prioritises categories with low usage and matches predominant time', () {
      final quest = Quest()
        ..id = 1
        ..owner = 'user'
        ..title = '朝のストレッチ'
        ..category = QuestCategory.fitness.displayName
        ..status = QuestStatus.active
        ..createdAt = DateTime(2023, 12, 1);

      final logs = [
        QuestLog()
          ..id = 1
          ..uid = 'user'
          ..questId = quest.id
          ..ts = DateTime(2024, 1, 1, 6, 30).toUtc()
          ..proofType = ProofType.check
          ..proofValue = 'done'
          ..synced = true,
        QuestLog()
          ..id = 2
          ..uid = 'user'
          ..questId = quest.id
          ..ts = DateTime(2024, 1, 2, 7, 0).toUtc()
          ..proofType = ProofType.check
          ..proofValue = 'done'
          ..synced = true,
      ];

      final suggestions = service.generateSuggestions(
        userQuests: [quest],
        logs: logs,
        now: DateTime(2024, 1, 3, 8, 0),
        limit: 5,
      );

      expect(
        suggestions.map((suggestion) => suggestion.template.title),
        isNot(contains('朝のストレッチ')),
      );
      expect(
        suggestions.any(
          (suggestion) => suggestion.rationale.contains('未登録'),
        ),
        isTrue,
      );
      expect(
        suggestions.first.supportingFacts.join(','),
        contains('主な活動時間'),
      );
    });
  });
}
