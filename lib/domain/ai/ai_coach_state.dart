import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:minq/domain/ai/chat_message.dart';

part 'ai_coach_state.freezed.dart';
part 'ai_coach_state.g.dart';

@freezed
class AICoachState with _$AICoachState {
  const factory AICoachState({
    required String userId,
    required List<ChatMessage> conversationHistory,
    required bool isTyping,
    required DateTime lastInteraction,
  }) = _AICoachState;

  factory AICoachState.fromJson(Map<String, dynamic> json) => _$AICoachStateFromJson(json);
}