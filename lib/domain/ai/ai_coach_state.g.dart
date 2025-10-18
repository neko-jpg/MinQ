// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_coach_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AICoachStateImpl _$$AICoachStateImplFromJson(Map<String, dynamic> json) =>
    _$AICoachStateImpl(
      userId: json['userId'] as String,
      conversationHistory: (json['conversationHistory'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      isTyping: json['isTyping'] as bool,
      lastInteraction: DateTime.parse(json['lastInteraction'] as String),
    );

Map<String, dynamic> _$$AICoachStateImplToJson(_$AICoachStateImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'conversationHistory': instance.conversationHistory,
      'isTyping': instance.isTyping,
      'lastInteraction': instance.lastInteraction.toIso8601String(),
    };
