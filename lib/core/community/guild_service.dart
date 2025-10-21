import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// ハビットコミュニティ（ギルド）サービス
/// MMO的な協力システムでユーザー同士が習慣継続を支援
class GuildService {
  static GuildService? _instance;
  static GuildService get instance => _instance ??= GuildService._();

  GuildService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? _guildsSubscription;
  StreamSubscription<DocumentSnapshot>? _currentGuildSubscription;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  final ValueNotifier<List<Guild>> _availableGuilds = ValueNotifier([]);
  final ValueNotifier<Guild?> _currentGuild = ValueNotifier(null);
  final ValueNotifier<List<GuildMessage>> _guildMessages = ValueNotifier([]);
  final ValueNotifier<List<GuildChallenge>> _activeChallenges = ValueNotifier(
    [],
  );

  ValueListenable<List<Guild>> get availableGuilds => _availableGuilds;
  ValueListenable<Guild?> get currentGuild => _currentGuild;
  ValueListenable<List<GuildMessage>> get guildMessages => _guildMessages;
  ValueListenable<List<GuildChallenge>> get activeChallenges =>
      _activeChallenges;

  /// サービスの初期化
  Future<void> initialize(String userId) async {
    try {
      log('GuildService: 初期化開始 - $userId');

      // ユーザーの所属ギルドを確認
      await _loadUserGuild(userId);

      // 利用可能なギルドを監視
      _guildsSubscription = _firestore
          .collection('guilds')
          .where('isPublic', isEqualTo: true)
          .where('memberCount', isLessThan: 50) // 最大50人
          .orderBy('memberCount', descending: false)
          .limit(20)
          .snapshots()
          .listen(_onAvailableGuildsChanged);

      log('GuildService: 初期化完了');
    } catch (e) {
      log('GuildService: 初期化エラー - $e');
    }
  }

  /// サービスの終了
  void dispose() {
    _guildsSubscription?.cancel();
    _currentGuildSubscription?.cancel();
    _messagesSubscription?.cancel();
    _availableGuilds.dispose();
    _currentGuild.dispose();
    _guildMessages.dispose();
    _activeChallenges.dispose();
  }

  /// ギルドの作成
  Future<Guild> createGuild({
    required String creatorId,
    required String name,
    required String description,
    required String category,
    String? iconUrl,
    bool isPublic = true,
    int maxMembers = 50,
  }) async {
    try {
      log('GuildService: ギルド作成開始');

      final guildId = _generateGuildId();
      final now = DateTime.now();

      final guild = Guild(
        id: guildId,
        name: name,
        description: description,
        category: category,
        iconUrl: iconUrl,
        creatorId: creatorId,
        adminIds: [creatorId],
        memberIds: [creatorId],
        memberCount: 1,
        maxMembers: maxMembers,
        isPublic: isPublic,
        level: 1,
        experience: 0,
        totalChallengesCompleted: 0,
        createdAt: now,
        lastActivityAt: now,
        rules: GuildRules.defaultRules(),
        stats: GuildStats.empty(),
      );

      await _firestore.collection('guilds').doc(guildId).set(guild.toMap());

      // ユーザーのギルド情報を更新
      await _updateUserGuildInfo(creatorId, guildId, GuildRole.admin);

      log('GuildService: ギルド作成完了 - $guildId');
      return guild;
    } catch (e) {
      log('GuildService: ギルド作成エラー - $e');
      rethrow;
    }
  }

