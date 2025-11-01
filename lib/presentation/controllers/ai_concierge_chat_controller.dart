import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder controller to avoid UTF-8 issues
class AiConciergeChatController
    extends StateNotifier<AsyncValue<List<AiConciergeMessage>>> {
  AiConciergeChatController() : super(const AsyncValue.data([]));

  String getCurrentAIMode() => 'Standard Mode';
  
  Future<void> resetConversation() async {
    state = const AsyncValue.data([]);
  }
  
  Future<void> sendUserMessage(String text) async {
    final currentMessages = state.value ?? [];
    final newMessage = AiConciergeMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = AsyncValue.data([...currentMessages, newMessage]);
  }
  
  void toggleAIMode() {
    // Toggle AI mode implementation
  }
}

class AiConciergeMessage {
  final String text;
  final bool isUser;
  final List<QuickAction> quickActions;
  final List<String> suggestions;
  final bool isOffline;
  final DateTime timestamp;

  AiConciergeMessage({
    required this.text,
    required this.isUser,
    this.quickActions = const [],
    this.suggestions = const [],
    this.isOffline = false,
    required this.timestamp,
  });
}

class QuickAction {
  final String id;
  final String title;
  final String? description;
  final String? icon;

  const QuickAction({
    required this.id,
    required this.title,
    this.description,
    this.icon,
  });
}

final aiConciergeChatControllerProvider = StateNotifierProvider<
  AiConciergeChatController,
  AsyncValue<List<AiConciergeMessage>>
>((ref) => AiConciergeChatController());
