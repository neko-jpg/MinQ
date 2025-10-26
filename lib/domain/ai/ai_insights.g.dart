// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_insights.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIInsightsImpl _$$AIInsightsImplFromJson(Map<String, dynamic> json) =>
    _$AIInsightsImpl(
      userId: json['userId'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      trends: HabitCompletionTrends.fromJson(
          json['trends'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) =>
              PersonalizedRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      progressAnalysis: ProgressAnalysis.fromJson(
          json['progressAnalysis'] as Map<String, dynamic>),
      failurePrediction: json['failurePrediction'] == null
          ? null
          : FailurePrediction.fromJson(
              json['failurePrediction'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AIInsightsImplToJson(_$AIInsightsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'trends': instance.trends,
      'recommendations': instance.recommendations,
      'progressAnalysis': instance.progressAnalysis,
      'failurePrediction': instance.failurePrediction,
    };

_$HabitCompletionTrendsImpl _$$HabitCompletionTrendsImplFromJson(
        Map<String, dynamic> json) =>
    _$HabitCompletionTrendsImpl(
      weeklyTrends: (json['weeklyTrends'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      dailyTrends: (json['dailyTrends'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      categoryDistribution:
          Map<String, int>.from(json['categoryDistribution'] as Map),
      overallTrend: (json['overallTrend'] as num).toDouble(),
      trendDescription: json['trendDescription'] as String,
    );

Map<String, dynamic> _$$HabitCompletionTrendsImplToJson(
        _$HabitCompletionTrendsImpl instance) =>
    <String, dynamic>{
      'weeklyTrends': instance.weeklyTrends,
      'dailyTrends': instance.dailyTrends,
      'categoryDistribution': instance.categoryDistribution,
      'overallTrend': instance.overallTrend,
      'trendDescription': instance.trendDescription,
    };

_$PersonalizedRecommendationImpl _$$PersonalizedRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$PersonalizedRecommendationImpl(
      id: json['id'] as String,
      type: $enumDecode(_$RecommendationTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      relatedHabits: (json['relatedHabits'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      actionText: json['actionText'] as String,
      iconKey: json['iconKey'] as String?,
    );

Map<String, dynamic> _$$PersonalizedRecommendationImplToJson(
        _$PersonalizedRecommendationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$RecommendationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'confidence': instance.confidence,
      'relatedHabits': instance.relatedHabits,
      'actionText': instance.actionText,
      'iconKey': instance.iconKey,
    };

const _$RecommendationTypeEnumMap = {
  RecommendationType.habitSuggestion: 'habitSuggestion',
  RecommendationType.timeOptimization: 'timeOptimization',
  RecommendationType.streakRecovery: 'streakRecovery',
  RecommendationType.categoryBalance: 'categoryBalance',
  RecommendationType.motivationalBoost: 'motivationalBoost',
};

_$ProgressAnalysisImpl _$$ProgressAnalysisImplFromJson(
        Map<String, dynamic> json) =>
    _$ProgressAnalysisImpl(
      currentStreak: (json['currentStreak'] as num).toDouble(),
      longestStreak: (json['longestStreak'] as num).toDouble(),
      weeklyCompletionRate: (json['weeklyCompletionRate'] as num).toDouble(),
      monthlyCompletionRate: (json['monthlyCompletionRate'] as num).toDouble(),
      totalHabitsCompleted: (json['totalHabitsCompleted'] as num).toInt(),
      categoryPerformance:
          (json['categoryPerformance'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => ProgressInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallScore: (json['overallScore'] as num).toDouble(),
    );

Map<String, dynamic> _$$ProgressAnalysisImplToJson(
        _$ProgressAnalysisImpl instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'weeklyCompletionRate': instance.weeklyCompletionRate,
      'monthlyCompletionRate': instance.monthlyCompletionRate,
      'totalHabitsCompleted': instance.totalHabitsCompleted,
      'categoryPerformance': instance.categoryPerformance,
      'insights': instance.insights,
      'overallScore': instance.overallScore,
    };

_$ProgressInsightImpl _$$ProgressInsightImplFromJson(
        Map<String, dynamic> json) =>
    _$ProgressInsightImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$InsightTypeEnumMap, json['type']),
      impact: (json['impact'] as num).toDouble(),
      actionRecommendation: json['actionRecommendation'] as String?,
    );

Map<String, dynamic> _$$ProgressInsightImplToJson(
        _$ProgressInsightImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'type': _$InsightTypeEnumMap[instance.type]!,
      'impact': instance.impact,
      'actionRecommendation': instance.actionRecommendation,
    };

const _$InsightTypeEnumMap = {
  InsightType.achievement: 'achievement',
  InsightType.improvement: 'improvement',
  InsightType.warning: 'warning',
  InsightType.opportunity: 'opportunity',
  InsightType.pattern: 'pattern',
};

_$FailurePredictionImpl _$$FailurePredictionImplFromJson(
        Map<String, dynamic> json) =>
    _$FailurePredictionImpl(
      riskScore: (json['riskScore'] as num).toDouble(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      preventionStrategies: (json['preventionStrategies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      predictedDate: DateTime.parse(json['predictedDate'] as String),
      riskLevel: json['riskLevel'] as String,
    );

Map<String, dynamic> _$$FailurePredictionImplToJson(
        _$FailurePredictionImpl instance) =>
    <String, dynamic>{
      'riskScore': instance.riskScore,
      'riskFactors': instance.riskFactors,
      'preventionStrategies': instance.preventionStrategies,
      'predictedDate': instance.predictedDate.toIso8601String(),
      'riskLevel': instance.riskLevel,
    };
