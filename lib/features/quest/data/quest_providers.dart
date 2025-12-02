import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/providers/core_providers.dart';
import 'package:minq/data/repositories/quest_log_repository.dart';
import 'package:minq/data/repositories/quest_repository.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/domain/recommendation/daily_focus_service.dart';
import 'package:minq/features/auth/data/auth_providers.dart';

QuestRepository _buildQuestRepository(Ref ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) {
    throw StateError('Isar instance is not yet initialised');
  }
  return QuestRepository(isar);
}

QuestLogRepository _buildQuestLogRepository(Ref ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) {
    throw StateError('Isar instance is not yet initialised');
  }
  return QuestLogRepository(isar);
}

final questRepositoryProvider = Provider<QuestRepository>(
  _buildQuestRepository,
);
final questLogRepositoryProvider = Provider<QuestLogRepository>(
  _buildQuestLogRepository,
);

Future<void> _ensureStartup(Ref ref) async {
  // TODO: Replace with AppBootstrapService check
  // For now, we rely on the fact that if isar is ready, we are mostly good.
  // But strictly speaking we should wait for appStartupProvider.
  // However, appStartupProvider is in providers.dart which we are refactoring.
  // We will fix this circular dependency by moving appStartupProvider or using a different mechanism.
  // For now, let's assume if isar is ready, we can proceed for local data.
  await ref.watch(isarProvider.future);
}

final allQuestsProvider = FutureProvider<List<Quest>>((ref) async {
  await _ensureStartup(ref);
  return ref.read(questRepositoryProvider).getAllQuests();
});

final templateQuestsProvider = FutureProvider<List<Quest>>((ref) async {
  await _ensureStartup(ref);
  return ref.read(questRepositoryProvider).getTemplateQuests();
});

final userQuestsProvider = FutureProvider<List<Quest>>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return [];
  }
  return ref.read(questRepositoryProvider).getQuestsForOwner(user.uid);
});

final questByIdProvider = FutureProvider.family<Quest?, int>((ref, id) async {
  await _ensureStartup(ref);
  return ref.read(questRepositoryProvider).getQuestById(id);
});

final questContactLinkProvider = FutureProvider.family<String?, int>((
  ref,
  questId,
) async {
  return ref.watch(contactLinkRepositoryProvider).getLink(questId);
});

final streakProvider = FutureProvider<int>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return 0;
  }
  return ref.read(questLogRepositoryProvider).calculateStreak(user.uid);
});

final longestStreakProvider = FutureProvider<int>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return 0;
  }
  return ref.read(questLogRepositoryProvider).calculateLongestStreak(user.uid);
});

final todayCompletionCountProvider = FutureProvider<int>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return 0;
  }
  return ref
      .read(questLogRepositoryProvider)
      .countLogsForDay(user.uid, DateTime.now());
});

final allLogsProvider = FutureProvider<List<QuestLog>>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return [];
  }
  return ref.read(questLogRepositoryProvider).getLogsForUser(user.uid);
});

final recentLogsProvider = FutureProvider<List<QuestLog>>((ref) async {
  final logs = await ref.watch(allLogsProvider.future);
  return logs.take(30).toList();
});

final dailyFocusServiceProvider = Provider<DailyFocusService>(
  (ref) => DailyFocusService(),
);

final heatmapDataProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  await _ensureStartup(ref);
  final user = await ref.watch(localUserProvider.future);
  if (user == null) {
    return {};
  }
  return ref.read(questLogRepositoryProvider).getHeatmapData(user.uid);
});
