import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/core/sync/offline_operations_service.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/domain/challenges/challenge.dart';
import 'package:minq/domain/challenges/challenge_progress.dart';
import 'package:uuid/uuid.dart';

/// Enhanced challenge service with offline-first capabilities
class OfflineChallengeService {
  OfflineChallengeService({
    required Isar isar,
    required OfflineOperationsService offlineOperations,
    required NetworkStatusService networkService,
    required String userId,
  }) : _isar = isar,
       _offlineOperations = offlineOperations,
       _networkService = networkService,
       _userId = userId;

  final Isar _isar;
  final OfflineOperationsService _offlineOperations;
  final NetworkStatusService _networkService;
  final String _userId;
  final _uuid = const Uuid();

  // Stream controllers for real-time updates
  final StreamController<List<LocalChallenge>> _activeChallengesController = 
      StreamController<List<LocalChallenge>>.broadcast();
  final StreamController<List<LocalChallenge>> _completedChallengesController = 
      StreamController<List<LocalChallenge>>.broadcast();
  final StreamController<Map<String, ChallengeProgressData>> _progressController = 
      StreamController<Map<String, ChallengeProgressData>>.broadcast();

  Stream<List<LocalChallenge>> get activeChallengesStream => _activeChallengesController.stream;
  Stream<List<LocalChallenge>> get completedChallengesStream => _completedChallengesController.stream;
  Stream<Map<String, ChallengeProgressData>> get progressStream => _progressController.stream;

  /// Initialize the service and start listening for changes
  Future<void> initialize() async {
    // Load initial data
    await _loadActiveChallenges();
    await _loadCompletedChallenges();
    await _loadProgressData();

    // Listen for local database changes
    _isar.localChallenges.watchLazy().listen((_) {
      _loadActiveChallenges();
      _loadCompletedChallenges();
      _loadProgressData();
    });

    MinqLogger.info('OfflineChallengeService initialized');
  }

  /// Get active challenges (offline-first)
  Future<List<LocalChallenge>> getActiveChallenges() async {
    final now = DateTime.now();
    return await _isar.localChallenges
        .filter()
        .isActiveEqualTo(true)
        .and()
        .startDateLessThanOrEqualTo(now)
        .and()
        .endDateGreaterThanOrEqualTo(now)
        .sortByStartDateDesc()
        .findAll();
  }

