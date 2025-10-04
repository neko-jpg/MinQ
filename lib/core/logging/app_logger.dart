import 'dart:convert';

import 'package:logger/logger.dart';

/// アプリケーションロガー
/// JSON構造ログとレベル別ログ出力
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  late final Logger _logger;
  bool _initialized = false;

  /// ロガーを初期化
  void initialize({
    Level level = Level.debug,
    bool enableColors = true,
    bool enableEmojis = true,
    bool enableTime = true,
    LogOutput? output,
  }) {
    if (_initialized) return;

    _logger = Logger(
      level: level,
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: enableColors,
        printEmojis: enableEmojis,
        printTime: enableTime,
      ),
      output: output,
    );

    _initialized = true;
  }

  /// デバッグログ
  static void debug(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    _instance._ensureInitialized();
    if (error != null || stackTrace != null) {
      _instance._logger.d(message, error: error, stackTrace: stackTrace);
    } else {
      _instance._logger.d(message);
    }
  }

  /// 情報ログ
  static void info(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    _instance._ensureInitialized();
    if (error != null || stackTrace != null) {
      _instance._logger.i(message, error: error, stackTrace: stackTrace);
    } else {
      _instance._logger.i(message);
    }
  }

  /// 警告ログ
  static void warning(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    _instance._ensureInitialized();
    if (error != null || stackTrace != null) {
      _instance._logger.w(message, error: error, stackTrace: stackTrace);
    } else {
      _instance._logger.w(message);
    }
  }

  /// エラーログ
  static void error(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    _instance._ensureInitialized();
    if (error != null || stackTrace != null) {
      _instance._logger.e(message, error: error, stackTrace: stackTrace);
    } else {
      _instance._logger.e(message);
    }
  }

  /// 致命的エラーログ
  static void fatal(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    _instance._ensureInitialized();
    if (error != null || stackTrace != null) {
      _instance._logger.f(message, error: error, stackTrace: stackTrace);
    } else {
      _instance._logger.f(message);
    }
  }

  /// クリティカルログ（fatalのエイリアス）
  static void critical(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    fatal(message, error: error, stackTrace: stackTrace, data: data);
  }

  /// JSON構造ログ
  static void logJson(String message, Map<String, dynamic> data, {Level level = Level.info}) {
    _instance._ensureInitialized();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final logMessage = '$message\n$jsonString';

    switch (level) {
      case Level.debug:
        _instance._logger.d(logMessage);
        break;
      case Level.info:
        _instance._logger.i(logMessage);
        break;
      case Level.warning:
        _instance._logger.w(logMessage);
        break;
      case Level.error:
        _instance._logger.e(logMessage);
        break;
      case Level.fatal:
        _instance._logger.f(logMessage);
        break;
      default:
        _instance._logger.i(logMessage);
    }
  }

  /// イベントログ（アナリティクス用）
  static void logEvent(String eventName, Map<String, dynamic> parameters) {
    logJson('Event: $eventName', parameters, level: Level.info);
  }

  /// APIリクエストログ
  static void logApiRequest(String method, String url, {Map<String, dynamic>? body}) {
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
  static void logApiResponse(
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
  static void logNavigation(String from, String to) {
    info('Navigation: $from → $to');
  }

  /// ユーザーアクションログ
  static void logUserAction(String action, {Map<String, dynamic>? context}) {
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
  static void logPerformance(String operation, Duration duration, {Map<String, dynamic>? metadata}) {
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
}

/// グローバルロガーインスタンス
final logger = AppLogger();

/// パフォーマンス測定ヘルパー
class PerformanceLogger {
  final String operation;
  final Stopwatch _stopwatch = Stopwatch();
  final Map<String, dynamic>? metadata;

  PerformanceLogger(this.operation, {this.metadata}) {
    _stopwatch.start();
  }

  /// 測定を終了してログ出力
  void stop() {
    _stopwatch.stop();
    AppLogger.logPerformance(
      operation,
      _stopwatch.elapsed,
      metadata: metadata,
    );
  }
}

/// ログ出力先のカスタマイズ
class FileLogOutput extends LogOutput {
  // ファイル出力の実装（必要に応じて）
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      // ファイルに書き込む処理
      print(line);
    }
  }
}

/// リモートログ出力（Crashlytics等）
class RemoteLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // リモートサービスに送信する処理
    for (final line in event.lines) {
      // Crashlytics.log(line);
      print(line);
    }
  }
}

/// 複数出力先対応
class MultiLogOutput extends LogOutput {
  final List<LogOutput> outputs;

  MultiLogOutput(this.outputs);

  @override
  void output(OutputEvent event) {
    for (final output in outputs) {
      output.output(event);
    }
  }
}
