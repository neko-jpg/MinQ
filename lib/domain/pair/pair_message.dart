import 'package:cloud_firestore/cloud_firestore.dart';

/// メッセージタイプ
enum MessageType { text, image, sticker, encouragement, system }

/// ペアメッセージ
class PairMessage {
  final String id;
  final String senderId;
  final MessageType type;
  final String? text;
  final String? imageUrl;
  final String? stickerUrl;
  final DateTime timestamp;
  final Map<String, List<String>> reactions;
  final bool isRead;
  final DateTime? readAt;

  const PairMessage({
    required this.id,
    required this.senderId,
    required this.type,
    this.text,
    this.imageUrl,
    this.stickerUrl,
    required this.timestamp,
    required this.reactions,
    required this.isRead,
    this.readAt,
  });

  /// テキストメッセージを作成
  factory PairMessage.text({
    required String id,
    required String senderId,
    required String text,
    required DateTime timestamp,
  }) {
    return PairMessage(
      id: id,
      senderId: senderId,
      type: MessageType.text,
      text: text,
      timestamp: timestamp,
      reactions: {},
      isRead: false,
    );
  }

  /// 画像メッセージを作成
  factory PairMessage.image({
    required String id,
    required String senderId,
    required String imageUrl,
    String? caption,
    required DateTime timestamp,
  }) {
    return PairMessage(
      id: id,
      senderId: senderId,
      type: MessageType.image,
      text: caption,
      imageUrl: imageUrl,
      timestamp: timestamp,
      reactions: {},
      isRead: false,
    );
  }

  /// 励ましメッセージを作成
  factory PairMessage.encouragement({
    required String id,
    required String senderId,
    required String text,
    required DateTime timestamp,
  }) {
    return PairMessage(
      id: id,
      senderId: senderId,
      type: MessageType.encouragement,
      text: text,
      timestamp: timestamp,
      reactions: {},
      isRead: false,
    );
  }

  /// システムメッセージを作成
  factory PairMessage.system({
    required String id,
    required String text,
    required DateTime timestamp,
  }) {
    return PairMessage(
      id: id,
      senderId: 'system',
      type: MessageType.system,
      text: text,
      timestamp: timestamp,
      reactions: {},
      isRead: true,
    );
  }

  /// Firestoreから作成
  factory PairMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PairMessage(
      id: doc.id,
      senderId: data['senderId'] as String,
      type: MessageType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => MessageType.text,
      ),
      text: data['text'] as String?,
      imageUrl: data['imageUrl'] as String?,
      stickerUrl: data['stickerUrl'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      reactions: Map<String, List<String>>.from(
        (data['reactions'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value as List)),
        ),
      ),
      isRead: data['isRead'] as bool? ?? false,
      readAt:
          data['readAt'] != null
              ? (data['readAt'] as Timestamp).toDate()
              : null,
    );
  }

  /// Firestoreに保存
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'type': type.name,
      'text': text,
      'imageUrl': imageUrl,
      'stickerUrl': stickerUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'reactions': reactions.map((key, value) => MapEntry(key, value)),
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  /// 既読にする
  PairMessage markAsRead() {
    return copyWith(isRead: true, readAt: DateTime.now());
  }

  /// リアクションを追加/削除
  PairMessage toggleReaction(String emoji, String userId) {
    final newReactions = Map<String, List<String>>.from(reactions);

    if (newReactions.containsKey(emoji)) {
      if (newReactions[emoji]!.contains(userId)) {
        newReactions[emoji]!.remove(userId);
        if (newReactions[emoji]!.isEmpty) {
          newReactions.remove(emoji);
        }
      } else {
        newReactions[emoji]!.add(userId);
      }
    } else {
      newReactions[emoji] = [userId];
    }

    return copyWith(reactions: newReactions);
  }

  /// コピーを作成
  PairMessage copyWith({
    String? id,
    String? senderId,
    MessageType? type,
    String? text,
    String? imageUrl,
    String? stickerUrl,
    DateTime? timestamp,
    Map<String, List<String>>? reactions,
    bool? isRead,
    DateTime? readAt,
  }) {
    return PairMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      stickerUrl: stickerUrl ?? this.stickerUrl,
      timestamp: timestamp ?? this.timestamp,
      reactions: reactions ?? this.reactions,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}
