import 'package:cloud_firestore/cloud_firestore.dart';

/// ペア接続の状態
enum PairStatus {
  active,
  paused,
  ended,
}

/// ペア接続
class PairConnection {
  final String id;
  final String user1Id;
  final String user2Id;
  final PairStatus status;
  final String category;
  final DateTime createdAt;
  final DateTime? endedAt;
  final String? endReason;
  final PairSettings settings;
  final PairStatistics statistics;

  const PairConnection({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.status,
    required this.category,
    required this.createdAt,
    this.endedAt,
    this.endReason,
    required this.settings,
    required this.statistics,
  });

  /// メンバーリスト
  List<String> get members => [user1Id, user2Id];

  /// アクティブかどうか
  bool get isActive => status == PairStatus.active;

  /// パートナーのIDを取得
  String getPartnerId(String userId) {
    if (userId == user1Id) return user2Id;
    if (userId == user2Id) return user1Id;
    throw ArgumentError('User is not a member of this pair');
  }

  /// Firestoreから作成
  factory PairConnection.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PairConnection(
      id: doc.id,
      user1Id: data['user1Id'] as String,
      user2Id: data['user2Id'] as String,
      status: PairStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => PairStatus.active,
      ),
      category: data['category'] as String? ?? 'general',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      endedAt: data['endedAt'] != null 
          ? (data['endedAt'] as Timestamp).toDate() 
          : null,
      endReason: data['endReason'] as String?,
      settings: PairSettings.fromMap(data['settings'] as Map<String, dynamic>? ?? {}),
      statistics: PairStatistics.fromMap(data['statistics'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Firestoreに保存
  Map<String, dynamic> toFirestore() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'members': members,
      'status': status.name,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'endReason': endReason,
      'settings': settings.toFirestore(),
      'statistics': statistics.toFirestore(),
    };
  }

  /// コピーを作成
  PairConnection copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    PairStatus? status,
    String? category,
    DateTime? createdAt,
    DateTime? endedAt,
    String? endReason,
    PairSettings? settings,
    PairStatistics? statistics,
  }) {
    return PairConnection(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      endReason: endReason ?? this.endReason,
      settings: settings ?? this.settings,
      statistics: statistics ?? this.statistics,
    );
  }
}

/// ペア設定
class PairSettings {
  final bool progressNotifications;
  final bool chatNotifications;
  final bool challengeInvites;
  final bool weeklyReports;
  final bool shareStreaks;
  final bool shareCompletions;
  final bool allowEncouragement;

  const PairSettings({
    required this.progressNotifications,
    required this.chatNotifications,
    required this.challengeInvites,
    required this.weeklyReports,
    required this.shareStreaks,
    required this.shareCompletions,
    required this.allowEncouragement,
  });

  /// デフォルト設定
  factory PairSettings.defaultSettings() {
    return const PairSettings(
      progressNotifications: true,
      chatNotifications: true,
      challengeInvites: true,
      weeklyReports: true,
      shareStreaks: true,
      shareCompletions: true,
      allowEncouragement: true,
    );
  }

  /// Mapから作成
  factory PairSettings.fromMap(Map<String, dynamic> map) {
    return PairSettings(
      progressNotifications: map['progressNotifications'] as bool? ?? true,
      chatNotifications: map['chatNotifications'] as bool? ?? true,
      challengeInvites: map['challengeInvites'] as bool? ?? true,
      weeklyReports: map['weeklyReports'] as bool? ?? true,
      shareStreaks: map['shareStreaks'] as bool? ?? true,
      shareCompletions: map['shareCompletions'] as bool? ?? true,
      allowEncouragement: map['allowEncouragement'] as bool? ?? true,
    );
  }

  /// Firestoreに保存
  Map<String, dynamic> toFirestore() {
    return {
      'progressNotifications': progressNotifications,
      'chatNotifications': chatNotifications,
      'challengeInvites': challengeInvites,
      'weeklyReports': weeklyReports,
      'shareStreaks': shareStreaks,
      'shareCompletions': shareCompletions,
      'allowEncouragement': allowEncouragement,
    };
  }

  /// コピーを作成
  PairSettings copyWith({
    bool? progressNotifications,
    bool? chatNotifications,
    bool? challengeInvites,
    bool? weeklyReports,
    bool? shareStreaks,
    bool? shareCompletions,
    bool? allowEncouragement,
  }) {
    return PairSettings(
      progressNotifications: progressNotifications ?? this.progressNotifications,
      chatNotifications: chatNotifications ?? this.chatNotifications,
      challengeInvites: challengeInvites ?? this.challengeInvites,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      shareStreaks: shareStreaks ?? this.shareStreaks,
      shareCompletions: shareCompletions ?? this.shareCompletions,
      allowEncouragement: allowEncouragement ?? this.allowEncouragement,
    );
  }
}

/// ペア統計
class PairStatistics {
  final int totalMessages;
  final int totalProgressShares;
  final int totalEncouragements;
  final int sharedStreakDays;
  final DateTime? lastInteractionAt;
  final Map<String, int> categoryProgress;

  const PairStatistics({
    required this.totalMessages,
    required this.totalProgressShares,
    required this.totalEncouragements,
    required this.sharedStreakDays,
    this.lastInteractionAt,
    required this.categoryProgress,
  });

  /// 空の統計
  factory PairStatistics.empty() {
    return const PairStatistics(
      totalMessages: 0,
      totalProgressShares: 0,
      totalEncouragements: 0,
      sharedStreakDays: 0,
      categoryProgress: {},
    );
  }

  /// Mapから作成
  factory PairStatistics.fromMap(Map<String, dynamic> map) {
    return PairStatistics(
      totalMessages: map['totalMessages'] as int? ?? 0,
      totalProgressShares: map['totalProgressShares'] as int? ?? 0,
      totalEncouragements: map['totalEncouragements'] as int? ?? 0,
      sharedStreakDays: map['sharedStreakDays'] as int? ?? 0,
      lastInteractionAt: map['lastInteractionAt'] != null
          ? (map['lastInteractionAt'] as Timestamp).toDate()
          : null,
      categoryProgress: Map<String, int>.from(map['categoryProgress'] as Map? ?? {}),
    );
  }

  /// Firestoreに保存
  Map<String, dynamic> toFirestore() {
    return {
      'totalMessages': totalMessages,
      'totalProgressShares': totalProgressShares,
      'totalEncouragements': totalEncouragements,
      'sharedStreakDays': sharedStreakDays,
      'lastInteractionAt': lastInteractionAt != null
          ? Timestamp.fromDate(lastInteractionAt!)
          : null,
      'categoryProgress': categoryProgress,
    };
  }

  /// コピーを作成
  PairStatistics copyWith({
    int? totalMessages,
    int? totalProgressShares,
    int? totalEncouragements,
    int? sharedStreakDays,
    DateTime? lastInteractionAt,
    Map<String, int>? categoryProgress,
  }) {
    return PairStatistics(
      totalMessages: totalMessages ?? this.totalMessages,
      totalProgressShares: totalProgressShares ?? this.totalProgressShares,
      totalEncouragements: totalEncouragements ?? this.totalEncouragements,
      sharedStreakDays: sharedStreakDays ?? this.sharedStreakDays,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      categoryProgress: categoryProgress ?? this.categoryProgress,
    );
  }
}