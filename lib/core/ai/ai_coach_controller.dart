import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/tflite_unified_ai_service.dart';
import 'package:minq/domain/ai/ai_coach_state.dart';
import 'package:minq/domain/ai/chat_message.dart';
import 'package:uuid/uuid.dart';

// Provider for the AI service
final tfliteAIServiceProvider = Provider<TFLiteUnifiedAIService>((ref) {
  return TFLiteUnifiedAIService.instance;
});

// Provider for the controller
final aiCoachControllerProvider =
    StateNotifierProvider<AICoachController, AICoachState>((ref) {
      final aiService = ref.watch(tfliteAIServiceProvider);
      return AICoachController(aiService);
    });

class AICoachController extends StateNotifier<AICoachState> {
  final TFLiteUnifiedAIService _tfliteService;
  final Uuid _uuid = const Uuid();

  AICoachController(this._tfliteService)
    : super(
        AICoachState(
          userId: '', // This should be initialized with the actual user ID
          conversationHistory: [],
          isTyping: false,
          lastInteraction: DateTime.now(),
        ),
      );

  /// Handles a new message sent by the user.
  Future<void> sendMessage(String text) async {
    // Add user message to history
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: text,
      sender: 'user',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      conversationHistory: [...state.conversationHistory, userMessage],
      isTyping: true,
    );

    var aiResponseText = _coachUnavailableMessage;
    try {
      // Initialize the service if it's not already
      await _tfliteService.initialize();

      aiResponseText = await _tfliteService.generateChatResponse(
        text,
        conversationHistory: _buildHistory(),
        systemPrompt: _coachSystemPrompt,
        maxTokens: 150,
      );
    } catch (e) {
      // Error handling is done inside the service, which returns a fallback message.
      // We can add additional logging here if needed.
    }

    // Add AI message to history
    final aiMessage = ChatMessage(
      id: _uuid.v4(),
      text: aiResponseText,
      sender: 'ai',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      conversationHistory: [...state.conversationHistory, aiMessage],
      isTyping: false,
      lastInteraction: DateTime.now(),
    );
  }

  List<String> _buildHistory() {
    return state.conversationHistory
        .map(
          (message) =>
              '${message.sender == 'user' ? 'User' : 'AI'}: ${message.text}',
        )
        .toList();
  }
}

const String _coachSystemPrompt =
    'You are a supportive habit coach. Provide actionable, upbeat guidance '
    'in Japanese. Keep responses within two short paragraphs.';

const String _coachUnavailableMessage =
    '申し訳ありません。AIコーチを利用できませんでした。少し時間を置いてから'
    'もう一度お試しください。';
