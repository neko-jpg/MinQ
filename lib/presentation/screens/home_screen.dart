import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/data/providers.dart';
import 'package:minq/domain/home/home_view_data.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/controllers/home_data_controller.dart';
import 'package:minq/presentation/controllers/sync_status_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ProviderSubscription<SyncStatus>? _syncStatusSubscription;

  @override
  void initState() {
    super.initState();
    _syncStatusSubscription = ref.listenManual<SyncStatus>(syncStatusProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;
      if (next.showBanner && next.bannerMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(next.bannerMessage!),
              duration: const Duration(seconds: 2),
            ),
          );
          ref.read(syncStatusProvider.notifier).acknowledgeBanner();
        });
      }
    });
  }

  @override
  void dispose() {
    _syncStatusSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);
    final HomeViewData? data = homeDataAsync.valueOrNull;
    final bool hasCachedContent = data?.hasCachedContent ?? false;
    final bool isLoading = homeDataAsync.isLoading && !hasCachedContent;
    final bool hasError = homeDataAsync.hasError && !hasCachedContent;
    final SyncStatus syncStatus = ref.watch(syncStatusProvider);
    final bool isOffline = syncStatus.phase == SyncPhase.offline;

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const maxContentWidth = 640.0;

            Widget child;
            if (isLoading) {
              child = const _HomeScreenSkeleton();
            } else if (isOffline && !hasCachedContent) {
              child = _HomeStateMessage(
                icon: Icons.wifi_off,
                title: 'オフラインになっています',
                message: 'ネットワーク接続を確認してから再読み込みしてください。',
                action: FilledButton.icon(
                  onPressed: () => ref.invalidate(homeDataProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('再読み込み'),
                ),
              );
            } else if (hasError) {
              child = _HomeStateMessage(
                icon: Icons.error_outline,
                title: 'データの読み込みに失敗しました',
                message: '時間をおいてから再度お試しください。',
                action: FilledButton.icon(
                  onPressed: () => ref.invalidate(homeDataProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('再試行'),
                ),
              );
            } else {
              final tokens = context.tokens;
              final HomeViewData content = data ?? HomeViewData.empty();
              final bool isContentEmpty =
                  content.quests.isEmpty &&
                  content.recentLogs.isEmpty &&
                  content.completionsToday == 0;

              if (isContentEmpty) {
                child = const _HomeEmptyBody();
              } else {
                final verticalGap = tokens.spacing(4);
                final List<Widget> children = <Widget>[
                  if (isOffline) ...<Widget>[
                    _HomeOfflineNotice(
                      onRetry: () => ref.invalidate(homeDataProvider),
                    ),
                    SizedBox(height: verticalGap),
                  ],
                  const _Header(),
                  SizedBox(height: verticalGap),
                  _FocusHeroCard(data: content),
                  SizedBox(height: verticalGap),
                  _HomeHighlights(data: content),
                  SizedBox(height: tokens.spacing(8)),
                  _WeeklyStreakSection(data: content),
                ];

                child = ListView(
                  padding: EdgeInsets.only(
                    left: tokens.spacing(4),
                    right: tokens.spacing(4),
                    top: verticalGap,
                    bottom:
                        tokens.spacing(4) +
                        mediaQuery.padding.bottom +
                        kBottomNavigationBarHeight,
                  ),
                  children: children,
                );
              }
            }

            if (constraints.maxWidth <= maxContentWidth) {
              return child;
            }

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxContentWidth),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeScreenSkeleton extends StatelessWidget {
  const _HomeScreenSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing(4),
            vertical: tokens.spacing(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: MinqSkeletonLine(
                  width: 160,
                  height: 28,
                  borderRadius: tokens.cornerMedium(),
                ),
              ),
              SizedBox(height: tokens.spacing(6)),
              MinqSkeleton(height: 180, borderRadius: tokens.cornerXLarge()),
              SizedBox(height: tokens.spacing(6)),
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = tokens.spacing(4);
                  if (constraints.maxWidth < 520) {
                    return Column(
                      children: [
                        MinqSkeleton(
                          height: 220,
                          borderRadius: tokens.cornerLarge(),
                        ),
                        SizedBox(height: spacing),
                        MinqSkeleton(
                          height: 220,
                          borderRadius: tokens.cornerLarge(),
                        ),
                      ],
                    );
                  }

                  final cardWidth = (constraints.maxWidth - spacing) / 2;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: MinqSkeleton(
                          height: 220,
                          borderRadius: tokens.cornerLarge(),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: MinqSkeleton(
                          height: 220,
                          borderRadius: tokens.cornerLarge(),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: tokens.spacing(8)),
              MinqSkeleton(height: 160, borderRadius: tokens.cornerLarge()),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeStateMessage extends StatelessWidget {
  const _HomeStateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing(4),
          vertical: tokens.spacing(10),
        ),
        child: MinqEmptyState(
          icon: icon,
          title: title,
          message: message,
          actionArea: action,
        ),
      ),
    );
  }
}

