import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/local_preferences_service.dart';
import 'package:minq/domain/stats/stats_view_data.dart';

class StatsDataController extends AutoDisposeAsyncNotifier<StatsViewData> {
  @override
  Future<StatsViewData> build() async {
    final LocalPreferencesService localPrefs = ref.read(localPreferencesServiceProvider);
    final StatsViewData? cached = await localPrefs.loadStatsViewData();
    if (cached != null && mounted) {
      state = AsyncData<StatsViewData>(cached);
    }

    final user = await ref.watch(localUserProvider.future);
    if (user == null) {
      return cached ?? StatsViewData.empty();
    }

    final streak = await ref.read(questLogRepositoryProvider).calculateStreak(user.uid);
    final heatmap = await ref.read(questLogRepositoryProvider).getHeatmapData(user.uid);

    final StatsViewData fresh = StatsViewData(
      streak: streak,
      heatmap: heatmap,
      updatedAt: DateTime.now(),
    );

    await localPrefs.saveStatsViewData(fresh);
    return fresh;
  }
}

final AutoDisposeAsyncNotifierProvider<StatsDataController, StatsViewData> statsDataProvider =
    AutoDisposeAsyncNotifierProvider<StatsDataController, StatsViewData>(StatsDataController.new);
