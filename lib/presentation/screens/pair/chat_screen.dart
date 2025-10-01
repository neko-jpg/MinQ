import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/pair/chat_message.dart';
import 'package:minq/presentation/screens/pair/share_progress_sheet.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, pairId) {
  final pairRepository = ref.watch(pairRepositoryProvider);
  if (pairRepository == null) return Stream.value([]);
  return pairRepository.getMessagesStream(pairId);
});

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, required this.pairId});

  final String pairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final messagesAsync = ref.watch(chatMessagesProvider(pairId));

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: Column(
          children: [
            Text('Buddy#1234', style: tokens.titleSmall.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
            Text('目標: 毎日運動する', style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _MessageBubble(message: message, pairId: pairId);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          _MessageInputBar(pairId: pairId),
        ],
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({required this.message, required this.pairId});

  final ChatMessage message;
  final String pairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final currentUserId = ref.watch(uidProvider);
    final isMe = message.senderId == currentUserId;

    void addReaction(String emoji) {
      ref.read(pairRepositoryProvider)?.addReaction(pairId, message.id, emoji);
    }

    Widget messageContent;
    if (message.imageUrl != null) {
      messageContent = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          message.imageUrl!,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    } else {
      messageContent = Text(
        message.text ?? '',
        style: tokens.bodyMedium.copyWith(color: isMe ? Colors.white : tokens.textPrimary),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: tokens.surface,
                  child: Icon(Icons.person, size: 24, color: tokens.textMuted),
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: message.imageUrl != null ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: isMe ? tokens.brandPrimary : tokens.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                  ),
                  child: messageContent,
                ),
              ),
              if (isMe)
                const SizedBox(width: 8),
              if (isMe)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: tokens.surface,
                  child: Icon(Icons.self_improvement, size: 24, color: tokens.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: isMe ? 0 : 48, right: isMe ? 48 : 0),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (message.reactions.isNotEmpty)
                  _ReactionsView(reactions: message.reactions),
                if (!isMe) ...[
                  const SizedBox(width: 8),
                  _ReactionButton(emoji: '👍', onTap: () => addReaction('👍')),
                  _ReactionButton(emoji: '👏', onTap: () => addReaction('👏')),
                  _ReactionButton(emoji: '🔥', onTap: () => addReaction('🔥')),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ReactionsView extends StatelessWidget {
  const _ReactionsView({required this.reactions});

  final Map<String, int> reactions;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return Wrap(
      spacing: 4.0,
      children: reactions.entries.map((entry) {
        return Chip(
          label: Text('${entry.key} ${entry.value}', style: const TextStyle(fontSize: 12)),
          backgroundColor: tokens.surface,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: tokens.cornerLarge(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(emoji, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _MessageInputBar extends ConsumerStatefulWidget {
  const _MessageInputBar({required this.pairId});

  final String pairId;

  @override
  ConsumerState<_MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends ConsumerState<_MessageInputBar> {
  final _textController = TextEditingController();
  bool _showSendButton = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (_textController.text.isNotEmpty != _showSendButton) {
        setState(() {
          _showSendButton = _textController.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    final currentUserId = ref.read(uidProvider);
    final pairRepository = ref.read(pairRepositoryProvider);

    if (text.isNotEmpty && currentUserId != null && pairRepository != null) {
      pairRepository.sendMessage(pairId: widget.pairId, senderId: currentUserId, text: text);
      _textController.clear();
    }
  }

  Future<void> _sendImage() async {
    final picker = ref.read(imagePickerProvider);
    final repo = ref.read(pairRepositoryProvider);
    final uid = ref.read(uidProvider);

    if (repo == null || uid == null) return;

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final imageFile = File(pickedFile.path);
      final imageUrl = await repo.uploadImage(widget.pairId, imageFile);
      await repo.sendMessage(pairId: widget.pairId, senderId: uid, imageUrl: imageUrl);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('画像アップロードに失敗しました: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return Material(
      color: tokens.surface,
      elevation: 10,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'メッセージを入力...',
                    filled: true,
                    fillColor: tokens.background,
                    border: OutlineInputBorder(borderRadius: tokens.cornerXLarge(), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              else
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: _showSendButton
                      ? IconButton.filled(
                          key: const ValueKey('send'),
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                          style: IconButton.styleFrom(backgroundColor: tokens.brandPrimary),
                        )
                      : Row(
                          key: const ValueKey('actions'),
                          children: [
                            IconButton(icon: const Icon(Icons.attach_file), onPressed: _sendImage),
                            IconButton(
                              icon: const Icon(Icons.fact_check_outlined),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => ShareProgressSheet(pairId: widget.pairId),
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                );
                              },
                            ),
                          ],
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}