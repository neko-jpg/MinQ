import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_gemma/core/api/flutter_gemma.dart';
import 'package:minq/core/ai/gemma_ai_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  stdout.writeln('[Gemma Installer] Initializing FlutterGemma...');

  final huggingFaceToken = await loadHuggingFaceToken();
  FlutterGemma.initialize(
    huggingFaceToken: huggingFaceToken,
    maxDownloadRetries: 10,
  );

  final alreadyInstalled = await GemmaAIService.isModelInstalled();
  if (alreadyInstalled) {
    stdout.writeln(
      '[Gemma Installer] Model ${GemmaAIService.modelFileName} already installed. '
      'Re-validating active configuration...',
    );
  } else {
    stdout.writeln('[Gemma Installer] Model not found. Starting download...');
  }

  final gemmaService = GemmaAIService();

  try {
    await gemmaService.ensureModelInstalled(onProgress: (progress) {
      stdout.writeln('[Gemma Installer] Download progress: $progress%');
    });
    stdout.writeln('[Gemma Installer] Installation complete.');
  } on GemmaModelAccessException catch (error) {
    stderr.writeln('[Gemma Installer] Access denied while downloading model.');
    stderr.writeln(error.message.trim());
    if (error.stackTrace != null) {
      stderr.writeln(error.stackTrace);
    }
    stderr.writeln(
      '[Gemma Installer] Visit https://huggingface.co/litert-community/'
      'gemma-3-270m-it and request access with the account associated with '
      'the configured token.',
    );
    exitCode = 2;
    return;
  } catch (error, stackTrace) {
    stderr.writeln('[Gemma Installer] Installation failed: $error');
    stderr.writeln(stackTrace);
    exitCode = 1;
    return;
  }

  final installedModels = await GemmaAIService.listInstalledModels();
  stdout.writeln('[Gemma Installer] Installed models: $installedModels');
  stdout.writeln('[Gemma Installer] Finished.');
}
