import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/data/logging/minq_logger.dart';

/// Service for handling sync conflicts between local and server data
class ConflictResolutionService {
  ConflictResolutionService({required Isar isar}) : _isar = isar;

  final Isar _isar;

  /// Detect and resolve conflicts for a quest
  Future<ConflictResolution> resolveQuestConflict(
    LocalQuest localQuest,
    Map<String, dynamic> serverData,
  ) async {
    final serverUpdatedAt = DateTime.parse(serverData['updatedAt'] as String);
    
    // Check if there's a conflict
    if (localQuest.updatedAt.isAfter(serverUpdatedAt)) {
      // Local is newer - use local data
      return ConflictResolution(
        resolution: ConflictResolutionType.useLocal,
        resolvedData: _questToMap(localQuest),
        reason: 'Local data is newer',
      );
    } else if (localQuest.updatedAt.isBefore(serverUpdatedAt)) {
      // Server is newer - use server data
      return ConflictResolution(
        resolution: ConflictResolutionType.useServer,
        resolvedData: serverData,
        reason: 'Server data is newer',
      );
    } else {
      // Same timestamp - check for actual differences
      final localData = _questToMap(localQuest);
      final differences = _findDifferences(localData, serverData);
      
      if (differences.isEmpty) {
        // No actual differences
        return ConflictResolution(
          resolution: ConflictResolutionType.noConflict,
          resolvedData: serverData,
          reason: 'No actual differences found',
        );
      } else {
        // Attempt automatic merge
        final mergedData = _attemptAutoMerge(localData, serverData, differences);
        if (mergedData != null) {
          return ConflictResolution(
            resolution: ConflictResolutionType.autoMerged,
            resolvedData: mergedData,
            reason: 'Successfully auto-merged differences',
            differences: differences,
          );
        } else {
          // Requires manual resolution
          return ConflictResolution(
            resolution: ConflictResolutionType.requiresManualResolution,
            resolvedData: null,
            reason: 'Cannot auto-merge, requires manual resolution',
            differences: differences,
            localData: localData,
            serverData: serverData,
          );
        }
      }
    }
  }

  /// Detect and resolve conflicts for a user
  Future<ConflictResolution> resolveUserConflict(
    LocalUser localUser,
    Map<String, dynamic> serverData,
  ) async {
    final serverUpdatedAt = DateTime.parse(serverData['updatedAt'] as String);
    
    // Check if there's a conflict
    if (localUser.updatedAt.isAfter(serverUpdatedAt)) {
      return ConflictResolution(
        resolution: ConflictResolutionType.useLocal,
        resolvedData: _userToMap(localUser),
        reason: 'Local data is newer',
      );
    } else if (localUser.updatedAt.isBefore(serverUpdatedAt)) {
      return ConflictResolution(
        resolution: ConflictResolutionType.useServer,
        resolvedData: serverData,
        reason: 'Server data is newer',
      );
    } else {
      // Same timestamp - check for differences
      final localData = _userToMap(localUser);
      final differences = _findDifferences(localData, serverData);
      
      if (differences.isEmpty) {
        return ConflictResolution(
          resolution: ConflictResolutionType.noConflict,
          resolvedData: serverData,
          reason: 'No actual differences found',
        );
      } else {
        // For user data, prefer server for most fields except XP/level
        final mergedData = _mergeUserData(localData, serverData);
        return ConflictResolution(
          resolution: ConflictResolutionType.autoMerged,
          resolvedData: mergedData,
          reason: 'Auto-merged user data with XP preference to local',
          differences: differences,
        );
      }
    }
  }

  /// Apply conflict resolution to local data
  Future<void> applyResolution(
    String entityType,
    String entityId,
    ConflictResolution resolution,
  ) async {
    if (resolution.resolvedData == null) {
      // Mark as requiring manual resolution
      await _markForManualResolution(entityType, entityId, resolution);
      return;
    }

    switch (entityType) {
      case 'quest':
        await _applyQuestResolution(entityId, resolution);
        break;
      case 'user':
        await _applyUserResolution(entityId, resolution);
        break;
      case 'challenge':
        await _applyChallengeResolution(entityId, resolution);
        break;
      case 'questLog':
        await _applyQuestLogResolution(entityId, resolution);
        break;
    }

    MinqLogger.info('Conflict resolution applied', metadata: {
      'entityType': entityType,
      'entityId': entityId,
      'resolution': resolution.resolution.name,
      'reason': resolution.reason,
    });
  }

