import 'package:flutter/material.dart';

import 'package:minq/presentation/theme/minq_theme.dart';

/// エラーバウンダリウィジェット
/// 子ウィジェットでエラーが発生した場合にフォールバック画面を表示
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    required this.child,
    this.errorBuilder,
    this.onError,
    super.key,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }
      return ErrorScreen(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _reset,
      );
    }

    return ErrorBoundaryWrapper(onError: _handleError, child: widget.child);
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });

    widget.onError?.call(error, stackTrace);

    // ログに記録
    print('❌ Error caught by ErrorBoundary: $error');
    print('Stack trace: $stackTrace');
  }

  void _reset() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }
}

/// エラーバウンダリラッパー
class ErrorBoundaryWrapper extends StatelessWidget {
  final Widget child;
  final void Function(Object error, StackTrace? stackTrace) onError;

  const ErrorBoundaryWrapper({
    required this.child,
    required this.onError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// エラー画面
class ErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const ErrorScreen({
    required this.error,
    this.stackTrace,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: tokens.accentError),
                SizedBox(height: tokens.spacing(6)),
                Text(
                  'エラーが発生しました',
                  style: tokens.titleLarge.copyWith(color: tokens.textPrimary),
                ),
                SizedBox(height: tokens.spacing(4)),
                Text(
                  _getErrorMessage(error),
                  textAlign: TextAlign.center,
                  style: tokens.bodyMedium.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
                SizedBox(height: tokens.spacing(8)),
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('再試行'),
                  ),
                SizedBox(height: tokens.spacing(4)),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('戻る'),
                ),
                SizedBox(height: tokens.spacing(8)),
                ExpansionTile(
                  title: Text(
                    '詳細情報',
                    style: tokens.bodyMedium.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  children: [
                    Container(
                      padding: EdgeInsets.all(tokens.spacing(4)),
                      color: tokens.surfaceAlt,
                      child: SingleChildScrollView(
                        child: Text(
                          'Error: $error\n\nStack trace:\n$stackTrace',
                          style: tokens.bodySmall.copyWith(
                            fontFamily: 'monospace',
                            color: tokens.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'アプリで予期しないエラーが発生しました。\n再試行するか、アプリを再起動してください。';
  }
}

/// グローバルエラーハンドラー
class GlobalErrorHandler {
  static void initialize() {
    // Flutter フレームワークのエラーをキャッチ
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    // Dart の非同期エラーをキャッチ
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   _logError(error, stack);
    //   return true;
    // };
  }

  static void _logError(Object error, StackTrace? stackTrace) {
    print('❌ Global error: $error');
    print('Stack trace: $stackTrace');

    // TODO: Crashlytics や Sentry に送信
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}

/// エラーウィジェット（ウィジェットビルドエラー用）
class ErrorWidget extends StatelessWidget {
  final String message;

  const ErrorWidget({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      color: tokens.accentError.withOpacity(0.12),
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: tokens.accentError),
          SizedBox(height: tokens.spacing(2)),
          Text(
            message,
            style: tokens.bodyMedium.copyWith(color: tokens.accentError),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
