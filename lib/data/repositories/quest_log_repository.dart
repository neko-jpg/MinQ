import 'package:collection/collection.dart';
import 'package:isar/isar.dart';
import 'package:meta/meta.dart';
import 'package:minq/domain/log/quest_log.dart';

class QuestLogRepository {
  final Isar _isar;

  QuestLogRepository(this._isar);

  /// Protected getter for subclasses to access Isar instance
  @protected
  Isar get isar => _isar;

  Future<void> addLog(QuestLog log) async {
    await _isar.writeTxn(() async {
      await _isar.questLogs.put(log);
    });
  }

  Future<void> deleteLog(int logId) async {
    await _isar.writeTxn(() async {
      await _isar.questLogs.delete(logId);
    });
  }

  Future<QuestLog?> getLogById(int logId) async {
    return _isar.questLogs.get(logId);
  }

  Future<QuestLog?> getLatestLogForQuest(String uid, int questId) async {
    return _isar.questLogs
        .filter()
        .uidEqualTo(uid)
        .questIdEqualTo(questId)
        .sortByTsDesc()
        .findFirst();
  }

  Future<List<QuestLog>> getLogsForDay(String uid, DateTime day) async {
    // Use local timezone for day boundaries to handle day transitions correctly
    final localDay = day.toLocal();
    final dayStart = DateTime(localDay.year, localDay.month, localDay.day);
    final nextDay = dayStart.add(const Duration(days: 1));

    return _isar.questLogs
        .filter()
        .uidEqualTo(uid)
        .tsBetween(
          dayStart.toUtc(),
          nextDay.toUtc(),
          includeLower: true,
          includeUpper: false,
        )
        .sortByTsDesc()
        .findAll();
  }

  Future<List<QuestLog>> getLogsForUser(String uid) async {
    return _isar.questLogs.filter().uidEqualTo(uid).sortByTsDesc().findAll();
  }

  Future<int> countLogsForDay(String uid, DateTime day) async {
    // Use local timezone for day boundaries to handle day transitions correctly
    final localDay = day.toLocal();
    final dayStart = DateTime(localDay.year, localDay.month, localDay.day);
    final nextDay = dayStart.add(const Duration(days: 1));

    return _isar.questLogs
        .filter()
        .uidEqualTo(uid)
        .tsBetween(
          dayStart.toUtc(),
          nextDay.toUtc(),
          includeLower: true,
          includeUpper: false,
        )
        .count();
  }

  Future<bool> hasCompletedDailyGoal(
    String uid, {
    DateTime? day,
    int targetCount = 3,
  }) async {
    final logs = await countLogsForDay(uid, day ?? DateTime.now().toUtc());
    return logs >= targetCount;
  }

  Future<void> markLogsAsSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    await _isar.writeTxn(() async {
      final logs = await _isar.questLogs.getAll(ids);
      for (final log in logs.whereType<QuestLog>()) {
        log.synced = true;
        await _isar.questLogs.put(log);
      }
    });
  }

  Future<bool> hasUnsyncedLogs(String uid) async {
    return _isar.questLogs
        .filter()
        .uidEqualTo(uid)
        .syncedEqualTo(false)
        .isNotEmpty();
  }

  Future<int> calculateStreak(String uid) async {
    final logs = await getLogsForUser(uid);
    if (logs.isEmpty) return 0;

    // Convert to local timezone for proper day calculation
    final uniqueDays =
        logs
            .map((log) {
              final localTime = log.ts.toLocal();
              return DateTime(localTime.year, localTime.month, localTime.day);
            })
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);

    // Check if the most recent log is from today or yesterday
    if (uniqueDays.first.isBefore(
      currentDate.subtract(const Duration(days: 1)),
    )) {
      return 0;
    }

    var streak = 0;
    for (var i = 0; i < uniqueDays.length; i++) {
      final day = uniqueDays[i];
      if (i == 0) {
        if (day == currentDate ||
            day == currentDate.subtract(const Duration(days: 1))) {
          streak = 1;
        } else {
          break;
        }
        continue;
      }

      final previousDay = uniqueDays[i - 1];
      if (previousDay.difference(day).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<double> calculateWeeklyCompletionRate(String uid) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get the start of the current week (Monday)
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    int completedDays = 0;
    int totalDays = 0;

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      totalDays++;

      // Don't count future days
      if (day.isAfter(today)) {
        totalDays--;
        continue;
      }

      final logsForDay = await countLogsForDay(uid, day);
      if (logsForDay > 0) {
        completedDays++;
      }
    }

    if (totalDays == 0) return 0.0;
    return completedDays / totalDays;
  }

  Future<int> calculateLongestStreak(String uid) async {
    final logs = await getLogsForUser(uid);
    if (logs.isEmpty) {
      return 0;
    }

    final days =
        logs
            .map((log) => DateTime.utc(log.ts.year, log.ts.month, log.ts.day))
            .toSet()
            .toList()
          ..sort();

    var longest = 0;
    var current = 0;
    DateTime? previous;

    for (final day in days) {
      if (previous == null) {
        current = 1;
      } else {
        final delta = day.difference(previous).inDays;
        if (delta == 0) {
          continue;
        }
        if (delta == 1) {
          current += 1;
        } else {
          current = 1;
        }
      }

      if (current > longest) {
        longest = current;
      }

      previous = day;
    }

    return longest;
  }

  Future<Map<DateTime, int>> getHeatmapData(String uid) async {
    final logs = await getLogsForUser(uid);
    final logsByDay = groupBy(
      logs,
      (QuestLog log) => DateTime.utc(log.ts.year, log.ts.month, log.ts.day),
    );

    return {
      for (final entry in logsByDay.entries) entry.key: entry.value.length,
    };
  }

  Future<List<QuestLog>> getQuestLogs(String uid) async {
    return getLogsForUser(uid);
  }
}
