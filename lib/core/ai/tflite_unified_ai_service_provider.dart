import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/tflite_unified_ai_service.dart';

final tfliteUnifiedAIServiceProvider = Provider<TFLiteUnifiedAIService>((ref) {
  return TFLiteUnifiedAIService.instance;
});
