import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/habit_dna/habit_dna_service.dart';
import 'package:minq/data/providers.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final questRecommendationsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final uid = ref.watch(uidProvider);
  if (uid == null) {
    return ['コップ1杯の水を飲む', '1分間、深呼吸する', '今日の感謝を1つ書き出す'];
  }

  final habitDnaService = ref.watch(habitDNAServiceProvider);
  final archetype = await habitDnaService.determineArchetype(uid);

  if (archetype == null) {
    return ['コップ1杯の水を飲む', '1分間、深呼吸する', '今日の感謝を1つ書き出す'];
  }

  // Return recommendations based on archetype
  switch (archetype.id) {
    case 'the_planner':
      return ['明日のタスクを3つ書き出す', '週末の計画を立てる', 'カバンの中を整理する'];
    case 'the_sprinter':
      return ['10分間だけ部屋を片付ける', '新しいレシピを試してみる', '5分間のHIITトレーニング'];
    case 'the_marathoner':
      return ['1ページだけ本を読む', '1分間だけ瞑想する', 'ストレッチを1つする'];
    case 'the_explorer':
      return ['近所を散歩して新しい発見をする', '聴いたことのないジャンルの音楽を聴く', '新しい単語を1つ覚える'];
    default:
      return ['コップ1杯の水を飲む'];
  }
});

final addQuestProvider = Provider((ref) {
  return (String questName) async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    final questId = _uuid.v4();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('quests')
        .doc(questId)
        .set({
          'id': questId,
          'name': questName,
          'completed': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
    // Invalidate to refresh quest lists if they are visible on the same screen
  };
});

class QuestRecommendationWidget extends ConsumerWidget {
  const QuestRecommendationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(questRecommendationsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('おすすめのミニクエスト', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            recommendationsAsync.when(
              data:
                  (recommendations) => Column(
                    children:
                        recommendations
                            .map(
                              (rec) => ListTile(
                                leading: const Icon(Icons.lightbulb_outline),
                                title: Text(rec),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  tooltip: 'クエストに追加',
                                  onPressed: () {
                                    ref.read(addQuestProvider)(rec);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('「$rec」をクエストに追加しました！'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Center(child: Text('おすすめの取得に失敗')),
            ),
          ],
        ),
      ),
    );
  }
}
