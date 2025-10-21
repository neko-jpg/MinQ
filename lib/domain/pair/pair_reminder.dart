/// リマインダーの種類
enum ReminderType {
  encouragement, // 励まし
  celebration, // お祝い
  checkIn, // チェックイン
  motivation, // モチベーション
}

/// ペア間のリマインダー
class PairReminder {
  final String id;
  final String pairId;
  final String senderId;
  final String receiverId;
  final ReminderType type;
  final String message;
  final DateTime sentAt;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  const PairReminder({
    required this.id,
    required this.pairId,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.message,
    required this.sentAt,
    required this.isRead,
    this.readAt,
    this.metadata,
  });

  factory PairReminder.fromJson(Map<String, dynamic> json) {
    return PairReminder(
      id: json['id'] as String,
      pairId: json['pairId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.encouragement,
      ),
      message: json['message'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      isRead: json['isRead'] as bool,
      readAt:
          json['readAt'] != null
              ? DateTime.parse(json['readAt'] as String)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pairId': pairId,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type.name,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  PairReminder copyWith({
    String? id,
    String? pairId,
    String? senderId,
    String? receiverId,
    ReminderType? type,
    String? message,
    DateTime? sentAt,
    bool? isRead,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return PairReminder(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// リマインダーテンプレート
class ReminderTemplate {
  final ReminderType type;
  final String message;
  final String emoji;
  final bool isCustom;

  const ReminderTemplate({
    required this.type,
    required this.message,
    required this.emoji,
    this.isCustom = false,
  });

  factory ReminderTemplate.fromJson(Map<String, dynamic> json) {
    return ReminderTemplate(
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.encouragement,
      ),
      message: json['message'] as String,
      emoji: json['emoji'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'message': message,
      'emoji': emoji,
      'isCustom': isCustom,
    };
  }
}

/// 定型リマインダーメッセージ
class ReminderTemplates {
  static const List<ReminderTemplate> encouragementTemplates = [
    ReminderTemplate(
      type: ReminderType.encouragement,
      message: '今日のクエスト、一緒に頑張りましょう！',
      emoji: '💪',
    ),
    ReminderTemplate(
      type: ReminderType.encouragement,
      message: 'あと少しで今日の目標達成ですね！',
      emoji: '🔥',
    ),
    ReminderTemplate(
      type: ReminderType.encouragement,
      message: '継続は力なり！今日も一歩ずつ進みましょう',
      emoji: '🌟',
    ),
    ReminderTemplate(
      type: ReminderType.encouragement,
      message: '一緒に習慣化を続けていきましょう！',
      emoji: '🤝',
    ),
  ];

  static const List<ReminderTemplate> celebrationTemplates = [
    ReminderTemplate(
      type: ReminderType.celebration,
      message: 'お疲れさまでした！今日もよく頑張りましたね',
      emoji: '🎉',
    ),
    ReminderTemplate(
      type: ReminderType.celebration,
      message: '素晴らしい！今日も目標達成ですね',
      emoji: '✨',
    ),
    ReminderTemplate(
      type: ReminderType.celebration,
      message: '継続記録更新！本当にすごいです',
      emoji: '🏆',
    ),
    ReminderTemplate(
      type: ReminderType.celebration,
      message: '今日も一日お疲れさまでした！',
      emoji: '😊',
    ),
  ];

  static const List<ReminderTemplate> checkInTemplates = [
    ReminderTemplate(
      type: ReminderType.checkIn,
      message: '調子はどうですか？一緒に継続していきましょう',
      emoji: '😊',
    ),
    ReminderTemplate(
      type: ReminderType.checkIn,
      message: '最近どうですか？お互い頑張りましょう',
      emoji: '🤗',
    ),
    ReminderTemplate(
      type: ReminderType.checkIn,
      message: '今日の調子はいかがですか？',
      emoji: '💭',
    ),
    ReminderTemplate(
      type: ReminderType.checkIn,
      message: 'お元気ですか？一緒に頑張っていきましょう',
      emoji: '🌈',
    ),
  ];

  static const List<ReminderTemplate> motivationTemplates = [
    ReminderTemplate(
      type: ReminderType.motivation,
      message: 'あなたならできます！応援しています',
      emoji: '🌟',
    ),
    ReminderTemplate(
      type: ReminderType.motivation,
      message: '小さな一歩も大きな変化につながります',
      emoji: '🚀',
    ),
    ReminderTemplate(
      type: ReminderType.motivation,
      message: '今日も素敵な一日にしましょう！',
      emoji: '☀️',
    ),
    ReminderTemplate(
      type: ReminderType.motivation,
      message: '一緒に成長していきましょう！',
      emoji: '🌱',
    ),
  ];

  /// 指定されたタイプのテンプレートを取得
  static List<ReminderTemplate> getTemplates(ReminderType type) {
    switch (type) {
      case ReminderType.encouragement:
        return encouragementTemplates;
      case ReminderType.celebration:
        return celebrationTemplates;
      case ReminderType.checkIn:
        return checkInTemplates;
      case ReminderType.motivation:
        return motivationTemplates;
    }
  }

  /// 全てのテンプレートを取得
  static List<ReminderTemplate> getAllTemplates() {
    return [
      ...encouragementTemplates,
      ...celebrationTemplates,
      ...checkInTemplates,
      ...motivationTemplates,
    ];
  }
}
