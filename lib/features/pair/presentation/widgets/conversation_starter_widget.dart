import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// In a real app, this would be part of a service that fetches from a remote source.
final conversationPromptsProvider = Provider<List<String>>((ref) {
  return [
    '最近、ハマっていることは何ですか？',
    'このアプリで達成したい一番の目標は何ですか？',
    'どんな時にモチベーションが上がりますか？',
    '週末の理想的な過ごし方は？',
    '最近学んだことで、一番面白かったことは何？',
  ];
});

// A dummy provider simulating a chat service.
final chatServiceProvider = Provider((ref) => ChatService());

class ChatService {
  Future<void> sendMessage({
    required String pairId,
    required String text,
  }) async {
    // This is a placeholder for the actual chat sending logic.
    print("Sending message to pair '$pairId': $text");
    // In a real implementation, this would interact with Firestore or another chat backend.
  }
}

class ConversationStarterWidget extends ConsumerWidget {
  const ConversationStarterWidget({super.key, required this.pairId});

  final String pairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompts = ref.watch(conversationPromptsProvider);
    // Use a simple non-shuffling selection to keep the UI stable during rebuilds
    final prompt = prompts[DateTime.now().second % prompts.length];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('会話のきっかけ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(prompt),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  ref
                      .read(chatServiceProvider)
                      .sendMessage(pairId: pairId, text: prompt);
                  // Optionally, show a confirmation snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('メッセージを送信しました！')),
                  );
                },
                child: const Text('この話題で話す'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
