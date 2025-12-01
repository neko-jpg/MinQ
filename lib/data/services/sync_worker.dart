import 'dart:async';

import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/data/services/connectivity_service.dart';

class SyncWorker {
  final ConnectivityService _connectivityService;
  final GamificationEngine _gamificationEngine;
  StreamSubscription? _subscription;

  SyncWorker(this._connectivityService, this._gamificationEngine);

  void initialize() {
    _subscription = _connectivityService.onStatusChanged.listen((status) {
      if (status == ConnectivityStatus.online) {
        MinqLogger.info('Network restored. Triggering sync...');
        _gamificationEngine.syncPendingTransactions();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
