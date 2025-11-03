import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/realtime/websocket_manager.dart';
import 'package:minq/presentation/providers/realtime_providers.dart';

/// リアルタイム接続状態表示ウィジェット
class ConnectionStatusWidget extends ConsumerWidget {
  final bool showWhenConnected;
  final EdgeInsetsGeometry? margin;

  const ConnectionStatusWidget({
    super.key,
    this.showWhenConnected = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(realtimeConnectionProvider);

    // 接続中で表示不要な場合は非表示
    if (connectionState.isConnected && !showWhenConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: _buildStatusCard(context, connectionState),
    );
  }

  Widget _buildStatusCard(BuildContext context, RealtimeConnectionState state) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String message;

    switch (state.status) {
      case WebSocketStatus.connected:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.wifi;
        message = 'リアルタイム通信中';
        break;

      case WebSocketStatus.connecting:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.wifi_find;
        message = '接続中...';
        break;

      case WebSocketStatus.reconnecting:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.refresh;
        message = '再接続中...';
        break;

      case WebSocketStatus.error:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.wifi_off;
        message = '接続エラー';
        break;

      case WebSocketStatus.disconnected:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.wifi_off;
        message = 'オフライン';
        break;
    }

    return Card(
      color: backgroundColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (state.status == WebSocketStatus.connecting ||
                state.status == WebSocketStatus.reconnecting) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// リアルタイム接続状態インジケーター（アプリバー用）
class ConnectionStatusIndicator extends ConsumerWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(realtimeConnectionProvider);

    if (connectionState.isConnected) {
      return const SizedBox.shrink();
    }

    Color color = Colors.grey;
    IconData icon = Icons.wifi_off;

    switch (connectionState.status) {
      case WebSocketStatus.connecting:
      case WebSocketStatus.reconnecting:
        color = Colors.orange;
        icon = Icons.refresh;
        break;

      case WebSocketStatus.error:
        color = Colors.red;
        icon = Icons.error_outline;
        break;

      case WebSocketStatus.disconnected:
        color = Colors.grey;
        icon = Icons.wifi_off;
        break;
      case WebSocketStatus.connected:
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

/// リアルタイム接続管理ボタン
class ConnectionControlButton extends ConsumerWidget {
  final String? userId;

  const ConnectionControlButton({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(realtimeConnectionProvider);
    final connectionNotifier = ref.read(realtimeConnectionProvider.notifier);

    return ElevatedButton.icon(
      onPressed:
          connectionState.isConnected
              ? () => connectionNotifier.disconnect()
              : userId != null
              ? () => connectionNotifier.connect(userId!)
              : null,
      icon: Icon(connectionState.isConnected ? Icons.wifi_off : Icons.wifi),
      label: Text(connectionState.isConnected ? '切断' : '接続'),
    );
  }
}
