import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

// Provider for the speech_to_text instance
final speechToTextProvider = Provider<SpeechToText>((ref) => SpeechToText());

class VoiceInputWidget extends ConsumerStatefulWidget {
  const VoiceInputWidget({super.key});

  @override
  ConsumerState<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends ConsumerState<VoiceInputWidget> {
  bool _isListening = false;

  void _listen() async {
    final speech = ref.read(speechToTextProvider);
    if (!_isListening) {
      bool available = await speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        speech.listen(
          onResult: (val) {
            // TODO: Parse the result text and complete the corresponding quest.
            print('onResult: ${val.recognizedWords}');
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      speech.stop();
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