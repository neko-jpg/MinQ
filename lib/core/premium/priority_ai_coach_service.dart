import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';

class PriorityAiCoachService {
  final PremiumService _premiumService;
  final LocalStorageService _localStorage;

  PriorityAiCoachService(this._premiumService, this._localStorage);

  Future<bool> hasPriorityAccess() async {
    return await _premiumService.hasPriorityAICoach();
  }

  Future<AiCoachResponse> generatePriorityResponse({
    required String userMessage,
    required Map<String, dynamic> userContext,
  }) async {
    final hasPriority = await hasPriorityAccess();

    if (hasPriority) {
      return await _generateAdvancedResponse(userMessage, userContext);
    } else {
      return await _generateBasicResponse(userMessage, userContext);
    }
  }

  Future<AiCoachResponse> _generateAdvancedResponse(
    String userMessage,
    Map<String, dynamic> userContext,
  ) async {
    // Simulate advanced AI processing with priority queue
    await Future.delayed(const Duration(milliseconds: 500)); // Faster response

    final insights = await _generateAdvancedInsights(userContext);
    final personalizedTips = await _generatePersonalizedTips(userContext);
    final predictiveAnalysis = await _generatePredictiveAnalysis(userContext);

    return AiCoachResponse(
      message: _buildAdvancedMessage(userMessage, userContext, insights),
      responseTime: const Duration(milliseconds: 500),
      confidence: 0.95,
      insights: insights,
      personalizedTips: personalizedTips,
      predictiveAnalysis: predictiveAnalysis,
      quickActions: _generateAdvancedQuickActions(userContext),
      followUpQuestions: _generateFollowUpQuestions(userContext),
      isPriorityResponse: true,
    );
  }

  Future<AiCoachResponse> _generateBasicResponse(
    String userMessage,
    Map<String, dynamic> userContext,
  ) async {
    // Simulate basic AI processing
    await Future.delayed(const Duration(seconds: 2)); // Slower response

    return AiCoachResponse(
      message: _buildBasicMessage(userMessage, userContext),
      responseTime: const Duration(seconds: 2),
      confidence: 0.75,
      insights: [],
      personalizedTips: [],
      predictiveAnalysis: null,
      quickActions: _generateBasicQuickActions(userContext),
      followUpQuestions: [],
      isPriorityResponse: false,
    );
  }

  Future<List<AiInsight>> _generateAdvancedInsights(
    Map<String, dynamic> userContext,
  ) async {
    final insights = <AiInsight>[];

    // Analyze user patterns
    final streak = userContext['currentStreak'] as int? ?? 0;
    final completionRate =
        userContext['weeklyCompletionRate'] as double? ?? 0.0;
    final preferredTimes =
        userContext['preferredCompletionTimes'] as List<int>? ?? [];

    if (streak > 7) {
      insights.add(
        AiInsight(
          id: 'streak_momentum',
          title: 'Strong Momentum',
          description:
              'Your $streak-day streak shows excellent consistency. This is a great foundation for long-term habit formation.',
          type: InsightType.positive,
          confidence: 0.9,
          actionable: true,
          relatedMetrics: ['streak', 'consistency'],
        ),
      );
    }

    if (completionRate < 0.6) {
      insights.add(
        const AiInsight(
          id: 'completion_improvement',
          title: 'Completion Opportunity',
          description:
              'Your completion rate could be improved. Consider reducing quest difficulty or adjusting timing.',
          type: InsightType.improvement,
          confidence: 0.85,
          actionable: true,
          relatedMetrics: ['completion_rate'],
        ),
      );
    }

    if (preferredTimes.isNotEmpty) {
      final mostCommonHour = _getMostCommonHour(preferredTimes);
      insights.add(
        AiInsight(
          id: 'optimal_timing',
          title: 'Optimal Timing Pattern',
          description:
              'You tend to be most successful completing quests around $mostCommonHour:00. Consider scheduling important quests during this time.',
          type: InsightType.pattern,
          confidence: 0.8,
          actionable: true,
          relatedMetrics: ['timing', 'success_rate'],
        ),
      );
    }

    return insights;
  }

