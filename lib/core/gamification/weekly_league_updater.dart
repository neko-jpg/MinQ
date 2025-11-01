import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/gamification/league_system.dart';
import 'package:minq/core/notifications/notification_channels.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/domain/gamification/league.dart';

/// Service that handles weekly league updates, promotions, and relegations
class WeeklyLeagueUpdater {
  final Isar _isar;
  final LeagueSystem _leagueSystem;
  final NotificationChannels _notificationService;
  final Ref _ref;

  Timer? _weeklyTimer;
  bool _isProcessing = false;
  final List<WeeklyUpdateRecord> _historyRecords = <WeeklyUpdateRecord>[];

  WeeklyLeagueUpdater(
    this._isar,
    this._leagueSystem,
    this._notificationService,
    this._ref,
  );

  /// Initialize the weekly update scheduler
  void initialize() {
    _scheduleWeeklyUpdate();
  }

  /// Dispose resources
  void dispose() {
    _weeklyTimer?.cancel();
  }

  /// Schedule the next weekly update (every Sunday at 23:59)
  void _scheduleWeeklyUpdate() {
    final now = DateTime.now();
    final nextSunday = _getNextSunday(now);
    final updateTime = DateTime(
      nextSunday.year,
      nextSunday.month,
      nextSunday.day,
      23,
      59,
    );

    final duration = updateTime.difference(now);

    _weeklyTimer?.cancel();
    _weeklyTimer = Timer(duration, () {
      _processWeeklyUpdate();
      _scheduleWeeklyUpdate(); // Schedule next week
    });
  }

  /// Get the next Sunday from the given date
  DateTime _getNextSunday(DateTime date) {
    final daysUntilSunday = (7 - date.weekday) % 7;
    return date.add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));
  }

  /// Process weekly league updates
  Future<WeeklyLeagueUpdate> _processWeeklyUpdate() async {
    if (_isProcessing) {
      throw Exception('Weekly update already in progress');
    }

    _isProcessing = true;

    try {
      // Process league updates
      final update = await _leagueSystem.processWeeklyUpdate();

      // Send notifications for promotions and relegations
      await _sendPromotionNotifications(update.promotions);
      await _sendRelegationNotifications(update.relegations);

      // Reset weekly XP for all users
      await _resetWeeklyXP();

      // Record the update
      await _recordWeeklyUpdate(update);

      return update;
    } finally {
      _isProcessing = false;
    }
  }

  /// Manually trigger weekly update (for testing or admin purposes)
  Future<WeeklyLeagueUpdate> triggerWeeklyUpdate() async {
    return await _processWeeklyUpdate();
  }

  /// Send promotion notifications to users
  Future<void> _sendPromotionNotifications(
    List<LeaguePromotion> promotions,
  ) async {
    for (final promotion in promotions) {
      try {
        final fromLeague = LeagueSystem.leagues[promotion.fromLeague];
        final toLeague = LeagueSystem.leagues[promotion.toLeague];

        if (fromLeague != null && toLeague != null) {
          await _notificationService.sendLeaguePromotionNotification(
            userId: promotion.userId,
            fromLeague: fromLeague.name,
            toLeague: toLeague.name,
            xpEarned: promotion.xpEarned,
          );
        }
      } catch (e) {
        // Log error but continue with other notifications
        print('Failed to send promotion notification: $e');
      }
    }
  }

  /// Send relegation notifications to users
  Future<void> _sendRelegationNotifications(
    List<LeagueRelegation> relegations,
  ) async {
    for (final relegation in relegations) {
      try {
        final fromLeague = LeagueSystem.leagues[relegation.fromLeague];
        final toLeague = LeagueSystem.leagues[relegation.toLeague];

        if (fromLeague != null && toLeague != null) {
          await _notificationService.sendLeagueRelegationNotification(
            userId: relegation.userId,
            fromLeague: fromLeague.name,
            toLeague: toLeague.name,
            weeklyXP: relegation.weeklyXP,
            threshold: relegation.threshold,
          );
        }
      } catch (e) {
        // Log error but continue with other notifications
        print('Failed to send relegation notification: $e');
      }
    }
  }

  /// Reset weekly XP for all users
  Future<void> _resetWeeklyXP() async {
    await _isar.writeTxn(() async {
      final allUsers = await _isar.collection<LocalUser>().where().findAll();

      for (final user in allUsers) {
        user.weeklyXP = 0;
        user.updatedAt = DateTime.now();
        user.needsSync = true;
      }

      await _isar.collection<LocalUser>().putAll(allUsers);
    });
  }

  /// Record weekly update in database
  Future<void> _recordWeeklyUpdate(WeeklyLeagueUpdate update) async {
    final record = WeeklyUpdateRecord(
      processedAt: update.processedAt,
      totalPromotions: update.totalPromotions,
      totalRelegations: update.totalRelegations,
      totalUsersProcessed: update.totalUsersProcessed,
      promotionDetails: update.promotions
          .map(
            (p) => {
              'userId': p.userId,
              'fromLeague': p.fromLeague,
              'toLeague': p.toLeague,
              'xpEarned': p.xpEarned,
            },
          )
          .toList(),
      relegationDetails: update.relegations
          .map(
            (r) => {
              'userId': r.userId,
              'fromLeague': r.fromLeague,
              'toLeague': r.toLeague,
              'weeklyXP': r.weeklyXP,
            },
          )
          .toList(),
    );

    _historyRecords.insert(0, record);
    if (_historyRecords.length > 50) {
      _historyRecords.removeRange(50, _historyRecords.length);
    }
  }

  /// Get weekly update history
  Future<List<WeeklyUpdateRecord>> getUpdateHistory({int limit = 10}) async {
    final effectiveLimit = limit.clamp(0, _historyRecords.length);
    return _historyRecords.take(effectiveLimit).toList(growable: false);
  }

  /// Get next update time
  DateTime getNextUpdateTime() {
    final now = DateTime.now();
    final nextSunday = _getNextSunday(now);
    return DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 23, 59);
  }

  /// Check if update is currently in progress
  bool get isProcessing => _isProcessing;

  /// Get time until next update
  Duration getTimeUntilNextUpdate() {
    final nextUpdate = getNextUpdateTime();
    return nextUpdate.difference(DateTime.now());
  }
}