  /// ギルドに参加
  Future<void> joinGuild(String guildId, String userId) async {
    try {
      log('GuildService: ギルド参加開始 - $guildId');

      final guildDoc = _firestore.collection('guilds').doc(guildId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(guildDoc);

        if (!snapshot.exists) {
          throw Exception('ギルドが見つかりません');
        }

        final guild = Guild.fromMap(snapshot.data()!);

        if (guild.memberIds.contains(userId)) {
          throw Exception('既に参加しています');
        }

        if (guild.memberCount >= guild.maxMembers) {
          throw Exception('メンバー数が上限に達しています');
        }

        if (!guild.isPublic) {
          throw Exception('このギルドは招待制です');
        }

        final updatedMemberIds = [...guild.memberIds, userId];

        transaction.update(guildDoc, {
          'memberIds': updatedMemberIds,
          'memberCount': updatedMemberIds.length,
          'lastActivityAt': FieldValue.serverTimestamp(),
        });
      });

      // ユーザーのギルド情報を更新
      await _updateUserGuildInfo(userId, guildId, GuildRole.member);

      // 参加メッセージを送信
      await sendMessage(
        guildId: guildId,
        senderId: 'system',
        content: 'ユーザーがギルドに参加しました！',
        type: GuildMessageType.system,
      );

      log('GuildService: ギルド参加完了');
    } catch (e) {
      log('GuildService: ギルド参加エラー - $e');
      rethrow;
    }
  }

  /// ギルドから退出
  Future<void> leaveGuild(String guildId, String userId) async {
    try {
      log('GuildService: ギルド退出開始 - $guildId');

      final guildDoc = _firestore.collection('guilds').doc(guildId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(guildDoc);

        if (!snapshot.exists) {
          throw Exception('ギルドが見つかりません');
        }

        final guild = Guild.fromMap(snapshot.data()!);

        if (!guild.memberIds.contains(userId)) {
          throw Exception('このギルドに参加していません');
        }

        final updatedMemberIds =
            guild.memberIds.where((id) => id != userId).toList();
        final updatedAdminIds =
            guild.adminIds.where((id) => id != userId).toList();

        // 最後のメンバーの場合はギルドを削除
        if (updatedMemberIds.isEmpty) {
          transaction.delete(guildDoc);
        } else {
          // 管理者が退出した場合は新しい管理者を指定
          if (guild.adminIds.contains(userId) && updatedAdminIds.isEmpty) {
            updatedAdminIds.add(updatedMemberIds.first);
          }

          transaction.update(guildDoc, {
            'memberIds': updatedMemberIds,
            'adminIds': updatedAdminIds,
            'memberCount': updatedMemberIds.length,
            'lastActivityAt': FieldValue.serverTimestamp(),
          });
        }
      });

      // ユーザーのギルド情報をクリア
      await _updateUserGuildInfo(userId, null, null);

      log('GuildService: ギルド退出完了');
    } catch (e) {
      log('GuildService: ギルド退出エラー - $e');
      rethrow;
    }
  }

  /// メッセージの送信
  Future<void> sendMessage({
    required String guildId,
    required String senderId,
    required String content,
    GuildMessageType type = GuildMessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      log('GuildService: メッセージ送信開始');

      final messageId = _generateMessageId();

      final message = GuildMessage(
        id: messageId,
        guildId: guildId,
        senderId: senderId,
        content: content,
        type: type,
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
        reactions: {},
      );

      await _firestore
          .collection('guild_messages')
          .doc(messageId)
          .set(message.toMap());

      // ギルドの最終活動時刻を更新
      await _firestore.collection('guilds').doc(guildId).update({
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      log('GuildService: メッセージ送信完了');
    } catch (e) {
      log('GuildService: メッセージ送信エラー - $e');
      rethrow;
    }
  }

  /// チャレンジの作成
  Future<GuildChallenge> createChallenge({
    required String guildId,
    required String creatorId,
    required String title,
    required String description,
    required String habitCategory,
    required int targetCount,
    required Duration duration,
    Map<String, dynamic>? rewards,
  }) async {
    try {
      log('GuildService: チャレンジ作成開始');

      final challengeId = _generateChallengeId();
      final now = DateTime.now();

      final challenge = GuildChallenge(
        id: challengeId,
        guildId: guildId,
        creatorId: creatorId,
        title: title,
        description: description,
        habitCategory: habitCategory,
        targetCount: targetCount,
        currentCount: 0,
        participantIds: [],
        completedUserIds: [],
        rewards: rewards ?? {},
        status: ChallengeStatus.active,
        createdAt: now,
        startTime: now,
        endTime: now.add(duration),
        completions: [],
      );

      await _firestore
          .collection('guild_challenges')
          .doc(challengeId)
          .set(challenge.toMap());

      log('GuildService: チャレンジ作成完了 - $challengeId');
      return challenge;
    } catch (e) {
      log('GuildService: チャレンジ作成エラー - $e');
      rethrow;
    }
  }

  /// チャレンジに参加
  Future<void> joinChallenge(String challengeId, String userId) async {
    try {
      log('GuildService: チャレンジ参加開始 - $challengeId');

      final challengeDoc = _firestore
          .collection('guild_challenges')
          .doc(challengeId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(challengeDoc);

        if (!snapshot.exists) {
          throw Exception('チャレンジが見つかりません');
        }

        final challenge = GuildChallenge.fromMap(snapshot.data()!);

        if (challenge.status != ChallengeStatus.active) {
          throw Exception('このチャレンジは参加できません');
        }

        if (challenge.participantIds.contains(userId)) {
          throw Exception('既に参加しています');
        }

        if (DateTime.now().isAfter(challenge.endTime)) {
          throw Exception('チャレンジの期限が過ぎています');
        }

        final updatedParticipantIds = [...challenge.participantIds, userId];

        transaction.update(challengeDoc, {
          'participantIds': updatedParticipantIds,
        });
      });

      log('GuildService: チャレンジ参加完了');
    } catch (e) {
      log('GuildService: チャレンジ参加エラー - $e');
      rethrow;
    }
  }

  /// チャレンジの完了を記録
  Future<void> recordChallengeCompletion({
    required String challengeId,
    required String userId,
    required String habitId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      log('GuildService: チャレンジ完了記録開始');

      final completionId = _generateCompletionId();

      final completion = ChallengeCompletion(
        id: completionId,
        challengeId: challengeId,
        userId: userId,
        habitId: habitId,
        completedAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      await _firestore
          .collection('challenge_completions')
          .doc(completionId)
          .set(completion.toMap());

      // チャレンジの進捗を更新
      await _updateChallengeProgress(challengeId, userId);

      log('GuildService: チャレンジ完了記録完了');
    } catch (e) {
      log('GuildService: チャレンジ完了記録エラー - $e');
      rethrow;
    }
  }

  /// ギルドの検索
  Future<List<Guild>> searchGuilds({
    String? query,
    String? category,
    int limit = 20,
  }) async {
    try {
      log('GuildService: ギルド検索開始');

      Query queryRef = _firestore
          .collection('guilds')
          .where('isPublic', isEqualTo: true);

      if (category != null) {
        queryRef = queryRef.where('category', isEqualTo: category);
      }

      queryRef = queryRef.orderBy('memberCount', descending: true).limit(limit);

      final snapshot = await queryRef.get();

      var guilds =
          snapshot.docs
              .map((doc) => Guild.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

      // クエリによるフィルタリング
      if (query != null && query.isNotEmpty) {
        guilds =
            guilds.where((guild) {
              return guild.name.toLowerCase().contains(query.toLowerCase()) ||
                  guild.description.toLowerCase().contains(query.toLowerCase());
            }).toList();
      }

      log('GuildService: ギルド検索完了 - ${guilds.length}件');
      return guilds;
    } catch (e) {
      log('GuildService: ギルド検索エラー - $e');
      return [];
    }
  }

  /// ギルドランキングの取得
  Future<List<GuildRanking>> getGuildRanking({
    RankingType type = RankingType.experience,
    int limit = 50,
  }) async {
    try {
      log('GuildService: ランキング取得開始');

      String orderField;
      switch (type) {
        case RankingType.experience:
          orderField = 'experience';
          break;
        case RankingType.memberCount:
          orderField = 'memberCount';
          break;
        case RankingType.challengesCompleted:
          orderField = 'totalChallengesCompleted';
          break;
      }

      final snapshot =
          await _firestore
              .collection('guilds')
              .where('isPublic', isEqualTo: true)
              .orderBy(orderField, descending: true)
              .limit(limit)
              .get();

      final rankings =
          snapshot.docs.asMap().entries.map((entry) {
            final index = entry.key;
            final doc = entry.value;
            final guild = Guild.fromMap(doc.data());

            return GuildRanking(
              rank: index + 1,
              guild: guild,
              score: _getScoreByType(guild, type),
            );
          }).toList();

      log('GuildService: ランキング取得完了');
      return rankings;
    } catch (e) {
      log('GuildService: ランキング取得エラー - $e');
      return [];
    }
  }

  // ========== プライベートメソッド ==========

  Future<void> _loadUserGuild(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final guildId = userData['guildId'] as String?;

        if (guildId != null) {
          await _subscribeToGuild(guildId);
        }
      }
    } catch (e) {
      log('GuildService: ユーザーギルド読み込みエラー - $e');
    }
  }

  Future<void> _subscribeToGuild(String guildId) async {
    _currentGuildSubscription?.cancel();
    _messagesSubscription?.cancel();

    // ギルド情報を監視
    _currentGuildSubscription = _firestore
        .collection('guilds')
        .doc(guildId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final guild = Guild.fromMap(snapshot.data()!);
            _currentGuild.value = guild;
            _loadActiveChallenges(guildId);
          } else {
            _currentGuild.value = null;
          }
        });

    // メッセージを監視
    _messagesSubscription = _firestore
        .collection('guild_messages')
        .where('guildId', isEqualTo: guildId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) {
          final messages =
              snapshot.docs
                  .map((doc) => GuildMessage.fromMap(doc.data()))
                  .toList();
          _guildMessages.value = messages;
        });
  }

  Future<void> _loadActiveChallenges(String guildId) async {
    try {
      final snapshot =
          await _firestore
              .collection('guild_challenges')
              .where('guildId', isEqualTo: guildId)
              .where('status', isEqualTo: 'active')
              .orderBy('createdAt', descending: true)
              .get();

      final challenges =
          snapshot.docs
              .map((doc) => GuildChallenge.fromMap(doc.data()))
              .toList();

      _activeChallenges.value = challenges;
    } catch (e) {
      log('GuildService: アクティブチャレンジ読み込みエラー - $e');
    }
  }

  void _onAvailableGuildsChanged(QuerySnapshot snapshot) {
    try {
      final guilds =
          snapshot.docs
              .map((doc) => Guild.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

      _availableGuilds.value = guilds;

      log('GuildService: 利用可能ギルド更新 - ${guilds.length}件');
    } catch (e) {
      log('GuildService: 利用可能ギルド更新エラー - $e');
    }
  }

  Future<void> _updateUserGuildInfo(
    String userId,
    String? guildId,
    GuildRole? role,
  ) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      if (guildId != null && role != null) {
        await userDoc.update({
          'guildId': guildId,
          'guildRole': role.name,
          'guildJoinedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userDoc.update({
          'guildId': FieldValue.delete(),
          'guildRole': FieldValue.delete(),
          'guildJoinedAt': FieldValue.delete(),
        });
      }
    } catch (e) {
      log('GuildService: ユーザーギルド情報更新エラー - $e');
    }
  }

  Future<void> _updateChallengeProgress(
    String challengeId,
    String userId,
  ) async {
    try {
      final challengeDoc = _firestore
          .collection('guild_challenges')
          .doc(challengeId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(challengeDoc);

        if (!snapshot.exists) return;

        final challenge = GuildChallenge.fromMap(snapshot.data()!);

        // ユーザーの完了数を計算
        final userCompletions =
            await _firestore
                .collection('challenge_completions')
                .where('challengeId', isEqualTo: challengeId)
                .where('userId', isEqualTo: userId)
                .get();

        final userCompletionCount = userCompletions.docs.length;

        // 全体の進捗を更新
        final totalCompletions =
            await _firestore
                .collection('challenge_completions')
                .where('challengeId', isEqualTo: challengeId)
                .get();

        final updatedCompletedUserIds = <String>{...challenge.completedUserIds};

        // 目標達成したユーザーを追加
        if (userCompletionCount >= challenge.targetCount) {
          updatedCompletedUserIds.add(userId);
        }

        transaction.update(challengeDoc, {
          'currentCount': totalCompletions.docs.length,
          'completedUserIds': updatedCompletedUserIds.toList(),
        });

        // チャレンジ完了チェック
        if (updatedCompletedUserIds.length >= challenge.participantIds.length) {
          transaction.update(challengeDoc, {'status': 'completed'});
        }
      });
    } catch (e) {
      log('GuildService: チャレンジ進捗更新エラー - $e');
    }
  }

  int _getScoreByType(Guild guild, RankingType type) {
    switch (type) {
      case RankingType.experience:
        return guild.experience;
      case RankingType.memberCount:
        return guild.memberCount;
      case RankingType.challengesCompleted:
        return guild.totalChallengesCompleted;
    }
  }

  String _generateGuildId() {
    return 'guild_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  String _generateChallengeId() {
    return 'challenge_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  String _generateCompletionId() {
    return 'completion_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }
}

