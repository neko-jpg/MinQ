import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AsyncValue拡張 - 標準化されたエラーハンドリングとUI表現
extension AsyncValueExtensions<T> on AsyncValue<T> {
  /// AsyncValue.guardの標準化ラッパー
  /// 例外を自動的にAsyncValue.errorに変換
  static Future<AsyncValue<T>> guard<T>(Future<T> Function() future) async {
    try {
      return AsyncValue.data(await future());
    } catch (error, stackTrace) {
      return AsyncValue.error(error, stackTrace);
    }
  }

  /// データまたはデフォルト値を取得
  T? get dataOrNull => when(
        data: (data) => data,
        loading: () => null,
        error: (_, __) => null,
      );

  /// データまたは例外をスロー
  T get dataOrThrow => when(
        data: (data) => data,
        loading: () => throw StateError('Data is loading'),
        error: (error, _) => throw error,
      );

  /// エラーメッセージを取得
  String? get errorMessage => when(
        data: (_) => null,
        loading: () => null,
        error: (error, _) => _getErrorMessage(error),
      );

  /// ローディング中かどうか
  bool get isLoading => when(
        data: (_) => false,
        loading: () => true,
        error: (_, __) => false,
      );

  /// エラーかどうか
  bool get isError => when(
        data: (_) => false,
        loading: () => false,
        error: (_, __) => true,
      );

  /// データがあるかどうか
  bool get hasData => when(
        data: (_) => true,
        loading: () => false,
        error: (_, __) => false,
      );

  /// UIウィジェットに変換（標準パターン）
  Widget toWidget({
    required Widget Function(T data) data,
    Widget Function()? loading,
    Widget Function(Object error, StackTrace stackTrace)? error,
  }) {
    return when(
      data: data,
      loading: loading ?? () => const Center(child: CircularProgressIndicator()),
      error: error ??
          (err, stack) => Center(
                child: ErrorDisplay(
                  error: err,
                  stackTrace: stack,
                ),
              ),
    );
  }

  /// UIウィジェットに変換（データのみ表示、エラーは無視）
  Widget? toWidgetOrNull(Widget Function(T data) builder) {
    return when(
      data: builder,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  /// リストの場合の空状態チェック
  bool get isEmptyList {
    if (T is! List) return false;
    return when(
      data: (data) => (data as List).isEmpty,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  /// エラーメッセージを取得（内部）
  static String _getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }
}

/// AsyncValueUI - 標準的なUI表現
class AsyncValueUI<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final Widget Function()? empty;

  const AsyncValueUI({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (d) {
        // 空状態チェック
        if (empty != null && d is List && d.isEmpty) {
          return empty!();
        }
        return data(d);
      },
      loading: loading ?? () => const LoadingWidget(),
      error: error ?? (err, stack) => ErrorWidget2(error: err, stackTrace: stack),
    );
  }
}

/// 標準ローディングウィジェット
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// 標準エラーウィジェット
class ErrorWidget2 extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  final VoidCallback? onRetry;

  const ErrorWidget2({
    super.key,
    required this.error,
    required this.stackTrace,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              AsyncValueExtensions._getErrorMessage(error),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 標準空状態ウィジェット
class EmptyWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final Widget? action;

  const EmptyWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            if (title != null)
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// エラー表示ウィジェット
class ErrorDisplay extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.error,
    required this.stackTrace,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget2(
      error: error,
      stackTrace: stackTrace,
      onRetry: onRetry,
    );
  }
}

/// AsyncValueビルダー - より簡潔な記述
class AsyncValueBuilder<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loading;
  final Widget Function(BuildContext context, Object error, StackTrace stack)? error;
  final Widget Function(BuildContext context)? empty;

  const AsyncValueBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.loading,
    this.error,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) {
        // 空状態チェック
        if (empty != null && data is List && data.isEmpty) {
          return empty!(context);
        }
        return builder(context, data);
      },
      loading: () => loading?.call(context) ?? const LoadingWidget(),
      error: (err, stack) =>
          error?.call(context, err, stack) ??
          ErrorWidget2(error: err, stackTrace: stack),
    );
  }
}

/// Ref拡張 - guard付きread
extension RefExtensions on Ref {
  /// guardを使用した安全な非同期処理
  Future<AsyncValue<T>> guardAsync<T>(Future<T> Function() future) async {
    return AsyncValueExtensions.guard(future);
  }
}
