import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/crash_recovery_store.dart';

class CrashRecoveryState {
  const CrashRecoveryState({
    required this.needsRecovery,
    this.report,
    this.isRestoring = false,
  });

  final bool needsRecovery;
  final CrashReport? report;
  final bool isRestoring;

  CrashRecoveryState copyWith({
    bool? needsRecovery,
    CrashReport? report,
    bool? isRestoring,
    bool clearReport = false,
  }) {
    return CrashRecoveryState(
      needsRecovery: needsRecovery ?? this.needsRecovery,
      report: clearReport ? null : (report ?? this.report),
      isRestoring: isRestoring ?? this.isRestoring,
    );
  }

  static CrashRecoveryState initial() => const CrashRecoveryState(needsRecovery: false);
}

class CrashRecoveryController extends StateNotifier<CrashRecoveryState> {
  CrashRecoveryController(this.ref)
      : _store = ref.read(crashRecoveryStoreProvider),
        super(CrashRecoveryState.initial()) {
    final CrashReport? report = _store.pendingReport;
    if (report != null) {
      state = CrashRecoveryState(needsRecovery: true, report: report);
    }
  }

  final Ref ref;
  final CrashRecoveryStore _store;

  Future<void> discardRecovery() async {
    await _store.clear();
    state = CrashRecoveryState.initial();
  }

  Future<void> restoreAndResume() async {
    if (!state.needsRecovery) return;
    state = state.copyWith(isRestoring: true);
    await _store.clear();
    state = CrashRecoveryState.initial();
    ref.invalidate(appStartupProvider);
  }
}

final StateNotifierProvider<CrashRecoveryController, CrashRecoveryState>
    crashRecoveryControllerProvider =
    StateNotifierProvider<CrashRecoveryController, CrashRecoveryState>(CrashRecoveryController.new);
