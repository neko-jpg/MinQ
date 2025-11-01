import 'package:flutter/foundation.dart';
import 'package:minq/core/logging/app_logger.dart';

/// Sentryサービス
class SentryService {
  static bool _initialized = false;

  /// 初期化（リリースビルドのみ）
  static Future<void> initialize({
    required String dsn,
    String? environment,
    double? tracesSampleRate,
  }) async {
    if (_initialized) return;

    // リリースビルドでのみ有効化
    if (!kReleaseMode) {
      logger.info('Sentry is disabled in debug mode');
      return;
    }

    // TODO: Sentry.init()を実装
    _initialized = true;
  }

  /// エラーを記録
  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? hint,
  }) async {
    if (!_initialized) return;

    // TODO: Sentry.captureException()を実装
    logger.info('Sentry: Captured exception: $exception');
  }

  /// メッセージを記録
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    if (!_initialized) return;

    // TODO: Sentry.captureMessage()を実装
    logger.info('Sentry: Captured message: $message');
  }

  /// ユーザー情報を設定
  static Future<void> setUser({
    required String id,
    String? email,
    String? username,
  }) async {
    if (!_initialized) return;

    // TODO: Sentry.configureScope()を実装
  }

  /// タグを設定
  static Future<void> setTag(String key, String value) async {
    if (!_initialized) return;

    // TODO: Sentry.configureScope()を実装
  }

  /// コンテキストを設定
  static Future<void> setContext(
    String key,
    Map<String, dynamic> context,
  ) async {
    if (!_initialized) return;

    // TODO: Sentry.configureScope()を実装
  }

  /// パンくずを追加
  static Future<void> addBreadcrumb({
    required String message,
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) async {
    if (!_initialized) return;

    // TODO: Sentry.addBreadcrumb()を実装
  }
}

/// Sentryレベル
enum SentryLevel { debug, info, warning, error, fatal }

/// Sentryラッパー
class SentryWrapper {
  /// エラーをキャッチして記録
  static Future<T> captureErrors<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      await SentryService.captureException(e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// ウィジェットエラーをキャッチ
  static Future<void> captureWidgetError(FlutterErrorDetails details) async {
    await SentryService.captureException(
      details.exception,
      stackTrace: details.stack,
      hint: details.context?.toString(),
    );
  }
}

class FlutterErrorDetails {
  final dynamic exception;
  final StackTrace? stack;
  final DiagnosticsNode? context;

  FlutterErrorDetails({required this.exception, this.stack, this.context});
}

class DiagnosticsNode {
  @override
  String toString() => '';
}
