import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/controllers/ai_concierge_chat_controller.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';
import 'package:minq/presentation/widgets/enhanced_ai_coach_overlay.dart';

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

    final chatState = ref.watch(aiConciergeChatControllerProvider);

    return Scaffold(
      backgroundColor: MinqTokens.background,
      appBar: AppBar(
        backgroundColor: MinqTokens.background,
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
              style: MinqTokens.titleMedium.copyWith(
                color: MinqTokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final controller =
                    ref.read(aiConciergeChatControllerProvider.notifier);
                final mode = controller.getCurrentAIMode();
                return Text(
                  mode,
                  style: MinqTokens.bodySmall
                      .copyWith(color: MinqTokens.textSecondary),
                );
              },
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<_ConciergeMenuOption>(
            icon: const Icon(Icons.more_horiz, color: MinqTokens.textSecondary),
            itemBuilder: (context) =>
                const <PopupMenuEntry<_ConciergeMenuOption>>[
              PopupMenuItem<_ConciergeMenuOption>(
                value: _ConciergeMenuOption.insights,
                child: Text('AIからのインサイト'),
              ),
              PopupMenuItem<_ConciergeMenuOption>(
                value: _ConciergeMenuOption.clearHistory,
                child: Text('チャット履歴を削除'),
              ),
              PopupMenuItem<_ConciergeMenuOption>(
                value: _ConciergeMenuOption.diagnostics,
                child: Text('AI診断情報'),
              ),
              PopupMenuItem<_ConciergeMenuOption>(
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
        data: (List<AiConciergeMessage> messages) => Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: MinqTokens.spacing(4),
                  vertical: MinqTokens.spacing(4),
                ),
                children: <Widget>[
                  ..._buildMessageList(messages),
                  if (_isSending) _buildTypingIndicator(),
                ],
              ),
            ),
            _buildInputArea(),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(MinqTokens.spacing(4)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'AIコンシェルジュを読み込めませんでした。',
                  style: MinqTokens.bodyMedium.copyWith(
                    color: MinqTokens.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MinqTokens.spacing(2)),
                FilledButton(
                  onPressed: () => ref
                      .read(aiConciergeChatControllerProvider.notifier)
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
          builder: (context) => AlertDialog(
            title: const Text('チャット履歴を削除'),
            content:
                const Text('すべてのチャット履歴を削除しますか？この操作は取り消せません。'),
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
  ) {
    final List<Widget> children = <Widget>[];
    DateTime? previousDate;

    for (final AiConciergeMessage message in messages) {
      final bool showDate =
          previousDate == null || !_isSameDay(previousDate, message.timestamp);
      if (showDate) {
        children.add(_buildDateChip(message.timestamp));
        previousDate = message.timestamp;
      }
      children.add(_buildMessageBubble(message));
      children.add(SizedBox(height: MinqTokens.spacing(3)));
    }

    return children;
  }

  Widget _buildDateChip(DateTime timestamp) {
    final formatter = DateFormat.yMMMd('ja');
    return Padding(
      padding: EdgeInsets.only(bottom: MinqTokens.spacing(1)),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: MinqTokens.spacing(2),
            vertical: MinqTokens.spacing(1),
          ),
          decoration: BoxDecoration(
            color: MinqTokens.surface,
            borderRadius: MinqTokens.cornerLarge(),
          ),
          child: Text(
            formatter.format(timestamp),
            style: MinqTokens.bodySmall
                .copyWith(color: MinqTokens.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AiConciergeMessage message) {
    return AICoachMessageBubble(
      message: message.text,
      isUser: message.isUser,
      quickActions: message.quickActions,
      suggestions: message.suggestions,
      isOffline: message.isOffline,
      timestamp: message.timestamp,
    );
              ),
              SizedBox(height: MinqTokens.spacing(1)),
              Text(
                DateFormat.Hm().format(message.timestamp),
                style: MinqTokens.bodySmall
                    .copyWith(color: MinqTokens.textSecondary),
              ),
            ],
          ),
        ),
      ],
    )
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: MinqTokens.spacing(2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: MinqTokens.brandPrimary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: MinqTokens.brandPrimary),
          ),
          SizedBox(width: MinqTokens.spacing(1)),
          Container(
            padding: EdgeInsets.all(MinqTokens.spacing(2)),
            decoration: BoxDecoration(
              color: MinqTokens.surface,
              borderRadius: MinqTokens.cornerLarge(),
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
                SizedBox(width: MinqTokens.spacing(1)),
                Text(
                  '考え中...',
                  style: MinqTokens.bodySmall
                      .copyWith(color: MinqTokens.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          MinqTokens.spacing(3),
          MinqTokens.spacing(1),
          MinqTokens.spacing(3),
          MinqTokens.spacing(3),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'メッセージを入力...',
                  filled: true,
                  fillColor: MinqTokens.surface,
                  border: OutlineInputBorder(
                    borderRadius: MinqTokens.cornerLarge(),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: MinqTokens.spacing(3),
                    vertical: MinqTokens.spacing(2),
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: MinqTokens.spacing(1)),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: MinqTokens.brandPrimary,
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
      builder: (context) => AlertDialog(
        title: const Text('AI診断情報'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(diagnostics),
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
      builder: (context) => AlertDialog(
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
