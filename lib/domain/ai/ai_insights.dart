import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_insights.freezed.dart';
part 'ai_insights.g.dart';

/// AI insights dashboard data model
@freezed
class AIInsights with _$AIInsights {
  const factory AIInsights({
    required String userId,
    required DateTime generatedAt,
    required HabitCompletionTrends trends,
    required List<PersonalizedRecommendation> recommendations,
    required ProgressAnalysis progressAnalysis,
    FailurePrediction? failurePrediction,
  }) = _AIInsights;

  factory AIInsights.fromJson(Map<String, dynamic> json) =>
      _$AIInsightsFromJson(json);
}

/// Habit completion trends over time
@freezed
class HabitCompletionTrends with _$HabitCompletionTrends {
  const factory HabitCompletionTrends({
    required Map<String, double> weeklyTrends, // Week -> completion rate
    required Map<String, double> dailyTrends, // Day -> completion rate
    required Map<String, int> categoryDistribution, // Category -> count
    required double overallTrend, // -1.0 to 1.0 (declining to improving)
    required String trendDescription,
  }) = _HabitCompletionTrends;

  factory HabitCompletionTrends.fromJson(Map<String, dynamic> json) =>
      _$HabitCompletionTrendsFromJson(json);
}

/// Personalized recommendation based on user data
@freezed
class PersonalizedRecommendation with _$PersonalizedRecommendation {
  const factory PersonalizedRecommendation({
    required String id,
    required RecommendationType type,
    required String title,
    required String description,
    required double confidence, // 0.0 to 1.0
    required List<String> relatedHabits,
    required String actionText,
    String? iconKey,
  }) = _PersonalizedRecommendation;

  factory PersonalizedRecommendation.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedRecommendationFromJson(json);
}

/// Progress analysis with insights
@freezed
class ProgressAnalysis with _$ProgressAnalysis {
  const factory ProgressAnalysis({
    required double currentStreak,
    required double longestStreak,
    required double weeklyCompletionRate,
    required double monthlyCompletionRate,
    required int totalHabitsCompleted,
    required Map<String, double>
    categoryPerformance, // Category -> completion rate
    required List<ProgressInsight> insights,
    required double overallScore, // 0.0 to 1.0
  }) = _ProgressAnalysis;

  factory ProgressAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ProgressAnalysisFromJson(json);
}

/// Individual progress insight
@freezed
class ProgressInsight with _$ProgressInsight {
  const factory ProgressInsight({
    required String title,
    required String description,
    required InsightType type,
    required double impact, // 0.0 to 1.0
    String? actionRecommendation,
  }) = _ProgressInsight;

  factory ProgressInsight.fromJson(Map<String, dynamic> json) =>
      _$ProgressInsightFromJson(json);
}

/// Failure prediction model
@freezed
class FailurePrediction with _$FailurePrediction {
  const factory FailurePrediction({
    required double riskScore, // 0.0 to 1.0
    required List<String> riskFactors,
    required List<String> preventionStrategies,
    required DateTime predictedDate,
    required String riskLevel, // 'low', 'medium', 'high'
  }) = _FailurePrediction;

  factory FailurePrediction.fromJson(Map<String, dynamic> json) =>
      _$FailurePredictionFromJson(json);
}

/// Enums
enum RecommendationType {
  habitSuggestion,
  timeOptimization,
  streakRecovery,
  categoryBalance,
  motivationalBoost,
}

enum InsightType { achievement, improvement, warning, opportunity, pattern }
