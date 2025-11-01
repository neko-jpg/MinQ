// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationEventImpl _$$NotificationEventImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationEventImpl(
      id: json['id'] as String,
      notificationId: json['notificationId'] as String,
      userId: json['userId'] as String,
      eventType: $enumDecode(_$NotificationEventTypeEnumMap, json['eventType']),
      category: $enumDecode(_$NotificationCategoryEnumMap, json['category']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      actionTaken: json['actionTaken'] as String?,
      timeToAction: json['timeToAction'] == null
          ? null
          : Duration(microseconds: (json['timeToAction'] as num).toInt()),
    );

Map<String, dynamic> _$$NotificationEventImplToJson(
        _$NotificationEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notificationId': instance.notificationId,
      'userId': instance.userId,
      'eventType': _$NotificationEventTypeEnumMap[instance.eventType]!,
      'category': _$NotificationCategoryEnumMap[instance.category]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
      'actionTaken': instance.actionTaken,
      'timeToAction': instance.timeToAction?.inMicroseconds,
    };

const _$NotificationEventTypeEnumMap = {
  NotificationEventType.sent: 'sent',
  NotificationEventType.delivered: 'delivered',
  NotificationEventType.opened: 'opened',
  NotificationEventType.clicked: 'clicked',
  NotificationEventType.dismissed: 'dismissed',
  NotificationEventType.converted: 'converted',
};

const _$NotificationCategoryEnumMap = {
  NotificationCategory.quest: 'quest',
  NotificationCategory.challenge: 'challenge',
  NotificationCategory.pair: 'pair',
  NotificationCategory.league: 'league',
  NotificationCategory.ai: 'ai',
  NotificationCategory.system: 'system',
  NotificationCategory.achievement: 'achievement',
  NotificationCategory.reminder: 'reminder',
};

_$NotificationMetricsImpl _$$NotificationMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationMetricsImpl(
      userId: json['userId'] as String,
      category: $enumDecode(_$NotificationCategoryEnumMap, json['category']),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalSent: (json['totalSent'] as num?)?.toInt() ?? 0,
      totalDelivered: (json['totalDelivered'] as num?)?.toInt() ?? 0,
      totalOpened: (json['totalOpened'] as num?)?.toInt() ?? 0,
      totalClicked: (json['totalClicked'] as num?)?.toInt() ?? 0,
      totalDismissed: (json['totalDismissed'] as num?)?.toInt() ?? 0,
      totalConverted: (json['totalConverted'] as num?)?.toInt() ?? 0,
      deliveryRate: (json['deliveryRate'] as num?)?.toDouble() ?? 0.0,
      openRate: (json['openRate'] as num?)?.toDouble() ?? 0.0,
      clickRate: (json['clickRate'] as num?)?.toDouble() ?? 0.0,
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0.0,
      averageTimeToAction: json['averageTimeToAction'] == null
          ? Duration.zero
          : Duration(
              microseconds: (json['averageTimeToAction'] as num).toInt()),
      hourlyDistribution:
          (json['hourlyDistribution'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      dayOfWeekPerformance:
          (json['dayOfWeekPerformance'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$$NotificationMetricsImplToJson(
        _$NotificationMetricsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'category': _$NotificationCategoryEnumMap[instance.category]!,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'totalSent': instance.totalSent,
      'totalDelivered': instance.totalDelivered,
      'totalOpened': instance.totalOpened,
      'totalClicked': instance.totalClicked,
      'totalDismissed': instance.totalDismissed,
      'totalConverted': instance.totalConverted,
      'deliveryRate': instance.deliveryRate,
      'openRate': instance.openRate,
      'clickRate': instance.clickRate,
      'conversionRate': instance.conversionRate,
      'averageTimeToAction': instance.averageTimeToAction.inMicroseconds,
      'hourlyDistribution': instance.hourlyDistribution,
      'dayOfWeekPerformance': instance.dayOfWeekPerformance,
    };

_$OptimalTimingAnalysisImpl _$$OptimalTimingAnalysisImplFromJson(
        Map<String, dynamic> json) =>
    _$OptimalTimingAnalysisImpl(
      userId: json['userId'] as String,
      category: $enumDecode(_$NotificationCategoryEnumMap, json['category']),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      optimalHours: (json['optimalHours'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      optimalDaysOfWeek: (json['optimalDaysOfWeek'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      sampleSize: (json['sampleSize'] as num?)?.toInt() ?? 0,
      hourlyEngagementRates:
          (json['hourlyEngagementRates'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      dailyEngagementRates:
          (json['dailyEngagementRates'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$$OptimalTimingAnalysisImplToJson(
        _$OptimalTimingAnalysisImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'category': _$NotificationCategoryEnumMap[instance.category]!,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
      'optimalHours': instance.optimalHours,
      'optimalDaysOfWeek': instance.optimalDaysOfWeek,
      'confidence': instance.confidence,
      'sampleSize': instance.sampleSize,
      'hourlyEngagementRates': instance.hourlyEngagementRates,
      'dailyEngagementRates': instance.dailyEngagementRates,
    };

_$BehaviorPatternAnalysisImpl _$$BehaviorPatternAnalysisImplFromJson(
        Map<String, dynamic> json) =>
    _$BehaviorPatternAnalysisImpl(
      userId: json['userId'] as String,
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      activeHours: (json['activeHours'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredCategories: (json['preferredCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      engagementTrend: (json['engagementTrend'] as num?)?.toDouble() ?? 0.0,
      responsiveness: (json['responsiveness'] as num?)?.toDouble() ?? 0.0,
      averageResponseTime: json['averageResponseTime'] == null
          ? Duration.zero
          : Duration(
              microseconds: (json['averageResponseTime'] as num).toInt()),
      categoryPreferences:
          (json['categoryPreferences'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      timingPreferences:
          (json['timingPreferences'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$$BehaviorPatternAnalysisImplToJson(
        _$BehaviorPatternAnalysisImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
      'activeHours': instance.activeHours,
      'preferredCategories': instance.preferredCategories,
      'engagementTrend': instance.engagementTrend,
      'responsiveness': instance.responsiveness,
      'averageResponseTime': instance.averageResponseTime.inMicroseconds,
      'categoryPreferences': instance.categoryPreferences,
      'timingPreferences': instance.timingPreferences,
    };

_$NotificationABTestResultImpl _$$NotificationABTestResultImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationABTestResultImpl(
      testId: json['testId'] as String,
      userId: json['userId'] as String,
      category: $enumDecode(_$NotificationCategoryEnumMap, json['category']),
      variant: json['variant'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      conversions: (json['conversions'] as num?)?.toInt() ?? 0,
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      testParameters: json['testParameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$NotificationABTestResultImplToJson(
        _$NotificationABTestResultImpl instance) =>
    <String, dynamic>{
      'testId': instance.testId,
      'userId': instance.userId,
      'category': _$NotificationCategoryEnumMap[instance.category]!,
      'variant': instance.variant,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'impressions': instance.impressions,
      'conversions': instance.conversions,
      'conversionRate': instance.conversionRate,
      'confidence': instance.confidence,
      'testParameters': instance.testParameters,
    };
