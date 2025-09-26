import 'package:shared_preferences/shared_preferences.dart';

typedef NowProvider = DateTime Function();

/// Stores lightweight privacy/safety related flags locally.
class LocalPreferencesService {
  LocalPreferencesService({NowProvider? now})
      : _prefsFuture = SharedPreferences.getInstance(),
        _now = now ?? DateTime.now;

  static const String _pairGuidelinesKey = 'pair_guidelines_seen_v1';
  static const String _reportHistoryKey = 'report_history_v1';

  final Future<SharedPreferences> _prefsFuture;
  final NowProvider _now;

  Future<bool> hasSeenPairGuidelines() async {
    final prefs = await _prefsFuture;
    return prefs.getBool(_pairGuidelinesKey) ?? false;
  }

  Future<void> markPairGuidelinesSeen() async {
    final prefs = await _prefsFuture;
    await prefs.setBool(_pairGuidelinesKey, true);
  }

  /// Records a report submission and enforces a rate limit.
  ///
  /// Returns the required wait time if the action is rate limited.
  Future<Duration?> registerReportAttempt({
    int maxReports = 3,
    Duration window = const Duration(minutes: 10),
    DateTime? now,
  }) async {
    final prefs = await _prefsFuture;
    final currentTime = (now ?? _now()).toUtc();
    final cutoff = currentTime.subtract(window);

    final stored = prefs.getStringList(_reportHistoryKey) ?? <String>[];
    final timestamps = stored
        .map((String value) => DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(value) ?? 0,
              isUtc: true,
            ))
        .where((DateTime timestamp) => timestamp.isAfter(cutoff))
        .toList()
      ..sort();

    if (timestamps.length >= maxReports) {
      final earliest = timestamps.first;
      final retryAfter = window - currentTime.difference(earliest);
      await prefs.setStringList(
        _reportHistoryKey,
        timestamps
            .map((DateTime ts) => ts.millisecondsSinceEpoch.toString())
            .toList(),
      );
      return retryAfter.isNegative ? Duration.zero : retryAfter;
    }

    timestamps.add(currentTime);
    await prefs.setStringList(
      _reportHistoryKey,
      timestamps
          .map((DateTime ts) => ts.millisecondsSinceEpoch.toString())
          .toList(),
    );
    return null;
  }

  Future<void> clearReportHistory() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_reportHistoryKey);
  }
}