class _HomeOfflineNotice extends StatelessWidget {
  const _HomeOfflineNotice({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.wifi_off, color: tokens.textMuted),
            SizedBox(width: tokens.spacing(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'オフラインで閲覧中',
                    style: tokens.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing(1)),
                  Text(
                    '接続が戻ると自動的に同期が再開されます。',
                    style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('再試行')),
          ],
        ),
      ),
    );
  }
}

class _HomeEmptyBody extends ConsumerWidget {
  const _HomeEmptyBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final navigation = ref.read(navigationUseCaseProvider);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing(4),
          vertical: tokens.spacing(10),
        ),
        child: MinqEmptyState(
          icon: Icons.auto_awesome,
          title: '今日のフォーカスを設定してみましょう',
          message: 'クエストを作成すると優先タスクや進捗がここに表示されます。',
          actionArea: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: navigation.goToCreateQuest,
                icon: const Icon(Icons.add_task),
                label: const Text('クエストを作成する'),
              ),
              SizedBox(height: tokens.spacing(2)),
              OutlinedButton.icon(
                onPressed: navigation.goToQuests,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('テンプレートを見る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return Text(
      'ホーム',
      textAlign: TextAlign.center,
      style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _FocusHeroCard extends ConsumerWidget {
  const _FocusHeroCard({required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final navigation = ref.read(navigationUseCaseProvider);
    final focus = data.focus;
    final quests = data.quests;
    final recentLogs = data.recentLogs;
    final focusQuest =
        focus != null
            ? quests.firstWhereOrNull(
              (HomeQuestItem quest) => quest.id == focus.questId,
            )
            : null;

    if (focus == null || focusQuest == null) {
      return Card(
        color: tokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.cornerXLarge(),
          side: BorderSide(color: tokens.border),
        ),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI今日のフォーカス',
                style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
              ),
              SizedBox(height: tokens.spacing(2)),
              Text(
                focus == null ? 'AIが学習中です' : '対象のクエストが見つかりません',
                style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: tokens.spacing(4)),
              Text(
                focus == null
                    ? '進捗データを収集すると、AIが今日取り組むべきクエストを提案します。'
                    : 'クエストが削除された可能性があります。新しいクエストを追加して提案を再取得してください。',
                style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: tokens.spacing(4)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => navigation.goToCreateQuest(),
                  child: const Text('クエストを作成する'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final hasCompletedToday = recentLogs.any(
      (log) =>
          log.questId == focus.questId &&
          log.timestamp.year == now.year &&
          log.timestamp.month == now.month &&
          log.timestamp.day == now.day,
    );
    final progress = hasCompletedToday ? 1.0 : 0.0;

    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerXLarge(),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI今日のフォーカス',
              style: tokens.bodyMedium.copyWith(
                color: tokens.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              focus.headline,
              style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: tokens.spacing(3)),
            Text(
              focusQuest.title,
              style: tokens.titleMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: tokens.spacing(4)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressRing(
                  progress: progress,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconDataForKey(focusQuest.iconKey),
                        size: tokens.spacing(6),
                        color: tokens.brandPrimary,
                      ),
                      SizedBox(height: tokens.spacing(2)),
                      Text(
                        '今日達成',
                        style: tokens.bodySmall.copyWith(
                          color: tokens.brandPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  emptyChild: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconDataForKey(focusQuest.iconKey),
                        size: tokens.spacing(6),
                        color: tokens.textMuted,
                      ),
                      SizedBox(height: tokens.spacing(2)),
                      Text(
                        '未完了',
                        style: tokens.bodySmall.copyWith(
                          color: tokens.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tokens.spacing(4)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'カテゴリ・所要時間',
                        style: tokens.bodySmall.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                      SizedBox(height: tokens.spacing(1)),
                      Text(
                        '${focusQuest.category}・${focusQuest.estimatedMinutes}分',
                        style: tokens.bodyMedium.copyWith(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: tokens.spacing(3)),
                      Text(
                        focus.rationale,
                        style: tokens.bodyMedium.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      SizedBox(height: tokens.spacing(3)),
                      Wrap(
                        spacing: tokens.spacing(2),
                        runSpacing: tokens.spacing(2),
                        children: [
                          ...focus.supportingFacts.map(
                            (fact) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: tokens.spacing(2.5),
                                vertical: tokens.spacing(1.5),
                              ),
                              decoration: BoxDecoration(
                                color: tokens.surfaceVariant,
                                borderRadius: tokens.cornerMedium(),
                              ),
                              child: Text(
                                fact,
                                style: tokens.bodySmall.copyWith(
                                  color: tokens.textMuted,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: tokens.spacing(2.5),
                              vertical: tokens.spacing(1.5),
                            ),
                            decoration: BoxDecoration(
                              color: tokens.brandPrimary.withOpacity(0.12),
                              borderRadius: tokens.cornerMedium(),
                            ),
                            child: Text(
                              'AI信頼度 ${(focus.confidence * 100).round()}%',
                              style: tokens.bodySmall.copyWith(
                                color: tokens.brandPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.spacing(4)),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed:
                                () => navigation.goToRecord(focus.questId),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('今すぐ記録'),
                          ),
                          SizedBox(width: tokens.spacing(2)),
                          OutlinedButton.icon(
                            onPressed:
                                () => navigation.goToQuestDetail(focus.questId),
                            icon: const Icon(Icons.info_outline),
                            label: const Text('詳細を見る'),
                          ),
                        ],
                      ),
                    ],
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

class _HomeHighlights extends StatelessWidget {
  const _HomeHighlights({required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalGap = tokens.spacing(4);
        final isWide = constraints.maxWidth >= 560;

        final cards = <Widget>[
          _MiniQuestsCard(quests: data.quests, recentLogs: data.recentLogs),
          _StatsSnapshotCard(data: data),
        ];

        if (!isWide) {
          return Column(
            children: [
              for (int index = 0; index < cards.length; index++) ...[
                cards[index],
                if (index < cards.length - 1) SizedBox(height: horizontalGap),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            SizedBox(width: horizontalGap),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }
}

class _MiniQuestsCard extends ConsumerStatefulWidget {
  const _MiniQuestsCard({required this.quests, required this.recentLogs});

  final List<HomeQuestItem> quests;
  final List<HomeLogItem> recentLogs;

  @override
  ConsumerState<_MiniQuestsCard> createState() => _MiniQuestsCardState();
}

class _MiniQuestsCardState extends ConsumerState<_MiniQuestsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final quests = widget.quests;
    final recentLogs = widget.recentLogs;
    final navigation = ref.read(navigationUseCaseProvider);

    if (quests.isEmpty) {
      return Card(
        color: tokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.cornerLarge(),
          side: BorderSide(color: tokens.border),
        ),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing(4)),
          child: MinqEmptyState(
            icon: Icons.auto_awesome,
            title: 'ミニクエストはまだありません',
            message: 'クエストを作成すると今日取り組む項目がここに表示されます。',
            actionArea: ElevatedButton(
              onPressed: () => navigation.goToCreateQuest(),
              child: const Text('クエストを作成する'),
            ),
          ),
        ),
      );
    }

    final visibleCount = _expanded ? quests.length : math.min(quests.length, 2);

    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'あなたのミニクエスト',
                  style: tokens.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton.filled(
                  onPressed: () => navigation.goToCreateQuest(),
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: tokens.brandPrimary,
                    minimumSize: const Size.square(48),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing(2)),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: ListView.separated(
                key: ValueKey<bool>(_expanded),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: visibleCount,
                separatorBuilder:
                    (_, __) => SizedBox(height: tokens.spacing(2)),
                itemBuilder: (context, index) {
                  final quest = quests[index];
                  return _QuestSummaryRow(
                    quest: quest,
                    isCompleted: _isCompletedToday(quest, recentLogs),
                  );
                },
              ),
            ),
            if (quests.length > visibleCount) ...[
              SizedBox(height: tokens.spacing(4)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = true),
                  child: const Text('もっと見る'),
                ),
              ),
            ] else if (_expanded) ...[
              SizedBox(height: tokens.spacing(4)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = false),
                  child: const Text('閉じる'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isCompletedToday(HomeQuestItem quest, List<HomeLogItem> recentLogs) {
    final now = DateTime.now();
    return recentLogs.any((log) {
      return log.questId == quest.id &&
          log.timestamp.year == now.year &&
          log.timestamp.month == now.month &&
          log.timestamp.day == now.day;
    });
  }
}

class _QuestSummaryRow extends StatelessWidget {
  const _QuestSummaryRow({required this.quest, required this.isCompleted});

  final HomeQuestItem quest;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        Container(
          width: tokens.spacing(8),
          height: tokens.spacing(8),
          decoration: BoxDecoration(
            color: tokens.brandPrimary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconDataForKey(quest.iconKey),
            color: tokens.brandPrimary,
          ),
        ),
        SizedBox(width: tokens.spacing(2)),
        Expanded(
          child: Text(
            quest.title,
            style: tokens.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: tokens.spacing(2)),
        Container(
          width: tokens.spacing(6),
          height: tokens.spacing(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? tokens.brandPrimary : Colors.transparent,
            border: Border.all(
              color: isCompleted ? tokens.brandPrimary : tokens.border,
            ),
          ),
          child:
              isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
        ),
      ],
    );
  }
}

class _StatsSnapshotCard extends StatelessWidget {
  const _StatsSnapshotCard({required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final streak = data.streak;
    final completedToday = data.completionsToday;

    final statItems = <_StatData>[
      _StatData(
        value: (streak % 7) / 7.0,
        label: '継続日数',
        stat: '$streak',
        emptyLabel: '記録なし',
        emptyIcon: Icons.local_fire_department_outlined,
      ),
      _StatData(
        value: completedToday > 0 ? 1.0 : 0.0,
        label: 'クエスト完了',
        stat: '$completedToday',
        emptyLabel: '未完了',
        emptyIcon: Icons.flag_outlined,
      ),
      const _StatData(
        value: 0.0,
        label: 'ペア進捗',
        stat: '',
        emptyLabel: 'データなし',
        emptyIcon: Icons.groups_2_outlined,
      ),
    ];

    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日の進捗',
              style: tokens.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing(4)),
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = tokens.spacing(4);
                if (constraints.maxWidth >= 480) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final data in statItems)
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: _StatCircle(data: data),
                          ),
                        ),
                    ],
                  );
                }

                return Column(
                  children: [
                    for (int i = 0; i < statItems.length; i++) ...[
                      _StatCircle(data: statItems[i]),
                      if (i < statItems.length - 1) SizedBox(height: gap),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.value,
    required this.label,
    required this.stat,
    required this.emptyLabel,
    required this.emptyIcon,
  });

  final double value;
  final String label;
  final String stat;
  final String emptyLabel;
  final IconData emptyIcon;
}

class _StatCircle extends StatelessWidget {
  const _StatCircle({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasProgress = data.value > 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ProgressRing(
          progress: data.value,
          child:
              hasProgress
                  ? Center(
                    child: Text(
                      data.stat.isEmpty ? '--' : data.stat,
                      style: tokens.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : const SizedBox.shrink(),
          emptyChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                data.emptyIcon,
                size: tokens.spacing(6),
                color: tokens.textMuted,
              ),
              SizedBox(height: tokens.spacing(2)),
              Text(
                data.emptyLabel,
                style: tokens.bodySmall.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spacing(2)),
        Text(
          data.label,
          style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.child,
    this.emptyChild,
  });

  final double progress;
  final Widget child;
  final Widget? emptyChild;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasProgress = progress > 0;
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(
              tokens.border.withOpacity(0.3),
            ),
            backgroundColor: Colors.transparent,
          ),
          if (hasProgress)
            CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
              backgroundColor: Colors.transparent,
            ),
          Padding(
            padding: EdgeInsets.all(tokens.spacing(2)),
            child: hasProgress ? child : (emptyChild ?? child),
          ),
        ],
      ),
    );
  }
}

class _WeeklyStreakSection extends StatelessWidget {
  const _WeeklyStreakSection({required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final recentLogs = data.recentLogs;
    final dayItems = _buildDayStatuses(recentLogs);

    return Card(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '週間ストリーク',
              style: tokens.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing(4)),
            Row(
              children: [
                for (int i = 0; i < dayItems.length; i++) ...[
                  Expanded(child: _DayItem(status: dayItems[i])),
                  if (i < dayItems.length - 1)
                    SizedBox(width: tokens.spacing(2)),
                ],
              ],
            ),
            SizedBox(height: tokens.spacing(4)),
            const _StreakLegend(),
          ],
        ),
      ),
    );
  }

  List<_DayStatus> _buildDayStatuses(List<HomeLogItem> logs) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    const labels = ['月', '火', '水', '木', '金', '土', '日'];

    return List<_DayStatus>.generate(7, (index) {
      final dayToDisplay = startOfWeek.add(Duration(days: index));
      final isCompleted = logs.any(
        (log) => DateUtils.isSameDay(log.timestamp, dayToDisplay),
      );

      return _DayStatus(
        label: labels[index],
        isCompleted: isCompleted,
        isToday: DateUtils.isSameDay(dayToDisplay, today),
      );
    });
  }
}

