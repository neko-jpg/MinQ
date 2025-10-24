import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/local_preferences_service.dart';
import 'package:minq/domain/stats/stats_view_data.dart';

class StatsDataController extends AutoDisposeAsyncNotifier<StatsViewData> {
  @override
  Future<StatsViewData> build() async {
    final LocalPreferencesService localPrefs = ref.read(localPreferencesServiceProvider);
    final StatsViewData? cached = await localPrefs.loadStatsViewData();
    if (cached != null) {
      state = AsyncData<StatsViewData>(cached);
    }

    final user = await ref.watch(localUserProvider.future);
    if (user == null) {
      return cached ?? StatsViewData.empty();
    }

    final logRepo = ref.read(questLogRepositoryProvider);
    final streak = await logRepo.calculateStreak(user.uid);
    final heatmap = await logRepo.getHeatmapData(user.uid);
    final weeklyCompletionRate = await logRepo.calculateWeeklyCompletionRate(user.uid);
    final todayCompletionCount = await logRepo.countLogsForDay(user.uid, DateTime.now());

    final StatsViewData fresh = StatsViewData(
      streak: streak,
      heatmap: heatmap,
      updatedAt: DateTime.now(),
      weeklyCompletionRate: weeklyCompletionRate,
      todayCompletionCount: todayCompletionCount,
    );

    await localPrefs.saveStatsViewData(fresh);
    return fresh;
  }
}

final AutoDisposeAsyncNotifierProvider<StatsDataController, StatsViewData> statsDataProvider =
    AutoDisposeAsyncNotifierProvider<StatsDataController, StatsViewData>(StatsDataController.new);
