// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_capsule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeCapsuleImpl _$$TimeCapsuleImplFromJson(Map<String, dynamic> json) =>
    _$TimeCapsuleImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      message: json['message'] as String,
      prediction: json['prediction'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveryDate: DateTime.parse(json['deliveryDate'] as String),
    );

Map<String, dynamic> _$$TimeCapsuleImplToJson(_$TimeCapsuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'message': instance.message,
      'prediction': instance.prediction,
      'createdAt': instance.createdAt.toIso8601String(),
      'deliveryDate': instance.deliveryDate.toIso8601String(),
    };
