import 'package:flutter/foundation.dart';
import 'package:minq/domain/analytics/behavior_pattern.dart';

/// インサイトの種類
enum InsightType {
  habitContinuity,
  failurePattern,
  goalPrediction,
  riskWarning,
  optimization,
  achievement,
}

/// インサイトの重要度
enum InsightPriority {
  low,
  medium,
  high,
  critical,
}

/// 分析インサイト
@immutable
class AnalyticsInsight {
  const AnalyticsInsight({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.actionItems,
    required this.confidence,
    required this.relatedPatterns,
    required this.metadata,
    required this.generatedAt,
    this.expiresAt,
  });

  final String id;
  final InsightType type;
  final InsightPriority priority;
  final String title;
  final String description;
  final List<ActionItem> actionItems;
  final double confidence; // 0.0 to 1.0
  final List<BehaviorPattern> relatedPatterns;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;
  final DateTime? expiresAt;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  AnalyticsInsight copyWith({
    String? id,
    InsightType? type,
    InsightPriority? priority,
    String? title,
    String? description,
    List<ActionItem>? actionItems,
    double? confidence,
    List<BehaviorPattern>? relatedPatterns,
    Map<String, dynamic>? metadata,
    DateTime? generatedAt,
    DateTime? expiresAt,
  }) {
    return AnalyticsInsight(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      actionItems: actionItems ?? this.actionItems,
      confidence: confidence ?? this.confidence,
      relatedPatterns: relatedPatterns ?? this.relatedPatterns,
      metadata: metadata ?? this.metadata,
      generatedAt: generatedAt ?? this.generatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsInsight &&
        other.id == id &&
        other.type == type &&
        other.priority == priority &&
        other.title == title &&
        other.description == description &&
        listEquals(other.actionItems, actionItems) &&
        other.confidence == confidence &&
        listEquals(other.relatedPatterns, relatedPatterns) &&
        mapEquals(other.metadata, metadata) &&
        other.generatedAt == generatedAt &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        type,
        priority,
        title,
        description,
        Object.hashAllUnordered(actionItems),
        confidence,
        Object.hashAllUnordered(relatedPatterns),
        Object.hashAllUnordered(metadata.entries),
        generatedAt,
        expiresAt,
      );
}

/// アクションアイテム
@immutable
class ActionItem {
  const ActionItem({
    required this.title,
    required this.description,
    required this.actionType,
    this.route,
    this.parameters,
  });

  final String title;
  final String description;
  final ActionType actionType;
  final String? route;
  final Map<String, dynamic>? parameters;

  ActionItem copyWith({
    String? title,
    String? description,
    ActionType? actionType,
    String? route,
    Map<String, dynamic>? parameters,
  }) {
    return ActionItem(
      title: title ?? this.title,
      description: description ?? this.description,
      actionType: actionType ?? this.actionType,
      route: route ?? this.route,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActionItem &&
        other.title == title &&
        other.description == description &&
        other.actionType == actionType &&
        other.route == route &&
        mapEquals(other.parameters, parameters);
  }

  @override
  int get hashCode => Object.hash(
        title,
        description,
        actionType,
        route,
        Object.hashAllUnordered(parameters?.entries ?? []),
      );
}

/// アクションの種類
enum ActionType {
  navigate,
  createQuest,
  adjustSchedule,
  setReminder,
  viewStats,
  shareProgress,
  adjustGoals,
}

/// 目標達成予測
@immutable
class GoalPrediction {
  const GoalPrediction({
    required this.goalType,
    required this.targetValue,
    required this.currentValue,
    required this.predictedCompletionDate,
    required this.confidence,
    required this.requiredDailyProgress,
    required this.riskFactors,
    required this.recommendations,
  });

  final String goalType;
  final double targetValue;
  final double currentValue;
  final DateTime predictedCompletionDate;
  final double confidence; // 0.0 to 1.0
  final double requiredDailyProgress;
  final List<RiskFactor> riskFactors;
  final List<String> recommendations;

  double get progressPercentage => currentValue / targetValue;
  
  bool get isOnTrack => DateTime.now().isBefore(predictedCompletionDate);

  GoalPrediction copyWith({
    String? goalType,
    double? targetValue,
    double? currentValue,
    DateTime? predictedCompletionDate,
    double? confidence,
    double? requiredDailyProgress,
    List<RiskFactor>? riskFactors,
    List<String>? recommendations,
  }) {
    return GoalPrediction(
      goalType: goalType ?? this.goalType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      predictedCompletionDate: predictedCompletionDate ?? this.predictedCompletionDate,
      confidence: confidence ?? this.confidence,
      requiredDailyProgress: requiredDailyProgress ?? this.requiredDailyProgress,
      riskFactors: riskFactors ?? this.riskFactors,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoalPrediction &&
        other.goalType == goalType &&
        other.targetValue == targetValue &&
        other.currentValue == currentValue &&
        other.predictedCompletionDate == predictedCompletionDate &&
        other.confidence == confidence &&
        other.requiredDailyProgress == requiredDailyProgress &&
        listEquals(other.riskFactors, riskFactors) &&
        listEquals(other.recommendations, recommendations);
  }

  @override
  int get hashCode => Object.hash(
        goalType,
        targetValue,
        currentValue,
        predictedCompletionDate,
        confidence,
        requiredDailyProgress,
        Object.hashAllUnordered(riskFactors),
        Object.hashAllUnordered(recommendations),
      );
}

/// リスク要因
@immutable
class RiskFactor {
  const RiskFactor({
    required this.name,
    required this.description,
    required this.severity,
    required this.probability,
    required this.mitigationStrategies,
  });

  final String name;
  final String description;
  final RiskSeverity severity;
  final double probability; // 0.0 to 1.0
  final List<String> mitigationStrategies;

  RiskFactor copyWith({
    String? name,
    String? description,
    RiskSeverity? severity,
    double? probability,
    List<String>? mitigationStrategies,
  }) {
    return RiskFactor(
      name: name ?? this.name,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      probability: probability ?? this.probability,
      mitigationStrategies: mitigationStrategies ?? this.mitigationStrategies,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RiskFactor &&
        other.name == name &&
        other.description == description &&
        other.severity == severity &&
        other.probability == probability &&
        listEquals(other.mitigationStrategies, mitigationStrategies);
  }

  @override
  int get hashCode => Object.hash(
        name,
        description,
        severity,
        probability,
        Object.hashAllUnordered(mitigationStrategies),
      );
}

/// リスクの深刻度
enum RiskSeverity {
  low,
  medium,
  high,
  critical,
}

extension RiskSeverityExtension on RiskSeverity {
  String get displayName {
    switch (this) {
      case RiskSeverity.low:
        return '低';
      case RiskSeverity.medium:
        return '中';
      case RiskSeverity.high:
        return '高';
      case RiskSeverity.critical:
        return '重大';
    }
  }
}