import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus {
  online,
  offline,
}

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  final StreamController<ConnectivityStatus> _controller =
      StreamController<ConnectivityStatus>.broadcast();

  StreamSubscription<ConnectivityResult>? _subscription;

  Stream<ConnectivityStatus> get onStatusChanged async* {
    final ConnectivityResult initial = await _connectivity.checkConnectivity();
    yield _mapResult(initial);
    yield* _controller.stream;
  }

  Future<void> initialize() async {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _controller.add(_mapResult(result));
    });
  }

  Future<ConnectivityStatus> getCurrentStatus() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return _mapResult(result);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }

  ConnectivityStatus _mapResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
        return ConnectivityStatus.online;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.other:
      case ConnectivityResult.none:
        return ConnectivityStatus.offline;
    }
  }
}
