import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/navigation/navigation_use_case.dart';
import 'package:minq/domain/home/home_view_data.dart';
import 'package:minq/presentation/common/layout/responsive_layout.dart';
import 'package:minq/presentation/common/layout/safe_scaffold.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/controllers/home_data_controller.dart';
import 'package:minq/presentation/controllers/sync_status_controller.dart';
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

    final syncStatus = ref.watch(syncStatusProvider);
    final homeAsync = ref.watch(homeDataProvider);

    return SafeScaffold(
      body: homeAsync.when(
        loading: () => const _HomeScreenSkeleton(),
        error: (error, _) => _HomeStateMessage(
          icon: Icons.error_outline,
          title: 'ホームデータの取得に失敗しました',
          message: '通信状態を確認して再度お試しください。',
          action: ResponsiveLayout.ensureTouchTarget(
            child: FilledButton.icon(
              onPressed: () => ref.invalidate(homeDataProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('再読み込み'),
            ),
          ),
        ),
        data: (data) => _HomeContent(
          data: data,
          isOffline: syncStatus.phase == SyncPhase.offline,
          onRetry: () => ref.invalidate(homeDataProvider),
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

    return SafeScrollView(
      enableResponsiveLayout: true,
      maxContentWidth: ResponsiveLayout.maxContentWidth,
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Home',
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '今日のフォーカスとMiniQuestをチェックして、一日のスタートを切りましょう。',
          style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
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
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today’s Focus',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    focusQuest?.title ?? 'AIがあなたの習慣を学習中です',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    focus?.headline ?? 'MiniQuestを作成して取り組むと、ここに今日のおすすめが表示されます。',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  ResponsiveLayout.ensureTouchTarget(
                    child: ElevatedButton.icon(
                      onPressed: navigation.goToCreateMiniQuest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      icon: const Icon(Icons.add_task),
                      label: const Text('MiniQuestを作成'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      backgroundColor: colorScheme.primary.withAlpha((255 * 0.1).round()),
                    ),
                  ),
                  Icon(
                    focusQuest != null
                        ? iconDataForKey(
                          focusQuest.iconKey,
                          fallback: Icons.auto_awesome,
                        )
                        : Icons.auto_awesome,
                    size: 32,
                    color: colorScheme.primary,
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final navigation = ref.read(navigationUseCaseProvider);

    if (miniQuests.isEmpty) {
      return Card(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: MinqEmptyState(
            icon: Icons.auto_awesome,
            title: 'MiniQuestはまだありません',
            message: 'まずは1件MiniQuestを作成して、習慣づくりを始めましょう。',
            actionArea: ElevatedButton(
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
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: navigation.goToQuests,
              child: const Text('一覧を見る'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = context.responsiveColumns(maxColumns: 2);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: display.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: context.isMobile ? 1.45 : 1.2,
              ),
              itemBuilder: (context, index) => _MiniQuestTile(quest: display[index]),
            );
          },
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withAlpha((255 * 0.75).round())],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconDataForKey(quest.iconKey, fallback: Icons.task_alt),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((255 * 0.25).round()),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quest.title,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (quest.estimatedMinutes > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${quest.estimatedMinutes}分',
              style: textTheme.bodySmall?.copyWith(color: Colors.white70),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final hasLog = recentLogs.any(
        (log) => DateUtils.isSameDay(log.timestamp, date),
      );
      return (date: date, hasLog: hasLog);
    });

    return Card(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Streak',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  weekDays.map((day) {
                    final isToday = DateUtils.isSameDay(day.date, now);
                    return Flexible(
                      child: Column(
                        children: [
                          Text(
                            _weekdayName(day.date.weekday),
                            style: textTheme.bodySmall?.copyWith(
                              color:
                                  isToday ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color:
                                  day.hasLog
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerHighest,
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
                      ),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        MinqSkeleton(height: 64),
        SizedBox(height: 16),
        MinqSkeleton(height: 96),
        SizedBox(height: 16),
        MinqSkeleton(height: 128),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withAlpha((255 * 0.3).round())),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'オフラインモードです',
              style: textTheme.bodyMedium?.copyWith(color: Colors.orange),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('再接続')),
        ],
      ),
    );
  }
}
