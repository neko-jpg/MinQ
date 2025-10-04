import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crashlyticsサービス
class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics;

  CrashlyticsService({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  /// 初期化
  Future<void> initialize() async {
    // リリースビルドでのみ有効化
    if (kReleaseMode) {
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
    } else {
      await _crashlytics.setCrashlyticsCollectionEnabled(false);
    }

    // Flutterエラーをキャッチ
    FlutterError.onError = _crashlytics.recordFlutterFatalError;

    // 非同期エラーをキャッチ
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// エラーを記録
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// 非致命的エラーを記録
  Future<void> recordNonFatalError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    await recordError(
      exception,
      stack,
      reason: reason,
      fatal: false,
    );
  }

  /// カスタムログを記録
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// ユーザーIDを設定
  Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  /// カスタムキーを設定
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// パンくずを追加
  Future<void> addBreadcrumb(String message, {Map<String, dynamic>? data}) async {
    final breadcrumb = StringBuffer(message);
    if (data != null) {
      breadcrumb.write(' - ${data.toString()}');
    }
    await log(breadcrumb.toString());
  }

  /// テストクラッシュを送信
  Future<void> testCrash() async {
    _crashlytics.crash();
  }
}

/// Crashlyticsラッパー
class CrashlyticsWrapper {
  static final CrashlyticsService _service = CrashlyticsService();

  /// 初期化
  static Future<void> initialize() async {
    await _service.initialize();
  }

  /// エラーを記録
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _service.recordError(exception, stack, reason: reason, fatal: fatal);
  }

  /// ログを記録
  static Future<void> log(String message) async {
    await _service.log(message);
  }

  /// ユーザーIDを設定
  static Future<void> setUserId(String userId) async {
    await _service.setUserId(userId);
  }

  /// カスタムキーを設定
  static Future<void> setCustomKey(String key, dynamic value) async {
    await _service.setCustomKey(key, value);
  }

  /// パンくずを追加
  static Future<void> addBreadcrumb(String message, {Map<String, dynamic>? data}) async {
    await _service.addBreadcrumb(message, data: data);
  }
}

/// エラーハンドラー
class ErrorHandler {
  /// エラーをハンドル
  static Future<void> handle(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalInfo,
  }) async {
    // ログに記録
    print('Error: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }

    // Crashlyticsに送信
    await CrashlyticsWrapper.recordError(
      error,
      stackTrace,
      reason: context,
    );

    // 追加情報を設定
    if (additionalInfo != null) {
      for (final entry in additionalInfo.entries) {
        await CrashlyticsWrapper.setCustomKey(entry.key, entry.value);
      }
    }
  }

  /// 非致命的エラーをハンドル
  static Future<void> handleNonFatal(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
  }) async {
    await CrashlyticsWrapper.recordError(
      error,
      stackTrace,
      reason: context,
      fatal: false,
    );
  }
}

class PlatformDispatcher {
  static final instance = PlatformDispatcher._();
  PlatformDispatcher._();
  
  bool Function(Object, StackTrace)? onError;
}
