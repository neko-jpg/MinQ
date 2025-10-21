import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:minq/core/ai/tflite_unified_ai_service.dart';

/// AIパーソナリティ診断サービス
/// ユーザーの習慣データから性格タイプを分析し、最適な習慣を提案
class PersonalityDiagnosisService {
  static PersonalityDiagnosisService? _instance;
  static PersonalityDiagnosisService get instance =>
      _instance ??= PersonalityDiagnosisService._();

  PersonalityDiagnosisService._();

  final TFLiteUnifiedAIService _aiService = TFLiteUnifiedAIService.instance;

  /// パーソナリティ診断の実行
  Future<PersonalityDiagnosis> diagnosePpersonality({
    required List<HabitData> habitHistory,
    required List<CompletionPattern> completionPatterns,
    required UserPreferences preferences,
    List<QuestionnaireAnswer>? questionnaire,
  }) async {
    await _aiService.initialize();

    try {
      // データ分析
      final behaviorAnalysis = _analyzeBehaviorPatterns(
        habitHistory,
        completionPatterns,
      );
      final preferenceAnalysis = _analyzePreferences(preferences);
      final timeAnalysis = _analyzeTimePatterns(completionPatterns);

      // アーキタイプの決定
      final archetype = await _determineArchetype(
        behaviorAnalysis,
        preferenceAnalysis,
        timeAnalysis,
        questionnaire,
      );

      // 詳細分析の生成
      final detailedAnalysis = await _generateDetailedAnalysis(
        archetype,
        behaviorAnalysis,
      );

      // 相性分析
      final compatibility = _calculateCompatibility(archetype);

      // 推奨習慣の生成
      final recommendations = await _generateHabitRecommendations(
        archetype,
        behaviorAnalysis,
      );

      return PersonalityDiagnosis(
        archetype: archetype,
        confidence: _calculateConfidence(behaviorAnalysis, preferenceAnalysis),
        detailedAnalysis: detailedAnalysis,
        strengths: _identifyStrengths(archetype),
        challenges: _identifyChallenges(archetype),
        recommendations: recommendations,
        compatibility: compatibility,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      log('PersonalityDiagnosis: 診断エラー - $e');
      return _generateFallbackDiagnosis();
    }
  }

  /// 行動パターンの分析
  BehaviorAnalysis _analyzeBehaviorPatterns(
    List<HabitData> habitHistory,
    List<CompletionPattern> completionPatterns,
  ) {
    // 一貫性の分析
    final consistency = _calculateConsistency(completionPatterns);

    // 多様性の分析
    final diversity = _calculateDiversity(habitHistory);

    // 持続性の分析
    final persistence = _calculatePersistence(completionPatterns);

    // 適応性の分析
    final adaptability = _calculateAdaptability(habitHistory);

    // 社会性の分析
    final sociability = _calculateSociability(habitHistory);

    return BehaviorAnalysis(
      consistency: consistency,
      diversity: diversity,
      persistence: persistence,
      adaptability: adaptability,
      sociability: sociability,
    );
  }

  /// 一貫性の計算
  double _calculateConsistency(List<CompletionPattern> patterns) {
    if (patterns.isEmpty) return 0.5;

    var totalVariance = 0.0;
    final dailyCompletions = <int, int>{};

    for (final pattern in patterns) {
      final dayOfWeek = pattern.completedAt.weekday;
      dailyCompletions[dayOfWeek] = (dailyCompletions[dayOfWeek] ?? 0) + 1;
    }

    final values = dailyCompletions.values.toList();
    if (values.isEmpty) return 0.5;

    final mean = values.reduce((a, b) => a + b) / values.length;
    for (final value in values) {
      totalVariance += math.pow(value - mean, 2);
    }

    final variance = totalVariance / values.length;
    final consistency = 1.0 - (variance / (mean + 1));

    return consistency.clamp(0.0, 1.0);
  }

  /// 多様性の計算
  double _calculateDiversity(List<HabitData> habitHistory) {
    if (habitHistory.isEmpty) return 0.5;

    final categories = habitHistory.map((h) => h.category).toSet();
    final maxCategories = HabitCategory.values.length;

    return (categories.length / maxCategories).clamp(0.0, 1.0);
  }

  /// 持続性の計算
  double _calculatePersistence(List<CompletionPattern> patterns) {
    if (patterns.isEmpty) return 0.5;

    final streaks = <int>[];
    var currentStreak = 0;
    DateTime? lastDate;

    final sortedPatterns =
        patterns..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    for (final pattern in sortedPatterns) {
      if (lastDate == null ||
          pattern.completedAt.difference(lastDate).inDays == 1) {
        currentStreak++;
      } else {
        if (currentStreak > 0) streaks.add(currentStreak);
        currentStreak = 1;
      }
      lastDate = pattern.completedAt;
    }

    if (currentStreak > 0) streaks.add(currentStreak);
    if (streaks.isEmpty) return 0.5;

    final averageStreak = streaks.reduce((a, b) => a + b) / streaks.length;
    return (averageStreak / 30.0).clamp(0.0, 1.0); // 30日を最大として正規化
  }

  /// 適応性の計算
  double _calculateAdaptability(List<HabitData> habitHistory) {
    if (habitHistory.isEmpty) return 0.5;

    var adaptationCount = 0;
    for (final habit in habitHistory) {
      if (habit.modifications.isNotEmpty) {
        adaptationCount++;
      }
    }

    return (adaptationCount / habitHistory.length).clamp(0.0, 1.0);
  }

  /// 社会性の計算
  double _calculateSociability(List<HabitData> habitHistory) {
    if (habitHistory.isEmpty) return 0.5;

    var socialHabits = 0;
    for (final habit in habitHistory) {
      if (habit.isSocial || habit.hasPartner) {
        socialHabits++;
      }
    }

    return (socialHabits / habitHistory.length).clamp(0.0, 1.0);
  }

  /// 好みの分析
  PreferenceAnalysis _analyzePreferences(UserPreferences preferences) {
    return PreferenceAnalysis(
      morningPreference:
          preferences.preferredTimes.contains(TimeOfDay.morning) ? 1.0 : 0.0,
      eveningPreference:
          preferences.preferredTimes.contains(TimeOfDay.evening) ? 1.0 : 0.0,
      shortSessionPreference:
          preferences.preferredDuration.inMinutes <= 15 ? 1.0 : 0.0,
      challengePreference: preferences.difficultyPreference / 5.0,
      socialPreference: preferences.socialPreference ? 1.0 : 0.0,
    );
  }

  /// 時間パターンの分析
  TimeAnalysis _analyzeTimePatterns(List<CompletionPattern> patterns) {
    final hourCounts = <int, int>{};

    for (final pattern in patterns) {
      final hour = pattern.completedAt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    var morningCount = 0;
    var afternoonCount = 0;
    var eveningCount = 0;
    var nightCount = 0;

    hourCounts.forEach((hour, count) {
      if (hour >= 5 && hour < 12) {
        morningCount += count;
      } else if (hour >= 12 && hour < 17) {
        afternoonCount += count;
      } else if (hour >= 17 && hour < 22) {
        eveningCount += count;
      } else {
        nightCount += count;
      }
    });

    final total = morningCount + afternoonCount + eveningCount + nightCount;
    if (total == 0) {
      return const TimeAnalysis(
        morningRatio: 0.25,
        afternoonRatio: 0.25,
        eveningRatio: 0.25,
        nightRatio: 0.25,
      );
    }

    return TimeAnalysis(
      morningRatio: morningCount / total,
      afternoonRatio: afternoonCount / total,
      eveningRatio: eveningCount / total,
      nightRatio: nightCount / total,
    );
  }

  /// アーキタイプの決定
  Future<HabitArchetype> _determineArchetype(
    BehaviorAnalysis behavior,
    PreferenceAnalysis preference,
    TimeAnalysis timeAnalysis,
    List<QuestionnaireAnswer>? questionnaire,
  ) async {
    // スコア計算
    final scores = <HabitArchetype, double>{};

    for (final archetype in HabitArchetype.values) {
      var score = 0.0;

      // 行動パターンによるスコア
      score += _calculateArchetypeScore(
        archetype,
        behavior,
        preference,
        timeAnalysis,
      );

      // アンケート結果による調整
      if (questionnaire != null) {
        score += _calculateQuestionnaireScore(archetype, questionnaire);
      }

      scores[archetype] = score;
    }

    // 最高スコアのアーキタイプを選択
    final sortedScores =
        scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedScores.first.key;
  }

  /// アーキタイプスコアの計算
  double _calculateArchetypeScore(
    HabitArchetype archetype,
    BehaviorAnalysis behavior,
    PreferenceAnalysis preference,
    TimeAnalysis timeAnalysis,
  ) {
    switch (archetype) {
      case HabitArchetype.disciplinedAchiever:
        return behavior.consistency * 0.4 +
            behavior.persistence * 0.4 +
            preference.challengePreference * 0.2;

      case HabitArchetype.flexibleExplorer:
        return behavior.diversity * 0.4 +
            behavior.adaptability * 0.4 +
            (1.0 - behavior.consistency) * 0.2;

      case HabitArchetype.socialConnector:
        return behavior.sociability * 0.5 +
            preference.socialPreference * 0.3 +
            behavior.diversity * 0.2;

      case HabitArchetype.mindfulReflector:
        return timeAnalysis.morningRatio * 0.3 +
            timeAnalysis.eveningRatio * 0.3 +
            preference.shortSessionPreference * 0.4;

      case HabitArchetype.energeticOptimizer:
        return behavior.persistence * 0.3 +
            behavior.adaptability * 0.3 +
            preference.challengePreference * 0.4;

      case HabitArchetype.balancedHarmonizer:
        return (behavior.consistency +
                behavior.diversity +
                behavior.sociability) /
            3.0;

      case HabitArchetype.creativeInnovator:
        return behavior.diversity * 0.4 +
            behavior.adaptability * 0.4 +
            (1.0 - behavior.persistence) * 0.2;

      case HabitArchetype.steadyBuilder:
        return behavior.consistency * 0.5 +
            behavior.persistence * 0.3 +
            preference.shortSessionPreference * 0.2;

      case HabitArchetype.analyticalPlanner:
        return behavior.consistency * 0.3 +
            (1.0 - behavior.sociability) * 0.3 +
            preference.challengePreference * 0.4;

      case HabitArchetype.adaptiveNavigator:
        return behavior.adaptability * 0.5 +
            behavior.diversity * 0.3 +
            (1.0 - behavior.consistency) * 0.2;

      case HabitArchetype.inspirationalLeader:
        return behavior.sociability * 0.4 +
            behavior.persistence * 0.3 +
            preference.challengePreference * 0.3;

      case HabitArchetype.peacefulGardener:
        return preference.shortSessionPreference * 0.4 +
            behavior.consistency * 0.3 +
            timeAnalysis.morningRatio * 0.3;

      case HabitArchetype.dynamicChallenger:
        return preference.challengePreference * 0.5 +
            behavior.persistence * 0.3 +
            behavior.adaptability * 0.2;

      case HabitArchetype.wisdomSeeker:
        return behavior.diversity * 0.4 +
            (1.0 - preference.socialPreference) * 0.3 +
            behavior.persistence * 0.3;

      case HabitArchetype.joyfulCelebrator:
        return behavior.sociability * 0.4 +
            behavior.diversity * 0.3 +
            (1.0 - behavior.consistency) * 0.3;

      case HabitArchetype.resilientSurvivor:
        return behavior.persistence * 0.5 +
            behavior.adaptability * 0.3 +
            (1.0 - preference.socialPreference) * 0.2;
    }
  }

  /// アンケートスコアの計算
  double _calculateQuestionnaireScore(
    HabitArchetype archetype,
    List<QuestionnaireAnswer> answers,
  ) {
    var score = 0.0;

    for (final answer in answers) {
      final archetypeAnswers = _getArchetypeAnswers(archetype);
      if (archetypeAnswers.containsKey(answer.questionId)) {
        final expectedAnswer = archetypeAnswers[answer.questionId]!;
        if (answer.selectedOption == expectedAnswer) {
          score += 0.1; // 各質問で最大0.1ポイント
        }
      }
    }

    return score;
  }

  /// アーキタイプ別の期待回答
  Map<String, int> _getArchetypeAnswers(HabitArchetype archetype) {
    // 簡略化された例
    switch (archetype) {
      case HabitArchetype.disciplinedAchiever:
        return {
          'consistency': 4, // 一貫性を重視
          'challenge': 4, // 挑戦を好む
          'planning': 4, // 計画性がある
        };
      case HabitArchetype.flexibleExplorer:
        return {
          'consistency': 2, // 一貫性より柔軟性
          'variety': 4, // 多様性を好む
          'spontaneity': 4, // 自発性がある
        };
      // 他のアーキタイプも同様に定義
      default:
        return {};
    }
  }

  /// 詳細分析の生成
  Future<String> _generateDetailedAnalysis(
    HabitArchetype archetype,
    BehaviorAnalysis behavior,
  ) async {
    try {
      final prompt = '''
あなたは${archetype.displayName}タイプです。
行動パターン:
- 一貫性: ${(behavior.consistency * 100).round()}%
- 多様性: ${(behavior.diversity * 100).round()}%
- 持続性: ${(behavior.persistence * 100).round()}%
- 適応性: ${(behavior.adaptability * 100).round()}%
- 社会性: ${(behavior.sociability * 100).round()}%

このタイプの特徴と、習慣形成における強みと注意点を詳しく説明してください。
''';

      final analysis = await _aiService.generateChatResponse(
        prompt,
        systemPrompt: 'あなたは習慣形成の専門家です。パーソナリティタイプに基づいた詳細で建設的な分析を提供してください。',
        maxTokens: 200,
      );

      if (analysis.isNotEmpty && analysis.length > 50) {
        return analysis;
      }
    } catch (e) {
      log('PersonalityDiagnosis: 詳細分析生成エラー - $e');
    }

    return _getFallbackAnalysis(archetype);
  }

  /// フォールバック分析
  String _getFallbackAnalysis(HabitArchetype archetype) {
    switch (archetype) {
      case HabitArchetype.disciplinedAchiever:
        return 'あなたは目標達成に向けて一貫して努力できるタイプです。計画性があり、困難な課題にも粘り強く取り組めます。';
      case HabitArchetype.flexibleExplorer:
        return 'あなたは新しいことに挑戦し、状況に応じて柔軟に対応できるタイプです。多様な経験を通じて成長していきます。';
      // 他のタイプも同様に定義
      default:
        return 'あなたは独自の強みを持つユニークなタイプです。自分らしい方法で習慣を築いていきましょう。';
    }
  }

  /// 強みの特定
  List<String> _identifyStrengths(HabitArchetype archetype) {
    switch (archetype) {
      case HabitArchetype.disciplinedAchiever:
        return ['高い継続力', '目標達成能力', '計画性', '自己管理能力'];
      case HabitArchetype.flexibleExplorer:
        return ['適応力', '創造性', '好奇心', '多様性への対応'];
      case HabitArchetype.socialConnector:
        return ['コミュニケーション能力', '協調性', 'モチベーション維持', '他者への影響力'];
      // 他のタイプも同様に定義
      default:
        return ['独自の視点', '柔軟性', '創造性'];
    }
  }

  /// 課題の特定
  List<String> _identifyChallenges(HabitArchetype archetype) {
    switch (archetype) {
      case HabitArchetype.disciplinedAchiever:
        return ['完璧主義の傾向', '柔軟性の不足', '燃え尽き症候群のリスク'];
      case HabitArchetype.flexibleExplorer:
        return ['一貫性の維持', '長期的な継続', '集中力の分散'];
      case HabitArchetype.socialConnector:
        return ['他者への依存', '個人時間の確保', '内向的な活動への取り組み'];
      // 他のタイプも同様に定義
      default:
        return ['バランスの取り方', '継続性の確保'];
    }
  }

  /// 習慣推奨の生成
  Future<List<PersonalizedHabitRecommendation>> _generateHabitRecommendations(
    HabitArchetype archetype,
    BehaviorAnalysis behavior,
  ) async {
    final baseRecommendations = _getBaseRecommendations(archetype);
    final personalizedRecommendations = <PersonalizedHabitRecommendation>[];

    for (final base in baseRecommendations) {
      try {
        final customization = await _aiService.generateChatResponse(
          '${archetype.displayName}タイプの人に「${base.title}」という習慣を提案します。このタイプに最適化した具体的な実践方法を提案してください。',
          systemPrompt: 'あなたは習慣形成の専門家です。パーソナリティタイプに合わせた具体的で実践的なアドバイスを提供してください。',
          maxTokens: 100,
        );

        personalizedRecommendations.add(
          PersonalizedHabitRecommendation(
            title: base.title,
            description: base.description,
            customization:
                customization.isNotEmpty
                    ? customization
                    : base.defaultCustomization,
            difficulty: base.difficulty,
            estimatedTime: base.estimatedTime,
            category: base.category,
            personalityFit: _calculatePersonalityFit(archetype, base),
          ),
        );
      } catch (e) {
        log('PersonalityDiagnosis: 習慣カスタマイズエラー - $e');
        personalizedRecommendations.add(
          PersonalizedHabitRecommendation(
            title: base.title,
            description: base.description,
            customization: base.defaultCustomization,
            difficulty: base.difficulty,
            estimatedTime: base.estimatedTime,
            category: base.category,
            personalityFit: _calculatePersonalityFit(archetype, base),
          ),
        );
      }
    }

    return personalizedRecommendations;
  }

  /// ベース推奨習慣の取得
  List<BaseHabitRecommendation> _getBaseRecommendations(
    HabitArchetype archetype,
  ) {
    switch (archetype) {
      case HabitArchetype.disciplinedAchiever:
        return [
          BaseHabitRecommendation(
            title: '朝のルーティン',
            description: '毎朝同じ時間に起きて決まった行動を取る',
            defaultCustomization: '具体的な時間を設定し、チェックリストを作成しましょう',
            difficulty: 3,
            estimatedTime: const Duration(minutes: 30),
            category: HabitCategory.productivity,
          ),
          BaseHabitRecommendation(
            title: '目標設定と振り返り',
            description: '週次で目標を設定し、達成度を振り返る',
            defaultCustomization: 'SMART目標を設定し、数値で進捗を測定しましょう',
            difficulty: 4,
            estimatedTime: const Duration(minutes: 20),
            category: HabitCategory.productivity,
          ),
        ];
      // 他のタイプも同様に定義
      default:
        return [
          BaseHabitRecommendation(
            title: '日記',
            description: '毎日の出来事や感情を記録する',
            defaultCustomization: '自分のペースで続けられる方法を見つけましょう',
            difficulty: 2,
            estimatedTime: const Duration(minutes: 10),
            category: HabitCategory.mindfulness,
          ),
        ];
    }
  }

  /// パーソナリティ適合度の計算
  double _calculatePersonalityFit(
    HabitArchetype archetype,
    BaseHabitRecommendation habit,
  ) {
    // アーキタイプと習慣の相性を計算
    // 簡略化された実装
    return 0.8 + math.Random().nextDouble() * 0.2;
  }

  /// 相性の計算
  Map<HabitArchetype, double> _calculateCompatibility(
    HabitArchetype userArchetype,
  ) {
    final compatibility = <HabitArchetype, double>{};

    for (final archetype in HabitArchetype.values) {
      if (archetype == userArchetype) {
        compatibility[archetype] = 1.0;
      } else {
        compatibility[archetype] = _getCompatibilityScore(
          userArchetype,
          archetype,
        );
      }
    }

    return compatibility;
  }

  /// 相性スコアの取得
  double _getCompatibilityScore(HabitArchetype type1, HabitArchetype type2) {
    // 相性マトリックスに基づいた計算
    // 簡略化された実装
    final compatibilityMatrix = {
      HabitArchetype.disciplinedAchiever: {
        HabitArchetype.steadyBuilder: 0.9,
        HabitArchetype.analyticalPlanner: 0.8,
        HabitArchetype.flexibleExplorer: 0.3,
      },
      // 他の組み合わせも定義
    };

    return compatibilityMatrix[type1]?[type2] ?? 0.5;
  }

  /// 信頼度の計算
  double _calculateConfidence(
    BehaviorAnalysis behavior,
    PreferenceAnalysis preference,
  ) {
    // データの豊富さと一貫性に基づいて信頼度を計算
    var confidence = 0.5; // ベース信頼度

    // 行動データの一貫性が高いほど信頼度アップ
    confidence += behavior.consistency * 0.3;

    // データの多様性があるほど信頼度アップ
    confidence += behavior.diversity * 0.2;

    return confidence.clamp(0.0, 1.0);
  }

  /// フォールバック診断
  PersonalityDiagnosis _generateFallbackDiagnosis() {
    return PersonalityDiagnosis(
      archetype: HabitArchetype.balancedHarmonizer,
      confidence: 0.5,
      detailedAnalysis:
          'データが不足しているため、バランス型として診断しました。より多くの習慣データが蓄積されると、より正確な診断が可能になります。',
      strengths: ['バランス感覚', '適応力', '柔軟性'],
      challenges: ['特化した強みの発見', '一貫性の維持'],
      recommendations: [
        PersonalizedHabitRecommendation(
          title: '日記',
          description: '毎日の振り返りを記録する',
          customization: '短時間でも継続できる方法を見つけましょう',
          difficulty: 2,
          estimatedTime: const Duration(minutes: 5),
          category: HabitCategory.mindfulness,
          personalityFit: 0.7,
        ),
      ],
      compatibility: {for (final type in HabitArchetype.values) type: 0.5},
      timestamp: DateTime.now(),
    );
  }
}

// ========== データクラス ==========

/// パーソナリティ診断結果
class PersonalityDiagnosis {
  final HabitArchetype archetype;
  final double confidence;
  final String detailedAnalysis;
  final List<String> strengths;
  final List<String> challenges;
  final List<PersonalizedHabitRecommendation> recommendations;
  final Map<HabitArchetype, double> compatibility;
  final DateTime timestamp;

  PersonalityDiagnosis({
    required this.archetype,
    required this.confidence,
    required this.detailedAnalysis,
    required this.strengths,
    required this.challenges,
    required this.recommendations,
    required this.compatibility,
    required this.timestamp,
  });
}

/// 行動分析結果
class BehaviorAnalysis {
  final double consistency;
  final double diversity;
  final double persistence;
  final double adaptability;
  final double sociability;

  BehaviorAnalysis({
    required this.consistency,
    required this.diversity,
    required this.persistence,
    required this.adaptability,
    required this.sociability,
  });
}

/// 好み分析結果
class PreferenceAnalysis {
  final double morningPreference;
  final double eveningPreference;
  final double shortSessionPreference;
  final double challengePreference;
  final double socialPreference;

  PreferenceAnalysis({
    required this.morningPreference,
    required this.eveningPreference,
    required this.shortSessionPreference,
    required this.challengePreference,
    required this.socialPreference,
  });
}

/// 時間分析結果
class TimeAnalysis {
  final double morningRatio;
  final double afternoonRatio;
  final double eveningRatio;
  final double nightRatio;

  const TimeAnalysis({
    required this.morningRatio,
    required this.afternoonRatio,
    required this.eveningRatio,
    required this.nightRatio,
  });
}

/// パーソナライズされた習慣推奨
class PersonalizedHabitRecommendation {
  final String title;
  final String description;
  final String customization;
  final int difficulty;
  final Duration estimatedTime;
  final HabitCategory category;
  final double personalityFit;

  PersonalizedHabitRecommendation({
    required this.title,
    required this.description,
    required this.customization,
    required this.difficulty,
    required this.estimatedTime,
    required this.category,
    required this.personalityFit,
  });
}

/// ベース習慣推奨
class BaseHabitRecommendation {
  final String title;
  final String description;
  final String defaultCustomization;
  final int difficulty;
  final Duration estimatedTime;
  final HabitCategory category;

  BaseHabitRecommendation({
    required this.title,
    required this.description,
    required this.defaultCustomization,
    required this.difficulty,
    required this.estimatedTime,
    required this.category,
  });
}

/// 習慣データ
class HabitData {
  final String id;
  final String title;
  final HabitCategory category;
  final bool isSocial;
  final bool hasPartner;
  final List<String> modifications;

  HabitData({
    required this.id,
    required this.title,
    required this.category,
    required this.isSocial,
    required this.hasPartner,
    required this.modifications,
  });
}

/// 完了パターン
class CompletionPattern {
  final DateTime completedAt;
  final String habitId;
  final Duration duration;

  CompletionPattern({
    required this.completedAt,
    required this.habitId,
    required this.duration,
  });
}

/// ユーザー好み
class UserPreferences {
  final List<TimeOfDay> preferredTimes;
  final Duration preferredDuration;
  final int difficultyPreference;
  final bool socialPreference;

  UserPreferences({
    required this.preferredTimes,
    required this.preferredDuration,
    required this.difficultyPreference,
    required this.socialPreference,
  });
}

/// アンケート回答
class QuestionnaireAnswer {
  final String questionId;
  final int selectedOption;

  QuestionnaireAnswer({required this.questionId, required this.selectedOption});
}

/// 習慣アーキタイプ
enum HabitArchetype {
  disciplinedAchiever('規律ある達成者'),
  flexibleExplorer('柔軟な探求者'),
  socialConnector('社交的な繋がり手'),
  mindfulReflector('内省的な思索者'),
  energeticOptimizer('エネルギッシュな最適化者'),
  balancedHarmonizer('バランス型調和者'),
  creativeInnovator('創造的な革新者'),
  steadyBuilder('着実な構築者'),
  analyticalPlanner('分析的な計画者'),
  adaptiveNavigator('適応的な航海者'),
  inspirationalLeader('インスピレーショナルリーダー'),
  peacefulGardener('平和な庭師'),
  dynamicChallenger('ダイナミックな挑戦者'),
  wisdomSeeker('知恵の探求者'),
  joyfulCelebrator('喜びの祝福者'),
  resilientSurvivor('回復力のあるサバイバー');

  const HabitArchetype(this.displayName);
  final String displayName;
}

/// 習慣カテゴリ
enum HabitCategory {
  fitness,
  mindfulness,
  learning,
  productivity,
  health,
  social,
  creative,
  financial,
}

/// 時間帯
enum TimeOfDay { morning, afternoon, evening, night }
