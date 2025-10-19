import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/network/network_status_service.dart';

final networkStatusProvider = Provider<NetworkStatusService>((ref) {
  return NetworkStatusService();
});