  Future<List<PersonalizedTip>> _generatePersonalizedTips(
    Map<String, dynamic> userContext,
  ) async {
    final tips = <PersonalizedTip>[];

    final focusTags = userContext['focusTags'] as List<String>? ?? [];
    final strugglingAreas =
        userContext['strugglingAreas'] as List<String>? ?? [];

    if (focusTags.contains('health')) {
      tips.add(
        const PersonalizedTip(
          id: 'health_stacking',
          title: 'Health Habit Stacking',
          description:
              'Try linking your health quests to existing routines, like doing stretches right after brushing your teeth.',
          category: 'health',
          difficulty: TipDifficulty.easy,
          estimatedImpact: 0.8,
        ),
      );
    }

    if (strugglingAreas.contains('consistency')) {
      tips.add(
        const PersonalizedTip(
          id: 'consistency_micro_habits',
          title: 'Start Smaller',
          description:
              'Break down challenging quests into 2-minute micro-habits to build consistency before increasing difficulty.',
          category: 'consistency',
          difficulty: TipDifficulty.easy,
          estimatedImpact: 0.9,
        ),
      );
    }

    if (focusTags.contains('productivity')) {
      tips.add(
        const PersonalizedTip(
          id: 'productivity_time_blocking',
          title: 'Time Blocking Strategy',
          description:
              'Dedicate specific time blocks for your productivity quests to avoid decision fatigue.',
          category: 'productivity',
          difficulty: TipDifficulty.medium,
          estimatedImpact: 0.85,
        ),
      );
    }

    return tips;
  }

  Future<PredictiveAnalysis?> _generatePredictiveAnalysis(
    Map<String, dynamic> userContext,
  ) async {
    final streak = userContext['currentStreak'] as int? ?? 0;
    final completionRate =
        userContext['weeklyCompletionRate'] as double? ?? 0.0;
    final totalQuests = userContext['totalQuests'] as int? ?? 0;

    if (totalQuests < 10) return null; // Need more data

    // Predict streak continuation probability
    double streakContinuationProbability = 0.5;
    if (streak > 0) {
      streakContinuationProbability =
          (completionRate * 0.7) + (streak > 7 ? 0.2 : 0.1);
    }

    // Predict goal achievement
    final goalAchievementProbability =
        completionRate * 0.8 + (streak > 0 ? 0.15 : 0.0);

    // Risk factors
    final riskFactors = <String>[];
    if (completionRate < 0.5) riskFactors.add('Low completion rate');
    if (streak == 0) riskFactors.add('No current streak');

    // Success factors
    final successFactors = <String>[];
    if (streak > 7) successFactors.add('Strong streak momentum');
    if (completionRate > 0.8) successFactors.add('High completion rate');

    return PredictiveAnalysis(
      streakContinuationProbability: streakContinuationProbability.clamp(
        0.0,
        1.0,
      ),
      goalAchievementProbability: goalAchievementProbability.clamp(0.0, 1.0),
      riskFactors: riskFactors,
      successFactors: successFactors,
      recommendedActions: _generateRecommendedActions(
        riskFactors,
        successFactors,
      ),
      confidenceLevel: 0.8,
    );
  }

  List<String> _generateRecommendedActions(
    List<String> riskFactors,
    List<String> successFactors,
  ) {
    final actions = <String>[];

    if (riskFactors.contains('Low completion rate')) {
      actions.add('Consider reducing quest difficulty or frequency');
      actions.add('Focus on building one habit at a time');
    }

    if (riskFactors.contains('No current streak')) {
      actions.add('Start with a simple 2-minute daily habit');
      actions.add('Set up environmental cues for your new habit');
    }

    if (successFactors.contains('Strong streak momentum')) {
      actions.add('Consider adding a complementary habit');
      actions.add('Share your success to maintain motivation');
    }

    return actions;
  }

