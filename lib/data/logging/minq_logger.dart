import 'dart:convert';
import 'dart:developer' as developer;

class MinqLogger {
  MinqLogger._();

  static const Set<String> _blockedKeys = <String>{
    'email',
    'mail',
    'token',
    'authToken',
    'refreshToken',
    'session',
    'cookie',
    'password',
    'imageUrl',
    'photoUrl',
    'filePath',
    'phone',
    'fullName',
    'firstName',
    'lastName',
    'address',
    'lat',
    'lng',
  };

  static void info(String event, {Map<String, dynamic>? metadata}) {
    _log(level: 'INFO', event: event, metadata: metadata);
  }

  static void warn(String event, {Map<String, dynamic>? metadata}) {
    _log(level: 'WARN', event: event, metadata: metadata, levelValue: 900);
  }

  static void error(
    String event, {
    Map<String, dynamic>? metadata,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    _log(
      level: 'ERROR',
      event: event,
      metadata: metadata,
      error: exception,
      stackTrace: stackTrace,
      levelValue: 1000,
    );
  }

  static void _log({
    required String level,
    required String event,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
    int levelValue = 800,
  }) {
    final sanitized = _sanitizeMetadata(metadata);
    final payload = <String, dynamic>{
      'event': event,
      if (sanitized.isNotEmpty) 'meta': sanitized,
    };

    developer.log(
      jsonEncode(payload),
      name: 'MinQ/$level',
      level: levelValue,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static Map<String, dynamic> _sanitizeMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null || metadata.isEmpty) {
      return const <String, dynamic>{};
    }

    final Map<String, dynamic> sanitized = <String, dynamic>{};
    metadata.forEach((String key, dynamic value) {
      if (_containsBlockedKeyword(key)) {
        sanitized[key] = '**redacted**';
      } else if (value is String && value.length > 120) {
        sanitized[key] = value.substring(0, 117) + '…';
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizeMetadata(value);
      } else if (value is Iterable) {
        sanitized[key] = value
            .map((dynamic element) => element is Map<String, dynamic>
                ? _sanitizeMetadata(element)
                : element)
            .toList();
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  static bool _containsBlockedKeyword(String key) {
    final lowerKey = key.toLowerCase();
    return _blockedKeys.any((String blocked) => lowerKey.contains(blocked));
  }
}
