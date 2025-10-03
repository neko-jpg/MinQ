import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/desktop_menu_bar_service.dart';
import 'package:minq/data/services/fitness_sync_service.dart';
import 'package:minq/data/services/live_activity_service.dart';
import 'package:minq/data/services/wearable_sync_service.dart';

class _AsyncToggleController extends StateNotifier<AsyncValue<bool>> {
  _AsyncToggleController(this._load, this._persist) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final Future<bool> Function() _load;
  final Future<void> Function(bool value) _persist;

  Future<void> _initialize() async {
    try {
      final enabled = await _load();
      state = AsyncValue.data(enabled);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggle(bool value) async {
    state = AsyncValue.data(value);
    try {
      await _persist(value);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      debugPrint('Failed to persist toggle: $error');
    }
  }
}

final liveActivityToggleProvider =
    StateNotifierProvider<_AsyncToggleController, AsyncValue<bool>>((ref) {
  final prefs = ref.watch(localPreferencesServiceProvider);
  final service = ref.watch(liveActivityServiceProvider);
  return _AsyncToggleController(
    () => prefs.isLiveActivityEnabled(),
    (value) async {
      await prefs.setLiveActivityEnabled(value);
      if (!value) {
        await service.endForQuest('all');
      }
    },
  );
});

final wearableSyncToggleProvider =
    StateNotifierProvider<_AsyncToggleController, AsyncValue<bool>>((ref) {
  final prefs = ref.watch(localPreferencesServiceProvider);
  final service = ref.watch(wearableSyncServiceProvider);
  return _AsyncToggleController(
    () => prefs.isWearableSyncEnabled(),
    (value) async {
      await prefs.setWearableSyncEnabled(value);
      if (value) {
        final userId = ref.read(uidProvider);
        if (userId != null) {
          final quests = await ref.read(questRepositoryProvider).getAllQuests();
          await service.syncQuests(userId: userId, quests: quests);
        }
      }
    },
  );
});

final fitnessSyncToggleProvider =
    StateNotifierProvider<_AsyncToggleController, AsyncValue<bool>>((ref) {
  final prefs = ref.watch(localPreferencesServiceProvider);
  final service = ref.watch(fitnessSyncServiceProvider);
  return _AsyncToggleController(
    () => prefs.isFitnessAutoLoggingEnabled(),
    (value) async {
      await prefs.setFitnessAutoLoggingEnabled(value);
      if (value) {
        final today = DateTime.now();
        final snapshot = await service.fetchDailySteps(today);
        debugPrint('Fetched ${snapshot.steps} steps for auto logging');
      }
    },
  );
});

final menuBarTimerToggleProvider =
    StateNotifierProvider<_AsyncToggleController, AsyncValue<bool>>((ref) {
  final prefs = ref.watch(localPreferencesServiceProvider);
  final service = ref.watch(desktopMenuBarServiceProvider);
  return _AsyncToggleController(
    () => prefs.isMenuBarTimerEnabled(),
    (value) async {
      await prefs.setMenuBarTimerEnabled(value);
      if (!value) {
        await service.clear();
      } else {
        await service.updateTimer(title: '次の集中タイム', remaining: const Duration(minutes: 25));
      }
    },
  );
});
