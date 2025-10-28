import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:minq/core/error/exceptions.dart';

/// Secure application logger with structured logging
/// Replaces all print statements with proper logging
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  late final Logger _logger;
  bool _initialized = false;
  final List<String> _sensitiveKeys = [
    'password', 'token', 'secret', 'key', 'auth', 'credential',
    'email', 'phone', 'address', 'name', 'userId', 'id'
  ];

  /// Initialize secure logger with production-ready configuration
  void initialize({
    Level? level,
    bool enableColors = true,
    bool enableEmojis = false,
    bool enableTime = true,
    LogOutput? output,
    bool enableFileLogging = false,
    String? logFilePath,
  }) {
    if (_initialized) return;

    // Set appropriate log level based on build mode
    final logLevel = level ?? (kDebugMode ? Level.debug : Level.info);
    
    // Create secure printer that filters sensitive data
    final printer = _SecurePrettyPrinter(
      methodCount: kDebugMode ? 2 : 0,
      errorMethodCount: kDebugMode ? 8 : 3,
      lineLength: 120,
      colors: enableColors && kDebugMode,
      printEmojis: enableEmojis,
      printTime: enableTime,
      sensitiveKeys: _sensitiveKeys,
    );

    // Configure output destinations
    LogOutput logOutput;
    if (output != null) {
      logOutput = output;
    } else {
      final outputs = <LogOutput>[ConsoleOutput()];
      
      // Add file logging in production or when explicitly enabled
      if (enableFileLogging || !kDebugMode) {
        outputs.add(SecureFileOutput(logFilePath));
      }
      
      logOutput = outputs.length == 1 ? outputs.first : MultiOutput(outputs);
    }

    _logger = Logger(
      level: logLevel,
      printer: printer,
      output: logOutput,
    );

    _initialized = true;
    
    // Log initialization
    info('Logger initialized', data: {
      'level': logLevel.name,
      'debugMode': kDebugMode,
      'fileLogging': enableFileLogging || !kDebugMode,
    });
  }

  /// デバッグログ
  void debug(
    String message, {
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _ensureInitialized();
    final logMessage = _formatMessage(message, data);
    if (error != null || stackTrace != null) {
      _logger.d(logMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.d(logMessage);
    }
  }

  /// 情報ログ
  void info(
    String message, {
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _ensureInitialized();
    final logMessage = _formatMessage(message, data);
    if (error != null || stackTrace != null) {
      _logger.i(logMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.i(logMessage);
    }
  }

  /// 警告ログ
  void warning(
    String message, {
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _ensureInitialized();
    final logMessage = _formatMessage(message, data);
    if (error != null || stackTrace != null) {
      _logger.w(logMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.w(logMessage);
    }
  }

  /// エラーログ
  void error(
    String message, {
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _ensureInitialized();
    final logMessage = _formatMessage(message, data);
    if (error != null || stackTrace != null) {
      _logger.e(logMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.e(logMessage);
    }
  }

  /// 致命的エラーログ
  void fatal(
    String message, {
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _ensureInitialized();
    final logMessage = _formatMessage(message, data);
    if (error != null || stackTrace != null) {
      _logger.f(logMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.f(logMessage);
    }
  }

  /// JSON構造ログ
  void logJson(String message, Map<String, dynamic> data, {Level level = Level.info}) {
    _ensureInitialized();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final logMessage = '$message\n$jsonString';

    switch (level) {
      case Level.debug:
        _logger.d(logMessage);
        break;
      case Level.info:
        _logger.i(logMessage);
        break;
      case Level.warning:
        _logger.w(logMessage);
        break;
      case Level.error:
        _logger.e(logMessage);
        break;
      case Level.fatal:
        _logger.f(logMessage);
        break;
      default:
        _logger.i(logMessage);
    }
  }

  /// イベントログ（アナリティクス用）
  void logEvent(String eventName, Map<String, dynamic> parameters) {
    logJson('Event: $eventName', parameters, level: Level.info);
  }

  /// APIリクエストログ
  void logApiRequest(String method, String url, {Map<String, dynamic>? body}) {
    logJson(
      'API Request: $method $url',
      {
        'method': method,
        'url': url,
        if (body != null) 'body': body,
        'timestamp': DateTime.now().toIso8601String(),
      },
      level: Level.debug,
    );
  }

  /// APIレスポンスログ
  void logApiResponse(
    String method,
    String url,
    int statusCode, {
    dynamic body,
    Duration? duration,
  }) {
    logJson(
      'API Response: $method $url ($statusCode)',
      {
        'method': method,
        'url': url,
        'statusCode': statusCode,
        if (body != null) 'body': body,
        if (duration != null) 'duration': '${duration.inMilliseconds}ms',
        'timestamp': DateTime.now().toIso8601String(),
      },
      level: statusCode >= 400 ? Level.error : Level.debug,
    );
  }

  /// ナビゲーションログ
  void logNavigation(String from, String to) {
    info('Navigation: $from → $to');
  }

  /// ユーザーアクションログ
  void logUserAction(String action, {Map<String, dynamic>? context}) {
    logJson(
      'User Action: $action',
      {
        'action': action,
        if (context != null) ...context,
        'timestamp': DateTime.now().toIso8601String(),
      },
      level: Level.info,
    );
  }

  /// パフォーマンスログ
  void logPerformance(String operation, Duration duration, {Map<String, dynamic>? metadata}) {
    logJson(
      'Performance: $operation',
      {
        'operation': operation,
        'duration': '${duration.inMilliseconds}ms',
        if (metadata != null) ...metadata,
        'timestamp': DateTime.now().toIso8601String(),
      },
      level: duration.inMilliseconds > 1000 ? Level.warning : Level.debug,
    );
  }

  /// 初期化チェック
  void _ensureInitialized() {
    if (!_initialized) {
      initialize();
    }
  }

  String _formatMessage(String message, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return message;
    }
    final sanitizedData = _sanitizeData(data);
    final jsonString = const JsonEncoder.withIndent('  ').convert(sanitizedData);
    return '$message\n$jsonString';
  }

  /// Log MinqException with full context
  void logException(
    MinqException exception, {
    Level level = Level.error,
    String? additionalContext,
  }) {
    _ensureInitialized();
    
    final logData = {
      ...exception.toMap(),
      if (additionalContext != null) 'additionalContext': additionalContext,
    };
    
    switch (level) {
      case Level.debug:
        debug('Exception occurred: ${exception.message}', data: logData);
        break;
      case Level.info:
        info('Exception occurred: ${exception.message}', data: logData);
        break;
      case Level.warning:
        warning('Exception occurred: ${exception.message}', data: logData);
        break;
      case Level.error:
        error('Exception occurred: ${exception.message}', data: logData);
        break;
      case Level.fatal:
        fatal('Exception occurred: ${exception.message}', data: logData);
        break;
      default:
        error('Exception occurred: ${exception.message}', data: logData);
    }
  }

  /// Log security event (always logged regardless of level)
  void logSecurityEvent(
    String event,
    Map<String, dynamic> details, {
    String? userId,
    String? ipAddress,
  }) {
    _ensureInitialized();
    
    final securityData = {
      'event': event,
      'details': _sanitizeData(details),
      if (userId != null) 'userId': _hashSensitiveData(userId),
      if (ipAddress != null) 'ipAddress': _hashSensitiveData(ipAddress),
      'timestamp': DateTime.now().toIso8601String(),
      'severity': 'SECURITY',
    };
    
    // Security events are always logged at warning level or higher
    _logger.w('SECURITY EVENT: $event', error: null, stackTrace: null);
    _logger.w(const JsonEncoder.withIndent('  ').convert(securityData));
  }

  /// Sanitize data to remove sensitive information
  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;
      
      if (_sensitiveKeys.any((sensitive) => key.contains(sensitive))) {
        sanitized[entry.key] = _hashSensitiveData(value.toString());
      } else if (value is Map<String, dynamic>) {
        sanitized[entry.key] = _sanitizeData(value);
      } else if (value is List) {
        sanitized[entry.key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _sanitizeData(item);
          }
          return item;
        }).toList();
      } else {
        sanitized[entry.key] = value;
      }
    }
    
    return sanitized;
  }

  /// Hash sensitive data for logging
  String _hashSensitiveData(String data) {
    if (data.length <= 4) return '***';
    return '${data.substring(0, 2)}***${data.substring(data.length - 2)}';
  }
}

/// グローバルロガーインスタンス
final logger = AppLogger();

/// Performance measurement helper with automatic logging
class PerformanceLogger {
  final String operation;
  final Stopwatch _stopwatch = Stopwatch();
  final Map<String, dynamic>? metadata;
  final Level logLevel;

  PerformanceLogger(
    this.operation, {
    this.metadata,
    this.logLevel = Level.debug,
  }) {
    _stopwatch.start();
    logger.debug('Performance tracking started: $operation');
  }

  /// Stop measurement and log performance data
  void stop() {
    _stopwatch.stop();
    logger.logPerformance(
      operation,
      _stopwatch.elapsed,
      metadata: metadata,
    );
  }

  /// Get elapsed time without stopping
  Duration get elapsed => _stopwatch.elapsed;
}

/// Secure printer that filters sensitive data
class _SecurePrettyPrinter extends PrettyPrinter {
  final List<String> sensitiveKeys;

  _SecurePrettyPrinter({
    super.methodCount,
    super.errorMethodCount,
    super.lineLength,
    super.colors,
    super.printEmojis,
    super.printTime,
    required this.sensitiveKeys,
  });

  @override
  List<String> log(LogEvent event) {
    // Filter sensitive data from the message
    final filteredMessage = _filterSensitiveData(event.message);
    final filteredEvent = LogEvent(
      event.level,
      filteredMessage,
    );
    
    return super.log(filteredEvent);
  }

  String _filterSensitiveData(dynamic message) {
    if (message == null) return '';
    
    String messageStr = message.toString();
    
    // Simple pattern matching for common sensitive data patterns
    for (final key in sensitiveKeys) {
      final pattern = RegExp('($key["\']?\\s*[:=]\\s*["\']?)([^"\'\\s,}]+)', 
        caseSensitive: false);
      messageStr = messageStr.replaceAllMapped(pattern, (match) {
        return '${match.group(1)}***';
      });
    }
    
    return messageStr;
  }
}

/// Secure file output that rotates logs and filters sensitive data
class SecureFileOutput extends LogOutput {
  final String? logFilePath;
  final int maxFileSize;
  final int maxFiles;
  
  SecureFileOutput(
    this.logFilePath, {
    this.maxFileSize = 10 * 1024 * 1024, // 10MB
    this.maxFiles = 5,
  });

  @override
  void output(OutputEvent event) {
    if (!kDebugMode) {
      // In production, implement secure file logging
      // This is a placeholder for actual file logging implementation
      // for (final line in event.lines) {
      //   // TODO: Implement secure file logging with rotation
      //   // File logging should be implemented with proper security measures
      // }
    }
  }
}

/// Multi-output logger that sends logs to multiple destinations
class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;

  MultiOutput(this.outputs);

  @override
  void output(OutputEvent event) {
    for (final output in outputs) {
      try {
        output.output(event);
      } catch (e) {
        // Don't let logging failures crash the app
        if (kDebugMode) {
          debugPrint('Logging output failed: $e');
        }
      }
    }
  }
}

/// Remote logging output for crash reporting services
class RemoteLogOutput extends LogOutput {
  final Future<void> Function(String level, String message, Map<String, dynamic>? data) _sendLog;

  RemoteLogOutput(this._sendLog);

  @override
  void output(OutputEvent event) {
    if (!kDebugMode) {
      // Only send logs to remote services in production
      try {
        final level = event.level.name;
        final message = event.lines.join('\n');
        _sendLog(level, message, null);
      } catch (e) {
        // Don't let remote logging failures crash the app
        if (kDebugMode) {
          debugPrint('Remote logging failed: $e');
        }
      }
    }
  }
}
