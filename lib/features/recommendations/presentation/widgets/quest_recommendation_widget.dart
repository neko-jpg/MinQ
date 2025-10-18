import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestRecommendationWidget extends ConsumerWidget {
  const QuestRecommendationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch quest recommendations from a service.
    final recommendations = [
      "寝る前に5分間ストレッチする",
      "コップ1杯の水を飲む",
      "今日の感謝を1つ書き出す",
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "おすすめのミニクエスト",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(rec),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: "クエストに追加",
                    onPressed: () {
                      // TODO: Implement adding the recommendation as a new quest.
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}