// ========== データクラス ==========

/// ギルド
class Guild {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? iconUrl;
  final String creatorId;
  final List<String> adminIds;
  final List<String> memberIds;
  final int memberCount;
  final int maxMembers;
  final bool isPublic;
  final int level;
  final int experience;
  final int totalChallengesCompleted;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final GuildRules rules;
  final GuildStats stats;

  Guild({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.iconUrl,
    required this.creatorId,
    required this.adminIds,
    required this.memberIds,
    required this.memberCount,
    required this.maxMembers,
    required this.isPublic,
    required this.level,
    required this.experience,
    required this.totalChallengesCompleted,
    required this.createdAt,
    required this.lastActivityAt,
    required this.rules,
    required this.stats,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'iconUrl': iconUrl,
      'creatorId': creatorId,
      'adminIds': adminIds,
      'memberIds': memberIds,
      'memberCount': memberCount,
      'maxMembers': maxMembers,
      'isPublic': isPublic,
      'level': level,
      'experience': experience,
      'totalChallengesCompleted': totalChallengesCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastActivityAt': lastActivityAt.millisecondsSinceEpoch,
      'rules': rules.toMap(),
      'stats': stats.toMap(),
    };
  }

  factory Guild.fromMap(Map<String, dynamic> map) {
    return Guild(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      iconUrl: map['iconUrl'],
      creatorId: map['creatorId'] ?? '',
      adminIds: List<String>.from(map['adminIds'] ?? []),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      memberCount: map['memberCount'] ?? 0,
      maxMembers: map['maxMembers'] ?? 50,
      isPublic: map['isPublic'] ?? true,
      level: map['level'] ?? 1,
      experience: map['experience'] ?? 0,
      totalChallengesCompleted: map['totalChallengesCompleted'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastActivityAt: DateTime.fromMillisecondsSinceEpoch(
        map['lastActivityAt'] ?? 0,
      ),
      rules: GuildRules.fromMap(map['rules'] ?? {}),
      stats: GuildStats.fromMap(map['stats'] ?? {}),
    );
  }
}

/// ギルドルール
class GuildRules {
  final bool allowInvites;
  final bool requireApproval;
  final int minLevel;
  final List<String> bannedWords;
  final Map<String, dynamic> customRules;

