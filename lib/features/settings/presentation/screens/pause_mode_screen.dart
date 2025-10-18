import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: This should be managed by a proper settings provider
final isPauseModeEnabledProvider = StateProvider<bool>((ref) => false);

class PauseModeScreen extends ConsumerWidget {
  const PauseModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaused = ref.watch(isPauseModeEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ポーズモード"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("ポーズモードを有効にする"),
              subtitle: const Text("有効にすると、全ての通知がオフになり、ストリークが維持されます。"),
              value: isPaused,
              onChanged: (bool value) {
                ref.read(isPauseModeEnabledProvider.notifier).state = value;
                // TODO: Persist the setting and update backend state.
              },
            ),
            const SizedBox(height: 24),
            if (isPaused)
              const Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "ポーズモードが有効です。ゆっくり休んで、準備ができたら戻ってきてくださいね。",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}