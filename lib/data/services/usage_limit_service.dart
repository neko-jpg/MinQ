import 'package:minq/data/services/local_preferences_service.dart';

class UsageLimitSnapshot {
  const UsageLimitSnapshot({
    required this.dailyLimit,
    required this.usedToday,
    required this.lastReset,
  });

  final Duration? dailyLimit;
  final Duration usedToday;
  final DateTime lastReset;

  bool get isBlocked =>
      dailyLimit != null && usedToday >= dailyLimit!;

  Duration get remaining {
    if (dailyLimit == null) {
      return Duration.zero;
    }
    final diff = dailyLimit! - usedToday;
    return diff.isNegative ? Duration.zero : diff;
  }

  UsageLimitSnapshot copyWith({
    Object? dailyLimit = _sentinel,
    Duration? usedToday,
    DateTime? lastReset,
  }) {
    return UsageLimitSnapshot(
      dailyLimit:
          dailyLimit == _sentinel ? this.dailyLimit : dailyLimit as Duration?,
      usedToday: usedToday ?? this.usedToday,
      lastReset: lastReset ?? this.lastReset,
    );
  }
}

const Object _sentinel = Object();

class UsageLimitService {
  UsageLimitService(this._preferences, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final LocalPreferencesService _preferences;
  final DateTime Function() _now;

  Future<UsageLimitSnapshot> loadSnapshot() async {
    final now = _now();
    final lastReset = await _preferences.getUsageLastReset();
    final limitMinutes = await _preferences.getUsageLimitMinutes();
    var usedSeconds = await _preferences.getUsageUsedSeconds();

    DateTime effectiveReset = lastReset ?? now;
    if (!_isSameDay(effectiveReset, now)) {
      effectiveReset = DateTime(now.year, now.month, now.day);
      usedSeconds = 0;
      await _preferences.setUsageLastReset(effectiveReset);
      await _preferences.setUsageUsedSeconds(0);
    }

    final dailyLimit =
        limitMinutes != null ? Duration(minutes: limitMinutes) : null;

    return UsageLimitSnapshot(
      dailyLimit: dailyLimit,
      usedToday: Duration(seconds: usedSeconds),
      lastReset: effectiveReset,
    );
  }

  Future<UsageLimitSnapshot> setDailyLimit(Duration? limit) async {
    await _preferences.setUsageLimitMinutes(limit?.inMinutes);
    if (limit == null) {
      await _preferences.setUsageUsedSeconds(0);
    }
    return loadSnapshot();
  }

  Future<UsageLimitSnapshot> recordUsage(Duration sessionDuration) async {
    final sanitized =
        sessionDuration.isNegative ? Duration.zero : sessionDuration;
    final snapshot = await loadSnapshot();
    if (sanitized == Duration.zero) {
      return snapshot;
    }
    final updatedUsed = snapshot.usedToday + sanitized;
    await _preferences.setUsageUsedSeconds(updatedUsed.inSeconds);
    return snapshot.copyWith(usedToday: updatedUsed);
  }

  Future<UsageLimitSnapshot> refresh() => loadSnapshot();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
