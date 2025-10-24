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
          style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '戻る',
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
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              color: tokens.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radius.xl),
                side: BorderSide(color: tokens.border),
              ),
              child: Padding(
                padding: EdgeInsets.all(tokens.spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: tokens.brandPrimary.withAlpha(25),
                            borderRadius:
                                BorderRadius.circular(tokens.radius.lg),
                          ),
                          child: Icon(
                            icon,
                            size: 32,
                            color: tokens.brandPrimary,
                          ),
                        ),
                        SizedBox(width: tokens.spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quest.title,
                                style: tokens.typography.h2.copyWith(
                                  color: tokens.textPrimary,
                                ),
                              ),
                              SizedBox(height: tokens.spacing.xs),
                              Wrap(
                                spacing: tokens.spacing.xs,
                                runSpacing: tokens.spacing.xs,
                                children: [
                                  _QuestInfoChip(
                                    icon: Icons.category_outlined,
                                    label: quest.category,
                                  ),
                                  _QuestInfoChip(
                                    icon: Icons.timer_outlined,
                                    label: '${quest.estimatedMinutes}分想定',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacing.md),
                    Text(
                      'このクエストについて',
                      style: tokens.typography.h4.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      '短い時間で取り組める${quest.category}クエストです。'
                      '記録するとペアに進捗が共有され、次の継続に向けたリマインダーも届きます。',
                      style: tokens.typography.body.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                    contactLinkAsync.when(
                      data: (link) {
                        final sanitized = link?.trim() ?? '';
                        if (sanitized.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: tokens.spacing.md),
                          child: _ContactLinkButton(link: sanitized),
                        );
                      },
                      loading:
                          () => Padding(
                            padding: EdgeInsets.only(top: tokens.spacing.md),
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
              label: '今すぐ開始',
              icon: Icons.play_arrow,
              onPressed: () async {
                navigation.goToQuestTimer(quest.id);
              },
            ),
            SizedBox(height: tokens.spacing.xs),
            MinqSecondaryButton(
              label: 'このクエストを記録する',
              onPressed: () async {
                navigation.goToRecord(quest.id);
              },
            ),
            SizedBox(height: tokens.spacing.xs),
            Row(
              children: [
                Expanded(
                  child: MinqSecondaryButton(
                    label: '編集',
                    onPressed: () async {
                      navigation.goToEditQuest(quest.id);
                    },
                  ),
                ),
                SizedBox(width: tokens.spacing.xs),
                Expanded(
                  child: MinqSecondaryButton(
                    label: '一覧に戻る',
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
          FeedbackMessenger.showErrorSnackBar(context, 'リンクの形式が正しくありません。');
          return;
        }
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && context.mounted) {
          FeedbackMessenger.showErrorSnackBar(context, 'リンクを開けませんでした。');
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
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 56,
              color: tokens.textMuted,
            ),
            SizedBox(height: tokens.spacing.md),
            Text(
              'クエストが見つかりませんでした',
              style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing.xs),
            Text(
              'リンクが古い可能性があります。クエスト一覧から探し直してください。',
              style: tokens.typography.body.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing.md),
            MinqSecondaryButton(
              label: 'クエスト一覧に戻る',
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
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: tokens.accentError,
            ),
            SizedBox(height: tokens.spacing.md),
            Text(
              'クエスト情報を読み込めませんでした',
              style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing.xs),
            Text(
              '通信状況を確認してからもう一度お試しください。',
              style: tokens.typography.body.copyWith(color: tokens.textMuted),
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
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withAlpha(25),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tokens.brandPrimary),
          SizedBox(width: tokens.spacing.xs),
          Text(
            label,
            style: tokens.typography.caption.copyWith(color: tokens.brandPrimary),
          ),
        ],
      ),
    );
  }
}