class _DayStatus {
  const _DayStatus({
    required this.label,
    required this.isCompleted,
    required this.isToday,
  });

  final String label;
  final bool isCompleted;
  final bool isToday;
}

class _DayItem extends StatelessWidget {
  const _DayItem({required this.status});

  final _DayStatus status;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bool isCompleted = status.isCompleted;
    final bool isToday = status.isToday;

    final tooltipLabel = isCompleted ? '達成' : '未達成';

    return Tooltip(
      message: '${status.label}曜: $tooltipLabel',
      waitDuration: const Duration(milliseconds: 250),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.label,
            style: tokens.bodyMedium.copyWith(
              color: isToday ? tokens.textPrimary : tokens.textMuted,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: tokens.spacing(2)),
          _StreakDot(isCompleted: isCompleted, highlight: isToday),
        ],
      ),
    );
  }
}

class _StreakDot extends StatelessWidget {
  const _StreakDot({required this.isCompleted, this.highlight = false});

  final bool isCompleted;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final double size = tokens.spacing(5);
    final Widget dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? tokens.brandPrimary : Colors.transparent,
        border: isCompleted ? null : Border.all(color: tokens.border, width: 2),
      ),
    );

    if (!highlight) {
      return dot;
    }

    return Container(
      padding: EdgeInsets.all(tokens.spacing(1)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: tokens.brandPrimary, width: 2),
      ),
      child: dot,
    );
  }
}

class _StreakLegend extends StatelessWidget {
  const _StreakLegend();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Wrap(
      spacing: tokens.spacing(4),
      runSpacing: tokens.spacing(2),
      alignment: WrapAlignment.center,
      children: const [
        _LegendEntry(label: '実績あり', isCompleted: true),
        _LegendEntry(label: '未達成', isCompleted: false),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.label, required this.isCompleted});

  final String label;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StreakDot(isCompleted: isCompleted),
        SizedBox(width: tokens.spacing(2)),
        Text(label, style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
      ],
    );
  }
}
