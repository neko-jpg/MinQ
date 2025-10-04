import 'dart:collection';

import 'package:flutter/material.dart';

/// SnackBar繧ｰ繝ｭ繝ｼ繝舌Ν繝槭ロ繝ｼ繧ｸ繝｣繝ｼ
/// 驥崎､・賜莉悶∝━蜈亥ｺｦ邂｡逅・√く繝･繝ｼ蜃ｦ逅・
class SnackBarManager {
  static final SnackBarManager _instance = SnackBarManager._internal();
  factory SnackBarManager() => _instance;
  SnackBarManager._internal();

  final Queue<_SnackBarRequest> _queue = Queue();
  bool _isShowing = false;
  ScaffoldMessengerState? _messenger;

  /// ScaffoldMessenger繧堤匳骭ｲ
  void registerMessenger(ScaffoldMessengerState messenger) {
    _messenger = messenger;
  }

  /// SnackBar繧定｡ｨ遉ｺ
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

    // 蜷後§繝｡繝・そ繝ｼ繧ｸ縺梧里縺ｫ繧ｭ繝･繝ｼ縺ｫ縺ゅｋ蝣ｴ蜷医・繧ｹ繧ｭ繝・・
    if (_queue.any((r) => r.message == message)) {
      return;
    }

    _queue.add(request);
    _processQueue();
  }

  /// 謌仙粥繝｡繝・そ繝ｼ繧ｸ
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

  /// 繧ｨ繝ｩ繝ｼ繝｡繝・そ繝ｼ繧ｸ
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

  /// 隴ｦ蜻翫Γ繝・そ繝ｼ繧ｸ
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

  /// 諠・ｱ繝｡繝・そ繝ｼ繧ｸ
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

  /// 迴ｾ蝨ｨ縺ｮSnackBar繧帝哩縺倥ｋ
  void dismiss() {
    _messenger?.hideCurrentSnackBar();
    _isShowing = false;
    _processQueue();
  }

  /// 縺吶∋縺ｦ縺ｮSnackBar繧偵け繝ｪ繧｢
  void clearAll() {
    _queue.clear();
    _messenger?.clearSnackBars();
    _isShowing = false;
  }

  /// 繧ｭ繝･繝ｼ繧貞・逅・
  void _processQueue() {
    if (_isShowing || _queue.isEmpty || _messenger == null) {
      return;
    }

    // 蜆ｪ蜈亥ｺｦ鬆・↓繧ｽ繝ｼ繝・
    final sortedQueue = _queue.toList()
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

    final request = sortedQueue.first;
    _queue.remove(request);

    _isShowing = true;
    _showSnackBar(request);
  }

  /// SnackBar繧貞ｮ滄圀縺ｫ陦ｨ遉ｺ
  void _showSnackBar(_SnackBarRequest request) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          _getIcon(request.type),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              request.message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColor(request.type),
      duration: request.duration,
      action: request.actionLabel != null
          ? SnackBarAction(
              label: request.actionLabel!,
              textColor: Colors.white,
              onPressed: request.onAction ?? () {},
            )
          : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      dismissDirection:
          request.dismissible ? DismissDirection.horizontal : DismissDirection.none,
    );

    _messenger?.showSnackBar(snackBar).closed.then((_) {
      _isShowing = false;
      _processQueue();
    });
  }

  /// 繧ｿ繧､繝励↓蠢懊§縺溘い繧､繧ｳ繝ｳ繧貞叙蠕・
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

  /// 繧ｿ繧､繝励↓蠢懊§縺溯レ譎ｯ濶ｲ繧貞叙蠕・
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

/// SnackBar繝ｪ繧ｯ繧ｨ繧ｹ繝・
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

/// SnackBar繧ｿ繧､繝・
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

/// SnackBar蜆ｪ蜈亥ｺｦ
enum SnackBarPriority {
  low,
  normal,
  high,
}

/// BuildContext諡｡蠑ｵ
extension SnackBarExtension on BuildContext {
  /// SnackBar繝槭ロ繝ｼ繧ｸ繝｣繝ｼ縺ｫ繧｢繧ｯ繧ｻ繧ｹ
  SnackBarManager get snackBar => SnackBarManager();

  /// 謌仙粥繝｡繝・そ繝ｼ繧ｸ繧定｡ｨ遉ｺ
  void showSuccess(String message) {
    SnackBarManager().showSuccess(message);
  }

  /// 繧ｨ繝ｩ繝ｼ繝｡繝・そ繝ｼ繧ｸ繧定｡ｨ遉ｺ
  void showError(String message) {
    SnackBarManager().showError(message);
  }

  /// 隴ｦ蜻翫Γ繝・そ繝ｼ繧ｸ繧定｡ｨ遉ｺ
  void showWarning(String message) {
    SnackBarManager().showWarning(message);
  }

  /// 諠・ｱ繝｡繝・そ繝ｼ繧ｸ繧定｡ｨ遉ｺ
  void showInfo(String message) {
    SnackBarManager().showInfo(message);
  }
}
