import 'package:freezed_annotation/freezed_annotation.dart';

part 'realtime_message.freezed.dart';
part 'realtime_message.g.dart';

/// リアルタイムメッセージタイプ
enum MessageType {
  // システムメッセージ
  heartbeat,
  heartbeatResponse,
  userOnline,
  userOffline,

  // ペアメッセージ
  pairMessage,
  pairProgressShare,
  pairEncouragement,
  pairInvitation,
  pairAccepted,

  // 通知
  pushNotification,
  questReminder,
  streakAlert,

  // リーグ・ランキング
  leagueUpdate,
  rankingChange,
  xpGained,
  levelUp,

  // チャレンジ
  challengeInvite,
  challengeUpdate,
  challengeCompleted,
}

/// リアルタイムメッセージ
@freezed
class RealtimeMessage with _$RealtimeMessage {
  const factory RealtimeMessage({
    required String id,
    required MessageType type,
    required String senderId,
    String? recipientId,
    required DateTime timestamp,
    required Map<String, dynamic> payload,
    @Default({}) Map<String, dynamic> metadata,
  }) = _RealtimeMessage;

  /// ハートビートメッセージを作成
  factory RealtimeMessage.heartbeat() {
    return RealtimeMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.heartbeat,
      senderId: 'client',
      timestamp: DateTime.now(),
      payload: {},
    );
  }

  /// ペアメッセージを作成
  factory RealtimeMessage.pairMessage({
    required String messageId,
    required String senderId,
    required String recipientId,
    required String text,
    String? imageUrl,
  }) {
    return RealtimeMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.pairMessage,
      senderId: senderId,
      recipientId: recipientId,
      timestamp: DateTime.now(),
      payload: {'messageId': messageId, 'text': text, 'imageUrl': imageUrl},
    );
  }

  /// 進捗共有メッセージを作成
  factory RealtimeMessage.progressShare({
    required String senderId,
    required String recipientId,
    required String shareId,
    required String title,
    required String description,
    int? score,
    List<String>? tags,
  }) {
    return RealtimeMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.pairProgressShare,
      senderId: senderId,
      recipientId: recipientId,
      timestamp: DateTime.now(),
      payload: {
        'shareId': shareId,
        'title': title,
        'description': description,
        'score': score,
        'tags': tags ?? [],
      },
    );
  }

  /// 励ましメッセージを作成
  factory RealtimeMessage.encouragement({
    required String senderId,
    required String recipientId,
    required String message,
    String? questId,
  }) {
    return RealtimeMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.pairEncouragement,
      senderId: senderId,
      recipientId: recipientId,
      timestamp: DateTime.now(),
      payload: {'message': message, 'questId': questId},
    );
  }

  /// XP獲得メッセージを作成
  factory RealtimeMessage.xpGained({
    required String userId,
    required int xpAmount,
    required String reason,
    String? questId,
  }) {
    return RealtimeMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.xpGained,
      senderId: 'system',
      recipientId: userId,
      timestamp: DateTime.now(),
      payload: {'xpAmount': xpAmount, 'reason': reason, 'questId': questId},
    );
  }

  /// レベルアップメッセージを作成
  factory RealtimeMessage.levelUp({
    required String userId,
    required int newLevel,
    required int totalXP,
    List<String>? rewards,
  }) {
    return RealtimeMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.levelUp,
      senderId: 'system',
      recipientId: userId,
      timestamp: DateTime.now(),
      payload: {
        'newLevel': newLevel,
        'totalXP': totalXP,
        'rewards': rewards ?? [],
      },
    );
  }

  /// ランキング変更メッセージを作成
  factory RealtimeMessage.rankingChange({
    required String userId,
    required String league,
    required int oldRank,
    required int newRank,
    required int weeklyXP,
  }) {
    return RealtimeMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.rankingChange,
      senderId: 'system',
      recipientId: userId,
      timestamp: DateTime.now(),
      payload: {
        'league': league,
        'oldRank': oldRank,
        'newRank': newRank,
        'weeklyXP': weeklyXP,
      },
    );
  }

  /// プッシュ通知メッセージを作成
  factory RealtimeMessage.pushNotification({
    required String recipientId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return RealtimeMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.pushNotification,
      senderId: 'system',
      recipientId: recipientId,
      timestamp: DateTime.now(),
      payload: {'title': title, 'body': body, 'data': data ?? {}},
    );
  }

  factory RealtimeMessage.fromJson(Map<String, dynamic> json) =>
      _$RealtimeMessageFromJson(json);
}
