// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_archetype.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitArchetypeImpl _$$HabitArchetypeImplFromJson(Map<String, dynamic> json) =>
    _$HabitArchetypeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      strengths:
          (json['strengths'] as List<dynamic>).map((e) => e as String).toList(),
      challenges: (json['challenges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$HabitArchetypeImplToJson(
        _$HabitArchetypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'strengths': instance.strengths,
      'challenges': instance.challenges,
    };
