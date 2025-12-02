import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/data/services/connectivity_service.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(connectivityServiceProvider)
      .onStatusChanged
      .map((status) => status == ConnectivityStatus.online);
});

final networkStatusProvider = Provider<NetworkStatusService>((ref) {
  return NetworkStatusService();
});
