import 'package:flutter/foundation.dart';

/// 行動パターンの種類
enum PatternType {
  success,
  failure,
  streak,
  timeOfDay,
  dayOfWeek,
  seasonal,
  category,
}

/// 行動パターンデータ
@immutable
class BehaviorPattern {
  const BehaviorPattern({
    required this.type,
    required this.name,
    required this.description,
    required this.confidence,
    required this.frequency,
    required this.impact,
    required this.suggestions,
    required this.metadata,
    required this.detectedAt,
  });

  final PatternType type;
  final String name;
  final String description;
  final double confidence; // 0.0 to 1.0
  final int frequency; // How often this pattern occurs
  final double impact; // Impact on success rate (-1.0 to 1.0)
  final List<String> suggestions;
  final Map<String, dynamic> metadata;
  final DateTime detectedAt;

  BehaviorPattern copyWith({
    PatternType? type,
    String? name,
    String? description,
    double? confidence,
    int? frequency,
    double? impact,
    List<String>? suggestions,
    Map<String, dynamic>? metadata,
    DateTime? detectedAt,
  }) {
    return BehaviorPattern(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      frequency: frequency ?? this.frequency,
      impact: impact ?? this.impact,
      suggestions: suggestions ?? this.suggestions,
      metadata: metadata ?? this.metadata,
      detectedAt: detectedAt ?? this.detectedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BehaviorPattern &&
        other.type == type &&
        other.name == name &&
        other.description == description &&
        other.confidence == confidence &&
        other.frequency == frequency &&
        other.impact == impact &&
        listEquals(other.suggestions, suggestions) &&
        mapEquals(other.metadata, metadata) &&
        other.detectedAt == detectedAt;
  }

  @override
  int get hashCode => Object.hash(
        type,
        name,
        description,
        confidence,
        frequency,
        impact,
        Object.hashAllUnordered(suggestions),
        Object.hashAllUnordered(metadata.entries),
        detectedAt,
      );
}

/// 時間帯別パターン
@immutable
class TimePattern {
  const TimePattern({
    required this.hour,
    required this.successRate,
    required this.completionCount,
    required this.averageDuration,
  });

  final int hour; // 0-23
  final double successRate; // 0.0 to 1.0
  final int completionCount;
  final Duration averageDuration;

  TimePattern copyWith({
    int? hour,
    double? successRate,
    int? completionCount,
    Duration? averageDuration,
  }) {
    return TimePattern(
      hour: hour ?? this.hour,
      successRate: successRate ?? this.successRate,
      completionCount: completionCount ?? this.completionCount,
      averageDuration: averageDuration ?? this.averageDuration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimePattern &&
        other.hour == hour &&
        other.successRate == successRate &&
        other.completionCount == completionCount &&
        other.averageDuration == averageDuration;
  }

  @override
  int get hashCode => Object.hash(
        hour,
        successRate,
        completionCount,
        averageDuration,
      );
}

/// 曜日別パターン
@immutable
class DayOfWeekPattern {
  const DayOfWeekPattern({
    required this.dayOfWeek,
    required this.successRate,
    required this.completionCount,
    required this.averageQuestsPerDay,
  });

  final int dayOfWeek; // 1-7 (Monday-Sunday)
  final double successRate; // 0.0 to 1.0
  final int completionCount;
  final double averageQuestsPerDay;

  String get dayName {
    const days = ['月', '火', '水', '木', '金', '土', '日'];
    return days[dayOfWeek - 1];
  }

  DayOfWeekPattern copyWith({
    int? dayOfWeek,
    double? successRate,
    int? completionCount,
    double? averageQuestsPerDay,
  }) {
    return DayOfWeekPattern(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      successRate: successRate ?? this.successRate,
      completionCount: completionCount ?? this.completionCount,
      averageQuestsPerDay: averageQuestsPerDay ?? this.averageQuestsPerDay,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayOfWeekPattern &&
        other.dayOfWeek == dayOfWeek &&
        other.successRate == successRate &&
        other.completionCount == completionCount &&
        other.averageQuestsPerDay == averageQuestsPerDay;
  }

  @override
  int get hashCode => Object.hash(
        dayOfWeek,
        successRate,
        completionCount,
        averageQuestsPerDay,
      );
}

/// 季節別パターン
@immutable
class SeasonalPattern {
  const SeasonalPattern({
    required this.season,
    required this.successRate,
    required this.completionCount,
    required this.popularCategories,
  });

  final Season season;
  final double successRate; // 0.0 to 1.0
  final int completionCount;
  final List<String> popularCategories;

  SeasonalPattern copyWith({
    Season? season,
    double? successRate,
    int? completionCount,
    List<String>? popularCategories,
  }) {
    return SeasonalPattern(
      season: season ?? this.season,
      successRate: successRate ?? this.successRate,
      completionCount: completionCount ?? this.completionCount,
      popularCategories: popularCategories ?? this.popularCategories,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeasonalPattern &&
        other.season == season &&
        other.successRate == successRate &&
        other.completionCount == completionCount &&
        listEquals(other.popularCategories, popularCategories);
  }

  @override
  int get hashCode => Object.hash(
        season,
        successRate,
        completionCount,
        Object.hashAllUnordered(popularCategories),
      );
}

/// 季節
enum Season {
  spring,
  summer,
  autumn,
  winter,
}

extension SeasonExtension on Season {
  String get displayName {
    switch (this) {
      case Season.spring:
        return '春';
      case Season.summer:
        return '夏';
      case Season.autumn:
        return '秋';
      case Season.winter:
        return '冬';
    }
  }

}

extension SeasonFromMonth on Season {
  static Season fromMonth(int month) {
    switch (month) {
      case 3:
      case 4:
      case 5:
        return Season.spring;
      case 6:
      case 7:
      case 8:
        return Season.summer;
      case 9:
      case 10:
      case 11:
        return Season.autumn;
      default:
        return Season.winter;
    }
  }
}