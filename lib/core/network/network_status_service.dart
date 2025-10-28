import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:minq/data/logging/minq_logger.dart';

/// ネットワークステータスサービス
class NetworkStatusService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();

  NetworkStatus _currentStatus = NetworkStatus.online;

  /// ネットワークステータスのストリーム
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  /// 現在のネットワークステータス
  NetworkStatus get currentStatus => _currentStatus;

  /// 初期化
  Future<void> initialize() async {
    // 初期状態をチェック
    await _checkConnectivity();

    // 接続状態の変化を監視
    _connectivity.onConnectivityChanged.listen((result) {
      _updateStatus(result);
    });
  }

  /// 接続状態をチェック
  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  /// ステータスを更新
  void _updateStatus(List<ConnectivityResult> results) {
    final result = results.firstOrNull ?? ConnectivityResult.none;

    NetworkStatus newStatus;
    if (result == ConnectivityResult.none) {
      newStatus = NetworkStatus.offline;
    } else if (result == ConnectivityResult.mobile) {
      newStatus = NetworkStatus.mobile;
    } else if (result == ConnectivityResult.wifi) {
      newStatus = NetworkStatus.wifi;
    } else {
      newStatus = NetworkStatus.online;
    }

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
      MinqLogger.info(
        'Network status changed',
        metadata: {'status': newStatus.name},
      );
    }
  }

  /// オンラインかチェック
  bool get isOnline => _currentStatus != NetworkStatus.offline;

  /// オフラインかチェック
  bool get isOffline => _currentStatus == NetworkStatus.offline;

  /// WiFi接続かチェック
  bool get isWifi => _currentStatus == NetworkStatus.wifi;

  /// モバイルデータ接続かチェック
  bool get isMobile => _currentStatus == NetworkStatus.mobile;

  /// 破棄
  void dispose() {
    _statusController.close();
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
