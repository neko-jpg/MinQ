import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechInputService {
  SpeechInputService(SpeechToText speechToText)
      : _speech = speechToText;

  final SpeechToText _speech;
  bool _initialised = false;

  Future<bool> ensureInitialized() async {
    if (_initialised) return true;
    _initialised = await _speech.initialize(
      debugLogging: false,
    );
    return _initialised;
  }

  bool get isListening => _speech.isListening;

  Future<void> startListening({
    required ValueChanged<String> onResult,
    VoidCallback? onFinalResult,
  }) async {
    await ensureInitialized();
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onFinalResult?.call();
        }
      },
      listenFor: const Duration(seconds: 40),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  Future<void> cancel() async {
    await _speech.cancel();
  }
}
