import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/network/network_status_provider.dart';
import 'package:minq/core/notifications/advanced_notification_service.dart';
import 'package:minq/core/realtime/realtime_message.dart';
import 'package:minq/core/realtime/realtime_service.dart';
import 'package:minq/core/realtime/websocket_manager.dart';

import 'package:minq/data/providers.dart';

/// WebSocketマネージャープロバイダー
final webSocketManagerProvider = Provider<WebSocketManager>((ref) {
  final networkService = ref.watch(networkStatusServiceProvider);
  return WebSocketManager(networkService);
});

/// リアルタイムサービスプロバイダー
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final webSocketManager = ref.watch(webSocketManagerProvider);
  final notificationService = ref.watch(advancedNotificationServiceProvider);

  final service =
      RealtimeService(webSocketManager, notificationService);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// WebSocket接続状態プロバイダー
final webSocketStatusProvider = StreamProvider<WebSocketStatus>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.connectionStatusStream;
});

/// ペアメッセージストリームプロバイダー
final pairMessageStreamProvider = StreamProvider<RealtimeMessage>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.pairMessageStream;
});

/// 進捗共有ストリームプロバイダー
final progressShareStreamProvider = StreamProvider<RealtimeMessage>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.progressShareStream;
});

/// ゲーミフィケーションストリームプロバイダー
final gamificationStreamProvider = StreamProvider<RealtimeMessage>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.gamificationStream;
});

/// 通知ストリームプロバイダー
final notificationStreamProvider = StreamProvider<RealtimeMessage>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.notificationStream;
});

/// リアルタイム接続管理プロバイダー
final realtimeConnectionProvider =
    StateNotifierProvider<RealtimeConnectionNotifier, RealtimeConnectionState>((
      ref,
    ) {
      final realtimeService = ref.watch(realtimeServiceProvider);
      return RealtimeConnectionNotifier(realtimeService);
    });

/// リアルタイム接続状態
class RealtimeConnectionState {
  final bool isConnected;
  final String? userId;
  final WebSocketStatus status;
  final String? errorMessage;

  const RealtimeConnectionState({
    required this.isConnected,
    this.userId,
    required this.status,
    this.errorMessage,
  });

  RealtimeConnectionState copyWith({
    bool? isConnected,
    String? userId,
    WebSocketStatus? status,
    String? errorMessage,
  }) {
    return RealtimeConnectionState(
      isConnected: isConnected ?? this.isConnected,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// リアルタイム接続管理ノーティファイアー
class RealtimeConnectionNotifier
    extends StateNotifier<RealtimeConnectionState> {
  final RealtimeService _realtimeService;

  RealtimeConnectionNotifier(this._realtimeService)
    : super(
        const RealtimeConnectionState(
          isConnected: false,
          status: WebSocketStatus.disconnected,
        ),
      ) {
    _initializeStatusListener();
  }

  /// 接続状態リスナーを初期化
  void _initializeStatusListener() {
    _realtimeService.connectionStatusStream.listen((status) {
      state = state.copyWith(
        status: status,
        isConnected: status == WebSocketStatus.connected,
        errorMessage:
            status == WebSocketStatus.error ? 'Connection error' : null,
      );
    });
  }

  /// 接続を開始
  Future<void> connect(String userId) async {
    try {
      await _realtimeService.connect(userId);
      state = state.copyWith(userId: userId, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 接続を切断
  void disconnect() {
    _realtimeService.disconnect();
    state = state.copyWith(
      userId: null,
      isConnected: false,
      status: WebSocketStatus.disconnected,
      errorMessage: null,
    );
  }

  /// ペアメッセージを送信
  void sendPairMessage({
    required String messageId,
    required String senderId,
    required String recipientId,
    required String text,
    String? imageUrl,
  }) {
    _realtimeService.sendPairMessage(
      messageId: messageId,
      senderId: senderId,
      recipientId: recipientId,
      text: text,
      imageUrl: imageUrl,
    );
  }

  /// 進捗共有を送信
  void sendProgressShare({
    required String senderId,
    required String recipientId,
    required String shareId,
    required String title,
    required String description,
    int? score,
    List<String>? tags,
  }) {
    _realtimeService.sendProgressShare(
      senderId: senderId,
      recipientId: recipientId,
      shareId: shareId,
      title: title,
      description: description,
      score: score,
      tags: tags,
    );
  }

  /// 励ましメッセージを送信
  void sendEncouragement({
    required String senderId,
    required String recipientId,
    required String message,
    String? questId,
  }) {
    _realtimeService.sendEncouragement(
      senderId: senderId,
      recipientId: recipientId,
      message: message,
      questId: questId,
    );
  }
}
