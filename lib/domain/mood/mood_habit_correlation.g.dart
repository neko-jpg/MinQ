// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_habit_correlation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MoodHabitCorrelationImpl _$$MoodHabitCorrelationImplFromJson(
        Map<String, dynamic> json) =>
    _$MoodHabitCorrelationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      habitId: json['habitId'] as String,
      mood: json['mood'] as String,
      correlationScore: (json['correlationScore'] as num).toDouble(),
    );

Map<String, dynamic> _$$MoodHabitCorrelationImplToJson(
        _$MoodHabitCorrelationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'habitId': instance.habitId,
      'mood': instance.mood,
      'correlationScore': instance.correlationScore,
    };
