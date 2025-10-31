import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/core/realtime/realtime_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket接続状態
enum WebSocketStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// WebSocket管理システム
class WebSocketManager {
  static const String _baseUrl = 'wss://api.minq.app/ws';
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const int _maxReconnectAttempts = 5;

  final Logger _logger = Logger();
  final NetworkStatusService _networkService;

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  String? _userId;
  int _reconnectAttempts = 0;
  WebSocketStatus _status = WebSocketStatus.disconnected;

  final StreamController<RealtimeMessage> _messageController = 
      StreamController<RealtimeMessage>.broadcast();
  final StreamController<WebSocketStatus> _statusController = 
      StreamController<WebSocketStatus>.broadcast();

  /// メッセージストリーム
  Stream<RealtimeMessage> get messageStream => _messageController.stream;
  
  /// 接続状態ストリーム
  Stream<WebSocketStatus> get statusStream => _statusController.stream;
  
  /// 現在の接続状態
  WebSocketStatus get status => _status;
  
  /// 接続中かどうか
  bool get isConnected => _status == WebSocketStatus.connected;

  WebSocketManager(this._networkService) {
    // ネットワーク状態の監視
    _networkService.statusStream.listen((networkStatus) {
      if (networkStatus == NetworkStatus.online && 
          _status == WebSocketStatus.disconnected && 
          _userId != null) {
        connect(_userId!);
      } else if (networkStatus == NetworkStatus.offline) {
        _disconnect();
      }
    });
  }

  /// WebSocket接続を開始
  Future<void> connect(String userId) async {
    if (_status == WebSocketStatus.connecting || 
        _status == WebSocketStatus.connected) {
      return;
    }

    _userId = userId;
    _updateStatus(WebSocketStatus.connecting);

    try {
      final uri = Uri.parse('$_baseUrl?userId=$userId');
      _logger.i('Connecting to WebSocket: $uri');
      
      _channel = WebSocketChannel.connect(uri);
      
      // メッセージリスナーを設定
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
        cancelOnError: false,
      );

      // 接続成功
      _updateStatus(WebSocketStatus.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();
      
      _logger.i('WebSocket connected successfully');
      
    } catch (e) {
      _logger.e('Failed to connect WebSocket: $e');
      _updateStatus(WebSocketStatus.error);
      _scheduleReconnect();
    }
  }

  /// WebSocket接続を切断
  void disconnect() {
    _userId = null;
    _disconnect();
  }

  void _disconnect() {
    _stopHeartbeat();
    _stopReconnectTimer();
    
    _channel?.sink.close(status.goingAway);
    _channel = null;
    
    _updateStatus(WebSocketStatus.disconnected);
  }

  /// メッセージを送信
  void sendMessage(RealtimeMessage message) {
    if (!isConnected) {
      _logger.w('Cannot send message: WebSocket not connected');
      return;
    }

    try {
      final jsonData = json.encode(message.toJson());
      _channel!.sink.add(jsonData);
      _logger.d('Message sent: ${message.type}');
    } catch (e) {
      _logger.e('Failed to send message: $e');
    }
  }

  /// メッセージハンドラー
  void _handleMessage(dynamic data) {
    try {
      final Map<String, dynamic> jsonData = json.decode(data as String);
      final message = RealtimeMessage.fromJson(jsonData);
      
      _logger.d('Message received: ${message.type}');
      
      // ハートビート応答の処理
      if (message.type == MessageType.heartbeatResponse) {
        return;
      }
      
      _messageController.add(message);
    } catch (e) {
      _logger.e('Failed to parse message: $e');
    }
  }

  /// エラーハンドラー
  void _handleError(dynamic error) {
    _logger.e('WebSocket error: $error');
    _updateStatus(WebSocketStatus.error);
    _scheduleReconnect();
  }

  /// 切断ハンドラー
  void _handleDisconnection() {
    _logger.w('WebSocket disconnected');
    _updateStatus(WebSocketStatus.disconnected);
    _scheduleReconnect();
  }

  /// 再接続をスケジュール
  void _scheduleReconnect() {
    if (_userId == null || _reconnectAttempts >= _maxReconnectAttempts) {
      _logger.w('Max reconnect attempts reached or no user ID');
      return;
    }

    _stopReconnectTimer();
    _reconnectAttempts++;
    
    final delay = Duration(
      seconds: _reconnectDelay.inSeconds * _reconnectAttempts,
    );
    
    _logger.i('Scheduling reconnect in ${delay.inSeconds} seconds (attempt $_reconnectAttempts)');
    _updateStatus(WebSocketStatus.reconnecting);
    
    _reconnectTimer = Timer(delay, () {
      if (_userId != null) {
        connect(_userId!);
      }
    });
  }

  /// ハートビートを開始
  void _startHeartbeat() {
    _stopHeartbeat();
    
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (isConnected) {
        final heartbeat = RealtimeMessage.heartbeat();
        sendMessage(heartbeat);
      }
    });
  }

  /// ハートビートを停止
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 再接続タイマーを停止
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// 接続状態を更新
  void _updateStatus(WebSocketStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(_status);
    }
  }

  /// リソースを解放
  void dispose() {
    _disconnect();
    _messageController.close();
    _statusController.close();
  }
}