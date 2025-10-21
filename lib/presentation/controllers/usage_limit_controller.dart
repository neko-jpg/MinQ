import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart' show usageLimitServiceProvider;
import 'package:minq/data/services/usage_limit_service.dart';

class UsageLimitViewState {
  const UsageLimitViewState._(this.snapshot, this.isLoading);

  const UsageLimitViewState.loading() : this._(null, true);

  const UsageLimitViewState.ready(UsageLimitSnapshot snapshot)
    : this._(snapshot, false);

  final UsageLimitSnapshot? snapshot;
  final bool isLoading;

  bool get isBlocked => snapshot?.isBlocked ?? false;
  Duration? get dailyLimit => snapshot?.dailyLimit;
  Duration get usedToday => snapshot?.usedToday ?? Duration.zero;
  Duration get remaining => snapshot?.remaining ?? Duration.zero;
}

final usageLimitControllerProvider =
    StateNotifierProvider<UsageLimitController, UsageLimitViewState>((ref) {
      final service = ref.watch(usageLimitServiceProvider);
      return UsageLimitController(service);
    });

class UsageLimitController extends StateNotifier<UsageLimitViewState> {
  UsageLimitController(this._service)
    : super(const UsageLimitViewState.loading()) {
    _load();
  }

  final UsageLimitService _service;

  Future<void> _load() async {
    final snapshot = await _service.loadSnapshot();
    state = UsageLimitViewState.ready(snapshot);
  }

  Future<void> refresh() => _load();

  Future<void> setDailyLimit(Duration? limit) async {
    state = const UsageLimitViewState.loading();
    final snapshot = await _service.setDailyLimit(limit);
    state = UsageLimitViewState.ready(snapshot);
  }

  Future<void> recordUsage(Duration duration) async {
    final snapshot = await _service.recordUsage(duration);
    state = UsageLimitViewState.ready(snapshot);
  }
}
