import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class OperationsSnapshot {
  const OperationsSnapshot({
    required this.totalSessions,
    required this.crashedSessions,
    required this.lastSessionStartedAt,
    required this.lastCrashAt,
  });

  final int totalSessions;
  final int crashedSessions;
  final DateTime? lastSessionStartedAt;
  final DateTime? lastCrashAt;

  double get crashFreeRate {
    if (totalSessions <= 0) {
      return 1.0;
    }
    final int safeSessions = totalSessions - crashedSessions;
    if (safeSessions <= 0) {
      return 0;
    }
    return safeSessions / totalSessions;
  }

  bool meetsCrashFreeTarget(double target) => crashFreeRate >= target;
}

class OperationsMetricsService {
  OperationsMetricsService(this._prefs);

  static const String _totalSessionsKey = 'operations_total_sessions_v1';
  static const String _crashedSessionsKey = 'operations_crashed_sessions_v1';
  static const String _sessionStartedAtKey = 'operations_session_started_at_v1';
  static const String _lastCrashAtKey = 'operations_last_crash_at_v1';
  static const String _crashRecordedKey = 'operations_crash_recorded_v1';

  final SharedPreferences _prefs;

  Future<void> recordSessionStart(DateTime now) async {
    final int total = _prefs.getInt(_totalSessionsKey) ?? 0;
    await _prefs.setInt(_totalSessionsKey, total + 1);
    await _prefs.setInt(
      _sessionStartedAtKey,
      now.toUtc().millisecondsSinceEpoch,
    );
    await _prefs.setBool(_crashRecordedKey, false);
  }

  Future<void> recordCrash(DateTime now) async {
    final bool alreadyRecorded = _prefs.getBool(_crashRecordedKey) ?? false;
    if (alreadyRecorded) {
      return;
    }
    final int crashed = _prefs.getInt(_crashedSessionsKey) ?? 0;
    await _prefs.setInt(_crashedSessionsKey, crashed + 1);
    await _prefs.setInt(_lastCrashAtKey, now.toUtc().millisecondsSinceEpoch);
    await _prefs.setBool(_crashRecordedKey, true);
  }

  Future<OperationsSnapshot> loadSnapshot() async {
    final int total = _prefs.getInt(_totalSessionsKey) ?? 0;
    final int crashed = _prefs.getInt(_crashedSessionsKey) ?? 0;
    final int startedAtMillis = _prefs.getInt(_sessionStartedAtKey) ?? 0;
    final int crashAtMillis = _prefs.getInt(_lastCrashAtKey) ?? 0;
    final DateTime? startedAt =
        startedAtMillis <= 0
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
              startedAtMillis,
              isUtc: true,
            ).toLocal();
    final DateTime? crashAt =
        crashAtMillis <= 0
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
              crashAtMillis,
              isUtc: true,
            ).toLocal();
    return OperationsSnapshot(
      totalSessions: total,
      crashedSessions: crashed,
      lastSessionStartedAt: startedAt,
      lastCrashAt: crashAt,
    );
  }

  Future<void> reset() async {
    await _prefs.remove(_totalSessionsKey);
    await _prefs.remove(_crashedSessionsKey);
    await _prefs.remove(_sessionStartedAtKey);
    await _prefs.remove(_lastCrashAtKey);
    await _prefs.remove(_crashRecordedKey);
  }
}
