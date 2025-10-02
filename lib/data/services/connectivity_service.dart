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

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<ConnectivityStatus> get onStatusChanged async* {
    final List<ConnectivityResult> initial = await _connectivity.checkConnectivity();
    yield _mapResult(initial.first);
    yield* _controller.stream;
  }

  Future<void> initialize() async {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _controller.add(_mapResult(result.first));
    });
  }

  Future<ConnectivityStatus> getCurrentStatus() async {
    final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    return _mapResult(result.first);
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