import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/content_moderation_service.dart';
import 'package:minq/domain/pair/chat_message.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/screens/pair/share_progress_sheet.dart';
import 'package:minq/presentation/theme/animation_system.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, pairId) {
  final pairRepository = ref.watch(pairRepositoryProvider);
  if (pairRepository == null) return Stream.value([]);
  return pairRepository.getMessagesStream(pairId);
});

const List<String> _quickReplyTemplates = <String>[
  'おつかれさま！',
  '今から取り組みます！',
  '今日はこれでおしまいにします。',
  '助けてくれてありがとう！',
];

const List<String> _stampOptions = <String>['👏', '🔥', '💪', '🙌', '✨'];

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, required this.pairId});

  final String pairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final messagesAsync = ref.watch(chatMessagesProvider(pairId));
    final pairAsync = ref.watch(pairByIdProvider(pairId));
    final currentUserId = ref.watch(uidProvider);

    final buddyId = pairAsync.when(
      data: (pair) => pair?.members.firstWhere((id) => id != currentUserId, orElse: () => ''),
      loading: () => '',
      error: (_, __) => '',
    );

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),),
        title: Column(
          children: [
            Text('Buddy#${buddyId?.substring(0, 4) ?? ''}',
                style: tokens.titleSmall
                    .copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold),),
            Text('目標: 毎日運動する',
                style: tokens.bodySmall.copyWith(color: tokens.textMuted),),
          ],
        ),
        centerTitle: true,
        actions: [
          if (buddyId != null && buddyId.isNotEmpty)
            _ChatMenu(pairId: pairId, currentUserId: currentUserId!, buddyId: buddyId),
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

class _ChatMenu extends ConsumerWidget {
  const _ChatMenu({
    required this.pairId,
    required this.currentUserId,
    required this.buddyId,
  });

  final String pairId;
  final String currentUserId;
  final String buddyId;

  Future<void> _showBlockDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.blockUser),
        content: Text(l10n.blockConfirmation),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.block)),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(pairRepositoryProvider)?.blockUser(currentUserId, buddyId);
      if (context.mounted) {
        FeedbackMessenger.showSuccessToast(context, l10n.userBlocked);
      }
    }
  }

  Future<void> _showReportDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reportUser),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.reportConfirmation),
            const SizedBox(height: 16),
            TextField(controller: reasonController, decoration: InputDecoration(labelText: l10n.reason)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.report)),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      await ref.read(pairRepositoryProvider)?.reportUser(currentUserId, buddyId, reasonController.text);
      if (context.mounted) {
        FeedbackMessenger.showSuccessToast(context, l10n.reportSubmitted);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'block') {
          _showBlockDialog(context, ref);
        } else if (value == 'report') {
          _showReportDialog(context, ref);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'block',
          child: Text(l10n.blockUser),
        ),
        PopupMenuItem<String>(
          value: 'report',
          child: Text(l10n.reportUser),
        ),
      ],
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
      final maxWidth = math.min(MediaQuery.of(context).size.width * 0.55, 260.0);
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final cacheDimension = (maxWidth * pixelRatio).round();
      messageContent = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          message.imageUrl!,
          width: maxWidth,
          cacheWidth: cacheDimension,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
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
                ],
              ],
            ),
          ),
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
  bool _isSending = false;
  final bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasText = _textController.text.isNotEmpty;
      if (hasText != _showSendButton) {
        setState(() => _showSendButton = hasText);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    final currentUserId = ref.read(uidProvider);
    final pairRepository = ref.read(pairRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    if (text.isEmpty || currentUserId == null || pairRepository == null || _isSending) {
      return;
    }

    // Content moderation check
    final moderationResult = ContentModerationService.moderateText(text);
    if (moderationResult.isBlocked) {
      FeedbackMessenger.showErrorSnackBar(
        context,
        moderationResult.details ?? '不適切な内容が含まれています',
      );
      return;
    }

    if (moderationResult.isFlagged) {
      // Show warning but allow sending
      final shouldSend = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('内容の確認'),
          content: Text(moderationResult.details ?? 'この内容を送信してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('送信'),
            ),
          ],
        ),
      );
      
      if (shouldSend != true) return;
    }

    setState(() => _isSending = true);

    try {
      await pairRepository.sendMessage(
        pairId: widget.pairId,
        senderId: currentUserId,
        text: text,
      );
      _textController.clear();
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(
          context,
          l10n.messageSentFailed,
          actionLabel: l10n.retry,
          onAction: _sendMessage,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _sendQuickText(String text) async {
    final trimmed = text.trim();
    final currentUserId = ref.read(uidProvider);
    final pairRepository = ref.read(pairRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    if (trimmed.isEmpty || currentUserId == null || pairRepository == null ||
        _isSending) {
      return;
    }

    setState(() => _isSending = true);
    try {
      await pairRepository.sendQuickMessage(
        widget.pairId,
        currentUserId,
        trimmed,
      );
      // TODO: Implement FeedbackManager
      // FeedbackManager.selected();
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(
          context,
          l10n.messageSentFailed,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _sendImage() async {
    // ... (existing implementation)
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: tokens.surface,
      elevation: 10,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing(2)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuickReplyBar(
                isSending: _isSending || _isUploading,
                onReplySelected: _sendQuickText,
                onStampSelected: _sendQuickText,
              ),
              SizedBox(height: tokens.spacing(2)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: l10n.chatInputHint,
                        filled: true,
                        fillColor: tokens.background,
                        border: OutlineInputBorder(
                          borderRadius: tokens.cornerXLarge(),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: tokens.spacing(4),
                          vertical: tokens.spacing(3),
                        ),
                      ),
                      minLines: 1,
                      maxLines: 5,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: tokens.spacing(2)),
                  if (_isUploading)
                    Padding(
                      padding: EdgeInsets.all(tokens.spacing(2)),
                      child: const CircularProgressIndicator(),
                    )
                  else
                    Builder(
                      builder: (context) {
                        final switchCurve = AnimationSystem.getCurve(
                          context,
                          AnimationSystem.animatedSwitcherCurve,
                        );
                        final switchDuration = AnimationSystem.getDuration(
                          context,
                          AnimationSystem.animatedSwitcher,
                        );
                        final reduceMotion = AnimationSystem.shouldReduceMotion(context);
                        return AnimatedSwitcher(
                          duration: switchDuration,
                          switchInCurve: switchCurve,
                          switchOutCurve: switchCurve,
                          transitionBuilder: (child, animation) {
                            if (reduceMotion) {
                              return child;
                            }
                            final curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve: switchCurve,
                            );
                            return ScaleTransition(scale: curvedAnimation, child: child);
                          },
                          child: _showSendButton
                              ? _isSending
                                  ? Padding(
                                      padding: EdgeInsets.all(tokens.spacing(3)),
                                      child: SizedBox(
                                        width: tokens.spacing(6),
                                        height: tokens.spacing(6),
                                        child: const CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : IconButton.filled(
                                      key: const ValueKey('send'),
                                      icon: const Icon(Icons.send),
                                      onPressed: _sendMessage,
                                      style: IconButton.styleFrom(
                                        backgroundColor: tokens.brandPrimary,
                                      ),
                                    )
                              : Row(
                                  key: const ValueKey('actions'),
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.attach_file),
                                      onPressed: _sendImage,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.fact_check_outlined),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (_) =>
                                              ShareProgressSheet(pairId: widget.pairId),
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: true,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickReplyBar extends StatelessWidget {
  const _QuickReplyBar({
    required this.isSending,
    required this.onReplySelected,
    required this.onStampSelected,
  });

  final bool isSending;
  final ValueChanged<String> onReplySelected;
  final ValueChanged<String> onStampSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: tokens.spacing(2),
          runSpacing: tokens.spacing(1.5),
          children: _quickReplyTemplates
              .map(
                (reply) => ActionChip(
                  label: Text(reply),
                  onPressed:
                      isSending ? null : () => onReplySelected(reply),
                ),
              )
              .toList(),
        ),
        SizedBox(height: tokens.spacing(2)),
        Wrap(
          spacing: tokens.spacing(1.5),
          children: _stampOptions.map((stamp) {
            return GestureDetector(
              onTap: isSending ? null : () => onStampSelected(stamp),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing(2),
                  vertical: tokens.spacing(1.5),
                ),
                decoration: BoxDecoration(
                  color: tokens.background,
                  borderRadius: tokens.cornerFull(),
                  border: Border.all(color: tokens.border.withOpacity(0.6)),
                ),
                child: Text(
                  stamp,
                  style: tokens.titleLarge,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}