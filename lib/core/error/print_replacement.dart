import 'package:flutter/foundation.dart';
import 'package:minq/core/logging/app_logger.dart';

/// Secure replacement for print statements
/// This should be used instead of print() throughout the application
void secureLog(
  dynamic message, {
  String? tag,
  Map<String, dynamic>? data,
  LogLevel level = LogLevel.debug,
}) {
  if (!kDebugMode && level == LogLevel.debug) {
    // Don't log debug messages in production
    return;
  }

  final formattedMessage = tag != null ? '[$tag] $message' : message.toString();

  switch (level) {
    case LogLevel.debug:
      logger.debug(formattedMessage, data: data);
      break;
    case LogLevel.info:
      logger.info(formattedMessage, data: data);
      break;
    case LogLevel.warning:
      logger.warning(formattedMessage, data: data);
      break;
    case LogLevel.error:
      logger.error(formattedMessage, data: data);
      break;
  }
}

/// Log levels for secure logging
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Secure debug print that only works in debug mode
void secureDebugPrint(dynamic message, {String? tag}) {
  if (kDebugMode) {
    secureLog(message, tag: tag, level: LogLevel.debug);
  }
}

/// Log error with context
void logError(
  String message,
  dynamic error, {
  StackTrace? stackTrace,
  Map<String, dynamic>? context,
  String? tag,
}) {
  logger.error(
    tag != null ? '[$tag] $message' : message,
    data: context,
    error: error,
    stackTrace: stackTrace,
  );
}

/// Log warning with context
void logWarning(
  String message, {
  Map<String, dynamic>? context,
  String? tag,
}) {
  logger.warning(
    tag != null ? '[$tag] $message' : message,
    data: context,
  );
}

/// Log info with context
void logInfo(
  String message, {
  Map<String, dynamic>? context,
  String? tag,
}) {
  logger.info(
    tag != null ? '[$tag] $message' : message,
    data: context,
  );
}

/// Performance logging helper
class PerformanceTracker {
  static final Map<String, Stopwatch> _trackers = {};

  /// Start tracking performance for an operation
  static void start(String operationName) {
    _trackers[operationName] = Stopwatch()..start();
    secureDebugPrint('Performance tracking started: $operationName', tag: 'PERF');
  }

  /// Stop tracking and log the result
  static void stop(String operationName, {Map<String, dynamic>? metadata}) {
    final stopwatch = _trackers.remove(operationName);
    if (stopwatch != null) {
      stopwatch.stop();
      logger.logPerformance(operationName, stopwatch.elapsed, metadata: metadata);
    }
  }

  /// Get elapsed time without stopping
  static Duration? getElapsed(String operationName) {
    return _trackers[operationName]?.elapsed;
  }
}

/// Network request logging
void logNetworkRequest(
  String method,
  String url, {
  Map<String, dynamic>? headers,
  dynamic body,
  int? statusCode,
  Duration? duration,
}) {
  final isError = statusCode != null && statusCode >= 400;
  final level = isError ? LogLevel.error : LogLevel.debug;

  final logData = {
    'method': method,
    'url': url,
    if (headers != null) 'headers': headers,
    if (body != null) 'body': body,
    if (statusCode != null) 'statusCode': statusCode,
    if (duration != null) 'duration': '${duration.inMilliseconds}ms',
    'timestamp': DateTime.now().toIso8601String(),
  };

  secureLog(
    'Network ${statusCode != null ? 'Response' : 'Request'}: $method $url${statusCode != null ? ' ($statusCode)' : ''}',
    tag: 'NETWORK',
    data: logData,
    level: level,
  );
}

/// User action logging for analytics
void logUserAction(
  String action, {
  Map<String, dynamic>? properties,
  String? screen,
  String? userId,
}) {
  final logData = {
    'action': action,
    if (properties != null) 'properties': properties,
    if (screen != null) 'screen': screen,
    if (userId != null) 'userId': userId,
    'timestamp': DateTime.now().toIso8601String(),
  };

  secureLog(
    'User Action: $action${screen != null ? ' on $screen' : ''}',
    tag: 'USER_ACTION',
    data: logData,
    level: LogLevel.info,
  );
}

