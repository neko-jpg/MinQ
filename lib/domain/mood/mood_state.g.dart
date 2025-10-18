// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MoodStateImpl _$$MoodStateImplFromJson(Map<String, dynamic> json) =>
    _$MoodStateImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      mood: json['mood'] as String,
      rating: (json['rating'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MoodStateImplToJson(_$MoodStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'mood': instance.mood,
      'rating': instance.rating,
      'createdAt': instance.createdAt.toIso8601String(),
    };
