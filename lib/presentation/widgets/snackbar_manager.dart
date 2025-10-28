import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

/// SnackBarグローバルマネージャー
/// 重複排他、優先度管理、キュー処理
class SnackBarManager {
  static final SnackBarManager _instance = SnackBarManager._internal();
  factory SnackBarManager() => _instance;
  SnackBarManager._internal();

  final Queue<_SnackBarRequest> _queue = Queue();
  bool _isShowing = false;
  ScaffoldMessengerState? _messenger;

  /// ScaffoldMessengerを登録
  void registerMessenger(ScaffoldMessengerState messenger) {
    _messenger = messenger;
  }

  /// SnackBarを表示
  void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    SnackBarPriority priority = SnackBarPriority.normal,
    bool dismissible = true,
  }) {
    final request = _SnackBarRequest(
      context: context,
      message: message,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      priority: priority,
      dismissible: dismissible,
    );

    // 同じメッセージが既にキューにある場合はスキップ
    if (_queue.any((r) => r.message == message)) {
      return;
    }

    _queue.add(request);
    _processQueue();
  }

  /// 成功メッセージ
  void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// エラーメッセージ
  void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      priority: SnackBarPriority.high,
    );
  }

  /// 警告メッセージ
  void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 情報メッセージ
  void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 現在のSnackBarを閉じる
  void dismiss() {
    _messenger?.hideCurrentSnackBar();
    _isShowing = false;
    _processQueue();
  }

  /// すべてのSnackBarをクリア
  void clearAll() {
    _queue.clear();
    _messenger?.clearSnackBars();
    _isShowing = false;
  }

  /// キューを処理
  void _processQueue() {
    if (_isShowing || _queue.isEmpty || _messenger == null) {
      return;
    }

    // 優先度順にソート
    final sortedQueue =
        _queue.toList()
          ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

    final request = sortedQueue.first;
    _queue.remove(request);

    _isShowing = true;
    _showSnackBar(request.context, request);
  }

  /// SnackBarを実際に表示
  void _showSnackBar(BuildContext context, _SnackBarRequest request) {
    final colors = context.tokens.colors;
    final snackBar = SnackBar(
      content: Row(
        children: [
          _getIcon(context, request.type),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              request.message,
              style: TextStyle(
                fontSize: 14,
                color: _getForegroundColor(context, request.type),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColor(context, request.type),
      duration: request.duration,
      action: request.actionLabel != null
          ? SnackBarAction(
              label: request.actionLabel!,
              textColor: _getForegroundColor(context, request.type),
              onPressed: request.onAction ?? () {},
            )
          : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      dismissDirection:
          request.dismissible ? DismissDirection.horizontal : DismissDirection.none,
    );

    _messenger?.showSnackBar(snackBar).closed.then((_) {
      _isShowing = false;
      _processQueue();
    });
  }

  /// タイプに応じたアイコンを取得
  Widget _getIcon(BuildContext context, SnackBarType type) {
    final colors = context.tokens.colors;
    IconData iconData;
    switch (type) {
      case SnackBarType.success:
        iconData = Icons.check_circle;
        break;
      case SnackBarType.error:
        iconData = Icons.error;
        break;
      case SnackBarType.warning:
        iconData = Icons.warning;
        break;
      case SnackBarType.info:
        iconData = Icons.info;
        break;
    }

    return Icon(iconData, color: _getForegroundColor(context, type), size: 20);
  }

  /// タイプに応じた背景色を取得
  Color _getBackgroundColor(BuildContext context, SnackBarType type) {
    final colors = context.tokens.colors;
    switch (type) {
      case SnackBarType.success:
        return colors.successContainer;
      case SnackBarType.error:
        return colors.errorContainer;
      case SnackBarType.warning:
        return colors.warningContainer;
      case SnackBarType.info:
        return colors.primaryContainer;
    }
  }

  /// タイプに応じた前景色（テキストやアイコンの色）を取得
  Color _getForegroundColor(BuildContext context, SnackBarType type) {
    final colors = context.tokens.colors;
    switch (type) {
      case SnackBarType.success:
        return colors.onSuccessContainer;
      case SnackBarType.error:
        return colors.onErrorContainer;
      case SnackBarType.warning:
        return colors.onWarningContainer;
      case SnackBarType.info:
        return colors.onPrimaryContainer;
    }
  }
}

/// SnackBarリクエスト
class _SnackBarRequest {
  final BuildContext context;
  final String message;
  final SnackBarType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final SnackBarPriority priority;
  final bool dismissible;

  _SnackBarRequest({
    required this.context,
    required this.message,
    required this.type,
    required this.duration,
    this.actionLabel,
    this.onAction,
    required this.priority,
    required this.dismissible,
  });
}

/// SnackBarタイプ
enum SnackBarType { success, error, warning, info }

/// SnackBar優先度
enum SnackBarPriority { low, normal, high }

/// BuildContext拡張
extension SnackBarExtension on BuildContext {
  /// SnackBarマネージャーにアクセス
  SnackBarManager get snackBar => SnackBarManager();

  /// 成功メッセージを表示
  void showSuccess(String message) {
    SnackBarManager().showSuccess(this, message);
  }

  /// エラーメッセージを表示
  void showError(String message) {
    SnackBarManager().showError(this, message);
  }

  /// 警告メッセージを表示
  void showWarning(String message) {
    SnackBarManager().showWarning(this, message);
  }

  /// 情報メッセージを表示
  void showInfo(String message) {
    SnackBarManager().showInfo(this, message);
  }
}
