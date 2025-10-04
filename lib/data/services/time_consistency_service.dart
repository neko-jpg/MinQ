import 'dart:async';
import 'dart:io';

/// Provides utilities to compare the device clock with a trusted network
/// source so that time-sensitive features (streaks, reminders) can detect
/// tampering or large drifts.
typedef _ServerTimeProvider = Future<DateTime?> Function();

class TimeConsistencyService {
  TimeConsistencyService({
    HttpClient? httpClient,
    Duration tolerance = const Duration(minutes: 3),
    Uri? probeUri,
    DateTime Function()? now,
    _ServerTimeProvider? serverTimeProvider,
  }) : _httpClient = httpClient ?? HttpClient(),
       _tolerance = tolerance,
       _probeUri = probeUri ?? Uri.parse('https://www.google.com'),
       _now = now ?? DateTime.now,
       _customServerTimeProvider = serverTimeProvider;

  final HttpClient _httpClient;
  final Duration _tolerance;
  final Uri _probeUri;
  final DateTime Function() _now;
  final _ServerTimeProvider? _customServerTimeProvider;

  /// Returns `true` when the device time is within [_tolerance] of the server
  /// time returned by [_probeUri]. If the probe fails we conservatively return
  /// `true` so the UI does not block usage, but the error is surfaced to the
  /// caller via the thrown [SocketException].
  Future<bool> isDeviceTimeConsistent() async {
    try {
      final serverTime = await _fetchServerTime();
      if (serverTime == null) {
        return true;
      }

      final deviceTime = _now().toUtc();
      final difference = deviceTime.difference(serverTime).abs();

      return difference <= _tolerance;
    } on SocketException {
      rethrow;
    } on FormatException {
      // Unable to parse the server date. Treat as consistent.
      return true;
    }
  }

  void close() {
    _httpClient.close(force: true);
  }

  Future<DateTime?> _fetchServerTime() async {
    if (_customServerTimeProvider != null) {
      return _customServerTimeProvider!();
    }

    final request = await _httpClient.openUrl('HEAD', _probeUri);
    request.followRedirects = true;
    final response = await request.close();
    final dateHeader = response.headers.value(HttpHeaders.dateHeader);
    if (dateHeader == null) {
      return null;
    }
    return HttpDate.parse(dateHeader).toUtc();
  }
}
