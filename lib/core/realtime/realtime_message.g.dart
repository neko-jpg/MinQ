// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RealtimeMessageImpl _$$RealtimeMessageImplFromJson(
        Map<String, dynamic> json) =>
    _$RealtimeMessageImpl(
      id: json['id'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      payload: json['payload'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$RealtimeMessageImplToJson(
        _$RealtimeMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'senderId': instance.senderId,
      'recipientId': instance.recipientId,
      'timestamp': instance.timestamp.toIso8601String(),
      'payload': instance.payload,
      'metadata': instance.metadata,
    };

const _$MessageTypeEnumMap = {
  MessageType.heartbeat: 'heartbeat',
  MessageType.heartbeatResponse: 'heartbeatResponse',
  MessageType.userOnline: 'userOnline',
  MessageType.userOffline: 'userOffline',
  MessageType.pairMessage: 'pairMessage',
  MessageType.pairProgressShare: 'pairProgressShare',
  MessageType.pairEncouragement: 'pairEncouragement',
  MessageType.pairInvitation: 'pairInvitation',
  MessageType.pairAccepted: 'pairAccepted',
  MessageType.pushNotification: 'pushNotification',
  MessageType.questReminder: 'questReminder',
  MessageType.streakAlert: 'streakAlert',
  MessageType.leagueUpdate: 'leagueUpdate',
  MessageType.rankingChange: 'rankingChange',
  MessageType.xpGained: 'xpGained',
  MessageType.levelUp: 'levelUp',
  MessageType.challengeInvite: 'challengeInvite',
  MessageType.challengeUpdate: 'challengeUpdate',
  MessageType.challengeCompleted: 'challengeCompleted',
};
