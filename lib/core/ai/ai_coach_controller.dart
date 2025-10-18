import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/ai/ai_coach_state.dart';
import 'package:minq/domain/ai/chat_message.dart';
import 'package:minq/core/ai/gemma_ai_service.dart';
import 'package:uuid/uuid.dart';

// Provider for the controller
final aiCoachControllerProvider = StateNotifierProvider<AICoachController, AICoachState>((ref) {
  final gemmaService = ref.watch(gemmaAIServiceProvider);
  return AICoachController(gemmaService);
});

class AICoachController extends StateNotifier<AICoachState> {
  final GemmaAIService _gemmaService;
  final Uuid _uuid = const Uuid();

  AICoachController(this._gemmaService)
      : super(AICoachState(
          userId: '', // This should be initialized with the actual user ID
          conversationHistory: [],
          isTyping: false,
          lastInteraction: DateTime.now(),
        ));

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

    // Get AI response
    final aiResponseText = await _gemmaService.generateText(text);

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
}