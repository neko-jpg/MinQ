import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/data/providers.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart' as minq_quest;
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(userQuestsProvider);
    final streakAsync = ref.watch(streakProvider);
    final completedTodayAsync = ref.watch(todayCompletionCountProvider);
    final recentLogsAsync = ref.watch(recentLogsProvider);

    final isLoading = questsAsync.isLoading ||
        streakAsync.isLoading ||
        completedTodayAsync.isLoading ||
        recentLogsAsync.isLoading;

    final hasError = questsAsync.hasError ||
        streakAsync.hasError ||
        completedTodayAsync.hasError ||
        recentLogsAsync.hasError;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const _HomeScreenSkeleton()
            : hasError
                ? const Center(child: Text("データの読み込みに失敗しました。"))
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: const [
                      _Header(),
                      SizedBox(height: 24),
                      _TodaysFocusSection(),
                      SizedBox(height: 32),
                      _MiniQuestsSection(),
                      SizedBox(height: 32),
                      _StatsSnapshotSection(),
                      SizedBox(height: 32),
                      _WeeklyStreakSection(),
                    ],
                  ),
      ),
    );
  }
}

class _HomeScreenSkeleton extends StatelessWidget {
  const _HomeScreenSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: MinqSkeletonLine(width: 120, height: 28, borderRadius: tokens.cornerMedium())),
          const SizedBox(height: 24),
          MinqSkeleton(height: 130, borderRadius: tokens.cornerLarge()),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MinqSkeletonLine(width: 200, height: 24, borderRadius: tokens.cornerMedium()),
              const MinqSkeletonAvatar(size: 40),
            ],
          ),
          const SizedBox(height: 16),
          const MinqSkeletonGrid(crossAxisCount: 2, itemAspectRatio: 2.0, itemCount: 2),
          const SizedBox(height: 32),
          MinqSkeletonLine(width: 220, height: 24, borderRadius: tokens.cornerMedium()),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(3, (_) => const MinqSkeletonAvatar(size: 96)),
          ),
          const SizedBox(height: 32),
          MinqSkeletonLine(width: 180, height: 24, borderRadius: tokens.cornerMedium()),
          const SizedBox(height: 16),
          const MinqSkeleton(height: 80, borderRadius: tokens.cornerLarge()),
        ],
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
      "ホーム",
      textAlign: TextAlign.center,
      style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _TodaysFocusSection extends ConsumerWidget {
  const _TodaysFocusSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final quests = ref.watch(userQuestsProvider).valueOrNull ?? [];
    final focusQuest = quests.firstOrNull;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      color: tokens.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "今日のフォーカス",
                    style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    focusQuest?.title ?? "クエストなし",
                    style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (focusQuest != null)
                    Text(
                      "${focusQuest.estimatedMinutes}分",
                      style: tokens.bodyLarge.copyWith(color: tokens.textMuted),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 0.7, // TODO: Implement progress logic
                    strokeWidth: 8,
                    backgroundColor: tokens.border.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
                  ),
                  Icon(
                    iconDataForKey(focusQuest?.iconKey),
                    size: 32,
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
  const _MiniQuestsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final quests = ref.watch(userQuestsProvider).valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "あなたのミニクエスト",
              style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton.filled(
              onPressed: () => ref.read(navigationUseCaseProvider).goToCreateQuest(),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(backgroundColor: tokens.brandPrimary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (quests.isEmpty)
          const Center(child: Text("今日のクエストはありません。"))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.0,
            ),
            itemCount: quests.length,
            itemBuilder: (context, index) {
              return _QuestGridItem(quest: quests[index]);
            },
          ),
      ],
    );
  }
}

class _QuestGridItem extends ConsumerWidget {
  const _QuestGridItem({required this.quest});

  final minq_quest.Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final recentLogs = ref.watch(recentLogsProvider).valueOrNull ?? [];

    final isCompleted = recentLogs.any((log) {
      final now = DateTime.now();
      return log.questId == quest.id &&
          log.ts.year == now.year &&
          log.ts.month == now.month &&
          log.ts.day == now.day;
    });

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border)
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(iconDataForKey(quest.iconKey), color: tokens.brandPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.title,
                          style: tokens.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (quest.category.isNotEmpty)
                          Text(
                            quest.category,
                            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? tokens.brandPrimary : tokens.background,
                border: Border.all(color: isCompleted ? tokens.brandPrimary : tokens.border)
              ),
              child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsSnapshotSection extends ConsumerWidget {
  const _StatsSnapshotSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;
    final completedToday = ref.watch(todayCompletionCountProvider).valueOrNull ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "統計スナップショット",
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatCircle(
              value: (streak % 7) / 7.0,
              label: "継続日数",
              stat: "$streak",
            ),
            _StatCircle(
              value: completedToday > 0 ? 1 : 0,
              label: "クエスト完了",
              stat: "$completedToday",
            ),
            const _StatCircle(
              value: 0.0,
              label: "パートナー進捗",
              stat: "N/A",
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCircle extends StatelessWidget {
  const _StatCircle({
    required this.value,
    required this.label,
    required this.stat,
  });

  final double value;
  final String label;
  final String stat;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return Column(
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: tokens.border.withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
              ),
              if (stat.isNotEmpty)
                Text(
                  stat,
                  style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }
}

class _WeeklyStreakSection extends ConsumerWidget {
  const _WeeklyStreakSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final recentLogs = ref.watch(recentLogsProvider).valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "週間ストリーク",
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: tokens.surface,
          shape: RoundedRectangleBorder(
            borderRadius: tokens.cornerLarge(),
            side: BorderSide(color: tokens.border)
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buildDayItems(context, recentLogs),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDayItems(BuildContext context, List<QuestLog> logs) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final List<Widget> items = [];

    for (int i = 0; i < 7; i++) {
      final dayToDisplay = startOfWeek.add(Duration(days: i));
      final isCompleted = logs.any(
        (log) => DateUtils.isSameDay(log.ts, dayToDisplay),
      );

      items.add(
        _DayItem(
          day: ["月", "火", "水", "木", "金", "土", "日"][dayToDisplay.weekday - 1],
          isCompleted: isCompleted,
          isToday: DateUtils.isSameDay(dayToDisplay, today),
        ),
      );
    }
    return items;
  }
}

class _DayItem extends StatelessWidget {
  const _DayItem({
    required this.day,
    required this.isCompleted,
    this.isToday = false,
  });

  final String day;
  final bool isCompleted;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return Column(
      children: [
        Text(
          day,
          style: tokens.bodyMedium.copyWith(
            color: isToday ? tokens.textPrimary : tokens.textMuted,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? tokens.brandPrimary : tokens.background,
            border: Border.all(color: isCompleted ? tokens.brandPrimary : tokens.border),
          ),
          child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
        ),
      ],
    );
  }
}