import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/realtime/realtime_message.dart' as realtime;
import 'package:minq/domain/pair/pair_message.dart';
import 'package:minq/presentation/providers/realtime_providers.dart';

/// リアルタイムチャットウィジェット
class RealtimeChatWidget extends ConsumerStatefulWidget {
  final String currentUserId;
  final String partnerId;
  final List<PairMessage> initialMessages;
  final Function(String text, String? imageUrl)? onSendMessage;

  const RealtimeChatWidget({
    super.key,
    required this.currentUserId,
    required this.partnerId,
    required this.initialMessages,
    this.onSendMessage,
  });

  @override
  ConsumerState<RealtimeChatWidget> createState() => _RealtimeChatWidgetState();
}

class _RealtimeChatWidgetState extends ConsumerState<RealtimeChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<PairMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll(widget.initialMessages);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // リアルタイムメッセージを監視
    ref.listen<AsyncValue<realtime.RealtimeMessage>>(pairMessageStreamProvider, (
      previous,
      next,
    ) {
      next.whenData((realtimeMessage) {
        if (realtimeMessage.type == realtime.MessageType.pairMessage &&
            (realtimeMessage.senderId == widget.partnerId ||
                realtimeMessage.recipientId == widget.currentUserId)) {
          _handleRealtimeMessage(realtimeMessage);
        }
      });
    });

    return Column(
      children: [
        // メッセージリスト
        Expanded(child: _buildMessageList()),

        // メッセージ入力欄
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isCurrentUser = message.senderId == widget.currentUserId;

        return _buildMessageBubble(message, isCurrentUser);
      },
    );
  }

  Widget _buildMessageBubble(PairMessage message, bool isCurrentUser) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.secondary,
              child: Text(
                'P',
                style: TextStyle(
                  color: theme.colorScheme.onSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isCurrentUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.text != null)
                    Text(
                      message.text!,
                      style: TextStyle(
                        color:
                            isCurrentUser
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                  if (message.imageUrl != null) ...[
                    if (message.text != null) const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.imageUrl!,
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 100,
                            color: theme.colorScheme.errorContainer,
                            child: Icon(
                              Icons.error,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isCurrentUser
                              ? theme.colorScheme.onPrimary.withAlpha((255 * 0.7).round())
                              : theme.colorScheme.onSurfaceVariant.withAlpha(
                                  (255 * 0.7).round(),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                'M',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: theme.colorScheme.outline.withAlpha((255 * 0.2).round())),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'メッセージを入力...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // メッセージを送信
    if (widget.onSendMessage != null) {
      widget.onSendMessage!(text, null);
    }

    // リアルタイムメッセージを送信
    final connectionNotifier = ref.read(realtimeConnectionProvider.notifier);
    connectionNotifier.sendPairMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.currentUserId,
      recipientId: widget.partnerId,
      text: text,
    );

    // ローカルメッセージを追加
    final localMessage = PairMessage.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.currentUserId,
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(localMessage);
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _handleRealtimeMessage(realtime.RealtimeMessage realtimeMessage) {
    if (realtimeMessage.senderId == widget.currentUserId) {
      // 自分が送信したメッセージは既にローカルに追加済み
      return;
    }

    final pairMessage = PairMessage.text(
      id: realtimeMessage.payload['messageId'] as String,
      senderId: realtimeMessage.senderId,
      text: realtimeMessage.payload['text'] as String,
      timestamp: realtimeMessage.timestamp,
    );

    setState(() {
      _messages.add(pairMessage);
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
