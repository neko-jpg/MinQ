import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/home/home_view_data.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/controllers/home_data_controller.dart';
import 'package:minq/presentation/controllers/sync_status_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/ai_concierge_card.dart';
import 'package:minq/presentation/widgets/failure_prediction_widget.dart';
import 'package:minq/presentation/widgets/gamification_status_card.dart';
import 'package:minq/presentation/widgets/level_progress_widget.dart';
import 'package:minq/presentation/widgets/live_activity_widget.dart';
import 'package:minq/presentation/widgets/referral_card.dart';

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
      if (!mounted || !next.showBanner || next.bannerMessage == null) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.bannerMessage!),
              duration: const Duration(seconds: 2),
            ),
          );
        ref.read(syncStatusProvider.notifier).acknowledgeBanner();
      });
    });
  }

  @override
  void dispose() {
    _syncStatusSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final syncStatus = ref.watch(syncStatusProvider);
    final homeAsync = ref.watch(homeDataProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double maxWidth = 640;
            Widget child = homeAsync.when(
              loading: () => const _HomeScreenSkeleton(),
              error:
                  (error, _) => _HomeStateMessage(
                    icon: Icons.error_outline,
                    title: 'ホームデータの取得に失敗しました',
                    message: '通信状態を確認して再度お試しください。',
                    action: FilledButton.icon(
                      onPressed: () => ref.invalidate(homeDataProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('再読み込み'),
                    ),
                  ),
              data:
                  (data) => _HomeContent(
                    data: data,
                    isOffline: syncStatus.phase == SyncPhase.offline,
                    onRetry: () => ref.invalidate(homeDataProvider),
                  ),
            );

            if (constraints.maxWidth > maxWidth) {
              child = Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxWidth),
                  child: child,
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.isOffline,
    required this.onRetry,
  });

  final HomeViewData data;
  final bool isOffline;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final miniQuests =
        data.quests.where((quest) => quest.category == 'MiniQuest').toList();

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(4),
        vertical: tokens.spacing(4),
      ),
      children: [
        if (isOffline) ...[
          _HomeOfflineNotice(onRetry: onRetry),
          SizedBox(height: tokens.spacing(4)),
        ],
        const _Header(),
        SizedBox(height: tokens.spacing(4)),
        const LiveActivityWidget(compact: true),
        SizedBox(height: tokens.spacing(4)),
        _TodayFocusCard(data: data),
        SizedBox(height: tokens.spacing(4)),
        _MiniQuestsSection(miniQuests: miniQuests),
        SizedBox(height: tokens.spacing(4)),
        const AiConciergeCard(),
        SizedBox(height: tokens.spacing(4)),
        _WeeklyStreakCard(recentLogs: data.recentLogs),
        SizedBox(height: tokens.spacing(4)),
        const GamificationStatusCard(),
        SizedBox(height: tokens.spacing(4)),
        const ReferralCard(),
        SizedBox(height: tokens.spacing(4)),
        const LevelProgressWidget(isCompact: true),
        SizedBox(height: tokens.spacing(4)),
        const FailurePredictionWidget(),
        SizedBox(height: tokens.spacing(8)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Home',
          style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tokens.spacing(2)),
        Text(
          '今日のフォーカスとMiniQuestをチェックして、一日のスタートを切りましょう。',
          style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }
}

