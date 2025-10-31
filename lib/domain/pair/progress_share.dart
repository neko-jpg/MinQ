import 'package:cloud_firestore/cloud_firestore.dart';

/// 進捗共有のタイプ
enum ProgressShareType {
  questCompleted,
  streakAchieved,
  challengeCompleted,
  milestoneReached,
  encouragement,
}

/// 進捗共有
class ProgressShare {
  final String id;
  final String userId;
  final ProgressShareType type;
  final String title;
  final String? description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final int? score;
  final String? imageUrl;
  final List<String> tags;

  const ProgressShare({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.description,
    required this.timestamp,
    required this.metadata,
    this.score,
    this.imageUrl,
    required this.tags,
  });

  /// クエスト完了の進捗共有を作成
  factory ProgressShare.questCompleted({
    required String id,
    required String userId,
    required String questTitle,
    String? description,
    required DateTime timestamp,
    int? score,
    List<String>? tags,
  }) {
    return ProgressShare(
      id: id,
      userId: userId,
      type: ProgressShareType.questCompleted,
      title: questTitle,
      description: description,
      timestamp: timestamp,
      metadata: {'questId': id},
      score: score,
      tags: tags ?? [],
    );
  }

  /// ストリーク達成の進捗共有を作成
  factory ProgressShare.streakAchieved({
    required String id,
    required String userId,
    required int streakDays,
    required DateTime timestamp,
    List<String>? tags,
  }) {
    return ProgressShare(
      id: id,
      userId: userId,
      type: ProgressShareType.streakAchieved,
      title: '$streakDays日連続達成！',
      description: '継続は力なり！素晴らしいストリークです。',
      timestamp: timestamp,
      metadata: {'streakDays': streakDays},
      score: streakDays * 10,
      tags: tags ?? [],
    );
  }

  /// チャレンジ完了の進捗共有を作成
  factory ProgressShare.challengeCompleted({
    required String id,
    required String userId,
    required String challengeTitle,
    String? description,
    required DateTime timestamp,
    int? score,
    List<String>? tags,
  }) {
    return ProgressShare(
      id: id,
      userId: userId,
      type: ProgressShareType.challengeCompleted,
      title: challengeTitle,
      description: description,
      timestamp: timestamp,
      metadata: {'challengeId': id},
      score: score,
      tags: tags ?? [],
    );
  }

  /// 励ましメッセージの進捗共有を作成
  factory ProgressShare.encouragement({
    required String id,
    required String userId,
    required String message,
    required DateTime timestamp,
  }) {
    return ProgressShare(
      id: id,
      userId: userId,
      type: ProgressShareType.encouragement,
      title: '励ましメッセージ',
      description: message,
      timestamp: timestamp,
      metadata: {},
      tags: [],
    );
  }

  /// Firestoreから作成
  factory ProgressShare.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressShare(
      id: doc.id,
      userId: data['userId'] as String,
      type: ProgressShareType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ProgressShareType.questCompleted,
      ),
      title: data['title'] as String,
      description: data['description'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] as Map? ?? {}),
      score: data['score'] as int?,
      imageUrl: data['imageUrl'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? []),
    );
  }

  /// Firestoreに保存
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
      'score': score,
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }

  /// コピーを作成
  ProgressShare copyWith({
    String? id,
    String? userId,
    ProgressShareType? type,
    String? title,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    int? score,
    String? imageUrl,
    List<String>? tags,
  }) {
    return ProgressShare(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      score: score ?? this.score,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
    );
  }
}