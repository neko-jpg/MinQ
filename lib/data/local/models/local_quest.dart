import 'package:isar/isar.dart';

part 'local_quest.g.dart';

@Collection()
class LocalQuest {
  Id id = Isar.autoIncrement;

  // Original quest data
  late String questId;
  late String owner;
  late String title;
  late String category;
  int estimatedMinutes = 5;
  String? difficulty;
  String? location;
  String? iconKey;
  bool isTemplate = false;
  @Enumerated(EnumType.name)
  late QuestStatus status;
  late DateTime createdAt;
  DateTime? deletedAt;

  // Sync metadata
  late DateTime updatedAt;
  bool needsSync = false;
  @Enumerated(EnumType.name)
  SyncStatus syncStatus = SyncStatus.synced;
  int syncRetryCount = 0;
  DateTime? lastSyncAttempt;
  String? syncError;

  // Offline-specific fields
  int xpReward = 10;
  List<String> tags = [];
  int priority = 0;
  DateTime? dueDate;

  // Conflict resolution
  String? conflictData; // JSON string of conflicting server data
  DateTime? serverUpdatedAt;
}

@Collection()
class LocalUser {
  Id id = Isar.autoIncrement;

  // Original user data
  @Index(unique: true, replace: true)
  late String uid;
  @Index(caseSensitive: false)
  String displayName = '';
  @Index(unique: true, replace: true, caseSensitive: false)
  String? handle;
  String bio = '';
  String avatarSeed = 'seed-01';
  List<String> focusTags = <String>[];
  late DateTime createdAt;
  List<String> notificationTimes = [];
  String privacy = 'private';
  int longestStreak = 0;
  int currentStreak = 0;
  DateTime? longestStreakReachedAt;
  String? pairId;
  bool onboardingCompleted = false;
  int? onboardingLevel;
  int currentLevel = 1;
  int totalPoints = 0;

  // Sync metadata
  late DateTime updatedAt;
  bool needsSync = false;
  @Enumerated(EnumType.name)
  SyncStatus syncStatus = SyncStatus.synced;
  int syncRetryCount = 0;
  DateTime? lastSyncAttempt;
  String? syncError;

  // Offline-specific fields
  int currentXP = 0;
  int weeklyXP = 0;
  int totalXP = 0;
  String currentLeague = 'bronze';
  DateTime? lastActiveDate;

  // Conflict resolution
  String? conflictData;
  DateTime? serverUpdatedAt;
}

@Collection()
class LocalChallenge {
  Id id = Isar.autoIncrement;

  // Challenge data
  late String challengeId;
  late String title;
  late String description;
  late DateTime startDate;
  late DateTime endDate;
  bool isActive = true;
  int progress = 0;
  int targetValue = 100;
  int xpReward = 50;
  List<String> participants = [];

  // Sync metadata
  late DateTime updatedAt;
  bool needsSync = false;
  @Enumerated(EnumType.name)
  SyncStatus syncStatus = SyncStatus.synced;
  int syncRetryCount = 0;
  DateTime? lastSyncAttempt;
  String? syncError;

  // Conflict resolution
  String? conflictData;
  DateTime? serverUpdatedAt;
}

@Collection()
class LocalQuestLog {
  Id id = Isar.autoIncrement;

  // Log data
  late String logId;
  late String uid;
  late String questId;
  late DateTime timestamp;
  @Enumerated(EnumType.name)
  late ProofType proofType;
  String? proofValue;
  int xpEarned = 0;

  // Sync metadata
  late DateTime updatedAt;
  bool needsSync = false;
  @Enumerated(EnumType.name)
  SyncStatus syncStatus = SyncStatus.synced;
  int syncRetryCount = 0;
  DateTime? lastSyncAttempt;
  String? syncError;

  // Conflict resolution
  String? conflictData;
  DateTime? serverUpdatedAt;
}

enum QuestStatus { active, paused }

enum ProofType { photo, check }

enum SyncStatus {
  synced, // Successfully synced with server
  pending, // Waiting to be synced
  syncing, // Currently being synced
  failed, // Sync failed
  conflict, // Conflict detected, needs resolution
}
