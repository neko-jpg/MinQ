import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/network/network_status_service.dart';

/// ネットワークスチE��タスの現在値
class NetworkStatusState {
  const NetworkStatusState({required this.status, this.lastChangedAt});

  final NetworkStatus status;
  final DateTime? lastChangedAt;

  bool get isOnline => status != NetworkStatus.offline;
  bool get isOffline => status == NetworkStatus.offline;
  bool get isWifi => status == NetworkStatus.wifi;
  bool get isMobile => status == NetworkStatus.mobile;

  NetworkStatusState copyWith({
    NetworkStatus? status,
    DateTime? lastChangedAt,
  }) {
    return NetworkStatusState(
      status: status ?? this.status,
      lastChangedAt: lastChangedAt ?? this.lastChangedAt,
    );
  }
}

class NetworkStatusNotifier extends StateNotifier<NetworkStatusState> {
  NetworkStatusNotifier(this._service)
    : super(
        NetworkStatusState(
          status: _service.currentStatus,
          lastChangedAt: DateTime.now(),
        ),
      ) {
    _init();
  }

  final NetworkStatusService _service;
  StreamSubscription<NetworkStatus>? _subscription;

  Future<void> _init() async {
    await _service.initialize();
    state = state.copyWith(
      status: _service.currentStatus,
      lastChangedAt: DateTime.now(),
    );
    _subscription = _service.statusStream.listen((NetworkStatus status) {
      state = state.copyWith(status: status, lastChangedAt: DateTime.now());
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final networkStatusServiceProvider = Provider<NetworkStatusService>((ref) {
  final service = NetworkStatusService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final networkStatusProvider =
    StateNotifierProvider<NetworkStatusNotifier, NetworkStatusState>((ref) {
      final service = ref.watch(networkStatusServiceProvider);
      return NetworkStatusNotifier(service);
    });
