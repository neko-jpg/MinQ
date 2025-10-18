import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationStarterWidget extends ConsumerWidget {
  const ConversationStarterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch conversation starter prompts from a service.
    final prompts = [
      "最近、ハマっていることは何ですか？",
      "このアプリで達成したい一番の目標は何ですか？",
      "どんな時にモチベーションが上がりますか？",
    ];
    final prompt = (prompts..shuffle()).first;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "会話のきっかけ",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(prompt),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implement sending the prompt to the chat.
                },
                child: const Text("この話題で話す"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}