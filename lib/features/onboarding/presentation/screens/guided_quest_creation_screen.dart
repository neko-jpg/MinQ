import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// In a real app, this would be a service fetching from a remote source.
final questTemplatesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'title': '運動',
      'icon': Icons.directions_run_outlined,
      'default_quest': '10分間のウォーキング',
    },
    {'title': '勉強', 'icon': Icons.book_outlined, 'default_quest': '15分間、本を読む'},
    {
      'title': '健康',
      'icon': Icons.favorite_border,
      'default_quest': 'コップ1杯の水を飲む',
    },
    {
      'title': '早起き',
      'icon': Icons.wb_sunny_outlined,
      'default_quest': 'いつもより15分早く起きる',
    },
    {
      'title': '整理整頓',
      'icon': Icons.checkroom_outlined,
      'default_quest': '机の上を片付ける',
    },
    {
      'title': 'リラックス',
      'icon': Icons.self_improvement_outlined,
      'default_quest': '5分間瞑想する',
    },
  ];
});

class GuidedQuestCreationScreen extends ConsumerWidget {
  const GuidedQuestCreationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(questTemplatesProvider);

    void navigateToQuestForm({String? defaultQuest}) {
      // Assuming a route like '/create-quest' that can take an optional query parameter.
      final location =
          Uri(
            path: '/create-quest',
            queryParameters: {'template': defaultQuest},
          ).toString();
      context.go(location);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('最初のクエストを作成しよう')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'どんな習慣を身につけたいですか？',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return Card(
                    child: InkWell(
                      onTap: () {
                        navigateToQuestForm(
                          defaultQuest: template['default_quest'] as String,
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            template['icon'] as IconData,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            template['title'] as String,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                navigateToQuestForm();
              },
              child: const Text('自分で作成する'),
            ),
          ],
        ),
      ),
    );
  }
}
