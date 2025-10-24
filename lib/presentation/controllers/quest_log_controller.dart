import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/log/quest_log.dart';

class QuestLogController extends StateNotifier<AsyncValue<void>> {
  QuestLogController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> undoLog(int logId) async {
    state = const AsyncValue.loading();

    try {
      final logRepository = _ref.read(questLogRepositoryProvider);
      final log = await logRepository.getLogById(logId);

      if (log == null) {
        state = AsyncValue.error('ログが見つかりませんでした', StackTrace.current);
        return false;
      }

      // Check if the log is from today (allow undo only for today's logs)
      final now = DateTime.now();
      final logDate = log.ts.toLocal();
      final today = DateTime(now.year, now.month, now.day);
      final logDay = DateTime(logDate.year, logDate.month, logDate.day);

      if (!logDay.isAtSameMomentAs(today)) {
        state = AsyncValue.error('今日のログのみ取り消しできます', StackTrace.current);
        return false;
      }

      await logRepository.deleteLog(logId);

      // Update streak and other stats
      final uid = _ref.read(uidProvider);
      if (uid != null) {
        final userRepository = _ref.read(userRepositoryProvider);
        final currentStreak = await logRepository.calculateStreak(uid);
        final longestStreak = await logRepository.calculateLongestStreak(uid);

        await userRepository.updateStreaks(
          uid,
          currentStreak: currentStreak,
          longestStreak: longestStreak,
        );
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('Failed to undo log: $e');
      return false;
    }
  }

  Future<bool> recordProgress(int questId, {String? proofValue, ProofType proofType = ProofType.check}) async {
    state = const AsyncValue.loading();

    try {
      final uid = _ref.read(uidProvider);
      if (uid == null) {
        state = AsyncValue.error('ユーザーがサインインしていません', StackTrace.current);
        return false;
      }

      // Check if already recorded today
      final logRepository = _ref.read(questLogRepositoryProvider);
      final todayLogs = await logRepository.getLogsForDay(uid, DateTime.now());
      final alreadyRecorded = todayLogs.any((log) => log.questId == questId);

      if (alreadyRecorded) {
        state = AsyncValue.error('今日はすでに記録済みです', StackTrace.current);
        return false;
      }

      final log = QuestLog()
        ..uid = uid
        ..questId = questId
        ..ts = DateTime.now().toUtc()
        ..proofType = proofType
        ..proofValue = proofValue ?? ''
        ..synced = false;

      await logRepository.addLog(log);

      // Update streak and other stats
      final userRepository = _ref.read(userRepositoryProvider);
      final currentStreak = await logRepository.calculateStreak(uid);
      final longestStreak = await logRepository.calculateLongestStreak(uid);

      await userRepository.updateStreaks(
        uid,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
      );

      // ゲーミフィケーション: ポイント付与とバッジチェック
      try {
        final gamificationEngine = _ref.read(gamificationEngineProvider);

        // クエスト完了でポイント付与
        await gamificationEngine.awardPoints(
          userId: uid,
          basePoints: 50, // 基本ポイント
          reason: 'クエスト完了',
        );

        // ストリークボーナス
        if (currentStreak >= 7) {
          await gamificationEngine.awardPoints(
            userId: uid,
            basePoints: currentStreak * 10,
            reason: '$currentStreak日連続達成ボーナス',
          );
        }

        // バッジ獲得チェック
        final newBadges = await gamificationEngine.checkAndAwardBadges(uid);

        // ランク計算
        await gamificationEngine.calculateRank(uid);

        // 新しいバッジがあれば通知を表示
        if (newBadges.isNotEmpty) {
          // 最初のバッジのみ表示（複数ある場合は順次表示）
          final badge = newBadges.first;
          // バッジ通知は呼び出し元で表示する
          debugPrint('New badge earned: ${badge.name}');
        }

        debugPrint('Gamification: Awarded points and checked badges. New badges: ${newBadges.length}');
      } catch (e) {
        debugPrint('Gamification error: $e');
        // ゲーミフィケーションエラーでもクエスト記録は成功とする
      }

      // Cancel auxiliary reminder if daily goal is reached
      final completedToday = await logRepository.countLogsForDay(uid, DateTime.now());
      if (completedToday >= 3) {
        final notificationService = _ref.read(notificationServiceProvider);
        await notificationService.cancelAuxiliaryReminder();
      }

      final questRepository = _ref.read(questRepositoryProvider);
      final quest = await questRepository.getQuestById(questId);
      if (quest != null) {
        unawaited(
          _ref.read(webhookDispatchServiceProvider).dispatchQuestCompletion(
                quest: quest,
                log: log,
              ),
        );

        // TODO: Implement live activity, wearable sync, and fitness sync
        // final prefs = _ref.read(localPreferencesServiceProvider);
        // if (await prefs.isLiveActivityEnabled()) {
        //   final liveActivityService = _ref.read(liveActivityServiceProvider);
        //   await liveActivityService.startForQuest(
        //     questId: quest.id.toString(),
        //     title: quest.title,
        //     completed: 1,
        //     total: 1,
        //   );
        //   await liveActivityService.endForQuest(quest.id.toString());
        // }

        // if (await prefs.isWearableSyncEnabled()) {
        //   final wearableService = _ref.read(wearableSyncServiceProvider);
        //   final quests = await questRepository.getAllQuests();
        //   await wearableService.syncQuests(userId: uid, quests: quests);
        // }

        // if (await prefs.isFitnessAutoLoggingEnabled()) {
        //   final fitnessService = _ref.read(fitnessSyncServiceProvider);
        //   final snapshot = await fitnessService.fetchDailySteps(DateTime.now());
        //   await fitnessService.syncHabit(
        //     habitId: questId.toString(),
        //     completionDate: DateTime.now(),
        //     steps: snapshot.steps,
        //   );
        // }
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('Failed to record progress: $e');
      return false;
    }
  }

  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}

final questLogControllerProvider = StateNotifierProvider<QuestLogController, AsyncValue<void>>((ref) {
  return QuestLogController(ref);
});

// Provider for today's logs
final todayLogsProvider = FutureProvider<List<QuestLog>>((ref) async {
  final uid = ref.watch(uidProvider);
  if (uid == null) return [];

  final logRepository = ref.watch(questLogRepositoryProvider);
  return logRepository.getLogsForDay(uid, DateTime.now());
});

// Provider for checking if a quest is completed today
final questCompletedTodayProvider = FutureProvider.family<bool, int>((ref, questId) async {
  final todayLogs = await ref.watch(todayLogsProvider.future);
  return todayLogs.any((log) => log.questId == questId);
});