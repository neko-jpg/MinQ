import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/gemma_ai_service.dart';

/// Gemma AI サービスプロバイダー
final gemmaAIServiceProvider = FutureProvider<GemmaAIService>((ref) async {
  final service = GemmaAIService.instance;
  await service.initialize();
  return service;
});

/// UID プロバイダー（仮実装）
final uidProvider = StateProvider<String?>((ref) => null);