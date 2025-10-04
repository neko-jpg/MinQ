import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class QuestDetailScreen extends ConsumerWidget {
  const QuestDetailScreen({super.key, required this.questId});

  final int questId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final questAsync = ref.watch(questByIdProvider(questId));

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'クエスト詳細',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '戻めE,
          onPressed: () => context.pop(),
        ),
        backgroundColor: tokens.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: questAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _QuestDetailError(tokens: tokens),
        data: (quest) {
          if (quest == null) {
            return _QuestDetailNotFound(tokens: tokens);
          }
          return _QuestDetailContent(quest: quest);
        },
      ),
    );
  }
}

class _QuestDetailContent extends ConsumerWidget {
  const _QuestDetailContent({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final icon = iconDataForKey(quest.iconKey);
    final navigation = ref.read(navigationUseCaseProvider);
    final contactLinkAsync = ref.watch(questContactLinkProvider(quest.id));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing(4),
          vertical: tokens.spacing(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              color: tokens.surface,
              shape: RoundedRectangleBorder(
                borderRadius: tokens.cornerXLarge(),
                side: BorderSide(color: tokens.border),
              ),
              child: Padding(
                padding: EdgeInsets.all(tokens.spacing(5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: tokens.spacing(12),
                          height: tokens.spacing(12),
                          decoration: BoxDecoration(
                            color: tokens.brandPrimary.withValues(alpha: 0.1),
                            borderRadius: tokens.cornerLarge(),
                          ),
                          child: Icon(
                            icon,
                            size: tokens.spacing(8),
                            color: tokens.brandPrimary,
                          ),
                        ),
                        SizedBox(width: tokens.spacing(4)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quest.title,
                                style: tokens.displaySmall
                                    .copyWith(color: tokens.textPrimary),
                              ),
                              SizedBox(height: tokens.spacing(2)),
                              Wrap(
                                spacing: tokens.spacing(2),
                                runSpacing: tokens.spacing(2),
                                children: [
                                  _QuestInfoChip(
                                    icon: Icons.category_outlined,
                                    label: quest.category,
                                  ),
                                  _QuestInfoChip(
                                    icon: Icons.timer_outlined,
                                    label: '${quest.estimatedMinutes}刁E��宁E,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacing(4)),
                    Text(
                      'こ�EクエストにつぁE��',
                      style: tokens.titleSmall.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(2)),
                    Text(
                      '短ぁE��間で取り絁E��めE{quest.category}クエストです、E
                      '記録するとペアに進捗が共有され、次の継続に向けたリマインダーも届きます、E,
                      style:
                          tokens.bodyMedium.copyWith(color: tokens.textMuted),
                    ),
                    contactLinkAsync.when(
                      data: (link) {
                        final sanitized = link?.trim() ?? '';
                        if (sanitized.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: tokens.spacing(4)),
                          child: _ContactLinkButton(link: sanitized),
                        );
                      },
                      loading: () => Padding(
                        padding: EdgeInsets.only(top: tokens.spacing(4)),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            MinqPrimaryButton(
              label: 'こ�Eクエストを記録する',
              onPressed: () async {
                navigation.goToRecord(quest.id);
              },
            ),
            SizedBox(height: tokens.spacing(2)),
            Row(
              children: [
                Expanded(
                  child: MinqSecondaryButton(
                    label: '編雁E,
                    onPressed: () async {
                      navigation.goToEditQuest(quest.id);
                    },
                  ),
                ),
                SizedBox(width: tokens.spacing(2)),
                Expanded(
                  child: MinqSecondaryButton(
                    label: '一覧に戻めE,
                    onPressed: () async {
                      navigation.goToQuests();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactLinkButton extends StatelessWidget {
  const _ContactLinkButton({required this.link});

  final String link;

  @override
  Widget build(BuildContext context) {
    return MinqSecondaryButton(
      label: 'ペアに連絡する',
      icon: Icons.link,
      onPressed: () async {
        final uri = Uri.tryParse(link);
        if (uri == null) {
          FeedbackMessenger.showErrorSnackBar(
            context,
            'リンクの形式が正しくありません、E,
          );
          return;
        }
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && context.mounted) {
          FeedbackMessenger.showErrorSnackBar(
            context,
            'リンクを開けませんでした、E,
          );
        }
      },
    );
  }
}

class _QuestDetailNotFound extends StatelessWidget {
  const _QuestDetailNotFound({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: tokens.spacing(14), color: tokens.textMuted),
            SizedBox(height: tokens.spacing(4)),
            Text(
              'クエストが見つかりませんでした',
              style:
                  tokens.titleSmall.copyWith(color: tokens.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              'リンクが古ぁE��能性があります。クエスト一覧から探し直してください、E,
              style: tokens.bodySmall.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing(4)),
            MinqSecondaryButton(
              label: 'クエスト一覧に戻めE,
              onPressed: () async {
                GoRouter.of(context).go(AppRoutes.quests);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestDetailError extends StatelessWidget {
  const _QuestDetailError({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: tokens.spacing(14), color: tokens.accentError),
            SizedBox(height: tokens.spacing(4)),
            Text(
              'クエスト情報を読み込めませんでした',
              style:
                  tokens.titleSmall.copyWith(color: tokens.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              '通信状況を確認してからもう一度お試しください、E,
              style: tokens.bodySmall.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestInfoChip extends StatelessWidget {
  const _QuestInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(3),
        vertical: tokens.spacing(2),
      ),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withValues(alpha: 0.1),
        borderRadius: tokens.cornerLarge(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: tokens.spacing(4), color: tokens.brandPrimary),
          SizedBox(width: tokens.spacing(2)),
          Text(
            label,
            style: tokens.bodySmall.copyWith(color: tokens.brandPrimary),
          ),
        ],
      ),
    );
  }
}