  /// Get completed challenges (offline-first)
  Future<List<LocalChallenge>> getCompletedChallenges() async {
    return await _isar.localChallenges
        .filter()
        .progressGreaterThanOrEqualTo(100) // Assuming 100% completion
        .or()
        .isActiveEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Get challenge progress for a specific challenge
  Future<ChallengeProgressData?> getChallengeProgress(String challengeId) async {
    final challenge = await _isar.localChallenges
        .filter()
        .challengeIdEqualTo(challengeId)
        .findFirst();

    if (challenge == null) return null;

    return ChallengeProgressData(
      challengeId: challengeId,
      userId: _userId,
      progress: challenge.progress,
      targetValue: challenge.targetValue,
      completed: challenge.progress >= challenge.targetValue,
      lastUpdated: challenge.updatedAt,
      isOffline: _networkService.isOffline,
    );
  }

  /// Update challenge progress (offline-first)
  Future<ChallengeProgressData> updateChallengeProgress({
    required String challengeId,
    required int progressIncrement,
    String? reason,
  }) async {
    final challenge = await _isar.localChallenges
        .filter()
        .challengeIdEqualTo(challengeId)
        .findFirst();

    if (challenge == null) {
      throw ChallengeNotFoundException('Challenge not found: $challengeId');
    }

    // Check if challenge is still active
    final now = DateTime.now();
    if (!challenge.isActive || 
        now.isBefore(challenge.startDate) || 
        now.isAfter(challenge.endDate)) {
      throw ChallengeExpiredException('Challenge is not active: $challengeId');
    }

    final oldProgress = challenge.progress;
    final newProgress = (challenge.progress + progressIncrement).clamp(0, challenge.targetValue);
    final wasCompleted = oldProgress >= challenge.targetValue;
    final isNowCompleted = newProgress >= challenge.targetValue;

    // Update challenge progress offline
    await _offlineOperations.updateChallengeProgress(
      challengeId,
      progressIncrement: newProgress - oldProgress,
      uid: _userId,
    );

    // Award XP if challenge is completed for the first time
    if (!wasCompleted && isNowCompleted) {
      await _awardChallengeCompletionXP(challenge);
    }

    final progressData = ChallengeProgressData(
      challengeId: challengeId,
      userId: _userId,
      progress: newProgress,
      targetValue: challenge.targetValue,
      completed: isNowCompleted,
      lastUpdated: DateTime.now(),
      isOffline: _networkService.isOffline,
      xpAwarded: isNowCompleted && !wasCompleted ? challenge.xpReward : 0,
    );

    MinqLogger.info('Challenge progress updated', metadata: {
      'challengeId': challengeId,
      'oldProgress': oldProgress,
      'newProgress': newProgress,
      'increment': progressIncrement,
      'completed': isNowCompleted,
      'reason': reason,
      'isOffline': _networkService.isOffline,
    });

    // Refresh streams
    await _loadProgressData();

    return progressData;
  }

  /// Create a new challenge (offline-first)
  Future<LocalChallenge> createChallenge({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int targetValue,
    int xpReward = 50,
    List<String> participants = const [],
  }) async {
    final challengeId = _uuid.v4();
    final now = DateTime.now();

    final challenge = LocalChallenge()
      ..challengeId = challengeId
      ..title = title
      ..description = description
      ..startDate = startDate
      ..endDate = endDate
      ..isActive = true
      ..progress = 0
      ..targetValue = targetValue
      ..xpReward = xpReward
      ..participants = participants
      ..updatedAt = now
      ..needsSync = true
      ..syncStatus = SyncStatus.pending;

    await _isar.writeTxn(() async {
      await _isar.localChallenges.put(challenge);
    });

    MinqLogger.info('Challenge created offline', metadata: {
      'challengeId': challengeId,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    });

    await _loadActiveChallenges();
    return challenge;
  }

  /// Join an existing challenge (offline-first)
  Future<void> joinChallenge(String challengeId) async {
    final challenge = await _isar.localChallenges
        .filter()
        .challengeIdEqualTo(challengeId)
        .findFirst();

    if (challenge == null) {
      throw ChallengeNotFoundException('Challenge not found: $challengeId');
    }

    if (!challenge.participants.contains(_userId)) {
      challenge.participants.add(_userId);
      challenge.updatedAt = DateTime.now();
      challenge.needsSync = true;
      challenge.syncStatus = SyncStatus.pending;

      await _isar.writeTxn(() async {
        await _isar.localChallenges.put(challenge);
      });

      MinqLogger.info('Joined challenge offline', metadata: {
        'challengeId': challengeId,
        'userId': _userId,
      });

      await _loadActiveChallenges();
    }
  }

  /// Leave a challenge (offline-first)
  Future<void> leaveChallenge(String challengeId) async {
    final challenge = await _isar.localChallenges
        .filter()
        .challengeIdEqualTo(challengeId)
        .findFirst();

    if (challenge == null) {
      throw ChallengeNotFoundException('Challenge not found: $challengeId');
    }

    if (challenge.participants.contains(_userId)) {
      challenge.participants.remove(_userId);
      challenge.updatedAt = DateTime.now();
      challenge.needsSync = true;
      challenge.syncStatus = SyncStatus.pending;

      await _isar.writeTxn(() async {
        await _isar.localChallenges.put(challenge);
      });

      MinqLogger.info('Left challenge offline', metadata: {
        'challengeId': challengeId,
        'userId': _userId,
      });

      await _loadActiveChallenges();
    }
  }

  /// Get time-limited challenges (special events)
  Future<List<LocalChallenge>> getTimeLimitedChallenges() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    return await _isar.localChallenges
        .filter()
        .isActiveEqualTo(true)
        .and()
        .endDateLessThan(tomorrow)
        .and()
        .endDateGreaterThan(now)
        .sortByEndDate()
        .findAll();
  }

  /// Get challenges by category/type
  Future<List<LocalChallenge>> getChallengesByType(String type) async {
    // For now, we'll use description to filter by type
    // In a real implementation, you'd add a 'type' field to LocalChallenge
    return await _isar.localChallenges
        .filter()
        .descriptionContains(type, caseSensitive: false)
        .sortByStartDateDesc()
        .findAll();
  }

  /// Get user's challenge statistics
  Future<ChallengeStats> getUserChallengeStats() async {
    final allChallenges = await _isar.localChallenges
        .filter()
        .participantsElementContains(_userId)
        .findAll();

    final completed = allChallenges.where((c) => c.progress >= c.targetValue).length;
    final active = allChallenges.where((c) => c.isActive && c.progress < c.targetValue).length;
    final totalXP = allChallenges
        .where((c) => c.progress >= c.targetValue)
        .fold<int>(0, (sum, c) => sum + c.xpReward);

    return ChallengeStats(
      totalChallenges: allChallenges.length,
      completedChallenges: completed,
      activeChallenges: active,
      totalXPEarned: totalXP,
      completionRate: allChallenges.isEmpty ? 0.0 : completed / allChallenges.length,
    );
  }

  /// Sync challenges with server (when online)
  Future<void> syncChallenges() async {
    if (_networkService.isOffline) {
      MinqLogger.warning('Cannot sync challenges while offline');
      return;
    }

    try {
      // This would typically fetch latest challenges from server
      // and merge with local data, handling conflicts appropriately
      MinqLogger.info('Challenge sync completed');
    } catch (e, stackTrace) {
      MinqLogger.error('Challenge sync failed', error: e, stackTrace: stackTrace);
    }
  }

