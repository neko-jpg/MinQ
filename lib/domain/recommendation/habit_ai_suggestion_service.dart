import 'dart:math';

import 'package:collection/collection.dart';
import 'package:minq/core/ai/ai_integration_manager.dart';
import 'package:minq/core/templates/quest_templates.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';

class HabitAiSuggestion {
  HabitAiSuggestion({
    required this.template,
    required this.confidence,
    required this.headline,
    required this.rationale,
    required this.supportingFacts,
  });

  final QuestTemplate template;
  final double confidence;
  final String headline;
  final String rationale;
  final List<String> supportingFacts;
}

class HabitAiSuggestionService {
  HabitAiSuggestionService({Random? random, AIIntegrationManager? aiManager})
    : _random = random ?? Random(),
      _aiManager = aiManager ?? AIIntegrationManager.instance;

  final Random _random;
  final AIIntegrationManager _aiManager;

  Future<List<HabitAiSuggestion>> generateSuggestions({
    required List<Quest> userQuests,
    required List<QuestLog> logs,
    required DateTime now,
    int limit = 3,
  }) async {
    if (userQuests.isEmpty && logs.isEmpty) {
      // If there's no data yet, use AI for personalized starter suggestions
      try {
        await _aiManager.generateChatResponse(
          'ユーザーが習慣形成アプリを始めたばかりです。初心者に最適な3つの習慣を提案してください。各習慣について、タイトル、理由、期待される効果を簡潔に説明してください。',
          systemPrompt: 'あなたは習慣形成の専門家です。初心者向けの実践的で継続しやすい習慣を提案してください。',
          maxTokens: 200,
        );
        // Parse AI response and create suggestions
        // For now, fallback to templates with AI-enhanced rationale
      } catch (e) {
        // Fallback to template-based suggestions
      }

      return QuestTemplateRepository.getAllTemplates()
          .take(limit)
          .map(
            (template) => HabitAiSuggestion(
              template: template,
              confidence: 0.55,
              headline: '最初の一歩に最適',
              rationale: 'AIが分析: まだ履歴が少ないため、取り組みやすいテンプレートを選びました。',
              supportingFacts: const <String>['実行時間が15分以内で完了します'],
            ),
          )
          .toList();
    }

    final templatePool = QuestTemplateRepository.getAllTemplates();
    final questById = {for (final quest in userQuests) quest.id: quest};
    final existingTitles =
        userQuests.map((quest) => quest.title.toLowerCase()).toSet();
    final existingCategories =
        userQuests.map((quest) => _normalizeCategory(quest.category)).toSet();

    final categoryUsage = _calculateCategoryUsage(logs, questById.values);
    final predominantTime = _detectPredominantTime(logs, now);

    final scored = <_ScoredSuggestion>[];

    for (final template in templatePool) {
      if (existingTitles.contains(template.title.toLowerCase())) {
        continue; // Already have a very similar quest.
      }

      final normalizedCategory = _normalizeCategory(
        template.category.displayName,
      );
      final usage = categoryUsage[normalizedCategory];
      final hasQuestInCategory = existingCategories.contains(
        normalizedCategory,
      );

      var score = 0.45; // Base confidence.
      final reasons = <String>[];

      if (!hasQuestInCategory) {
        score += 0.25;
        reasons.add('${template.category.displayName}ジャンルが未登録です。');
      } else if (usage != null && usage.count <= 2) {
        score += 0.18;
        reasons.add(
          '${template.category.displayName}の記録が最近${usage.count}件と少なめです。',
        );
      }

      if (usage != null && usage.daysSinceLastCompletion(now) > 5) {
        score += 0.12;
        reasons.add('直近${usage.daysSinceLastCompletion(now)}日間このジャンルに触れていません。');
      }

      if (_matchesTimePreference(template.category, predominantTime)) {
        score += 0.08;
        reasons.add('あなたが集中しやすい時間帯にフィットします。');
      }

      // Add a tiny exploration factor to avoid identical ordering.
      score += _random.nextDouble() * 0.05;
      final confidence = score.clamp(0.0, 0.99);

      final supportingFacts = <String>[];
      if (usage != null && usage.count > 0) {
        supportingFacts.add(
          '過去30日で${usage.count}件の${template.category.displayName}ログがあります。',
        );
      }
      if (predominantTime != null) {
        supportingFacts.add('主な活動時間: ${predominantTime.label}');
      }

      // Enhance rationale with AI if available
      String enhancedRationale =
          reasons.isEmpty ? '日々のリズムから親和性の高い習慣をピックアップしました。' : reasons.join(' ');

      if (confidence > 0.7) {
        try {
          final aiEnhancement = await _aiManager.generateChatResponse(
            'ユーザーに「${template.title}」という習慣を提案します。以下の理由を元に、より魅力的で具体的な提案文を1文で作成してください: $enhancedRationale',
            systemPrompt: 'あなたは習慣形成の専門家です。魅力的で実践的な提案文を作成してください。',
            maxTokens: 100,
          );
          if (aiEnhancement.isNotEmpty && aiEnhancement.trim().length > 10) {
            enhancedRationale = 'TensorFlow Lite AI提案: $aiEnhancement';
          }
        } catch (e) {
          // Keep original rationale on error - TensorFlow Lite service handles fallbacks internally
          print('AI enhancement failed, using rule-based rationale: $e');
        }
      }

      scored.add(
        _ScoredSuggestion(
          suggestion: HabitAiSuggestion(
            template: template,
            confidence: confidence,
            headline: _buildHeadline(template, confidence),
            rationale: enhancedRationale,
            supportingFacts: supportingFacts,
          ),
          score: confidence,
        ),
      );
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).map((entry) => entry.suggestion).toList();
  }

