import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/repositories/quest_repository.dart';
import 'package:minq/domain/quest/quest.dart';

// This is a placeholder. You'll need to replace this with your actual
// QuestRepository implementation.
final questRepositoryProvider = Provider<QuestRepository>((ref) {
  return QuestRepository();
});

final questByIdProvider = FutureProvider.family<Quest?, int>((ref, questId) async {
  final questRepository = ref.watch(questRepositoryProvider);
  return questRepository.getQuestById(questId);
});

final userQuestsProvider = FutureProvider<List<Quest>>((ref) async {
  final questRepository = ref.watch(questRepositoryProvider);
  // You'll need to implement a method to get the current user's ID
  // and pass it to the repository.
  return questRepository.getAllQuests();
});

final habitAiSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  // This is a placeholder. You'll need to replace this with your actual
  // AI suggestions implementation.
  return Future.value([]);
});

final templateQuestsProvider = FutureProvider<List<Quest>>((ref) async {
  // This is a placeholder. You'll need to replace this with your actual
  // template quests implementation.
  return Future.value([]);
});