/// Simple record of weekly league updates kept in memory.
class WeeklyUpdateRecord {
  WeeklyUpdateRecord({
    required this.processedAt,
    required this.totalPromotions,
    required this.totalRelegations,
    required this.totalUsersProcessed,
    required this.promotionDetails,
    required this.relegationDetails,
  });

  final DateTime processedAt;
  final int totalPromotions;
  final int totalRelegations;
  final int totalUsersProcessed;
  final List<Map<String, dynamic>> promotionDetails;
  final List<Map<String, dynamic>> relegationDetails;
}

/// Extension for notification service to handle league notifications
extension LeagueNotifications on NotificationChannels {
  Future<void> sendLeaguePromotionNotification({
    required String userId,
    required String fromLeague,
    required String toLeague,
    required int xpEarned,
  }) async {
    // Implementation would depend on your notification system
    // This is a placeholder for the actual notification sending logic
    print(
      'Sending promotion notification: $userId promoted from $fromLeague to $toLeague',
    );
  }

  Future<void> sendLeagueRelegationNotification({
    required String userId,
    required String fromLeague,
    required String toLeague,
    required int weeklyXP,
    required int threshold,
  }) async {
    // Implementation would depend on your notification system
    // This is a placeholder for the actual notification sending logic
    print(
      'Sending relegation notification: $userId relegated from $fromLeague to $toLeague',
    );
  }
}

// Providers
final weeklyLeagueUpdaterProvider = Provider<WeeklyLeagueUpdater>((ref) {
  // This would need to be implemented with proper dependencies
  throw UnimplementedError('WeeklyLeagueUpdater provider needs proper setup');
});

final weeklyUpdateHistoryProvider = FutureProvider<List<WeeklyUpdateRecord>>((
  ref,
) {
  final updater = ref.watch(weeklyLeagueUpdaterProvider);
  return updater.getUpdateHistory();
});

final nextUpdateTimeProvider = Provider<DateTime>((ref) {
  final updater = ref.watch(weeklyLeagueUpdaterProvider);
  return updater.getNextUpdateTime();
});

final timeUntilNextUpdateProvider = Provider<Duration>((ref) {
  final updater = ref.watch(weeklyLeagueUpdaterProvider);
  return updater.getTimeUntilNextUpdate();
});
