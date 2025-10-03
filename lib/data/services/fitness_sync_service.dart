import 'package:minq/data/providers.dart';
import 'package:minq/domain/health/daily_steps_snapshot.dart';
// TODO: Fix integrations package
// import 'package:miinq_integrations/miinq_integrations.dart';
import 'package:riverpod/riverpod.dart';

// Dummy type until integrations package is fixed
class FitnessBridge {
  const FitnessBridge();
  Future<bool> isAvailable() async => false;
  Future<int> fetchDailySteps(DateTime day) async => 0;
  Future<void> syncHabitCompletion({required String habitId, required DateTime completionDate, required int steps}) async {}
}

class FitnessSyncService {
  FitnessSyncService({required FitnessBridge bridge}) : _bridge = bridge;

  final FitnessBridge _bridge;

  Future<bool> isAvailable() => _bridge.isAvailable();

  Future<DailyStepsSnapshot> fetchDailySteps(DateTime day) async {
    final steps = await _bridge.fetchDailySteps(day);
    return DailyStepsSnapshot(date: day, steps: steps);
  }

  Future<void> syncHabit({
    required String habitId,
    required DateTime completionDate,
    required int steps,
  }) async {
    await _bridge.syncHabitCompletion(
      habitId: habitId,
      completionDate: completionDate,
      steps: steps,
    );
  }
}

final fitnessBridgeProvider = Provider<FitnessBridge>((ref) {
  return FitnessBridge();
});

final fitnessSyncServiceProvider = Provider<FitnessSyncService>((ref) {
  return FitnessSyncService(
    bridge: ref.watch(fitnessBridgeProvider),
  );
});