  /// Apply quest conflict resolution
  Future<void> _applyQuestResolution(
    String questId,
    ConflictResolution resolution,
  ) async {
    final quest = await _isar.localQuests
        .filter()
        .questIdEqualTo(questId)
        .findFirst();

    if (quest == null) return;

    final data = resolution.resolvedData!;
    
    await _isar.writeTxn(() async {
      quest.title = data['title'] as String;
      quest.category = data['category'] as String;
      quest.estimatedMinutes = data['estimatedMinutes'] as int;
      quest.difficulty = data['difficulty'] as String?;
      quest.location = data['location'] as String?;
      quest.iconKey = data['iconKey'] as String?;
      quest.isTemplate = data['isTemplate'] as bool;
      quest.status = QuestStatus.values.byName(data['status'] as String);
      quest.updatedAt = DateTime.parse(data['updatedAt'] as String);
      quest.xpReward = data['xpReward'] as int? ?? 10;
      quest.tags = List<String>.from(data['tags'] as List? ?? []);
      quest.priority = data['priority'] as int? ?? 0;
      quest.dueDate = data['dueDate'] != null 
          ? DateTime.parse(data['dueDate'] as String) 
          : null;
      
      // Clear conflict state
      quest.syncStatus = SyncStatus.synced;
      quest.needsSync = false;
      quest.conflictData = null;
      quest.serverUpdatedAt = null;
      
      await _isar.localQuests.put(quest);
    });
  }

  /// Apply user conflict resolution
  Future<void> _applyUserResolution(
    String uid,
    ConflictResolution resolution,
  ) async {
    final user = await _isar.localUsers
        .filter()
        .uidEqualTo(uid)
        .findFirst();

    if (user == null) return;

    final data = resolution.resolvedData!;
    
    await _isar.writeTxn(() async {
      user.displayName = data['displayName'] as String;
      user.handle = data['handle'] as String?;
      user.bio = data['bio'] as String;
      user.avatarSeed = data['avatarSeed'] as String;
      user.focusTags = List<String>.from(data['focusTags'] as List);
      user.notificationTimes = List<String>.from(data['notificationTimes'] as List);
      user.privacy = data['privacy'] as String;
      user.longestStreak = data['longestStreak'] as int;
      user.currentStreak = data['currentStreak'] as int;
      user.longestStreakReachedAt = data['longestStreakReachedAt'] != null
          ? DateTime.parse(data['longestStreakReachedAt'] as String)
          : null;
      user.pairId = data['pairId'] as String?;
      user.onboardingCompleted = data['onboardingCompleted'] as bool;
      user.onboardingLevel = data['onboardingLevel'] as int?;
      user.currentLevel = data['currentLevel'] as int;
      user.totalPoints = data['totalPoints'] as int;
      user.currentXP = data['currentXP'] as int? ?? 0;
      user.weeklyXP = data['weeklyXP'] as int? ?? 0;
      user.currentLeague = data['currentLeague'] as String? ?? 'bronze';
      user.updatedAt = DateTime.parse(data['updatedAt'] as String);
      
      // Clear conflict state
      user.syncStatus = SyncStatus.synced;
      user.needsSync = false;
      user.conflictData = null;
      user.serverUpdatedAt = null;
      
      await _isar.localUsers.put(user);
    });
  }

  /// Apply challenge conflict resolution
  Future<void> _applyChallengeResolution(
    String challengeId,
    ConflictResolution resolution,
  ) async {
    final challenge = await _isar.localChallenges
        .filter()
        .challengeIdEqualTo(challengeId)
        .findFirst();

    if (challenge == null) return;

    final data = resolution.resolvedData!;
    
    await _isar.writeTxn(() async {
      challenge.title = data['title'] as String;
      challenge.description = data['description'] as String;
      challenge.startDate = DateTime.parse(data['startDate'] as String);
      challenge.endDate = DateTime.parse(data['endDate'] as String);
      challenge.isActive = data['isActive'] as bool;
      challenge.progress = data['progress'] as int;
      challenge.targetValue = data['targetValue'] as int;
      challenge.xpReward = data['xpReward'] as int;
      challenge.participants = List<String>.from(data['participants'] as List);
      challenge.updatedAt = DateTime.parse(data['updatedAt'] as String);
      
      // Clear conflict state
      challenge.syncStatus = SyncStatus.synced;
      challenge.needsSync = false;
      challenge.conflictData = null;
      challenge.serverUpdatedAt = null;
      
      await _isar.localChallenges.put(challenge);
    });
  }

  /// Apply quest log conflict resolution
  Future<void> _applyQuestLogResolution(
    String logId,
    ConflictResolution resolution,
  ) async {
    final questLog = await _isar.localQuestLogs
        .filter()
        .logIdEqualTo(logId)
        .findFirst();

    if (questLog == null) return;

    final data = resolution.resolvedData!;
    
    await _isar.writeTxn(() async {
      questLog.uid = data['uid'] as String;
      questLog.questId = data['questId'] as String;
      questLog.timestamp = DateTime.parse(data['timestamp'] as String);
      questLog.proofType = ProofType.values.byName(data['proofType'] as String);
      questLog.proofValue = data['proofValue'] as String?;
      questLog.xpEarned = data['xpEarned'] as int;
      questLog.updatedAt = DateTime.parse(data['updatedAt'] as String);
      
      // Clear conflict state
      questLog.syncStatus = SyncStatus.synced;
      questLog.needsSync = false;
      questLog.conflictData = null;
      questLog.serverUpdatedAt = null;
      
      await _isar.localQuestLogs.put(questLog);
    });
  }

