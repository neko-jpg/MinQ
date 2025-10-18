import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String text,
    required String sender, // 'user' or 'ai'
    required DateTime timestamp,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}