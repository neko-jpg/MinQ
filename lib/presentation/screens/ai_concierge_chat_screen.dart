import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:minq/presentation/controllers/ai_concierge_chat_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

enum _ConciergeMenuOption { insights, clearHistory, diagnostics, toggleAI }

class AiConciergeChatScreen extends ConsumerStatefulWidget {
  const AiConciergeChatScreen({super.key});

  @override
  ConsumerState<AiConciergeChatScreen> createState() =>
      _AiConciergeChatScreenState();
}

class _AiConciergeChatScreenState extends ConsumerState<AiConciergeChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // プロバイダーの初期化のみ行う
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiConciergeChatControllerProvider);
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
    ref.listen<AsyncValue<List<AiConciergeMessage>>>(
      aiConciergeChatControllerProvider,
      (previous, next) {
        if (!mounted || !next.hasValue) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToBottom();
        });
      },
    );

    final tokens = context.tokens;
    final chatState = ref.watch(aiConciergeChatControllerProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '戻る',
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: <Widget>[
            Text(
              'AI Concierge',
              style: tokens.typography.h4.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final controller = ref.read(
                  aiConciergeChatControllerProvider.notifier,
                );
                final mode = controller.getCurrentAIMode();
                return Text(
                  mode,
                  style: tokens.typography.caption.copyWith(color: tokens.textMuted),
                );
              },
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<_ConciergeMenuOption>(
            icon: Icon(Icons.more_horiz, color: tokens.textMuted),
            itemBuilder:
                (context) => <PopupMenuEntry<_ConciergeMenuOption>>[
                  const PopupMenuItem<_ConciergeMenuOption>(
                    value: _ConciergeMenuOption.insights,
                    child: Text('AIからのインサイト'),
                  ),
                  const PopupMenuItem<_ConciergeMenuOption>(
                    value: _ConciergeMenuOption.clearHistory,
                    child: Text('チャット履歴を削除'),
                  ),
                  const PopupMenuItem<_ConciergeMenuOption>(
                    value: _ConciergeMenuOption.diagnostics,
                    child: Text('AI診断情報'),
                  ),
                  const PopupMenuItem<_ConciergeMenuOption>(
                    value: _ConciergeMenuOption.toggleAI,
                    child: Text('AIモード切り替え'),
                  ),
                ],
            onSelected: (option) async {
              await _handleMenuSelection(option);
            },
          ),
        ],
      ),
      body: chatState.when(
        data:
            (List<AiConciergeMessage> messages) => Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.lg,
                      vertical: tokens.spacing.lg,
                    ),
                    children: <Widget>[
                      ..._buildMessageList(messages, tokens),
                      if (_isSending) _buildTypingIndicator(tokens),
                    ],
                  ),
                ),
                _buildInputArea(tokens),
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(tokens.spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'AIコンシェルジュを読み込めませんでした。',
                      style: tokens.typography.body.copyWith(
                        color: tokens.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    FilledButton(
                      onPressed:
                          () =>
                              ref
                                  .read(
                                    aiConciergeChatControllerProvider.notifier,
                                  )
                                  .resetConversation(),
                      child: const Text('再読み込み'),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Future<void> _handleMenuSelection(_ConciergeMenuOption option) async {
    final navigation = ref.read(navigationUseCaseProvider);
    final notifier = ref.read(aiConciergeChatControllerProvider.notifier);
    switch (option) {
      case _ConciergeMenuOption.insights:
        navigation.goToAiInsights();
        break;
      case _ConciergeMenuOption.clearHistory:
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('チャット履歴を削除'),
                content: const Text('すべてのチャット履歴を削除しますか？この操作は取り消せません。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('キャンセル'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('削除'),
                  ),
                ],
              ),
        );
        if (confirmed == true) {
          await notifier.resetConversation();
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('チャット履歴を削除しました'),
                duration: Duration(seconds: 2),
              ),
            );
        }
        break;
      case _ConciergeMenuOption.diagnostics:
        await _showDiagnostics();
        break;
      case _ConciergeMenuOption.toggleAI:
        await _toggleAIMode();
        break;
    }
  }

  List<Widget> _buildMessageList(
    List<AiConciergeMessage> messages,
    MinqTheme tokens,
  ) {
    final List<Widget> children = <Widget>[];
    DateTime? previousDate;

    for (final AiConciergeMessage message in messages) {
      final bool showDate =
          previousDate == null || !_isSameDay(previousDate, message.timestamp);
      if (showDate) {
        children.add(_buildDateChip(message.timestamp, tokens));
        previousDate = message.timestamp;
      }
      children.add(_buildMessageBubble(message, tokens));
      children.add(SizedBox(height: tokens.spacing.md));
    }

    return children;
  }

  Widget _buildDateChip(DateTime timestamp, MinqTheme tokens) {
    final formatter = DateFormat.yMMMd('ja');
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.xs),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.sm,
            vertical: tokens.spacing.xs,
          ),
          decoration: BoxDecoration(
            color: tokens.surfaceVariant,
            borderRadius: BorderRadius.circular(tokens.radius.lg),
          ),
          child: Text(
            formatter.format(timestamp),
            style: tokens.typography.caption.copyWith(color: tokens.textMuted),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AiConciergeMessage message, MinqTheme tokens) {
    final bool isUser = message.isUser;
    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser ? tokens.brandPrimary : tokens.surfaceVariant;
    final textColor = isUser ? Colors.white : tokens.textPrimary;
    final borderRadius =
        isUser
            ? BorderRadius.only(
              topLeft: Radius.circular(tokens.radius.lg),
              topRight: Radius.circular(tokens.radius.lg),
              bottomLeft: Radius.circular(tokens.radius.lg),
              bottomRight: Radius.circular(tokens.radius.sm),
            )
            : BorderRadius.only(
              topLeft: Radius.circular(tokens.radius.lg),
              topRight: Radius.circular(tokens.radius.lg),
              bottomLeft: Radius.circular(tokens.radius.sm),
              bottomRight: Radius.circular(tokens.radius.lg),
            );
    final icon = isUser ? null : Icons.psychology;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isUser)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tokens.brandPrimary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tokens.brandPrimary),
          )
        else
          const SizedBox(width: 40),
        SizedBox(width: tokens.spacing.xs),
        Flexible(
          child: Column(
            crossAxisAlignment: alignment,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.md,
                  vertical: tokens.spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: borderRadius,
                ),
                child: Text(
                  message.text,
                  style: tokens.typography.body.copyWith(
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: tokens.spacing.xs),
              Text(
                DateFormat.Hm().format(message.timestamp),
                style: tokens.typography.caption.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator(MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tokens.brandPrimary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology, color: tokens.brandPrimary),
          ),
          SizedBox(width: tokens.spacing.xs),
          Container(
            padding: EdgeInsets.all(tokens.spacing.sm),
            decoration: BoxDecoration(
              color: tokens.surfaceVariant,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: tokens.spacing.xs),
                Text(
                  '考え中...',
                  style: tokens.typography.caption.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(MinqTheme tokens) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.spacing.md,
          tokens.spacing.xs,
          tokens.spacing.md,
          tokens.spacing.md,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'メッセージを入力...',
                  filled: true,
                  fillColor: tokens.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.xl),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.md,
                    vertical: tokens.spacing.sm,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: tokens.spacing.xs),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tokens.brandPrimary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_isSending) {
      return;
    }
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    _messageController.clear();
    setState(() => _isSending = true);
    await ref
        .read(aiConciergeChatControllerProvider.notifier)
        .sendUserMessage(text);
    if (mounted) {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _showDiagnostics() async {
    // AI診断機能は現在利用できません
    const diagnostics = 'AI診断機能は現在メンテナンス中です。';

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('AI診断情報'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDiagnosticItem(
                    '初期化状態',
                    diagnostics['isInitialized']?.toString() ?? 'unknown',
                  ),
                  _buildDiagnosticItem(
                    'アクティブモデル',
                    diagnostics['hasActiveModel']?.toString() ?? 'unknown',
                  ),
                  _buildDiagnosticItem(
                    'モデルファイル',
                    diagnostics['modelFileName']?.toString() ?? 'unknown',
                  ),
                  _buildDiagnosticItem(
                    'インストール済み',
                    diagnostics['isModelInstalled']?.toString() ?? 'unknown',
                  ),
                  _buildDiagnosticItem(
                    'リカバリ試行',
                    diagnostics['hasAttemptedRecovery']?.toString() ??
                        'unknown',
                  ),
                  if (diagnostics['installedModels'] != null)
                    _buildDiagnosticItem(
                      'インストール済みモデル',
                      diagnostics['installedModels'].toString(),
                    ),
                  if (diagnostics['diagnosticError'] != null)
                    _buildDiagnosticItem(
                      'エラー',
                      diagnostics['diagnosticError'].toString(),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _forceResetAI();
                },
                child: const Text('AIをリセット'),
              ),
            ],
          ),
    );
  }

  Widget _buildDiagnosticItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _forceResetAI() async {
    try {
      // AI リセット機能は現在利用できません

      // チャットも再初期化
      await ref
          .read(aiConciergeChatControllerProvider.notifier)
          .resetConversation();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AIをリセットしました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('リセットに失敗しました: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _toggleAIMode() async {
    final controller = ref.read(aiConciergeChatControllerProvider.notifier);
    final currentMode = controller.getCurrentAIMode();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('AIモード切り替え'),
            content: Text('現在のモード: $currentMode\n\nAIモードを切り替えますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('切り替え'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      controller.toggleAIMode();
      if (mounted) {
        final newMode = controller.getCurrentAIMode();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AIモードを $newMode に切り替えました'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