  List<QuickAction> _generateAdvancedQuickActions(
    Map<String, dynamic> userContext,
  ) {
    final actions = <QuickAction>[];

    actions.add(
      QuickAction(
        id: 'ai_quest_suggestion',
        title: 'Get AI Quest Suggestion',
        description: 'Let AI suggest your next quest based on your patterns',
        icon: 'smart_toy',
        action: () => _suggestOptimalQuest(userContext),
      ),
    );

    actions.add(
      QuickAction(
        id: 'schedule_optimization',
        title: 'Optimize Schedule',
        description: 'AI-powered schedule optimization for your quests',
        icon: 'schedule',
        action: () => _optimizeSchedule(userContext),
      ),
    );

    actions.add(
      QuickAction(
        id: 'habit_stack_suggestion',
        title: 'Habit Stacking Ideas',
        description: 'Get personalized habit stacking suggestions',
        icon: 'link',
        action: () => _suggestHabitStacks(userContext),
      ),
    );

    return actions;
  }

  List<QuickAction> _generateBasicQuickActions(
    Map<String, dynamic> userContext,
  ) {
    return [
      QuickAction(
        id: 'create_quest',
        title: 'Create Quest',
        description: 'Create a new quest',
        icon: 'add',
        action: () => {},
      ),
      QuickAction(
        id: 'view_progress',
        title: 'View Progress',
        description: 'Check your progress',
        icon: 'trending_up',
        action: () => {},
      ),
    ];
  }

  List<String> _generateFollowUpQuestions(Map<String, dynamic> userContext) {
    final questions = <String>[];

    final streak = userContext['currentStreak'] as int? ?? 0;
    if (streak > 0) {
      questions.add(
        'What has been the key to maintaining your current streak?',
      );
      questions.add('Are there any obstacles that might break your streak?');
    }

    questions.add('What time of day do you feel most motivated?');
    questions.add(
      'Which habit would have the biggest positive impact on your life?',
    );

    return questions;
  }

  String _buildAdvancedMessage(
    String userMessage,
    Map<String, dynamic> userContext,
    List<AiInsight> insights,
  ) {
    final userName = userContext['name'] as String? ?? 'there';
    final streak = userContext['currentStreak'] as int? ?? 0;

    var message = 'Hi $userName! ';

    if (streak > 0) {
      message += 'I see you\'re on a fantastic $streak-day streak! ';
    }

    if (insights.isNotEmpty) {
      final topInsight = insights.first;
      message += '${topInsight.description} ';
    }

    message +=
        'Based on your patterns, I have some personalized recommendations for you. ';
    message += 'How can I help you build on your momentum today?';

    return message;
  }

  String _buildBasicMessage(
    String userMessage,
    Map<String, dynamic> userContext,
  ) {
    return 'Thanks for your message! I\'m here to help you build better habits. '
        'What would you like to work on today?';
  }

