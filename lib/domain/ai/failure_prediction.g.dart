// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'failure_prediction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FailurePredictionModelImpl _$$FailurePredictionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$FailurePredictionModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      habitId: json['habitId'] as String,
      predictionScore: (json['predictionScore'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FailurePredictionModelImplToJson(
        _$FailurePredictionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'habitId': instance.habitId,
      'predictionScore': instance.predictionScore,
      'createdAt': instance.createdAt.toIso8601String(),
    };
