import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuidedQuestCreationScreen extends ConsumerWidget {
  const GuidedQuestCreationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch quest templates from a service.
    final templates = [
      {'title': '運動', 'icon': Icons.directions_run},
      {'title': '勉強', 'icon': Icons.book},
      {'title': '健康', 'icon': Icons.favorite},
      {'title': '早起き', 'icon': Icons.wb_sunny},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("最初のクエストを作成しよう"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "どんな習慣を身につけたいですか？",
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
                        // TODO: Navigate to a pre-filled quest creation form.
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(template['icon'] as IconData, size: 48),
                          const SizedBox(height: 8),
                          Text(template['title'] as String),
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
                // TODO: Navigate to the regular, non-templated quest creation screen.
              },
              child: const Text("自分で作成する"),
            ),
          ],
        ),
      ),
    );
  }
}