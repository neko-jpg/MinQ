// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeProgressImpl _$$ChallengeProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$ChallengeProgressImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      challengeId: json['challengeId'] as String,
      progress: (json['progress'] as num).toInt(),
      completed: json['completed'] as bool,
    );

Map<String, dynamic> _$$ChallengeProgressImplToJson(
        _$ChallengeProgressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'challengeId': instance.challengeId,
      'progress': instance.progress,
      'completed': instance.completed,
    };
