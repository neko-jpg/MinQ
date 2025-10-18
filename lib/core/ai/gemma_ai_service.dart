import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Provider for the service
final gemmaAIServiceProvider = Provider<GemmaAIService>((ref) {
  return GemmaAIService();
});

class GemmaAIService {
  late FlutterGemma _gemma;
  bool _isInitialized = false;

  GemmaAIService() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // For now, we assume the model is bundled. A real app might download it.
      _gemma = FlutterGemma();
      // NOTE: Ensure 'gemma-2b-it-cpu.bin' is present in 'assets/models/'
      // and that 'assets/models/' is listed in pubspec.yaml
      await _gemma.loadModel(
        modelPath: 'assets/models/gemma-2b-it-cpu.bin',
        modelType: GemmaModelType.gemma2b, // Specify model type
        // Add other configurations as needed, e.g., numThreads
      );
      _isInitialized = true;
      print("Gemma AI Service Initialized successfully.");
    } catch (e, s) {
      print("Error initializing Gemma AI Service: $e");
      Sentry.captureException(e, stackTrace: s);
      _isInitialized = false;
    }
  }

  /// Generates text using the loaded Gemma model.
  Future<String> generateText(String prompt) async {
    if (!_isInitialized) {
      print("Gemma not initialized. Returning fallback message.");
      return "AI service is currently unavailable. Please try again later.";
    }
    try {
      final result = await _gemma.generate(
        prompt,
        maxLength: 250,
        temperature: 0.7,
      );
      return result ?? "I'm sorry, I couldn't generate a response.";
    } catch (e, s) {
      print("Error generating text with Gemma: $e");
      Sentry.captureException(e, stackTrace: s);
      return "An error occurred while generating the AI response.";
    }
  }
}