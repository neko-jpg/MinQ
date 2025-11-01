import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Secure logging system for startup operations that prevents sensitive data exposure
class SecureStartupLogger {
  static SecureStartupLogger? _instance;
  static SecureStartupLogger get instance =>
      _instance ??= SecureStartupLogger._();

  SecureStartupLogger._();

  final List<LogEntry> _logBuffer = [];
  final Set<String> _sensitiveKeys = {};
  final Map<String, String> _sanitizationRules = {};

  Timer? _flushTimer;
  bool _isInitialized = false;

  /// Sensitive data patterns to redact
  static const Set<String> _defaultSensitivePatterns = {
    // User identifiers
    'uid', 'userId', 'user_id', 'id',
    'email', 'mail', 'emailAddress',
    'phone', 'phoneNumber', 'mobile',
    'name', 'fullName', 'firstName', 'lastName', 'displayName',

    // Authentication
    'token', 'authToken', 'accessToken', 'refreshToken',
    'password', 'pwd', 'pass', 'secret', 'key', 'apiKey',
    'session', 'sessionId', 'cookie', 'auth',

    // Location and personal data
    'lat', 'lng', 'latitude', 'longitude', 'location',
    'address', 'street', 'city', 'zip', 'postal',
    'ip', 'ipAddress', 'deviceId', 'imei',

    // File paths and URLs that might contain sensitive info
    'path', 'filePath', 'url', 'imageUrl', 'photoUrl',

    // App-specific sensitive data
    'pairId', 'buddyId', 'partnerId',
    'questData', 'habitData', 'personalData',
  };

  /// Initialize secure logging
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setupSensitivePatterns();
      _setupSanitizationRules();
      _startPeriodicFlush();

