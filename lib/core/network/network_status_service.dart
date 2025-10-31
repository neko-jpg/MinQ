import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/logging/minq_logger.dart';

/// ネットワークステータスサービス
class NetworkStatusService extends StateNotifier<NetworkStatus> {
  NetworkStatusService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(NetworkStatus.online);

  final Connectivity _connectivity;
  StreamSubscription<dynamic>? _connectivitySubscription;

  /// ネットワークステータスのストリーム
  Stream<NetworkStatus> get statusStream => stream;

  /// 現在のネットワークステータス
  NetworkStatus get currentStatus => state;

  /// 初期化
  Future<void> initialize() async {
    await _connectivitySubscription?.cancel();

    await _checkConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateDynamicStatus);
  }

  /// 接続状態をチェック
  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateDynamicStatus(result);
  }

  void _updateDynamicStatus(dynamic rawResult) {
    final ConnectivityResult result;
    if (rawResult is ConnectivityResult) {
      result = rawResult;
    } else if (rawResult is List<ConnectivityResult>) {
      result = rawResult.isEmpty ? ConnectivityResult.none : rawResult.first;
    } else {
      result = ConnectivityResult.none;
    }

    _updateStatus(result);
  }

  /// ステータスを更新
  void _updateStatus(ConnectivityResult result) {
    final NetworkStatus newStatus;
    switch (result) {
      case ConnectivityResult.wifi:
        newStatus = NetworkStatus.wifi;
        break;
      case ConnectivityResult.mobile:
        newStatus = NetworkStatus.mobile;
        break;
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
        newStatus = NetworkStatus.online;
        break;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.other:
      case ConnectivityResult.none:
        newStatus = NetworkStatus.offline;
        break;
    }

    if (newStatus != state) {
      state = newStatus;
      MinqLogger.info(
        'Network status changed',
        metadata: {'status': newStatus.name},
      );
    }
  }

  /// オンラインかチェック
  bool get isOnline => state != NetworkStatus.offline;

  /// オフラインかチェック
  bool get isOffline => state == NetworkStatus.offline;

  /// WiFi接続かチェック
  bool get isWifi => state == NetworkStatus.wifi;

  /// モバイルデータ接続かチェック
  bool get isMobile => state == NetworkStatus.mobile;

  /// 破棄
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// ネットワークステータス
enum NetworkStatus {
  /// オンライン
  online,

  /// オフライン
  offline,

  /// WiFi接続
  wifi,

  /// モバイルデータ接続
  mobile,
}

/// Riverpod provider for network status service
final networkStatusServiceProvider = StateNotifierProvider<NetworkStatusService, NetworkStatus>(
  (ref) {
    final service = NetworkStatusService();
    service.initialize();
    return service;
  },
);

/// Convenience provider for checking if online
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(networkStatusServiceProvider);
  return status != NetworkStatus.offline;
});

/// Convenience provider for checking if offline
final isOfflineProvider = Provider<bool>((ref) {
  final status = ref.watch(networkStatusServiceProvider);
  return status == NetworkStatus.offline;
});