  GuildRules({
    required this.allowInvites,
    required this.requireApproval,
    required this.minLevel,
    required this.bannedWords,
    required this.customRules,
  });

  factory GuildRules.defaultRules() {
    return GuildRules(
      allowInvites: true,
      requireApproval: false,
      minLevel: 1,
      bannedWords: [],
      customRules: {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allowInvites': allowInvites,
      'requireApproval': requireApproval,
      'minLevel': minLevel,
      'bannedWords': bannedWords,
      'customRules': customRules,
    };
  }

  factory GuildRules.fromMap(Map<String, dynamic> map) {
    return GuildRules(
      allowInvites: map['allowInvites'] ?? true,
      requireApproval: map['requireApproval'] ?? false,
      minLevel: map['minLevel'] ?? 1,
      bannedWords: List<String>.from(map['bannedWords'] ?? []),
      customRules: Map<String, dynamic>.from(map['customRules'] ?? {}),
    );
  }
}

/// ギルド統計
class GuildStats {
  final int totalMessages;
  final int totalChallenges;
  final int totalHabitsCompleted;
  final double averageCompletionRate;
  final Map<String, int> categoryStats;

  GuildStats({
    required this.totalMessages,
    required this.totalChallenges,
    required this.totalHabitsCompleted,
    required this.averageCompletionRate,
    required this.categoryStats,
  });

