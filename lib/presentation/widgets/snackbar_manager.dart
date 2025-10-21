import 'dart:collection';

import 'package:flutter/material.dart';

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
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    SnackBarPriority priority = SnackBarPriority.normal,
    bool dismissible = true,
  }) {
    final request = _SnackBarRequest(
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
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      message: message,
      type: SnackBarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// エラーメッセージ
  void showError(
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
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
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 情報メッセージ
  void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
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
    _showSnackBar(request);
  }

  /// SnackBarを実際に表示
  void _showSnackBar(_SnackBarRequest request) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          _getIcon(request.type),
          const SizedBox(width: 12),
          Expanded(
            child: Text(request.message, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColor(request.type),
      duration: request.duration,
      action:
          request.actionLabel != null
              ? SnackBarAction(
                label: request.actionLabel!,
                textColor: Colors.white,
                onPressed: request.onAction ?? () {},
              )
              : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      dismissDirection:
          request.dismissible
              ? DismissDirection.horizontal
              : DismissDirection.none,
    );

    _messenger?.showSnackBar(snackBar).closed.then((_) {
      _isShowing = false;
      _processQueue();
    });
  }

  /// タイプに応じたアイコンを取得
  Widget _getIcon(SnackBarType type) {
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

    return Icon(iconData, color: Colors.white, size: 20);
  }

  /// タイプに応じた背景色を取得
  Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF10B981);
      case SnackBarType.error:
        return const Color(0xFFEF4444);
      case SnackBarType.warning:
        return const Color(0xFFF59E0B);
      case SnackBarType.info:
        return const Color(0xFF3B82F6);
    }
  }
}

/// SnackBarリクエスト
class _SnackBarRequest {
  final String message;
  final SnackBarType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final SnackBarPriority priority;
  final bool dismissible;

  _SnackBarRequest({
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
    SnackBarManager().showSuccess(message);
  }

  /// エラーメッセージを表示
  void showError(String message) {
    SnackBarManager().showError(message);
  }

  /// 警告メッセージを表示
  void showWarning(String message) {
    SnackBarManager().showWarning(message);
  }

  /// 情報メッセージを表示
  void showInfo(String message) {
    SnackBarManager().showInfo(message);
  }
}
