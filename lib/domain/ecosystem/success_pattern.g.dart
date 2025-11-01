// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_pattern.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SuccessPatternImpl _$$SuccessPatternImplFromJson(Map<String, dynamic> json) =>
    _$SuccessPatternImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      description: json['description'] as String,
      relatedHabitIds: (json['relatedHabitIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$SuccessPatternImplToJson(
        _$SuccessPatternImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'description': instance.description,
      'relatedHabitIds': instance.relatedHabitIds,
    };
