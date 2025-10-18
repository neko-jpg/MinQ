// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PointsImpl _$$PointsImplFromJson(Map<String, dynamic> json) => _$PointsImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      value: (json['value'] as num).toInt(),
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PointsImplToJson(_$PointsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'value': instance.value,
      'reason': instance.reason,
      'createdAt': instance.createdAt.toIso8601String(),
    };
