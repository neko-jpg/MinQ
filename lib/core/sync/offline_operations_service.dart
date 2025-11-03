import 'dart:convert';
import 'dart:math';

import 'package:isar/isar.dart';
import 'package:minq/core/sync/sync_queue_manager.dart' hide SyncStatus;
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:uuid/uuid.dart';

/// Service for handling offline operations on local data
class OfflineOperationsService {
  OfflineOperationsService({
    required Isar isar,
    required SyncQueueManager syncQueueManager,
  }) : _isar = isar,
       _syncQueueManager = syncQueueManager;

  final Isar _isar;
  final SyncQueueManager _syncQueueManager;
  final _uuid = const Uuid();

  // Quest Operations

  /// Create a quest offline
  Future<LocalQuest> createQuest({
    required String owner,
    required String title,
    required String category,
    int estimatedMinutes = 5,
    String? difficulty,
    String? location,
    String? iconKey,
    bool isTemplate = false,
    int xpReward = 10,
    List<String> tags = const [],
    int priority = 0,
    DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    final questId = _uuid.v4();

    final quest =
        LocalQuest()
          ..questId = questId
          ..owner = owner
          ..title = title
          ..category = category
          ..estimatedMinutes = estimatedMinutes
          ..difficulty = difficulty
          ..location = location
          ..iconKey = iconKey
          ..isTemplate = isTemplate
          ..status = QuestStatus.active
          ..createdAt = now
          ..updatedAt = now
          ..needsSync = true
          ..syncStatus = SyncStatus.pending
          ..xpReward = xpReward
          ..tags = tags
          ..priority = priority
          ..dueDate = dueDate;

    await _isar.writeTxn(() async {
      await _isar.localQuests.put(quest);
    });

    // Enqueue sync job
    await _syncQueueManager.enqueueSyncJob(
      SyncJob()
        ..entityType = 'quest'
        ..entityId = questId
        ..operation = 'create'
        ..data = jsonEncode(_questToMap(quest))
        ..createdAt = now
        ..priority = 1,
    );

    MinqLogger.info(
      'Quest created offline',
      metadata: {'questId': questId, 'title': title},
    );

    return quest;
  }

  /// Update a quest offline
  Future<LocalQuest> updateQuest(
    String questId, {
    String? title,
    String? category,
    int? estimatedMinutes,
    String? difficulty,
    String? location,
    String? iconKey,
    QuestStatus? status,
    int? xpReward,
    List<String>? tags,
    int? priority,
    DateTime? dueDate,
  }) async {
    final quest =
        await _isar.localQuests.filter().questIdEqualTo(questId).findFirst();

    if (quest == null) {
      throw Exception('Quest not found: $questId');
    }

    final now = DateTime.now();

    // Update fields
    if (title != null) quest.title = title;
    if (category != null) quest.category = category;
    if (estimatedMinutes != null) quest.estimatedMinutes = estimatedMinutes;
    if (difficulty != null) quest.difficulty = difficulty;
    if (location != null) quest.location = location;
    if (iconKey != null) quest.iconKey = iconKey;
    if (status != null) quest.status = status;
    if (xpReward != null) quest.xpReward = xpReward;
    if (tags != null) quest.tags = tags;
    if (priority != null) quest.priority = priority;
    if (dueDate != null) quest.dueDate = dueDate;

    quest.updatedAt = now;
    quest.needsSync = true;
    quest.syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.localQuests.put(quest);
    });

    // Enqueue sync job
    await _syncQueueManager.enqueueSyncJob(
      SyncJob()
        ..entityType = 'quest'
        ..entityId = questId
        ..operation = 'update'
        ..data = jsonEncode(_questToMap(quest))
        ..createdAt = now
        ..priority = 1,
    );

    MinqLogger.info('Quest updated offline', metadata: {'questId': questId});

