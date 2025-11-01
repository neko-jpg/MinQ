// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeSlotImpl _$$TimeSlotImplFromJson(Map<String, dynamic> json) =>
    _$TimeSlotImpl(
      startHour: (json['startHour'] as num).toInt(),
      startMinute: (json['startMinute'] as num).toInt(),
      endHour: (json['endHour'] as num).toInt(),
      endMinute: (json['endMinute'] as num).toInt(),
    );

Map<String, dynamic> _$$TimeSlotImplToJson(_$TimeSlotImpl instance) =>
    <String, dynamic>{
      'startHour': instance.startHour,
      'startMinute': instance.startMinute,
      'endHour': instance.endHour,
      'endMinute': instance.endMinute,
    };

_$CategoryNotificationSettingsImpl _$$CategoryNotificationSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$CategoryNotificationSettingsImpl(
      category: $enumDecode(_$NotificationCategoryEnumMap, json['category']),
      enabled: json['enabled'] as bool? ?? true,
      frequency: $enumDecodeNullable(
              _$NotificationFrequencyEnumMap, json['frequency']) ??
          NotificationFrequency.immediate,
      sound: json['sound'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
      badge: json['badge'] as bool? ?? true,
      lockScreen: json['lockScreen'] as bool? ?? true,
      customSound: json['customSound'] as String?,
      vibrationPattern: (json['vibrationPattern'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$$CategoryNotificationSettingsImplToJson(
        _$CategoryNotificationSettingsImpl instance) =>
    <String, dynamic>{
      'category': _$NotificationCategoryEnumMap[instance.category]!,
      'enabled': instance.enabled,
      'frequency': _$NotificationFrequencyEnumMap[instance.frequency]!,
      'sound': instance.sound,
      'vibration': instance.vibration,
      'badge': instance.badge,
      'lockScreen': instance.lockScreen,
      'customSound': instance.customSound,
      'vibrationPattern': instance.vibrationPattern,
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

const _$NotificationFrequencyEnumMap = {
  NotificationFrequency.immediate: 'immediate',
  NotificationFrequency.hourly: 'hourly',
  NotificationFrequency.threeHours: 'threeHours',
  NotificationFrequency.daily: 'daily',
};

_$TimeBasedNotificationSettingsImpl
    _$$TimeBasedNotificationSettingsImplFromJson(Map<String, dynamic> json) =>
        _$TimeBasedNotificationSettingsImpl(
          enabled: json['enabled'] as bool? ?? true,
          sleepTime: json['sleepTime'] == null
              ? null
              : TimeSlot.fromJson(json['sleepTime'] as Map<String, dynamic>),
          workTime: json['workTime'] == null
              ? null
              : TimeSlot.fromJson(json['workTime'] as Map<String, dynamic>),
          customQuietHours: (json['customQuietHours'] as List<dynamic>?)
                  ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
          respectSystemDnd: json['respectSystemDnd'] as bool? ?? true,
          weekendMode: json['weekendMode'] as bool? ?? false,
          weekendSleepTime: json['weekendSleepTime'] == null
              ? null
              : TimeSlot.fromJson(
                  json['weekendSleepTime'] as Map<String, dynamic>),
          weekendWorkTime: json['weekendWorkTime'] == null
              ? null
              : TimeSlot.fromJson(
                  json['weekendWorkTime'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$$TimeBasedNotificationSettingsImplToJson(
        _$TimeBasedNotificationSettingsImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'sleepTime': instance.sleepTime,
      'workTime': instance.workTime,
      'customQuietHours': instance.customQuietHours,
      'respectSystemDnd': instance.respectSystemDnd,
      'weekendMode': instance.weekendMode,
      'weekendSleepTime': instance.weekendSleepTime,
      'weekendWorkTime': instance.weekendWorkTime,
    };

_$SmartNotificationSettingsImpl _$$SmartNotificationSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$SmartNotificationSettingsImpl(
      enabled: json['enabled'] as bool? ?? true,
      behaviorLearning: json['behaviorLearning'] as bool? ?? true,
      adaptiveFrequency: json['adaptiveFrequency'] as bool? ?? true,
      contextAware: json['contextAware'] as bool? ?? true,
      engagementOptimization: json['engagementOptimization'] as bool? ?? true,
      confidenceThreshold:
          (json['confidenceThreshold'] as num?)?.toDouble() ?? 0.7,
      learningPeriodDays: (json['learningPeriodDays'] as num?)?.toInt() ?? 7,
    );

Map<String, dynamic> _$$SmartNotificationSettingsImplToJson(
        _$SmartNotificationSettingsImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'behaviorLearning': instance.behaviorLearning,
      'adaptiveFrequency': instance.adaptiveFrequency,
      'contextAware': instance.contextAware,
      'engagementOptimization': instance.engagementOptimization,
      'confidenceThreshold': instance.confidenceThreshold,
      'learningPeriodDays': instance.learningPeriodDays,
    };

_$NotificationAnalyticsSettingsImpl
    _$$NotificationAnalyticsSettingsImplFromJson(Map<String, dynamic> json) =>
        _$NotificationAnalyticsSettingsImpl(
          enabled: json['enabled'] as bool? ?? true,
          trackOpenRate: json['trackOpenRate'] as bool? ?? true,
          trackEngagementRate: json['trackEngagementRate'] as bool? ?? true,
          trackConversionRate: json['trackConversionRate'] as bool? ?? true,
          trackOptimalTiming: json['trackOptimalTiming'] as bool? ?? true,
          retentionPeriodDays:
              (json['retentionPeriodDays'] as num?)?.toInt() ?? 30,
        );

Map<String, dynamic> _$$NotificationAnalyticsSettingsImplToJson(
        _$NotificationAnalyticsSettingsImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'trackOpenRate': instance.trackOpenRate,
      'trackEngagementRate': instance.trackEngagementRate,
      'trackConversionRate': instance.trackConversionRate,
      'trackOptimalTiming': instance.trackOptimalTiming,
      'retentionPeriodDays': instance.retentionPeriodDays,
    };

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationSettingsImpl(
      globalEnabled: json['globalEnabled'] as bool? ?? true,
      categorySettings:
          (json['categorySettings'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    $enumDecode(_$NotificationCategoryEnumMap, k),
                    CategoryNotificationSettings.fromJson(
                        e as Map<String, dynamic>)),
              ) ??
              const {},
      timeSettings: json['timeSettings'] == null
          ? const TimeBasedNotificationSettings()
          : TimeBasedNotificationSettings.fromJson(
              json['timeSettings'] as Map<String, dynamic>),
      smartSettings: json['smartSettings'] == null
          ? const SmartNotificationSettings()
          : SmartNotificationSettings.fromJson(
              json['smartSettings'] as Map<String, dynamic>),
      analyticsSettings: json['analyticsSettings'] == null
          ? const NotificationAnalyticsSettings()
          : NotificationAnalyticsSettings.fromJson(
              json['analyticsSettings'] as Map<String, dynamic>),
      deviceToken: json['deviceToken'] as String? ?? '',
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$NotificationSettingsImplToJson(
        _$NotificationSettingsImpl instance) =>
    <String, dynamic>{
      'globalEnabled': instance.globalEnabled,
      'categorySettings': instance.categorySettings
          .map((k, e) => MapEntry(_$NotificationCategoryEnumMap[k]!, e)),
      'timeSettings': instance.timeSettings,
      'smartSettings': instance.smartSettings,
      'analyticsSettings': instance.analyticsSettings,
      'deviceToken': instance.deviceToken,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

_$NotificationContextImpl _$$NotificationContextImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationContextImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      category: $enumDecode(_$NotificationCategoryEnumMap, json['category']),
      userId: json['userId'] as String,
      questId: json['questId'] as String?,
      challengeId: json['challengeId'] as String?,
      pairId: json['pairId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isUrgent: json['isUrgent'] as bool? ?? false,
      priority: (json['priority'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$NotificationContextImplToJson(
        _$NotificationContextImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'category': _$NotificationCategoryEnumMap[instance.category]!,
      'userId': instance.userId,
      'questId': instance.questId,
      'challengeId': instance.challengeId,
      'pairId': instance.pairId,
      'metadata': instance.metadata,
      'isUrgent': instance.isUrgent,
      'priority': instance.priority,
    };
