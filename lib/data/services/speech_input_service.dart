import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

class SpeechInputService {
  SpeechInputService(SpeechToText speechToText)
      : _speech = SpeechToTextProvider(speechToText: speechToText);

  final SpeechToTextProvider _speech;
  bool _initialised = false;

  Future<bool> ensureInitialized() async {
    if (_initialised) return true;
    _initialised = await _speech.initialize(
      debugLogging: false,
      onError: (SpeechRecognitionError error) {},
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
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onFinalResult?.call();
        }
      },
      listenFor: const Duration(seconds: 40),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      localeId: _speech.localeId,
    );
  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();
}