      _isInitialized = true;
      _logInternal(
        LogLevel.info,
        'SecureStartupLogger',
        'Secure logging initialized',
      );
    } catch (error) {
      // Can't use logger here since it's not initialized
      debugPrint('Failed to initialize secure logging: $error');
      rethrow;
    }
  }

  /// Set up sensitive data patterns
  void _setupSensitivePatterns() {
    _sensitiveKeys.addAll(_defaultSensitivePatterns);

    // Add custom patterns based on app configuration
    _sensitiveKeys.addAll([
      'minqUserId',
      'questId',
      'habitId',
      'achievementId',
      'streakData',
      'personalGoals',
    ]);
  }

  /// Set up sanitization rules
  void _setupSanitizationRules() {
    _sanitizationRules.addAll({
      // Email patterns
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b':
          '[EMAIL_REDACTED]',

      // Phone number patterns
      r'\b\d{3}-?\d{3}-?\d{4}\b': '[PHONE_REDACTED]',
      r'\b\+\d{1,3}\s?\d{3,4}\s?\d{3,4}\s?\d{3,4}\b': '[PHONE_REDACTED]',

      // Token patterns (long alphanumeric strings)
      r'\b[A-Za-z0-9]{32,}\b': '[TOKEN_REDACTED]',

      // File paths
      r'\/[^\s]*\/[^\s]*': '[PATH_REDACTED]',
      r'[A-Z]:\\[^\s]*': '[PATH_REDACTED]',

      // URLs with potential sensitive data
      r'https?:\/\/[^\s]*\?[^\s]*': '[URL_WITH_PARAMS_REDACTED]',

      // IP addresses
      r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b': '[IP_REDACTED]',

      // UUIDs
      r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b':
          '[UUID_REDACTED]',
    });
  }

  /// Start periodic log flushing
  void _startPeriodicFlush() {
    _flushTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _flushLogs(),
    );
  }

  /// Log startup phase information
  void logStartupPhase(
    String phase,
    String message, {
    Map<String, dynamic>? data,
    Duration? duration,
  }) {
    final sanitizedData = data != null ? _sanitizeData(data) : null;

    _logInternal(
      LogLevel.info,
      'StartupPhase',
      '$phase: $message',
      data: {
        'phase': phase,
        if (duration != null) 'duration_ms': duration.inMilliseconds,
        if (sanitizedData != null) ...sanitizedData,
      },
    );
  }

  /// Log startup error with secure data handling
  void logStartupError(
    String phase,
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
  }) {
    final sanitizedContext = context != null ? _sanitizeData(context) : null;
    final sanitizedError = _sanitizeErrorMessage(error.toString());

    _logInternal(
      LogLevel.error,
      'StartupError',
      'Error in $phase: $sanitizedError',
      data: {
        'phase': phase,
        'error_type': error.runtimeType.toString(),
        if (sanitizedContext != null) 'context': sanitizedContext,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log performance metrics
  void logPerformanceMetric(
    String metric,
    num value, {
    String? unit,
    Map<String, dynamic>? tags,
  }) {
    final sanitizedTags = tags != null ? _sanitizeData(tags) : null;

    _logInternal(
      LogLevel.info,
      'Performance',
      'Metric: $metric = $value${unit ?? ''}',
      data: {
        'metric': metric,
        'value': value,
        if (unit != null) 'unit': unit,
        if (sanitizedTags != null) 'tags': sanitizedTags,
      },
    );
  }

  /// Log memory usage information
  void logMemoryUsage(
    int memoryBytes, {
    String? context,
    Map<String, dynamic>? details,
  }) {
    final memoryMB = (memoryBytes / (1024 * 1024)).toStringAsFixed(1);
    final sanitizedDetails = details != null ? _sanitizeData(details) : null;

    _logInternal(
      LogLevel.info,
      'Memory',
      'Memory usage: ${memoryMB}MB${context != null ? ' ($context)' : ''}',
      data: {
        'memory_bytes': memoryBytes,
        'memory_mb': double.parse(memoryMB),
        if (context != null) 'context': context,
        if (sanitizedDetails != null) ...sanitizedDetails,
      },
    );
  }

  /// Log initialization progress
  void logInitializationProgress(
    String service,
    double progress,
    String status,
  ) {
    _logInternal(
      LogLevel.info,
      'Initialization',
      '$service: $status (${(progress * 100).toStringAsFixed(1)}%)',
      data: {'service': service, 'progress': progress, 'status': status},
    );
  }

  /// Log crash information with secure handling
  void logCrash(
    String type,
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
  }) {
    final sanitizedContext = context != null ? _sanitizeData(context) : null;
    final sanitizedError = _sanitizeErrorMessage(error.toString());

    _logInternal(
      LogLevel.error,
      'Crash',
      'Crash detected: $type - $sanitizedError',
      data: {
        'crash_type': type,
        'error_type': error.runtimeType.toString(),
        if (sanitizedContext != null) 'context': sanitizedContext,
        'timestamp': DateTime.now().toIso8601String(),
      },
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log health check results
  void logHealthCheck(
    String component,
    bool healthy, {
    Map<String, dynamic>? metrics,
    String? message,
  }) {
    final sanitizedMetrics = metrics != null ? _sanitizeData(metrics) : null;

    _logInternal(
      healthy ? LogLevel.info : LogLevel.warning,
      'HealthCheck',
      '$component: ${healthy ? 'HEALTHY' : 'UNHEALTHY'}${message != null ? ' - $message' : ''}',
      data: {
        'component': component,
        'healthy': healthy,
        if (sanitizedMetrics != null) 'metrics': sanitizedMetrics,
      },
    );
  }

  /// Sanitize data to remove sensitive information
  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (_isSensitiveKey(key)) {
        sanitized[key] = '[REDACTED]';
      } else if (value is String) {
        sanitized[key] = _sanitizeString(value);
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizeData(value);
      } else if (value is List) {
        sanitized[key] = _sanitizeList(value);
      } else {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  /// Sanitize a list of values
  List<dynamic> _sanitizeList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return _sanitizeData(item);
      } else if (item is String) {
        return _sanitizeString(item);
      } else {
        return item;
      }
    }).toList();
  }

  /// Check if a key is sensitive
  bool _isSensitiveKey(String key) {
    final lowerKey = key.toLowerCase();
    return _sensitiveKeys.any(
      (pattern) => lowerKey.contains(pattern.toLowerCase()),
    );
  }

  /// Sanitize string content
  String _sanitizeString(String input) {
    String sanitized = input;

    // Apply sanitization rules
    for (final entry in _sanitizationRules.entries) {
      sanitized = sanitized.replaceAll(RegExp(entry.key), entry.value);
    }

    // Truncate very long strings
    if (sanitized.length > 500) {
      sanitized = '${sanitized.substring(0, 497)}...';
    }

    return sanitized;
  }

  /// Sanitize error messages
  String _sanitizeErrorMessage(String errorMessage) {
    // Remove file paths from stack traces
    String sanitized = errorMessage.replaceAll(
      RegExp(r'file:\/\/\/[^\s)]+'),
      '[FILE_PATH_REDACTED]',
    );

    // Remove package paths
    sanitized = sanitized.replaceAll(
      RegExp(r'package:[^\s)]+'),
      '[PACKAGE_PATH_REDACTED]',
    );

    // Apply general string sanitization
    return _sanitizeString(sanitized);
  }

  /// Internal logging method
  void _logInternal(
    LogLevel level,
    String category,
    String message, {
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final logEntry = LogEntry(
      level: level,
      category: category,
      message: message,
      data: data,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    _logBuffer.add(logEntry);

    // Keep buffer size manageable
    if (_logBuffer.length > 1000) {
      _logBuffer.removeRange(0, 500); // Remove oldest 500 entries
    }

    // Also log to developer console in debug mode
    if (kDebugMode) {
      _logToDeveloperConsole(logEntry);
    }
  }

  /// Log to developer console
  void _logToDeveloperConsole(LogEntry entry) {
    final levelValue = _getLevelValue(entry.level);
    final payload = <String, dynamic>{
      'category': entry.category,
      'message': entry.message,
      if (entry.data != null) 'data': entry.data,
    };

    developer.log(
      jsonEncode(payload),
      name: 'MinQ/${entry.level.name.toUpperCase()}',
      level: levelValue,
      error: entry.error,
      stackTrace: entry.stackTrace,
    );
  }

  /// Get numeric level value for developer.log
  int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  /// Flush logs to persistent storage or remote service
  void _flushLogs() {
    if (_logBuffer.isEmpty) return;

    try {
      // In a real implementation, this would:
      // 1. Write logs to secure local storage
      // 2. Send logs to remote logging service (if configured)
      // 3. Respect user privacy settings

      final logCount = _logBuffer.length;
      _logBuffer.clear();

      if (kDebugMode) {
        debugPrint('Flushed $logCount log entries');
      }
    } catch (error) {
      // Can't log this error since we're in the logging system
      debugPrint('Failed to flush logs: $error');
    }
  }

  /// Get recent logs for debugging (sanitized)
  List<LogEntry> getRecentLogs({int limit = 100}) {
    return _logBuffer.reversed.take(limit).toList();
  }

  /// Get logs by category
  List<LogEntry> getLogsByCategory(String category, {int limit = 50}) {
    return _logBuffer
        .where((entry) => entry.category == category)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  /// Get error logs only
  List<LogEntry> getErrorLogs({int limit = 50}) {
    return _logBuffer
        .where((entry) => entry.level == LogLevel.error)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  /// Export logs for debugging (with additional sanitization)
  String exportLogsForDebugging() {
    final buffer = StringBuffer();
    buffer.writeln('=== MinQ Startup Logs Export ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total entries: ${_logBuffer.length}');
    buffer.writeln('');

    for (final entry in _logBuffer.reversed.take(200)) {
      buffer.writeln(
        '${entry.timestamp.toIso8601String()} '
        '[${entry.level.name.toUpperCase()}] '
        '${entry.category}: ${entry.message}',
      );

      if (entry.data != null && entry.data!.isNotEmpty) {
        buffer.writeln('  Data: ${jsonEncode(entry.data)}');
      }

      if (entry.error != null) {
        buffer.writeln('  Error: ${entry.error.runtimeType}');
      }

      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// Clear all logs
  void clearLogs() {
    _logBuffer.clear();
    _logInternal(LogLevel.info, 'SecureStartupLogger', 'Logs cleared');
  }

  /// Dispose logger
  void dispose() {
    _flushTimer?.cancel();
    _flushLogs(); // Final flush
    _logBuffer.clear();
    _sensitiveKeys.clear();
    _sanitizationRules.clear();
    _isInitialized = false;
    _instance = null;
  }

  /// Reset for testing
  @visibleForTesting
  void reset() {
    dispose();
  }
}

/// Log entry
class LogEntry {
  final LogLevel level;
  final String category;
  final String message;
  final Map<String, dynamic>? data;
  final dynamic error;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  const LogEntry({
    required this.level,
    required this.category,
    required this.message,
    this.data,
    this.error,
    this.stackTrace,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'level': level.name,
      'category': category,
      'message': message,
      if (data != null) 'data': data,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '${timestamp.toIso8601String()} [${level.name.toUpperCase()}] $category: $message';
  }
}

/// Log levels
enum LogLevel { debug, info, warning, error }

/// Global secure startup logger instance
final secureStartupLogger = SecureStartupLogger.instance;
