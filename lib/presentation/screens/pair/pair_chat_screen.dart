import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/social/pair_system.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/pair/pair_message.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// ペアチャット画面
class PairChatScreen extends ConsumerStatefulWidget {
  final String pairId;

  const PairChatScreen({
    super.key,
    required this.pairId,
  });

  @override
  ConsumerState<PairChatScreen> createState() => _PairChatScreenState();
}

class _PairChatScreenState extends ConsumerState<PairChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userId = ref.read(uidProvider);
    if (userId == null) return;

    setState(() => _isLoading = true);
    _messageController.clear();

    try {
      final pairSystem = ref.read(pairSystemProvider);
      final message = PairMessage.text(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: userId,
        text: text,
        timestamp: DateTime.now(),
      );

      await pairSystem.sendMessage(
        pairId: widget.pairId,
        message: message,
      );

      // メッセージ送信後にスクロール
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(
          context,
          'メッセージの送信に失敗しました: $e',
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendEncouragement(String message) async {
    final userId = ref.read(uidProvider);
    if (userId == null) return;

    try {
      final pairSystem = ref.read(pairSystemProvider);
      final encouragementMessage = PairMessage.encouragement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: userId,
        text: message,
        timestamp: DateTime.now(),
      );

      await pairSystem.sendMessage(
        pairId: widget.pairId,
        message: encouragementMessage,
      );

      if (mounted) {
        FeedbackMessenger.showSuccessSnackBar(
          context,
          '励ましメッセージを送信しました！',
        );
      }
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(
          context,
          '励ましメッセージの送信に失敗しました: $e',
        );
      }
    }
  }

  Future<void> _addReaction(String messageId, String emoji) async {
    final userId = ref.read(uidProvider);
    if (userId == null) return;

    try {
      final pairSystem = ref.read(pairSystemProvider);
      await pairSystem.addReaction(
        pairId: widget.pairId,
        messageId: messageId,
        emoji: emoji,
        userId: userId,
      );
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(
          context,
          'リアクションの追加に失敗しました: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);
    final userId = ref.watch(uidProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'ペアチャット',
          style: tokens.typography.h4.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: tokens.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: tokens.textPrimary),
            onPressed: () => _showChatOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 励ましメッセージクイックアクション
          _buildQuickEncouragements(tokens),
          
          // メッセージリスト
          Expanded(
            child: _buildMessageList(tokens, userId),
          ),
          
          // メッセージ入力
          _buildMessageInput(tokens),
        ],
      ),
    );
  }

  Widget _buildQuickEncouragements(MinqTheme tokens) {
    final encouragements = [
      '👏 お疲れさま！',
      '🔥 頑張って！',
      '✨ 素晴らしい！',
      '💪 一緒に頑張ろう！',
    ];

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(
          bottom: BorderSide(color: tokens.border, width: 0.5),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: encouragements.length,
        itemBuilder: (context, index) {
          final message = encouragements[index];
          return Padding(
            padding: EdgeInsets.only(right: tokens.spacing.sm),
            child: Center(
              child: ActionChip(
                label: Text(
                  message,
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.primary,
                  ),
                ),
                onPressed: () => _sendEncouragement(message),
                backgroundColor: tokens.primary.withOpacity(0.1),
                side: BorderSide(color: tokens.primary.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageList(MinqTheme tokens, String? userId) {
    final pairSystem = ref.watch(pairSystemProvider);
    
    return StreamBuilder<List<PairMessage>>(
      stream: pairSystem.getMessagesStream(widget.pairId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'メッセージの読み込みに失敗しました',
              style: tokens.typography.body.copyWith(
                color: tokens.error,
              ),
            ),
          );
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: tokens.textMuted,
                ),
                SizedBox(height: tokens.spacing.md),
                Text(
                  'まだメッセージがありません',
                  style: tokens.typography.body.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  '最初のメッセージを送信してみましょう！',
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: EdgeInsets.all(tokens.spacing.md),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMyMessage = message.senderId == userId;
            final isSystemMessage = message.type == MessageType.system;

            if (isSystemMessage) {
              return _buildSystemMessage(tokens, message);
            }

            return _buildChatMessage(tokens, message, isMyMessage);
          },
        );
      },
    );
  }

  Widget _buildSystemMessage(MinqTheme tokens, PairMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.md,
            vertical: tokens.spacing.xs,
          ),
          decoration: BoxDecoration(
            color: tokens.textMuted.withOpacity(0.1),
            borderRadius: BorderRadius.circular(tokens.radius.lg),
          ),
          child: Text(
            message.text ?? '',
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessage(MinqTheme tokens, PairMessage message, bool isMyMessage) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
      child: Row(
        mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: tokens.primary.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 16,
                color: tokens.primary,
              ),
            ),
            SizedBox(width: tokens.spacing.xs),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _showReactionPicker(message.id),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.md,
                      vertical: tokens.spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isMyMessage ? tokens.primary : tokens.surface,
                      borderRadius: BorderRadius.circular(tokens.radius.lg).copyWith(
                        bottomLeft: isMyMessage ? null : Radius.zero,
                        bottomRight: isMyMessage ? Radius.zero : null,
                      ),
                      border: isMyMessage ? null : Border.all(color: tokens.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.type == MessageType.encouragement)
                          Container(
                            margin: EdgeInsets.only(bottom: tokens.spacing.xs),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: isMyMessage ? tokens.onPrimary : tokens.error,
                                ),
                                SizedBox(width: tokens.spacing.xs),
                                Text(
                                  '励まし',
                                  style: tokens.typography.bodySmall.copyWith(
                                    color: isMyMessage ? tokens.onPrimary : tokens.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          message.text ?? '',
                          style: tokens.typography.body.copyWith(
                            color: isMyMessage ? tokens.onPrimary : tokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // リアクション表示
                if (message.reactions.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: tokens.spacing.xs),
                    child: Wrap(
                      spacing: tokens.spacing.xs,
                      children: message.reactions.entries.map((entry) {
                        final emoji = entry.key;
                        final users = entry.value;
                        return GestureDetector(
                          onTap: () => _addReaction(message.id, emoji),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: tokens.spacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: tokens.surface,
                              borderRadius: BorderRadius.circular(tokens.radius.sm),
                              border: Border.all(color: tokens.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(emoji, style: const TextStyle(fontSize: 12)),
                                if (users.length > 1) ...[
                                  const SizedBox(width: 2),
                                  Text(
                                    '${users.length}',
                                    style: tokens.typography.bodySmall.copyWith(
                                      color: tokens.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                
                // タイムスタンプ
                Container(
                  margin: EdgeInsets.only(top: tokens.spacing.xs),
                  child: Text(
                    _formatMessageTime(message.timestamp),
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMyMessage) ...[
            SizedBox(width: tokens.spacing.xs),
            CircleAvatar(
              radius: 16,
              backgroundColor: tokens.primary.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 16,
                color: tokens.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(
          top: BorderSide(color: tokens.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'メッセージを入力...',
                filled: true,
                fillColor: tokens.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                  borderSide: BorderSide(color: tokens.border),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.md,
                  vertical: tokens.spacing.sm,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: tokens.spacing.sm),
          IconButton(
            onPressed: _isLoading ? null : _sendMessage,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(tokens.primary),
                    ),
                  )
                : Icon(Icons.send, color: tokens.primary),
            style: IconButton.styleFrom(
              backgroundColor: tokens.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radius.lg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReactionPicker(String messageId) {
    final reactions = ['👍', '❤️', '😊', '🎉', '👏', '🔥'];
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final tokens = context.tokens;
        return Container(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'リアクションを選択',
                style: tokens.typography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: tokens.spacing.md),
              Wrap(
                spacing: tokens.spacing.md,
                children: reactions.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      _addReaction(messageId, emoji);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: BorderRadius.circular(tokens.radius.md),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final tokens = context.tokens;
        return Container(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.settings, color: tokens.textPrimary),
                title: const Text('チャット設定'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: チャット設定画面に遷移
                },
              ),
              ListTile(
                leading: Icon(Icons.block, color: tokens.error),
                title: const Text('ペアを終了'),
                onTap: () {
                  Navigator.pop(context);
                  _showEndPairDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEndPairDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final tokens = context.tokens;
        return AlertDialog(
          title: const Text('ペアを終了しますか？'),
          content: const Text('この操作は取り消せません。本当にペアを終了しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: ペア終了処理
              },
              style: TextButton.styleFrom(foregroundColor: tokens.error),
              child: const Text('終了'),
            ),
          ],
        );
      },
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}