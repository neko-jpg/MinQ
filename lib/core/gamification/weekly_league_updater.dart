import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/gamification/services/league_system.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/notification_service.dart';
import 'package:minq/domain/gamification/league.dart';

/// Service that handles weekly league updates, promotions, and relegations
class WeeklyLeagueUpdater {
  WeeklyLeagueUpdater(
    this._isar,
    this._leagueSystem,
    this._notificationService,
  );

  Timer? _weeklyTimer;
  bool _isProcessing = false;
  final List<WeeklyUpdateRecord> _historyRecords = <WeeklyUpdateRecord>[];

  final Isar _isar;
  final LeagueSystem _leagueSystem;
  final NotificationService _notificationService;

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
          await _notificationService.sendNotificationToUser(
            userId: promotion.userId,
            title: 'リーグ昇格おめでとうございます！',
            body:
                '${fromLeague.nameEn}から${toLeague.nameEn}へ昇格しました。XP ${promotion.xpEarned} を獲得！',
            data: const {
              'type': 'system',
              'route': '/league',
            },
          );
        }
      } catch (e) {
        logger.warning(
          'Failed to send promotion notification',
          error: e,
          stackTrace: StackTrace.current,
        );
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
          await _notificationService.sendNotificationToUser(
            userId: relegation.userId,
            title: 'リーグ順位に変動があります',
            body:
                '${fromLeague.nameEn}から${toLeague.nameEn}へ降格しました。今週の獲得XPは${relegation.weeklyXP}でした。',
            data: const {
              'type': 'system',
              'route': '/league',
            },
          );
        }
      } catch (e) {
        logger.warning(
          'Failed to send relegation notification',
          error: e,
          stackTrace: StackTrace.current,
        );
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
      promotionDetails:
          update.promotions
              .map(
                (p) => {
                  'userId': p.userId,
                  'fromLeague': p.fromLeague,
                  'toLeague': p.toLeague,
                  'xpEarned': p.xpEarned,
                },
              )
              .toList(),
      relegationDetails:
          update.relegations
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

// Providers
final weeklyLeagueUpdaterProvider = Provider<WeeklyLeagueUpdater>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: (isar) {
      final leagueSystem = ref.read(leagueSystemProvider);
      return WeeklyLeagueUpdater(isar, leagueSystem, notificationService);
    },
    loading: () => throw StateError('Isar instance is not yet initialised'),
    error: (error, _) => throw error,
  );
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
