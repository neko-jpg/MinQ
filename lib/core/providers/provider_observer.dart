import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Riverpod ProviderObserver
/// すべてのProvider状態変化をログ記録
class AppProviderObserver extends ProviderObserver {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  final bool enableLogging;
  final bool logStateChanges;
  final bool logErrors;
  final bool logDispose;

  AppProviderObserver({
    this.enableLogging = true,
    this.logStateChanges = true,
    this.logErrors = true,
    this.logDispose = false,
  });

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (!enableLogging) return;

    _logger.d(
      '➕ Provider Added: ${provider.name ?? provider.runtimeType}\n'
      'Value: $value',
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (!enableLogging || !logStateChanges) return;

    _logger.i(
      '🔄 Provider Updated: ${provider.name ?? provider.runtimeType}\n'
      'Previous: $previousValue\n'
      'New: $newValue',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    if (!enableLogging || !logDispose) return;

    _logger.d(
      '🗑️ Provider Disposed: ${provider.name ?? provider.runtimeType}',
    );
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    if (!enableLogging || !logErrors) return;

    _logger.e(
      '❌ Provider Failed: ${provider.name ?? provider.runtimeType}\n'
      'Error: $error',
      error,
      stackTrace,
    );
  }
}

/// 開発環境用の詳細ログObserver
class DevProviderObserver extends AppProviderObserver {
  DevProviderObserver()
      : super(
          enableLogging: true,
          logStateChanges: true,
          logErrors: true,
          logDispose: true,
        );
}

/// 本番環境用の最小ログObserver
class ProdProviderObserver extends AppProviderObserver {
  ProdProviderObserver()
      : super(
          enableLogging: true,
          logStateChanges: false,
          logErrors: true,
          logDispose: false,
        );
}