  Map<String, _CategoryUsage> _calculateCategoryUsage(
    List<QuestLog> logs,
    Iterable<Quest> quests,
  ) {
    final questById = {for (final quest in quests) quest.id: quest};
    final usage = <String, List<DateTime>>{};

    for (final log in logs) {
      final quest = questById[log.questId];
      if (quest == null) continue;
      final normalized = _normalizeCategory(quest.category);
      usage.putIfAbsent(normalized, () => <DateTime>[]).add(log.ts.toLocal());
    }

    return usage.map(
      (key, value) => MapEntry(
        key,
        _CategoryUsage(
          count: value.length,
          lastCompletedAt: value.sorted((a, b) => b.compareTo(a)).first,
        ),
      ),
    );
  }

  _PredominantTimeOfDay? _detectPredominantTime(
    List<QuestLog> logs,
    DateTime now,
  ) {
    if (logs.isEmpty) return null;
    final buckets = <_PredominantTimeOfDay, int>{
      for (final value in _PredominantTimeOfDay.values) value: 0,
    };

    for (final log in logs) {
      final localHour = log.ts.toLocal().hour;
      final bucket = _PredominantTimeOfDay.fromHour(localHour);
      buckets[bucket] = (buckets[bucket] ?? 0) + 1;
    }

    final mostActive =
        buckets.entries
            .where((entry) => entry.value > 0)
            .sortedBy((entry) => entry.value)
            .lastOrNull;
    return mostActive?.key;
  }

  bool _matchesTimePreference(
    QuestCategory category,
    _PredominantTimeOfDay? predominantTime,
  ) {
    if (predominantTime == null) return false;
    const preferences = <QuestCategory, Set<_PredominantTimeOfDay>>{
      QuestCategory.mindfulness: {
        _PredominantTimeOfDay.morning,
        _PredominantTimeOfDay.night,
      },
      QuestCategory.fitness: {
        _PredominantTimeOfDay.morning,
        _PredominantTimeOfDay.afternoon,
      },
      QuestCategory.learning: {
        _PredominantTimeOfDay.night,
        _PredominantTimeOfDay.afternoon,
      },
      QuestCategory.productivity: {_PredominantTimeOfDay.afternoon},
      QuestCategory.creative: {_PredominantTimeOfDay.night},
      QuestCategory.social: {
        _PredominantTimeOfDay.evening,
        _PredominantTimeOfDay.night,
      },
      QuestCategory.financial: {_PredominantTimeOfDay.afternoon},
      QuestCategory.health: {_PredominantTimeOfDay.morning},
      QuestCategory.other: {_PredominantTimeOfDay.afternoon},
    };

    final acceptable = preferences[category];
    if (acceptable == null || acceptable.isEmpty) {
      return false;
    }
    return acceptable.contains(predominantTime);
  }

  String _buildHeadline(QuestTemplate template, double confidence) {
    if (confidence > 0.75) {
      return '${template.title} は好相性です';
    }
    if (confidence > 0.6) {
      return '${template.title} を試してみませんか？';
    }
    return '${template.title} で新しい刺激を';
  }

  String _normalizeCategory(String value) => value.trim().toLowerCase();
}

class _CategoryUsage {
  _CategoryUsage({required this.count, required this.lastCompletedAt});

  final int count;
  final DateTime lastCompletedAt;

  int daysSinceLastCompletion(DateTime now) {
    final difference = now.difference(lastCompletedAt.toLocal()).inDays;
    return difference < 0 ? 0 : difference;
  }
}

class _ScoredSuggestion {
  const _ScoredSuggestion({required this.suggestion, required this.score});

  final HabitAiSuggestion suggestion;
  final double score;
}

enum _PredominantTimeOfDay {
  morning('朝', 5, 11),
  afternoon('昼', 12, 17),
  evening('夕方', 18, 21),
  night('夜', 22, 4);

  const _PredominantTimeOfDay(this.label, this.startHour, this.endHour);

  final String label;
  final int startHour;
  final int endHour;

  static _PredominantTimeOfDay fromHour(int hour) {
    for (final value in _PredominantTimeOfDay.values) {
      if (value._contains(hour)) {
        return value;
      }
    }
    return _PredominantTimeOfDay.afternoon;
  }

  bool _contains(int hour) {
    if (startHour <= endHour) {
      return hour >= startHour && hour <= endHour;
    }
    return hour >= startHour || hour <= endHour;
  }
}
