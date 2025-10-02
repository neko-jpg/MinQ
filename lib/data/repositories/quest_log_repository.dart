import 'package:collection/collection.dart';
import 'package:isar/isar.dart';
import 'package:minq/domain/log/quest_log.dart';

class QuestLogRepository {
  final Isar _isar;

  QuestLogRepository(this._isar);

  Future<void> addLog(QuestLog log) async {
    await _isar.writeTxn(() async {
      await _isar.questLogs.put(log);
    });
  }

  Future<List<QuestLog>> getLogsForUser(String uid) async {
    return _isar.questLogs.filter().uidEqualTo(uid).sortByTsDesc().findAll();
  }

  Future<int> countLogsForDay(String uid, DateTime day) async {
    final dayStart = DateTime(day.year, day.month, day.day);
    final nextDay = dayStart.add(const Duration(days: 1));
    return _isar.questLogs
        .filter()
        .uidEqualTo(uid)
        .tsBetween(dayStart, nextDay, includeLower: true, includeUpper: false)
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

    final uniqueDays =
        logs
            .map((log) => DateTime.utc(log.ts.year, log.ts.month, log.ts.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now().toUtc();
    final currentDate = DateTime.utc(today.year, today.month, today.day);

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

  Future<int> calculateLongestStreak(String uid) async {
    final logs = await getLogsForUser(uid);
    if (logs.isEmpty) {
      return 0;
    }

    final days = logs
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
}


