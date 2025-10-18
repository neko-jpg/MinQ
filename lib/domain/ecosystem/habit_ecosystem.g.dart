// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_ecosystem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitEcosystemImpl _$$HabitEcosystemImplFromJson(Map<String, dynamic> json) =>
    _$HabitEcosystemImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      connections: (json['connections'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$HabitEcosystemImplToJson(
        _$HabitEcosystemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'connections': instance.connections,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