  factory GuildStats.empty() {
    return GuildStats(
      totalMessages: 0,
      totalChallenges: 0,
      totalHabitsCompleted: 0,
      averageCompletionRate: 0.0,
      categoryStats: {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMessages': totalMessages,
      'totalChallenges': totalChallenges,
      'totalHabitsCompleted': totalHabitsCompleted,
      'averageCompletionRate': averageCompletionRate,
      'categoryStats': categoryStats,
    };
  }

  factory GuildStats.fromMap(Map<String, dynamic> map) {
    return GuildStats(
      totalMessages: map['totalMessages'] ?? 0,
      totalChallenges: map['totalChallenges'] ?? 0,
      totalHabitsCompleted: map['totalHabitsCompleted'] ?? 0,
      averageCompletionRate: (map['averageCompletionRate'] ?? 0).toDouble(),
      categoryStats: Map<String, int>.from(map['categoryStats'] ?? {}),
    );
  }
}

/// ギルドメッセージ
class GuildMessage {
  final String id;
  final String guildId;
  final String senderId;
  final String content;
  final GuildMessageType type;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final Map<String, List<String>> reactions;

  GuildMessage({
    required this.id,
    required this.guildId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.metadata,
    required this.createdAt,
    required this.reactions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guildId': guildId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'metadata': metadata,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'reactions': reactions,
    };
  }

