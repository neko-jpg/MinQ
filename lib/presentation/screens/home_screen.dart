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

  @override
  Widget build(BuildContext context) {
    ref.listen<SyncStatus>(
      syncStatusProvider,
      (previous, next) {
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
      },
    );

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
        horizontal: tokens.spacing.lg,
        vertical: tokens.spacing.lg,
      ),
      children: [
        if (isOffline) ...[
          _HomeOfflineNotice(onRetry: onRetry),
          SizedBox(height: tokens.spacing.lg),
        ],
        const _Header(),
        SizedBox(height: tokens.spacing.lg),
        const LiveActivityWidget(compact: true),
        SizedBox(height: tokens.spacing.lg),
        _TodayFocusCard(data: data),
        SizedBox(height: tokens.spacing.lg),
        _MiniQuestsSection(miniQuests: miniQuests),
        SizedBox(height: tokens.spacing.lg),
        const AiConciergeCard(),
        SizedBox(height: tokens.spacing.lg),
        _WeeklyStreakCard(recentLogs: data.recentLogs),
        SizedBox(height: tokens.spacing.lg),
        const GamificationStatusCard(),
        SizedBox(height: tokens.spacing.lg),
        const ReferralCard(),
        SizedBox(height: tokens.spacing.lg),
        const LevelProgressWidget(isCompact: true),
        SizedBox(height: tokens.spacing.lg),
        const FailurePredictionWidget(),
        SizedBox(height: tokens.spacing.xl),
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
          style: tokens.typography.h2.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tokens.spacing.sm),
        Text(
          '今日のフォーカスとMiniQuestをチェックして、一日のスタートを切りましょう。',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
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
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today’s Focus',
                    style: tokens.typography.caption.copyWith(color: tokens.textMuted),
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    focusQuest?.title ?? 'AIがあなたの習慣を学習中です',
                    style: tokens.typography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    focus?.headline ?? 'MiniQuestを作成して取り組むと、ここに今日のおすすめが表示されます。',
                    style: tokens.typography.body.copyWith(color: tokens.textMuted),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.spacing.md),
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
            SizedBox(width: tokens.spacing.lg),
            SizedBox(
              width: tokens.spacing.xl * 2,
              height: tokens.spacing.xl * 2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation(tokens.brandPrimary),
                      backgroundColor: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
                    ),
                  ),
                  Icon(
                    focusQuest != null
                        ? iconDataForKey(
                          focusQuest.iconKey,
                          fallback: Icons.auto_awesome,
                        )
                        : Icons.auto_awesome,
                    size: tokens.spacing.xl,
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
          borderRadius: BorderRadius.circular(tokens.radius.lg),
          side: BorderSide(color: tokens.border),
        ),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.lg),
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
              style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: navigation.goToQuests,
              child: const Text('一覧を見る'),
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.sm),
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
          colors: [tokens.brandPrimary, tokens.brandPrimary.withAlpha((255 * 0.75).round())],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: tokens.spacing.lg + tokens.spacing.sm,
                height: tokens.spacing.lg + tokens.spacing.sm,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                child: Icon(
                  iconDataForKey(quest.iconKey, fallback: Icons.task_alt),
                  color: Colors.white,
                  size: tokens.spacing.lg,
                ),
              ),
              const Spacer(),
              Container(
                width: tokens.spacing.lg,
                height: tokens.spacing.lg,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((255 * 0.25).round()),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            quest.title,
            style: tokens.typography.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (quest.estimatedMinutes > 0) ...[
            SizedBox(height: tokens.spacing.xs),
            Text(
              '${quest.estimatedMinutes}分',
              style: tokens.typography.caption.copyWith(color: Colors.white70),
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
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Streak',
              style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  weekDays.map((day) {
                    final isToday = DateUtils.isSameDay(day.date, now);
                    return Column(
                      children: [
                        Text(
                          _weekdayName(day.date.weekday),
                          style: tokens.typography.caption.copyWith(
                            color:
                                isToday ? tokens.textPrimary : tokens.textMuted,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: tokens.spacing.sm),
                        Container(
                          width: tokens.spacing.xl,
                          height: tokens.spacing.xl,
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
      padding: EdgeInsets.all(tokens.spacing.lg),
      children: [
        MinqSkeleton(height: tokens.spacing.xl * 2),
        SizedBox(height: tokens.spacing.lg),
        MinqSkeleton(height: tokens.spacing.xl * 3),
        SizedBox(height: tokens.spacing.lg),
        MinqSkeleton(height: tokens.spacing.xl * 4),
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
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: tokens.spacing.xl * 1.5, color: tokens.textMuted),
            SizedBox(height: tokens.spacing.lg),
            Text(
              title,
              style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing.sm),
            Text(
              message,
              style: tokens.typography.body.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: tokens.spacing.lg),
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
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: Colors.orange.withAlpha((255 * 0.3).round())),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.orange, size: tokens.spacing.lg),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Text(
              'オフラインモードです',
              style: tokens.typography.body.copyWith(color: Colors.orange),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('再接続')),
        ],
      ),
    );
  }
}