class _TodayFocusCard extends ConsumerWidget {
  const _TodayFocusCard({required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final focus = data.focus;
    final quests = data.quests;
    final focusQuest =
        focus == null
            ? null
            : quests.firstWhereOrNull((q) => q.id == focus.questId);

    final bool hasCompletedToday = data.recentLogs.any((log) {
      return focus != null &&
          log.questId == focus.questId &&
          DateUtils.isSameDay(log.timestamp, DateTime.now());
    });

    final double progress = hasCompletedToday ? 1.0 : 0.4;
    final navigation = ref.read(navigationUseCaseProvider);

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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today’s Focus',
                    style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                  ),
                  SizedBox(height: tokens.spacing(1)),
                  Text(
                    focusQuest?.title ?? 'AIがあなたの習慣を学習中です',
                    style: tokens.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.spacing(1)),
                  Text(
                    focus?.headline ?? 'MiniQuestを作成して取り組むと、ここに今日のおすすめが表示されます。',
                    style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.spacing(3)),
                  FilledButton.icon(
                    onPressed: navigation.goToCreateMiniQuest,
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.brandPrimary,
                    ),
                    icon: const Icon(Icons.add_task),
                    label: const Text('MiniQuestを作成'),
                  ),
                ],
              ),
            ),
            SizedBox(width: tokens.spacing(4)),
            SizedBox(
              width: tokens.spacing(20),
              height: tokens.spacing(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation(tokens.brandPrimary),
                      backgroundColor: tokens.brandPrimary.withValues(alpha: 0.1),
                    ),
                  ),
                  Icon(
                    focusQuest != null
                        ? iconDataForKey(
                          focusQuest.iconKey,
                          fallback: Icons.auto_awesome,
                        )
                        : Icons.auto_awesome,
                    size: tokens.spacing(8),
                    color: tokens.brandPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniQuestsSection extends ConsumerWidget {
  const _MiniQuestsSection({required this.miniQuests});

  final List<HomeQuestItem> miniQuests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final navigation = ref.read(navigationUseCaseProvider);

    if (miniQuests.isEmpty) {
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
            title: 'MiniQuestはまだありません',
            message: 'まずは1件MiniQuestを作成して、習慣づくりを始めましょう。',
            actionArea: FilledButton(
              onPressed: navigation.goToCreateMiniQuest,
              child: const Text('MiniQuestを作成'),
            ),
          ),
        ),
      );
    }

    final display = miniQuests.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Mini-Quests',
              style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: navigation.goToQuests,
              child: const Text('一覧を見る'),
            ),
          ],
        ),
        SizedBox(height: tokens.spacing(2)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: display.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemBuilder:
              (context, index) => _MiniQuestTile(quest: display[index]),
        ),
      ],
    );
  }
}

class _MiniQuestTile extends StatelessWidget {
  const _MiniQuestTile({required this.quest});

  final HomeQuestItem quest;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tokens.brandPrimary, tokens.brandPrimary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: tokens.cornerLarge(),
      ),
      padding: EdgeInsets.all(tokens.spacing(3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: tokens.spacing(7),
                height: tokens.spacing(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: tokens.cornerMedium(),
                ),
                child: Icon(
                  iconDataForKey(quest.iconKey, fallback: Icons.task_alt),
                  color: Colors.white,
                  size: tokens.spacing(4),
                ),
              ),
              const Spacer(),
              Container(
                width: tokens.spacing(6),
                height: tokens.spacing(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing(3)),
          Text(
            quest.title,
            style: tokens.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (quest.estimatedMinutes > 0) ...[
            SizedBox(height: tokens.spacing(1)),
            Text(
              '${quest.estimatedMinutes}分',
              style: tokens.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklyStreakCard extends StatelessWidget {
  const _WeeklyStreakCard({required this.recentLogs});

  final List<HomeLogItem> recentLogs;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final hasLog = recentLogs.any(
        (log) => DateUtils.isSameDay(log.timestamp, date),
      );
      return (date: date, hasLog: hasLog);
    });

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
              'Weekly Streak',
              style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing(3)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  weekDays.map((day) {
                    final isToday = DateUtils.isSameDay(day.date, now);
                    return Column(
                      children: [
                        Text(
                          _weekdayName(day.date.weekday),
                          style: tokens.bodySmall.copyWith(
                            color:
                                isToday ? tokens.textPrimary : tokens.textMuted,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: tokens.spacing(2)),
                        Container(
                          width: tokens.spacing(8),
                          height: tokens.spacing(8),
                          decoration: BoxDecoration(
                            color:
                                day.hasLog
                                    ? tokens.brandPrimary
                                    : tokens.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child:
                              day.hasLog
                                  ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                  : null,
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}

class _HomeScreenSkeleton extends StatelessWidget {
  const _HomeScreenSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ListView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      children: [
        MinqSkeleton(height: tokens.spacing(20)),
        SizedBox(height: tokens.spacing(4)),
        MinqSkeleton(height: tokens.spacing(30)),
        SizedBox(height: tokens.spacing(4)),
        MinqSkeleton(height: tokens.spacing(40)),
      ],
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
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: tokens.spacing(16), color: tokens.textMuted),
            SizedBox(height: tokens.spacing(4)),
            Text(
              title,
              style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              message,
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: tokens.spacing(4)),
              action!,
            ],
          ],
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
    return Container(
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.orange, size: tokens.spacing(6)),
          SizedBox(width: tokens.spacing(3)),
          Expanded(
            child: Text(
              'オフラインモードです',
              style: tokens.bodyMedium.copyWith(color: Colors.orange),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('再接続')),
        ],
      ),
    );
  }
}