  factory GuildMessage.fromMap(Map<String, dynamic> map) {
    return GuildMessage(
      id: map['id'] ?? '',
      guildId: map['guildId'] ?? '',
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      type: GuildMessageType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => GuildMessageType.text,
      ),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      reactions: Map<String, List<String>>.from(
        (map['reactions'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value ?? [])),
        ),
      ),
    );
  }
}

/// ギルドチャレンジ
class GuildChallenge {
  final String id;
  final String guildId;
  final String creatorId;
  final String title;
  final String description;
  final String habitCategory;
  final int targetCount;
  final int currentCount;
  final List<String> participantIds;
  final List<String> completedUserIds;
  final Map<String, dynamic> rewards;
  final ChallengeStatus status;
  final DateTime createdAt;
  final DateTime startTime;
  final DateTime endTime;
  final List<ChallengeCompletion> completions;

  GuildChallenge({
    required this.id,
    required this.guildId,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.habitCategory,
    required this.targetCount,
    required this.currentCount,
    required this.participantIds,
    required this.completedUserIds,
    required this.rewards,
    required this.status,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.completions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guildId': guildId,
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'habitCategory': habitCategory,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'participantIds': participantIds,
      'completedUserIds': completedUserIds,
      'rewards': rewards,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'completions': completions.map((c) => c.toMap()).toList(),
    };
  }

  factory GuildChallenge.fromMap(Map<String, dynamic> map) {
    return GuildChallenge(
      id: map['id'] ?? '',
      guildId: map['guildId'] ?? '',
      creatorId: map['creatorId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      habitCategory: map['habitCategory'] ?? '',
      targetCount: map['targetCount'] ?? 0,
      currentCount: map['currentCount'] ?? 0,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      completedUserIds: List<String>.from(map['completedUserIds'] ?? []),
      rewards: Map<String, dynamic>.from(map['rewards'] ?? {}),
      status: ChallengeStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => ChallengeStatus.active,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] ?? 0),
      completions:
          (map['completions'] as List<dynamic>?)
              ?.map((c) => ChallengeCompletion.fromMap(c))
              .toList() ??
          [],
    );
  }
}

/// チャレンジ完了記録
class ChallengeCompletion {
  final String id;
  final String challengeId;
  final String userId;
  final String habitId;
  final DateTime completedAt;
  final Map<String, dynamic> metadata;

  ChallengeCompletion({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.habitId,
    required this.completedAt,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'challengeId': challengeId,
      'userId': userId,
      'habitId': habitId,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  factory ChallengeCompletion.fromMap(Map<String, dynamic> map) {
    return ChallengeCompletion(
      id: map['id'] ?? '',
      challengeId: map['challengeId'] ?? '',
      userId: map['userId'] ?? '',
      habitId: map['habitId'] ?? '',
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt'] ?? 0),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

/// ギルドランキング
class GuildRanking {
  final int rank;
  final Guild guild;
  final int score;

  GuildRanking({required this.rank, required this.guild, required this.score});
}

/// 列挙型
enum GuildRole { member, admin, creator }

enum GuildMessageType { text, system, achievement, challenge }

enum ChallengeStatus { active, completed, cancelled }

enum RankingType { experience, memberCount, challengesCompleted }
