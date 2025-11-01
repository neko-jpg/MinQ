import 'package:minq/core/database/database_performance_monitor.dart';
import 'package:minq/data/repositories/quest_repository.dart';
import 'package:minq/domain/quest/quest.dart';

/// Enhanced quest repository with performance monitoring and memory management
class EnhancedQuestRepository extends QuestRepository
    with DatabasePerformanceTracking {
  EnhancedQuestRepository(super.isar);

  @override
  Future<List<Quest>> getAllQuests() {
    return trackOperation('quest_get_all', () => super.getAllQuests());
  }

  @override
  Future<List<Quest>> getTemplateQuests() {
    return trackOperation(
      'quest_get_templates',
      () => super.getTemplateQuests(),
    );
  }

  @override
  Future<List<Quest>> getQuestsForOwner(String owner) {
    return trackOperation(
      'quest_get_by_owner',
      () => super.getQuestsForOwner(owner),
    );
  }

  @override
  Future<Quest?> getQuestById(int id) {
    return trackOperation('quest_get_by_id', () => super.getQuestById(id));
  }

  Future<void> saveQuest(Quest quest) {
    return trackOperation('quest_save', () async {
      await isar.writeTxn(() async {
        await isar.quests.put(quest);
      });
    });
  }

  @override
  Future<void> deleteQuest(int id) {
    return trackOperation('quest_delete', () => super.deleteQuest(id));
  }

  @override
  Future<void> seedInitialQuests() {
    return trackOperation(
      'quest_seed_initial',
      () => super.seedInitialQuests(),
    );
  }

  /// Optimized batch operations
  Future<void> saveQuestsBatch(List<Quest> quests) {
    return trackOperation('quest_save_batch', () async {
      await isar.writeTxn(() async {
        await isar.quests.putAll(quests);
      });
    });
  }

  /// Clean up unused quests to free memory
  Future<int> cleanupUnusedQuests({
    Duration olderThan = const Duration(days: 365),
  }) {
    return trackOperation('quest_cleanup', () async {
      final cutoffDate = DateTime.now().subtract(olderThan);

      return await isar.writeTxn(() async {
        final unusedQuests =
            await isar.quests
                .filter()
                .createdAtLessThan(cutoffDate)
                .isTemplateEqualTo(false)
                .findAll();

        final idsToDelete = unusedQuests.map((q) => q.id).toList();
        await isar.quests.deleteAll(idsToDelete);

        return idsToDelete.length;
      });
    });
  }

  /// Get quest statistics for performance monitoring
  Future<QuestRepositoryStats> getStats() {
    return trackOperation('quest_get_stats', () async {
      final totalCount = await isar.quests.count();
      final templateCount =
          await isar.quests.filter().isTemplateEqualTo(true).count();
      final userQuestCount = totalCount - templateCount;

      return QuestRepositoryStats(
        totalQuests: totalCount,
        templateQuests: templateCount,
        userQuests: userQuestCount.toInt(),
      );
    });
  }
}

/// Quest repository statistics
class QuestRepositoryStats {
  final int totalQuests;
  final int templateQuests;
  final int userQuests;

  const QuestRepositoryStats({
    required this.totalQuests,
    required this.templateQuests,
    required this.userQuests,
  });

  @override
  String toString() {
    return 'QuestRepositoryStats(total: $totalQuests, templates: $templateQuests, user: $userQuests)';
  }
}
