import 'package:flutter/foundation.dart';

/// Lightweight network facade that can be swapped with a real client.
class NetworkService {
  const NetworkService();

  Future<Map<String, dynamic>> get(String path) async {
    debugPrint('NetworkService.get ↁE$path (stubbed response)');
    return const {};
  }

  Future<bool> isConnected() async {
    return true;
  }

  Future<String> getConnectionType() async {
    return "unknown";
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    debugPrint('NetworkService.post ↁE$path (stubbed response)');
    return const {};
  }
}