    return quest;
  }

  /// Delete a quest offline
  Future<void> deleteQuest(String questId) async {
    final quest =
        await _isar.localQuests.filter().questIdEqualTo(questId).findFirst();

    if (quest == null) {
      throw Exception('Quest not found: $questId');
    }

    final now = DateTime.now();
    quest.deletedAt = now;
    quest.updatedAt = now;
    quest.needsSync = true;
    quest.syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.localQuests.put(quest);
    });

    // Enqueue sync job
    await _syncQueueManager.enqueueSyncJob(
      SyncJob()
        ..entityType = 'quest'
        ..entityId = questId
        ..operation = 'delete'
        ..data = jsonEncode({'questId': questId})
        ..createdAt = now
        ..priority = 1,
    );

    MinqLogger.info('Quest deleted offline', metadata: {'questId': questId});
  }

  // User Operations

  /// Update user profile offline
  Future<LocalUser> updateUserProfile(
    String uid, {
    String? displayName,
    String? handle,
    String? bio,
    String? avatarSeed,
    List<String>? focusTags,
    List<String>? notificationTimes,
    String? privacy,
  }) async {
    final user = await _isar.localUsers.filter().uidEqualTo(uid).findFirst();

    if (user == null) {
      throw Exception('User not found: $uid');
    }

    final now = DateTime.now();

    // Update fields
    if (displayName != null) user.displayName = displayName;
    if (handle != null) user.handle = handle;
    if (bio != null) user.bio = bio;
    if (avatarSeed != null) user.avatarSeed = avatarSeed;
    if (focusTags != null) user.focusTags = focusTags;
    if (notificationTimes != null) user.notificationTimes = notificationTimes;
    if (privacy != null) user.privacy = privacy;

    user.updatedAt = now;
    user.needsSync = true;
    user.syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.localUsers.put(user);
    });

    // Enqueue sync job
    await _syncQueueManager.enqueueSyncJob(
      SyncJob()
        ..entityType = 'user'
        ..entityId = uid
        ..operation = 'update'
        ..data = jsonEncode(_userToMap(user))
        ..createdAt = now
        ..priority = 2,
    ); // Higher priority for user updates

    MinqLogger.info('User profile updated offline', metadata: {'uid': uid});

    return user;
  }

  /// Update user XP and level offline
  Future<LocalUser> updateUserXP(
    String uid, {
    required int xpGained,
    String? reason,
  }) async {
    final user = await _isar.localUsers.filter().uidEqualTo(uid).findFirst();

    if (user == null) {
      throw Exception('User not found: $uid');
    }

    final now = DateTime.now();

    // Update XP
    user.currentXP += xpGained;
    user.totalPoints += xpGained;
    user.weeklyXP += xpGained;

    // Calculate new level
    final newLevel = _calculateLevel(user.totalPoints);
    if (newLevel > user.currentLevel) {
      user.currentLevel = newLevel;
    }

    user.updatedAt = now;
    user.needsSync = true;
    user.syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.localUsers.put(user);
    });

    // Enqueue sync job
    await _syncQueueManager.enqueueSyncJob(
      SyncJob()
        ..entityType = 'user'
        ..entityId = uid
        ..operation = 'update'
        ..data = jsonEncode(_userToMap(user))
        ..createdAt = now
        ..priority = 1,
    );

    MinqLogger.info(
      'User XP updated offline',
      metadata: {
        'uid': uid,
        'xpGained': xpGained,
        'newTotal': user.totalPoints,
        'newLevel': user.currentLevel,
        'reason': reason,
      },
    );

    return user;
  }

  // Quest Log Operations

  /// Complete a quest offline
  Future<LocalQuestLog> completeQuest({
    required String uid,
    required String questId,
    required ProofType proofType,
    String? proofValue,
    int xpEarned = 10,
  }) async {
    final now = DateTime.now();
    final logId = _uuid.v4();

    final questLog =
        LocalQuestLog()
          ..logId = logId
          ..uid = uid
          ..questId = questId
          ..timestamp = now
          ..proofType = proofType
          ..proofValue = proofValue
          ..xpEarned = xpEarned
          ..updatedAt = now
          ..needsSync = true
          ..syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.localQuestLogs.put(questLog);
    });

    // Update user XP
    await updateUserXP(uid, xpGained: xpEarned, reason: 'quest_completion');

    // Enqueue sync job
    await _syncQueueManager.enqueueSyncJob(
      SyncJob()
        ..entityType = 'questLog'
        ..entityId = logId
        ..operation = 'create'
        ..data = jsonEncode(_questLogToMap(questLog))
        ..createdAt = now
        ..priority = 1,
    );

    MinqLogger.info(
      'Quest completed offline',
      metadata: {'questId': questId, 'uid': uid, 'xpEarned': xpEarned},
    );

    return questLog;
  }

  // Challenge Operations

  /// Update challenge progress offline
  Future<LocalChallenge> updateChallengeProgress(
    String challengeId, {
    required int progressIncrement,
    String? uid,
  }) async {
    final challenge =
        await _isar.localChallenges
            .filter()
            .challengeIdEqualTo(challengeId)
            .findFirst();

    if (challenge == null) {
      throw Exception('Challenge not found: $challengeId');
    }

    final now = DateTime.now();

    challenge.progress += progressIncrement;
    challenge.updatedAt = now;
    challenge.needsSync = true;
    challenge.syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.localChallenges.put(challenge);
    });

    // Enqueue sync job
    await _syncQueueManager.enqueueSyncJob(
      SyncJob()
        ..entityType = 'challenge'
        ..entityId = challengeId
        ..operation = 'update'
        ..data = jsonEncode(_challengeToMap(challenge))
        ..createdAt = now
        ..priority = 1,
    );

    MinqLogger.info(
      'Challenge progress updated offline',
      metadata: {
        'challengeId': challengeId,
        'progressIncrement': progressIncrement,
        'newProgress': challenge.progress,
      },
    );

    return challenge;
  }

  // Helper methods

  Map<String, dynamic> _questToMap(LocalQuest quest) {
    return {
      'questId': quest.questId,
      'owner': quest.owner,
      'title': quest.title,
      'category': quest.category,
      'estimatedMinutes': quest.estimatedMinutes,
      'difficulty': quest.difficulty,
      'location': quest.location,
      'iconKey': quest.iconKey,
      'isTemplate': quest.isTemplate,
      'status': quest.status.name,
      'createdAt': quest.createdAt.toIso8601String(),
      'updatedAt': quest.updatedAt.toIso8601String(),
      'deletedAt': quest.deletedAt?.toIso8601String(),
      'xpReward': quest.xpReward,
      'tags': quest.tags,
      'priority': quest.priority,
      'dueDate': quest.dueDate?.toIso8601String(),
    };
  }

  Map<String, dynamic> _userToMap(LocalUser user) {
    return {
      'uid': user.uid,
      'displayName': user.displayName,
      'handle': user.handle,
      'bio': user.bio,
      'avatarSeed': user.avatarSeed,
      'focusTags': user.focusTags,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
      'notificationTimes': user.notificationTimes,
      'privacy': user.privacy,
      'longestStreak': user.longestStreak,
      'currentStreak': user.currentStreak,
      'longestStreakReachedAt': user.longestStreakReachedAt?.toIso8601String(),
      'pairId': user.pairId,
      'onboardingCompleted': user.onboardingCompleted,
      'onboardingLevel': user.onboardingLevel,
      'currentLevel': user.currentLevel,
      'totalPoints': user.totalPoints,
      'currentXP': user.currentXP,
      'weeklyXP': user.weeklyXP,
      'currentLeague': user.currentLeague,
    };
  }

  Map<String, dynamic> _challengeToMap(LocalChallenge challenge) {
    return {
      'challengeId': challenge.challengeId,
      'title': challenge.title,
      'description': challenge.description,
      'startDate': challenge.startDate.toIso8601String(),
      'endDate': challenge.endDate.toIso8601String(),
      'isActive': challenge.isActive,
      'progress': challenge.progress,
      'targetValue': challenge.targetValue,
      'xpReward': challenge.xpReward,
      'participants': challenge.participants,
      'updatedAt': challenge.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _questLogToMap(LocalQuestLog questLog) {
    return {
      'logId': questLog.logId,
      'uid': questLog.uid,
      'questId': questLog.questId,
      'timestamp': questLog.timestamp.toIso8601String(),
      'proofType': questLog.proofType.name,
      'proofValue': questLog.proofValue,
      'xpEarned': questLog.xpEarned,
      'updatedAt': questLog.updatedAt.toIso8601String(),
    };
  }

  int _calculateLevel(int totalXP) {
    // Simple level calculation: level = sqrt(totalXP / 100) + 1
    return sqrt(totalXP / 100).floor() + 1;
  }

  // Query methods

  /// Get all quests for a user
  Future<List<LocalQuest>> getUserQuests(String uid) async {
    return await _isar.localQuests
        .filter()
        .ownerEqualTo(uid)
        .and()
        .deletedAtIsNull()
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get active quests for a user
  Future<List<LocalQuest>> getActiveQuests(String uid) async {
    return await _isar.localQuests
        .filter()
        .ownerEqualTo(uid)
        .and()
        .statusEqualTo(QuestStatus.active)
        .and()
        .deletedAtIsNull()
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get quest logs for a user
  Future<List<LocalQuestLog>> getUserQuestLogs(String uid, {int? limit}) async {
    var query =
        _isar.localQuestLogs.filter().uidEqualTo(uid).sortByTimestampDesc();

    if (limit != null) {
      query = query.limit(limit);
    }

    return await query.findAll();
  }

  /// Get user by uid
  Future<LocalUser?> getUser(String uid) async {
    return await _isar.localUsers.filter().uidEqualTo(uid).findFirst();
  }

  /// Get active challenges
  Future<List<LocalChallenge>> getActiveChallenges() async {
    final now = DateTime.now();
    return await _isar.localChallenges
        .filter()
        .isActiveEqualTo(true)
        .and()
        .startDateLessThan(now)
        .and()
        .endDateGreaterThan(now)
        .sortByStartDateDesc()
        .findAll();
  }
}