  /// Mark entity for manual resolution
  Future<void> _markForManualResolution(
    String entityType,
    String entityId,
    ConflictResolution resolution,
  ) async {
    final conflictData = jsonEncode({
      'localData': resolution.localData,
      'serverData': resolution.serverData,
      'differences': resolution.differences,
      'reason': resolution.reason,
    });

    switch (entityType) {
      case 'quest':
        final quest = await _isar.localQuests
            .filter()
            .questIdEqualTo(entityId)
            .findFirst();
        if (quest != null) {
          await _isar.writeTxn(() async {
            quest.syncStatus = SyncStatus.conflict;
            quest.conflictData = conflictData;
            await _isar.localQuests.put(quest);
          });
        }
        break;
      case 'user':
        final user = await _isar.localUsers
            .filter()
            .uidEqualTo(entityId)
            .findFirst();
        if (user != null) {
          await _isar.writeTxn(() async {
            user.syncStatus = SyncStatus.conflict;
            user.conflictData = conflictData;
            await _isar.localUsers.put(user);
          });
        }
        break;
    }
  }

  /// Find differences between local and server data
  List<String> _findDifferences(
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
  ) {
    final differences = <String>[];
    
    for (final key in localData.keys) {
      if (serverData.containsKey(key)) {
        final localValue = localData[key];
        final serverValue = serverData[key];
        
        if (localValue != serverValue) {
          differences.add(key);
        }
      }
    }
    
    return differences;
  }

  /// Attempt automatic merge of conflicting data
  Map<String, dynamic>? _attemptAutoMerge(
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
    List<String> differences,
  ) {
    // Only auto-merge if differences are in non-critical fields
    final autoMergeableFields = {
      'tags', 'priority', 'estimatedMinutes', 'difficulty', 'location'
    };
    
    final criticalDifferences = differences
        .where((field) => !autoMergeableFields.contains(field))
        .toList();
    
    if (criticalDifferences.isNotEmpty) {
      return null; // Cannot auto-merge critical differences
    }
    
    // Merge by preferring local changes for auto-mergeable fields
    final merged = Map<String, dynamic>.from(serverData);
    for (final field in differences) {
      if (autoMergeableFields.contains(field)) {
        merged[field] = localData[field];
      }
    }
    
    return merged;
  }

  /// Merge user data with special handling for XP/level fields
  Map<String, dynamic> _mergeUserData(
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
  ) {
    final merged = Map<String, dynamic>.from(serverData);
    
    // Prefer local values for XP and level-related fields
    final localPreferredFields = {
      'currentXP', 'totalPoints', 'weeklyXP', 'currentLevel', 'currentLeague'
    };
    
    for (final field in localPreferredFields) {
      if (localData.containsKey(field)) {
        merged[field] = localData[field];
      }
    }
    
    return merged;
  }

  /// Get entities with conflicts
  Future<List<ConflictEntity>> getConflictingEntities() async {
    final conflicts = <ConflictEntity>[];
    
    // Get conflicting quests
    final conflictingQuests = await _isar.localQuests
        .filter()
        .syncStatusEqualTo(SyncStatus.conflict)
        .findAll();
    
    for (final quest in conflictingQuests) {
      conflicts.add(ConflictEntity(
        entityType: 'quest',
        entityId: quest.questId,
        title: quest.title,
        conflictData: quest.conflictData,
      ));
    }
    
    // Get conflicting users
    final conflictingUsers = await _isar.localUsers
        .filter()
        .syncStatusEqualTo(SyncStatus.conflict)
        .findAll();
    
    for (final user in conflictingUsers) {
      conflicts.add(ConflictEntity(
        entityType: 'user',
        entityId: user.uid,
        title: user.displayName,
        conflictData: user.conflictData,
      ));
    }
    
    return conflicts;
  }

  // Helper methods for data conversion
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
}

class ConflictResolution {
  final ConflictResolutionType resolution;
  final Map<String, dynamic>? resolvedData;
  final String reason;
  final List<String>? differences;
  final Map<String, dynamic>? localData;
  final Map<String, dynamic>? serverData;

  const ConflictResolution({
    required this.resolution,
    required this.resolvedData,
    required this.reason,
    this.differences,
    this.localData,
    this.serverData,
  });
}

enum ConflictResolutionType {
  noConflict,
  useLocal,
  useServer,
  autoMerged,
  requiresManualResolution,
}

class ConflictEntity {
  final String entityType;
  final String entityId;
  final String title;
  final String? conflictData;

  const ConflictEntity({
    required this.entityType,
    required this.entityId,
    required this.title,
    this.conflictData,
  });
}