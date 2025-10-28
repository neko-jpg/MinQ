import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/support_chat_service.dart';
import 'package:minq/domain/support/support_message.dart';
import 'package:minq/presentation/common/dialogs/discard_changes_dialog.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  late final TextEditingController _commentController;
  late final TextEditingController _chatController;
  int _npsScore = 8;
  int _initialNpsScore = 8;
  bool _submitted = false;
  DateTime? _recordedAt;
  final List<SupportMessage> _messages = <SupportMessage>[];
  bool _chatSending = false;
  late final String _conversationId;
  late final ScrollController _chatScrollController;
  String _initialComment = '';
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _chatController = TextEditingController();
    _chatScrollController = ScrollController();
    _commentController.addListener(_updateUnsavedState);
    _chatController.addListener(_updateUnsavedState);
    _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
    _messages.add(
      const SupportMessage(
        role: 'assistant',
        content: 'こんにちは！MinQサポートです。ご質問や不具合があれば気軽にメッセージを送ってください。',
      ),
    );
    Future<void>.microtask(() async {
      final prefs = ref.read(localPreferencesServiceProvider);
      final response = await prefs.loadNpsResponse();
      if (!context.mounted || response == null) {
        return;
      }
      final comment = response.comment ?? '';
      _commentController.removeListener(_updateUnsavedState);
      _commentController.text = comment;
      _commentController.addListener(_updateUnsavedState);
      _initialComment = comment.trim();
      setState(() {
        _npsScore = response.score;
        _initialNpsScore = response.score;
        _submitted = true;
        _recordedAt = response.recordedAt.toLocal();
      });
      _updateUnsavedState();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _commentController.removeListener(_updateUnsavedState);
    _chatController.removeListener(_updateUnsavedState);
    _commentController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        await _requestExit();
      },
      child: Scaffold(
        backgroundColor: tokens.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _requestExit,
          ),
          title: Text(
            'サポートとFAQ',
            style: tokens.typography.h3.copyWith(color: tokens.textPrimary),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(tokens.spacing.lg),
          children: <Widget>[
            _buildSupportBotCard(tokens),
            SizedBox(height: tokens.spacing.lg),
            _buildNpsCard(tokens),
            SizedBox(height: tokens.spacing.lg),
            Card(
              elevation: 0,
              color: tokens.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.lg)),
              child: Padding(
                padding: EdgeInsets.all(tokens.spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Contact Us',
                      style: tokens.typography.h4
                          .copyWith(color: tokens.textPrimary),
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    _SupportActionTile(
                      icon: Icons.mail_outline,
                      title: 'Email',
                      subtitle: 'support@minq.app',
                      onCopy:
                          () => _copyToClipboard(context, 'support@minq.app'),
                    ),
                    Divider(height: tokens.spacing.xl),
                    _SupportActionTile(
                      icon: Icons.forum_outlined,
                      title: 'Feedback Form',
                      subtitle: 'https://minq.app/feedback',
                      onCopy:
                          () => _copyToClipboard(
                            context,
                            'https://minq.app/feedback',
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            Card(
              elevation: 0,
              color: tokens.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.lg)),
              child: Padding(
                padding: EdgeInsets.all(tokens.spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Quick Answers',
                      style: tokens.typography.h4
                          .copyWith(color: tokens.textPrimary),
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    const _FaqItem(
                      questionJa: '通知が届かないときは？',
                      questionEn: 'Notifications are missing?',
                      answerJa:
                          '端末の通知許可とアプリ内の通知時間を確認してください。端末再起動や再ログインで改善する場合があります。',
                      answerEn:
                          'Please review device notification permissions and the in-app notification schedule. Restarting the device or re-signing in can help restore delivery.',
                    ),
                    const _FaqItem(
                      questionJa: 'ペアを変更したい',
                      questionEn: 'I want to change my pair',
                      answerJa:
                          'Pair画面のメニューから「再マッチ」を選択すると、現在のペアに通知した上で新しい候補を探します。',
                      answerEn:
                          'Use the “Re-match” option from the Pair screen menu. Your current partner will be notified while we look for a new match.',
                    ),
                    const _FaqItem(
                      questionJa: 'データのエクスポート方法',
                      questionEn: 'How can I export my data?',
                      answerJa:
                          '設定 > プライバシー > データをエクスポート から申請すると、登録メールへ安全なダウンロードリンクを送信します。',
                      answerEn:
                          'Open Settings → Privacy → Export My Data to request an export. A secure download link will be emailed to you.',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            const _BatteryOptimizationCard(),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    FeedbackMessenger.showSuccessToast(context, 'コピーしました: $text');
  }

  Future<void> _sendChatMessage(BuildContext context) async {
    if (_chatSending) return;
    final content = _chatController.text.trim();
    if (content.isEmpty) {
      FeedbackMessenger.showInfoToast(context, '質問内容を入力してください');
      return;
    }
    final service = ref.read(supportChatServiceProvider);
    if (service == null) {
      FeedbackMessenger.showInfoToast(context, '現在はサポートボットをご利用いただけません');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    final history = List<SupportMessage>.from(_messages);
    setState(() {
      _chatSending = true;
      _messages.add(SupportMessage(role: 'user', content: content));
    });
    _chatController.clear();
    _updateUnsavedState();
    _scrollToBottom();

    try {
      final reply = await service.sendMessage(
        conversationId: _conversationId,
        content: content,
        history: history,
      );
      if (!context.mounted) return;
      setState(() {
        _messages.add(reply);
        _chatSending = false;
      });
      _scrollToBottom();
    } catch (error) {
      if (context.mounted) {
        setState(() {
          _chatSending = false;
          _messages.add(
            const SupportMessage(
              role: 'assistant',
              content: '申し訳ありません。現在サポートボットに接続できませんでした。時間をおいて再度お試しください。',
            ),
          );
        });
        _scrollToBottom();
      }
      // TODO(agent): Re-implement with FeedbackMessenger if a non-static version is available
      // to preserve original toast appearance.
      messenger.showSnackBar(
        const SnackBar(content: Text('サポートボットとの通信に失敗しました。')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  bool _computeHasUnsavedChanges() {
    final commentChanged =
        _commentController.text.trim() != _initialComment.trim();
    final scoreChanged = _npsScore != _initialNpsScore;
    final hasDraft = _chatController.text.trim().isNotEmpty;
    return commentChanged || scoreChanged || hasDraft;
  }

  void _updateUnsavedState() {
    final shouldFlag = _computeHasUnsavedChanges();
    if (shouldFlag != _hasUnsavedChanges && context.mounted) {
      setState(() {
        _hasUnsavedChanges = shouldFlag;
      });
    }
  }

  Future<void> _requestExit() async {
    if (!_hasUnsavedChanges) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final navigator = Navigator.of(context);
    final shouldLeave = await showDiscardChangesDialog(
      context,
      message: '未送信のチャットや保存されていないフィードバックがあります。画面を閉じると破棄されます。',
      discardLabel: '破棄して戻る',
    );

    if (shouldLeave) {
      navigator.pop();
    }
  }

  void _setNpsScore(int value) {
    if (_npsScore == value) {
      return;
    }
    setState(() => _npsScore = value);
    _updateUnsavedState();
  }

  Widget _buildSupportBotCard(MinqTheme tokens) {
    final chatService = ref.watch(supportChatServiceProvider);
    final isChatAvailable = chatService != null;
    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.lg)),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI サポートチャット',
              style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing.sm),
            if (!isChatAvailable)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(tokens.spacing.sm),
                margin: EdgeInsets.only(bottom: tokens.spacing.sm),
                decoration: BoxDecoration(
                  color: tokens.surfaceVariant,
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                child: Text(
                  '現在はサポートボットへの接続を準備中です。しばらくお待ちください。',
                  style:
                      tokens.typography.caption.copyWith(color: tokens.textMuted),
                ),
              ),
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: tokens.surfaceVariant,
                borderRadius: BorderRadius.circular(tokens.radius.md),
              ),
              child: ListView.builder(
                controller: _chatScrollController,
                padding: EdgeInsets.all(tokens.spacing.sm),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.isUser;
                  final alignment =
                      isUser ? Alignment.centerRight : Alignment.centerLeft;
                  final bubbleColor =
                      isUser ? tokens.brandPrimary : tokens.surface;
                  final textColor =
                      isUser ? tokens.onPrimary : tokens.textPrimary;
                  return Align(
                    alignment: alignment,
                    child: Container(
                      margin: EdgeInsets.only(bottom: tokens.spacing.xs),
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.sm,
                        vertical: tokens.spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(tokens.radius.sm),
                      ),
                      child: Text(
                        message.content,
                        style:
                            tokens.typography.caption.copyWith(color: textColor),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: tokens.spacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    minLines: 1,
                    maxLines: 3,
                    enabled: isChatAvailable && !_chatSending,
                    onSubmitted:
                        isChatAvailable && !_chatSending
                            ? (_) => _sendChatMessage(context)
                            : null,
                    decoration: const InputDecoration(
                      hintText: '例: 通知が届かないのですが…',
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacing.xs),
                FilledButton.icon(
                  onPressed:
                      !_chatSending && isChatAvailable
                          ? () => _sendChatMessage(context)
                          : null,
                  icon:
                      _chatSending
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send),
                  label: const Text('送信'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNpsCard(MinqTheme tokens) {
    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.lg)),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'MinQの使い心地を教えてください',
              style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing.xs),
            Text(
              '0 = おすすめしたくない / 10 = とてもおすすめしたい',
              style: tokens.typography.caption.copyWith(color: tokens.textMuted),
            ),
            SizedBox(height: tokens.spacing.md),
            Slider(
              value: _npsScore.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: tokens.brandPrimary,
              label: _npsScore.toString(),
              onChanged: (double value) => _setNpsScore(value.round()),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'スコア: $_npsScore',
                style: tokens.typography.caption.copyWith(color: tokens.textMuted),
              ),
            ),
            SizedBox(height: tokens.spacing.md),
            TextField(
              controller: _commentController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'コメント (任意)',
                hintText: 'ペア機能や通知タイミングで改善して欲しい点を教えてください',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.md)),
              ),
            ),
            SizedBox(height: tokens.spacing.md),
            if (_submitted && _recordedAt != null)
              Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing.xs),
                child: Text(
                  'ありがとうございます！ ${_recordedAt!.year}/${_recordedAt!.month}/${_recordedAt!.day} に保存しました。',
                  style: tokens.typography.caption
                      .copyWith(color: tokens.accentSuccess),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => _submitNps(tokens),
                child: Text(_submitted ? 'フィードバックを更新する' : 'フィードバックを送信する'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitNps(MinqTheme tokens) async {
    final prefs = ref.read(localPreferencesServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    await prefs.saveNpsResponse(
      score: _npsScore,
      comment: _commentController.text,
    );
    final response = await prefs.loadNpsResponse();
    setState(() {
      _submitted = true;
      _recordedAt = response?.recordedAt.toLocal();
      _initialNpsScore = _npsScore;
      _initialComment = _commentController.text.trim();
    });
    _updateUnsavedState();

    // TODO(agent): Re-implement with FeedbackMessenger if a non-static version is available
    // to preserve original toast appearance.
    messenger.showSnackBar(
      const SnackBar(content: Text('ご協力ありがとうございます！')),
    );
  }
}

class _BatteryOptimizationCard extends StatelessWidget {
  const _BatteryOptimizationCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const instructions = <String>[
      'Android: 設定 > アプリと通知 > 特別なアプリアクセス > 電池の最適化 で MinQ を「最適化しない」に設定してください。',
      'iOS: 設定 > 一般 > Appのバックグラウンド更新 から MinQ をオンにして通知を維持してください。',
      'どの端末でも、省電力モードが有効な場合は通知が遅れることがあります。学習時間に合わせて解除することをおすすめします。',
    ];

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.lg)),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '通知が届かない場合のチェックリスト',
              style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing.sm),
            ...instructions.map(
              (instruction) => Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: tokens.typography.body
                          .copyWith(color: tokens.brandPrimary),
                    ),
                    Expanded(
                      child: Text(
                        instruction,
                        style: tokens.typography.body
                            .copyWith(color: tokens.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportActionTile extends StatelessWidget {
  const _SupportActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onCopy,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: tokens.brandPrimary),
        SizedBox(width: tokens.spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style:
                    tokens.typography.body.copyWith(color: tokens.textPrimary),
              ),
              SizedBox(height: tokens.spacing.xs),
              SelectableText(
                subtitle,
                style:
                    tokens.typography.caption.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onCopy,
          icon: Icon(Icons.copy, color: tokens.textMuted),
          tooltip: 'Copy',
        ),
      ],
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.questionJa,
    required this.questionEn,
    required this.answerJa,
    required this.answerEn,
  });

  final String questionJa;
  final String questionEn;
  final String answerJa;
  final String answerEn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.sm),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(bottom: tokens.spacing.xs),
        title: Text(
          questionJa,
          style: tokens.typography.body.copyWith(color: tokens.textPrimary),
        ),
        subtitle: Text(
          questionEn,
          style: tokens.typography.caption.copyWith(color: tokens.textMuted),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius.md)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.md),
        ),
        children: <Widget>[
          Text(
            answerJa,
            style: tokens.typography.caption.copyWith(color: tokens.textPrimary),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            answerEn,
            style: tokens.typography.caption.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }
}