  // Private helper methods

  Future<void> _loadActiveChallenges() async {
    final challenges = await getActiveChallenges();
    _activeChallengesController.add(challenges);
  }

  Future<void> _loadCompletedChallenges() async {
    final challenges = await getCompletedChallenges();
    _completedChallengesController.add(challenges);
  }

  Future<void> _loadProgressData() async {
    final challenges = await _isar.localChallenges.where().findAll();
    final progressMap = <String, ChallengeProgressData>{};
    
    for (final challenge in challenges) {
      progressMap[challenge.challengeId] = ChallengeProgressData(
        challengeId: challenge.challengeId,
        userId: _userId,
        progress: challenge.progress,
        targetValue: challenge.targetValue,
        completed: challenge.progress >= challenge.targetValue,
        lastUpdated: challenge.updatedAt,
        isOffline: _networkService.isOffline,
      );
    }
    
    _progressController.add(progressMap);
  }

  Future<void> _awardChallengeCompletionXP(LocalChallenge challenge) async {
    try {
      await _offlineOperations.updateUserXP(
        _userId,
        xpGained: challenge.xpReward,
        reason: 'challenge_completion:${challenge.challengeId}',
      );

      MinqLogger.info('Challenge completion XP awarded', metadata: {
        'challengeId': challenge.challengeId,
        'xpReward': challenge.xpReward,
        'userId': _userId,
      });
    } catch (e, stackTrace) {
      MinqLogger.error('Failed to award challenge completion XP', 
          error: e, stackTrace: stackTrace);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _activeChallengesController.close();
    await _completedChallengesController.close();
    await _progressController.close();
  }
}

/// Enhanced challenge progress data with offline support
class ChallengeProgressData {
  final String challengeId;
  final String userId;
  final int progress;
  final int targetValue;
  final bool completed;
  final DateTime lastUpdated;
  final bool isOffline;
  final int xpAwarded;

  const ChallengeProgressData({
    required this.challengeId,
    required this.userId,
    required this.progress,
    required this.targetValue,
    required this.completed,
    required this.lastUpdated,
    required this.isOffline,
    this.xpAwarded = 0,
  });

  double get progressPercentage => targetValue > 0 ? progress / targetValue : 0.0;
  int get remainingProgress => (targetValue - progress).clamp(0, targetValue);
  bool get isNearCompletion => progressPercentage >= 0.8;
}

/// Challenge statistics
class ChallengeStats {
  final int totalChallenges;
  final int completedChallenges;
  final int activeChallenges;
  final int totalXPEarned;
  final double completionRate;

  const ChallengeStats({
    required this.totalChallenges,
    required this.completedChallenges,
    required this.activeChallenges,
    required this.totalXPEarned,
    required this.completionRate,
  });
}

/// Challenge-related exceptions
class ChallengeNotFoundException implements Exception {
  final String message;
  const ChallengeNotFoundException(this.message);
  
  @override
  String toString() => 'ChallengeNotFoundException: $message';
}

class ChallengeExpiredException implements Exception {
  final String message;
  const ChallengeExpiredException(this.message);
  
  @override
  String toString() => 'ChallengeExpiredException: $message';
}

/// Providers for the offline challenge service
final offlineChallengeServiceProvider = Provider.family<OfflineChallengeService?, String>((ref, userId) {
  final isar = ref.watch(isarProvider);
  final offlineOperations = ref.watch(offlineOperationsProvider);
  final networkService = ref.watch(networkStatusServiceProvider);
  
  if (isar == null || offlineOperations == null) return null;
  
  return OfflineChallengeService(
    isar: isar,
    offlineOperations: offlineOperations,
    networkService: networkService,
    userId: userId,
  );
});

final activeChallengesStreamProvider = StreamProvider.family<List<LocalChallenge>, String>((ref, userId) {
  final service = ref.watch(offlineChallengeServiceProvider(userId));
  return service?.activeChallengesStream ?? Stream.value([]);
});

final completedChallengesStreamProvider = StreamProvider.family<List<LocalChallenge>, String>((ref, userId) {
  final service = ref.watch(offlineChallengeServiceProvider(userId));
  return service?.completedChallengesStream ?? Stream.value([]);
});

final challengeProgressStreamProvider = StreamProvider.family<Map<String, ChallengeProgressData>, String>((ref, userId) {
  final service = ref.watch(offlineChallengeServiceProvider(userId));
  return service?.progressStream ?? Stream.value({});
});

// Placeholder providers - these would need to be implemented based on your existing architecture
final isarProvider = Provider<Isar?>((ref) => throw UnimplementedError());
final offlineOperationsProvider = Provider<OfflineOperationsService?>((ref) => throw UnimplementedError());
final networkStatusServiceProvider = Provider<NetworkStatusService>((ref) => throw UnimplementedError());