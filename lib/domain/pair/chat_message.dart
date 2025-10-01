import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderId,
    String? text,
    String? imageUrl,
    required DateTime timestamp,
    @Default({}) Map<String, int> reactions,
  }) = _ChatMessage;

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String,
      text: data['text'] as String?,
      imageUrl: data['imageUrl'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      reactions: Map<String, int>.from(data['reactions'] as Map? ?? {}),
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}