import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/local_preferences_service.dart';
import 'package:minq/domain/home/home_view_data.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/domain/recommendation/daily_focus_service.dart';

class HomeDataController extends AutoDisposeAsyncNotifier<HomeViewData> {
  @override
  Future<HomeViewData> build() async {
    final LocalPreferencesService localPrefs = ref.read(
      localPreferencesServiceProvider,
    );
    final HomeViewData? cached = await localPrefs.loadHomeViewData();
    if (cached != null) {
      state = AsyncData<HomeViewData>(cached);
    }

    final user = await ref.watch(localUserProvider.future);
    if (user == null) {
      return cached ?? HomeViewData.empty();
    }

    final questRepo = ref.read(questRepositoryProvider);
    final logRepo = ref.read(questLogRepositoryProvider);

    final List<Quest> quests = await questRepo.getQuestsForOwner(user.uid);
    final int streak = await logRepo.calculateStreak(user.uid);
    final int completionsToday = await logRepo.countLogsForDay(
      user.uid,
      DateTime.now(),
    );
    final List<QuestLog> logs = await logRepo.getLogsForUser(user.uid);

    final focusService = ref.read(dailyFocusServiceProvider);
    final DailyFocusRecommendation? focusRecommendation = focusService
        .recommend(quests: quests, logs: logs, now: DateTime.now());

    final HomeFocusRecommendation? focus =
        focusRecommendation == null
            ? null
            : HomeFocusRecommendation(
              questId: focusRecommendation.quest.id,
              questTitle: focusRecommendation.quest.title,
              confidence: focusRecommendation.confidence,
              headline: focusRecommendation.headline,
              rationale: focusRecommendation.rationale,
              supportingFacts: focusRecommendation.supportingFacts,
              lastCompletedAt: focusRecommendation.lastCompletedAt,
            );

    final HomeViewData fresh = HomeViewData(
      quests: quests
          .map(
            (Quest quest) => HomeQuestItem(
              id: quest.id,
              title: quest.title,
              category: quest.category,
              estimatedMinutes: quest.estimatedMinutes,
              iconKey: quest.iconKey,
            ),
          )
          .toList(growable: false),
      streak: streak,
      completionsToday: completionsToday,
      recentLogs: logs
          .take(20)
          .map(
            (QuestLog log) => HomeLogItem(
              id: log.id,
              questId: log.questId,
              timestamp: log.ts,
              proofType: log.proofType,
              proofValue: log.proofValue,
            ),
          )
          .toList(growable: false),
      updatedAt: DateTime.now(),
      focus: focus,
    );

    await localPrefs.saveHomeViewData(fresh);

    return fresh;
  }
}

final AutoDisposeAsyncNotifierProvider<HomeDataController, HomeViewData>
homeDataProvider =
    AutoDisposeAsyncNotifierProvider<HomeDataController, HomeViewData>(
      HomeDataController.new,
    );
