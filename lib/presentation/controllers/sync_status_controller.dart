import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/connectivity_service.dart';

enum SyncPhase { idle, online, offline, syncing, synced, error }

class SyncStatus {
  const SyncStatus({
    this.phase = SyncPhase.idle,
    this.bannerMessage,
    this.showBanner = false,
    this.lastSyncedAt,
  });

  final SyncPhase phase;
  final String? bannerMessage;
  final bool showBanner;
  final DateTime? lastSyncedAt;

  SyncStatus copyWith({
    SyncPhase? phase,
    String? bannerMessage,
    bool? showBanner,
    DateTime? lastSyncedAt,
    bool clearBanner = false,
  }) {
    return SyncStatus(
      phase: phase ?? this.phase,
      bannerMessage: clearBanner ? null : (bannerMessage ?? this.bannerMessage),
      showBanner: showBanner ?? this.showBanner,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  SyncStatusNotifier(this.ref)
    : _connectivityService = ref.read(connectivityServiceProvider),
      super(const SyncStatus()) {
    _init();
  }

  final Ref ref;
  final ConnectivityService _connectivityService;

  StreamSubscription<ConnectivityStatus>? _subscription;
  bool _wasOffline = false;

  Future<void> _init() async {
    await _connectivityService.initialize();
    final ConnectivityStatus status =
        await _connectivityService.getCurrentStatus();
    if (status == ConnectivityStatus.offline) {
      _wasOffline = true;
      state = state.copyWith(phase: SyncPhase.offline);
    } else {
      state = state.copyWith(phase: SyncPhase.online);
    }

    _subscription = _connectivityService.onStatusChanged.listen(_handleStatus);
  }

  Future<void> _handleStatus(ConnectivityStatus status) async {
    if (status == ConnectivityStatus.offline) {
      _wasOffline = true;
      state = state.copyWith(phase: SyncPhase.offline);
      return;
    }

    if (!_wasOffline) {
      state = state.copyWith(phase: SyncPhase.online);
      return;
    }

    _wasOffline = false;
    state = state.copyWith(phase: SyncPhase.syncing);

    final String? uid = ref.read(uidProvider);
    if (uid == null) {
      state = state.copyWith(
        phase: SyncPhase.synced,
        bannerMessage: '接続が回復しました',
        showBanner: true,
        lastSyncedAt: DateTime.now(),
      );
      return;
    }

    final logRepository = ref.read(questLogRepositoryProvider);
    final bool hasPending = await logRepository.hasUnsyncedLogs(uid);
    final syncService = ref.read(firestoreSyncServiceProvider);

    if (!hasPending || syncService == null) {
      state = state.copyWith(
        phase: SyncPhase.synced,
        bannerMessage: '接続が回復しました',
        showBanner: true,
        lastSyncedAt: DateTime.now(),
      );
      return;
    }

    try {
      await syncService.syncQuestLogs(uid);
      state = state.copyWith(
        phase: SyncPhase.synced,
        bannerMessage: '同期が完了しました',
        showBanner: true,
        lastSyncedAt: DateTime.now(),
      );
    } catch (_) {
      state = state.copyWith(
        phase: SyncPhase.error,
        bannerMessage: 'データの同期に失敗しました',
        showBanner: true,
      );
    }
  }

  void acknowledgeBanner() {
    if (!state.showBanner) return;
    state = state.copyWith(
      phase: state.phase,
      showBanner: false,
      clearBanner: true,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }
}

final StateNotifierProvider<SyncStatusNotifier, SyncStatus> syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatus>(
      SyncStatusNotifier.new,
    );
