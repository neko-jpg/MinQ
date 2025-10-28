import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/features/home/presentation/screens/home_screen_v2.dart';
import 'package:speech_to_text/speech_to_text.dart';

// Provider for the speech_to_text instance
final speechToTextProvider = Provider<SpeechToText>((ref) => SpeechToText());

final voiceQuestCompleterProvider = Provider.autoDispose((ref) {
  final userId = ref.watch(userIdProvider);
  return (String recognizedText) async {
    // Simple parsing: assumes format " [Quest Name] を完了"
    const keyword = 'を完了';
    if (!recognizedText.contains(keyword)) return false;

    final questName = recognizedText.split(keyword).first.trim();
    if (questName.isEmpty) return false;

    // Find the quest
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId) // Using the dummy user ID from home_screen_v2
            .collection('quests')
            .where('name', isEqualTo: questName)
            .where('completed', isEqualTo: false)
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: startOfDay,
              isLessThanOrEqualTo: endOfDay,
            )
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final questId = snapshot.docs.first.id;
      // Use the existing completion logic from home_screen_v2
      await ref.read(questCompletionProvider)(questId, questName);
      return true;
    }
    MinqLogger.debug("Quest '$questName' not found or already completed.");
    return false;
  };
});

class VoiceInputWidget extends ConsumerStatefulWidget {
  const VoiceInputWidget({super.key});

  @override
  ConsumerState<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends ConsumerState<VoiceInputWidget> {
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    // Initialize speech recognition early if needed, or just before listening.
  }

  void _listen() async {
    final speech = ref.read(speechToTextProvider);
    if (!_isListening) {
      bool available = await speech.initialize(
        onStatus: (val) => MinqLogger.debug('onStatus: $val'),
        onError: (val) => MinqLogger.error('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        speech.listen(
          onResult: (val) => setState(() => _lastWords = val.recognizedWords),
        );
      } else {
        MinqLogger.info('The user has denied the use of speech recognition.');
      }
    } else {
      setState(() => _isListening = false);
      speech.stop();
      if (_lastWords.isNotEmpty) {
        final success = await ref.read(voiceQuestCompleterProvider)(_lastWords);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? "'$_lastWords' を完了しました！" : 'クエストが見つかりませんでした。',
              ),
            ),
          );
        }
        setState(() {
          _lastWords = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _listen,
      tooltip: 'クエストを音声で記録',
      child: Icon(_isListening ? Icons.mic : Icons.mic_none),
    );
  }
}
