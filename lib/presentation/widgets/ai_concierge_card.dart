import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/controllers/ai_concierge_chat_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

enum _ConciergeMenuOption { insights, clearHistory }

class AiConciergeCard extends ConsumerWidget {
  const AiConciergeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final chatState = ref.watch(aiConciergeChatControllerProvider);
    final navigation = ref.read(navigationUseCaseProvider);
    final notifier = ref.read(aiConciergeChatControllerProvider.notifier);

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: InkWell(
        borderRadius: tokens.cornerLarge(),
        onTap: navigation.goToAiConciergeChat,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'AIコンシェルジュ',
                    style: tokens.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<_ConciergeMenuOption>(
                    icon: Icon(Icons.more_horiz, color: tokens.textMuted),
                    itemBuilder:
                        (context) => const [
                          PopupMenuItem<_ConciergeMenuOption>(
                            value: _ConciergeMenuOption.insights,
                            child: Text('AIからのインサイト'),
                          ),
                          PopupMenuItem<_ConciergeMenuOption>(
                            value: _ConciergeMenuOption.clearHistory,
                            child: Text('チャット履歴を削除'),
                          ),
                        ],
                    onSelected: (option) async {
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
                                  content: const Text(
                                    'すべてのチャット履歴を削除しますか？この操作は取り消せません。',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('キャンセル'),
                                    ),
                                    FilledButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('削除'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirmed == true) {
                            await notifier.resetConversation();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(
                                    content: Text('チャット履歴を削除しました'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                            }
                          }
                          break;
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: tokens.spacing(3)),
              chatState.when(
                data: (messages) => _ConversationPreview(messages: messages),
                loading:
                    () => Row(
                      children: [
                        SizedBox(
                          width: tokens.spacing(6),
                          height: tokens.spacing(6),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              tokens.brandPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: tokens.spacing(3)),
                        Text(
                          'Gemmaが準備中です...',
                          style: tokens.bodyMedium.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                error:
                    (_, __) => Text(
                      'AIコンシェルジュを読み込めませんでした。',
                      style: tokens.bodyMedium.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
              ),
              SizedBox(height: tokens.spacing(4)),
              _InputPlaceholderRow(tokens: tokens),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationPreview extends StatelessWidget {
  const _ConversationPreview({required this.messages});

  final List<AiConciergeMessage> messages;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final latestAi = messages.lastWhere(
      (message) => !message.isUser,
      orElse:
          () =>
              messages.isNotEmpty
                  ? messages.last
                  : AiConciergeMessage(
                    text: 'Gemmaが今日のインサイトを準備中です。',
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
    );
    final latestUser = messages.lastWhereOrNull((message) => message.isUser);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: tokens.spacing(10),
              height: tokens.spacing(10),
              decoration: BoxDecoration(
                color: tokens.brandPrimary.withOpacity(0.12),
                borderRadius: tokens.cornerLarge(),
              ),
              child: Icon(
                Icons.psychology,
                color: tokens.brandPrimary,
                size: tokens.spacing(6),
              ),
            ),
            SizedBox(width: tokens.spacing(3)),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing(3),
                  vertical: tokens.spacing(2),
                ),
                decoration: BoxDecoration(
                  color: tokens.surfaceVariant,
                  borderRadius: tokens.cornerLarge(),
                ),
                child: Text(
                  latestAi.text,
                  style: tokens.bodyMedium.copyWith(height: 1.5),
                ),
              ),
            ),
          ],
        ),
        if (latestUser != null) ...[
          SizedBox(height: tokens.spacing(2)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing(3),
                      vertical: tokens.spacing(2),
                    ),
                    decoration: BoxDecoration(
                      color: tokens.brandPrimary.withOpacity(0.12),
                      borderRadius: tokens.cornerLarge(),
                    ),
                    child: Text(
                      latestUser.text,
                      style: tokens.bodyMedium.copyWith(
                        color: tokens.brandPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: tokens.spacing(2)),
        Text(
          'タップしてGemmaと会話を始める',
          style: tokens.bodySmall.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }
}

class _InputPlaceholderRow extends StatelessWidget {
  const _InputPlaceholderRow({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing(3),
              vertical: tokens.spacing(2),
            ),
            decoration: BoxDecoration(
              color: tokens.surfaceVariant,
              borderRadius: tokens.cornerXLarge(),
            ),
            child: Text(
              'メッセージを入力...',
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            ),
          ),
        ),
        SizedBox(width: tokens.spacing(2)),
        Container(
          width: tokens.spacing(10),
          height: tokens.spacing(10),
          decoration: BoxDecoration(
            color: tokens.brandPrimary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.send, color: Colors.white),
        ),
      ],
    );
  }
}
