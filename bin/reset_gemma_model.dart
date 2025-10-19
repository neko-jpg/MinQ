import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_gemma/core/api/flutter_gemma.dart';
import 'package:minq/core/ai/gemma_ai_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  stdout.writeln('[Gemma Reset] Initializing FlutterGemma...');
  final huggingFaceToken = await loadHuggingFaceToken();
  FlutterGemma.initialize(
    huggingFaceToken: huggingFaceToken,
    maxDownloadRetries: 10,
  );

  try {
    final installedBefore = await GemmaAIService.listInstalledModels();
    stdout.writeln('[Gemma Reset] Installed models before reset: $installedBefore');

    final alreadyInstalled = installedBefore.contains(GemmaAIService.modelFileName);
    if (alreadyInstalled) {
      stdout.writeln('[Gemma Reset] Uninstalling ${GemmaAIService.modelFileName}...');
      await FlutterGemma.uninstallModel(GemmaAIService.modelFileName);
      stdout.writeln('[Gemma Reset] Uninstall command completed.');
    } else {
      stdout.writeln('[Gemma Reset] Model not registered. Nothing to uninstall.');
    }

    final installedAfter = await GemmaAIService.listInstalledModels();
    stdout.writeln('[Gemma Reset] Installed models after reset: $installedAfter');
  } catch (error, stackTrace) {
    stderr.writeln('[Gemma Reset] Failed to reset model metadata: $error');
    stderr.writeln(stackTrace);
    exitCode = 1;
  }
}