/// Navigation logging
void logNavigation(String from, String to, {Map<String, dynamic>? parameters}) {
  final logData = {
    'from': from,
    'to': to,
    if (parameters != null) 'parameters': parameters,
    'timestamp': DateTime.now().toIso8601String(),
  };

  secureLog(
    'Navigation: $from → $to',
    tag: 'NAVIGATION',
    data: logData,
    level: LogLevel.debug,
  );
}

/// Database operation logging
void logDatabaseOperation(
  String operation,
  String collection, {
  String? documentId,
  Map<String, dynamic>? data,
  Duration? duration,
  bool success = true,
}) {
  final logData = {
    'operation': operation,
    'collection': collection,
    if (documentId != null) 'documentId': documentId,
    if (data != null) 'data': data,
    if (duration != null) 'duration': '${duration.inMilliseconds}ms',
    'success': success,
    'timestamp': DateTime.now().toIso8601String(),
  };

  secureLog(
    'Database $operation: $collection${documentId != null ? '/$documentId' : ''} - ${success ? 'SUCCESS' : 'FAILED'}',
    tag: 'DATABASE',
    data: logData,
    level: success ? LogLevel.debug : LogLevel.error,
  );
}

/// AI service operation logging
void logAIOperation(
  String operation, {
  String? model,
  Map<String, dynamic>? input,
  Map<String, dynamic>? output,
  Duration? duration,
  bool success = true,
  String? errorMessage,
}) {
  final logData = {
    'operation': operation,
    if (model != null) 'model': model,
    if (input != null) 'input': input,
    if (output != null) 'output': output,
    if (duration != null) 'duration': '${duration.inMilliseconds}ms',
    'success': success,
    if (errorMessage != null) 'error': errorMessage,
    'timestamp': DateTime.now().toIso8601String(),
  };

  secureLog(
    'AI Operation: $operation${model != null ? ' ($model)' : ''} - ${success ? 'SUCCESS' : 'FAILED'}',
    tag: 'AI',
    data: logData,
    level: success ? LogLevel.debug : LogLevel.error,
  );
}

/// Authentication event logging
void logAuthEvent(
  String event, {
  String? userId,
  String? method,
  bool success = true,
  String? errorMessage,
}) {
  final logData = {
    'event': event,
    if (userId != null) 'userId': userId,
    if (method != null) 'method': method,
    'success': success,
    if (errorMessage != null) 'error': errorMessage,
    'timestamp': DateTime.now().toIso8601String(),
  };

  // Authentication events are always logged as security events
  logger.logSecurityEvent(event, logData, userId: userId);
}

/// Feature flag logging
void logFeatureFlag(
  String flagName,
  bool enabled, {
  String? userId,
  Map<String, dynamic>? context,
}) {
  final logData = {
    'flag': flagName,
    'enabled': enabled,
    if (userId != null) 'userId': userId,
    if (context != null) 'context': context,
    'timestamp': DateTime.now().toIso8601String(),
  };

  secureLog(
    'Feature Flag: $flagName = $enabled',
    tag: 'FEATURE_FLAG',
    data: logData,
    level: LogLevel.debug,
  );
}

/// Crash logging
void logCrash(
  String message,
  dynamic error,
  StackTrace stackTrace, {
  Map<String, dynamic>? context,
  bool fatal = false,
}) {
  final logData = {
    'message': message,
    'error': error.toString(),
    'stackTrace': stackTrace.toString(),
    if (context != null) 'context': context,
    'fatal': fatal,
    'timestamp': DateTime.now().toIso8601String(),
  };

  if (fatal) {
    logger.fatal(message, data: logData, error: error, stackTrace: stackTrace);
  } else {
    logger.error(message, data: logData, error: error, stackTrace: stackTrace);
  }
}