import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/features/home/presentation/screens/home_screen_v2.dart'; // for _userId
import 'package:shared_preferences/shared_preferences.dart';

const String _pauseModeKey = 'is_pause_mode_enabled';

class PauseModeNotifier extends StateNotifier<bool> {
  PauseModeNotifier() : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_pauseModeKey) ?? false;
  }

  Future<void> setPauseMode(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pauseModeKey, isEnabled);

    // Also update the backend state
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId) // Using dummy user ID
          .update({'isPaused': isEnabled});
    } catch (e) {
      debugPrint('Error updating backend pause state: $e');
      // Optionally, revert the local state if backend fails
      await prefs.setBool(_pauseModeKey, !isEnabled);
      state = !isEnabled;
      return;
    }

    state = isEnabled;
  }
}

final pauseModeProvider = StateNotifierProvider<PauseModeNotifier, bool>((ref) {
  return PauseModeNotifier();
});

class PauseModeScreen extends ConsumerWidget {
  const PauseModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaused = ref.watch(pauseModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ポーズモード')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('ポーズモードを有効にする'),
              subtitle: const Text('有効にすると、全ての通知がオフになり、ストリークが維持されます。'),
              value: isPaused,
              onChanged: (bool value) {
                ref.read(pauseModeProvider.notifier).setPauseMode(value);
              },
            ),
            const SizedBox(height: 24),
            if (isPaused)
              Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'ポーズモードが有効です。ゆっくり休んで、準備ができたら戻ってきてくださいね。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
