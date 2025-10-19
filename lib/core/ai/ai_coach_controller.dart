import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/gemma_ai_service.dart';
import 'package:minq/domain/ai/ai_coach_state.dart';
import 'package:minq/domain/ai/chat_message.dart';
import 'package:uuid/uuid.dart';

// Provider for the controller
final aiCoachControllerProvider =
    StateNotifierProvider<AICoachController, AICoachState>((ref) {
      final gemmaAsync = ref.watch(gemmaAIServiceProvider);
      return AICoachController(gemmaAsync.valueOrNull);
    });

class AICoachController extends StateNotifier<AICoachState> {
  final GemmaAIService? _gemmaService;
  final Uuid _uuid = const Uuid();

  AICoachController(this._gemmaService)
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

    final gemma = _gemmaService;
    var aiResponseText = _coachUnavailableMessage;
    if (gemma != null) {
      aiResponseText = await gemma.generateText(
        text,
        history: _buildHistoryWithoutLatest(),
        systemPrompt: _coachSystemPrompt,
        maxTokens: 320,
      );
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

  List<GemmaChatMessage> _buildHistoryWithoutLatest() {
    final messages = state.conversationHistory;
    if (messages.isEmpty) {
      return const <GemmaChatMessage>[];
    }

    final mapped =
        messages
            .map(
              (message) => GemmaChatMessage(
                role:
                    message.sender == 'user'
                        ? GemmaChatRole.user
                        : GemmaChatRole.assistant,
                text: message.text,
              ),
            )
            .toList();

    if (mapped.isNotEmpty && mapped.last.isUser) {
      mapped.removeLast();
    }

    return mapped;
  }
}

const String _coachSystemPrompt =
    'You are a supportive habit coach. Provide actionable, upbeat guidance '
    'in Japanese. Keep responses within two short paragraphs.';

const String _coachUnavailableMessage =
    '申し訳ありません。AIコーチを利用できませんでした。少し時間を置いてから'
    'もう一度お試しください。';