  int _getMostCommonHour(List<int> hours) {
    if (hours.isEmpty) return 9; // Default to 9 AM

    final hourCounts = <int, int>{};
    for (final hour in hours) {
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    return hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Future<void> _suggestOptimalQuest(Map<String, dynamic> userContext) async {
    // Implementation for AI quest suggestion
  }

  Future<void> _optimizeSchedule(Map<String, dynamic> userContext) async {
    // Implementation for schedule optimization
  }

  Future<void> _suggestHabitStacks(Map<String, dynamic> userContext) async {
    // Implementation for habit stacking suggestions
  }

  // Analytics and Usage Tracking
  Future<void> trackAiInteraction({
    required String interactionType,
    required bool isPriorityUser,
    required Duration responseTime,
    Map<String, dynamic>? metadata,
  }) async {
    final interaction = {
      'type': interactionType,
      'isPriorityUser': isPriorityUser,
      'responseTime': responseTime.inMilliseconds,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
    };

    // Store interaction for analytics
    final interactions = await _getStoredInteractions();
    interactions.add(interaction);

    // Keep only last 100 interactions
    if (interactions.length > 100) {
      interactions.removeRange(0, interactions.length - 100);
    }

    await _localStorage.setString('ai_interactions', jsonEncode(interactions));
  }

  Future<List<Map<String, dynamic>>> _getStoredInteractions() async {
    try {
      final interactionsData = await _localStorage.getString('ai_interactions');
      if (interactionsData == null) return [];

      final List<dynamic> interactionsList = jsonDecode(interactionsData);
      return interactionsList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<AiUsageStats> getUsageStats() async {
    final interactions = await _getStoredInteractions();
    final priorityInteractions =
        interactions.where((i) => i['isPriorityUser'] == true).toList();

    final avgResponseTime =
        interactions.isNotEmpty
            ? interactions
                    .map((i) => i['responseTime'] as int)
                    .reduce((a, b) => a + b) /
                interactions.length
            : 0.0;

    final avgPriorityResponseTime =
        priorityInteractions.isNotEmpty
            ? priorityInteractions
                    .map((i) => i['responseTime'] as int)
                    .reduce((a, b) => a + b) /
                priorityInteractions.length
            : 0.0;

    return AiUsageStats(
      totalInteractions: interactions.length,
      priorityInteractions: priorityInteractions.length,
      averageResponseTime: Duration(milliseconds: avgResponseTime.round()),
      averagePriorityResponseTime: Duration(
        milliseconds: avgPriorityResponseTime.round(),
      ),
      lastInteractionAt:
          interactions.isNotEmpty
              ? DateTime.parse(interactions.last['timestamp'])
              : null,
    );
  }
}

class AiCoachResponse {
  final String message;
  final Duration responseTime;
  final double confidence;
  final List<AiInsight> insights;
  final List<PersonalizedTip> personalizedTips;
  final PredictiveAnalysis? predictiveAnalysis;
  final List<QuickAction> quickActions;
  final List<String> followUpQuestions;
  final bool isPriorityResponse;

  const AiCoachResponse({
    required this.message,
    required this.responseTime,
    required this.confidence,
    required this.insights,
    required this.personalizedTips,
    this.predictiveAnalysis,
    required this.quickActions,
    required this.followUpQuestions,
    required this.isPriorityResponse,
  });
}

class AiInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final double confidence;
  final bool actionable;
  final List<String> relatedMetrics;

  const AiInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.confidence,
    required this.actionable,
    required this.relatedMetrics,
  });
}

class PersonalizedTip {
  final String id;
  final String title;
  final String description;
  final String category;
  final TipDifficulty difficulty;
  final double estimatedImpact;

  const PersonalizedTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedImpact,
  });
}

class PredictiveAnalysis {
  final double streakContinuationProbability;
  final double goalAchievementProbability;
  final List<String> riskFactors;
  final List<String> successFactors;
  final List<String> recommendedActions;
  final double confidenceLevel;

  const PredictiveAnalysis({
    required this.streakContinuationProbability,
    required this.goalAchievementProbability,
    required this.riskFactors,
    required this.successFactors,
    required this.recommendedActions,
    required this.confidenceLevel,
  });
}

class QuickAction {
  final String id;
  final String title;
  final String description;
  final String icon;
  final VoidCallback action;

  const QuickAction({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.action,
  });
}

class AiUsageStats {
  final int totalInteractions;
  final int priorityInteractions;
  final Duration averageResponseTime;
  final Duration averagePriorityResponseTime;
  final DateTime? lastInteractionAt;

  const AiUsageStats({
    required this.totalInteractions,
    required this.priorityInteractions,
    required this.averageResponseTime,
    required this.averagePriorityResponseTime,
    this.lastInteractionAt,
  });
}

enum InsightType { positive, improvement, pattern, warning }

enum TipDifficulty { easy, medium, hard }

typedef VoidCallback = void Function();

final priorityAiCoachServiceProvider = Provider<PriorityAiCoachService>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return PriorityAiCoachService(premiumService, localStorage);
});

final aiUsageStatsProvider = FutureProvider<AiUsageStats>((ref) {
  final aiCoachService = ref.watch(priorityAiCoachServiceProvider);
  return aiCoachService.getUsageStats();
});
