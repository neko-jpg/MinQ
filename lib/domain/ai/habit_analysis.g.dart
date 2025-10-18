// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitAnalysisImpl _$$HabitAnalysisImplFromJson(Map<String, dynamic> json) =>
    _$HabitAnalysisImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      habitId: json['habitId'] as String,
      successRate: (json['successRate'] as num).toDouble(),
      successByDay: (json['successByDay'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      successByTime: (json['successByTime'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$HabitAnalysisImplToJson(_$HabitAnalysisImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'habitId': instance.habitId,
      'successRate': instance.successRate,
      'successByDay': instance.successByDay,
      'successByTime': instance.successByTime,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
