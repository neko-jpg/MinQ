
import 'package:minq/presentation/routing/app_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Text(
      "ホーム",
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _TodaysFocusSection extends ConsumerWidget {
  const _TodaysFocusSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final questsAsync = ref.watch(userQuestsProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: questsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text("エラー: $err"),
          data: (quests) {
            final focusQuest = quests.firstOrNull;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "今日のフォーカス",
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      focusQuest?.title ?? "クエストなし",
                      style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (focusQuest != null)
                      Text(
                        "${focusQuest.estimatedMinutes}分",
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 0.7, // TODO: Implement progress logic
                        strokeWidth: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                      Icon(iconDataForKey(focusQuest?.iconKey), size: 32, color: colorScheme.primary),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MiniQuestsSection extends ConsumerWidget {
  const _MiniQuestsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final questsAsync = ref.watch(userQuestsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "あなたのミニクエスト",
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton.filled(
              onPressed: () => ref.read(navigationUseCaseProvider).goToCreateQuest(),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        questsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text("エラー: $err"),
          data: (quests) {
            if (quests.isEmpty) {
              return const Text("今日のクエストはありません。");
            }
            return GridView.builder(
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
            );
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final recentLogsAsync = ref.watch(recentLogsProvider);

    final isCompleted = recentLogsAsync.when(
      data: (logs) {
        final now = DateTime.now();
        return logs.any((log) =>
            log.questId == quest.id &&
            log.ts.year == now.year &&
            log.ts.month == now.month &&
            log.ts.day == now.day);
      },
      loading: () => false,
      error: (_, __) => false,
    );

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(iconDataForKey(quest.iconKey), color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.title,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (quest.category.isNotEmpty)
                          Text(
                            quest.category,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                            ),
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
                color: isCompleted ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.3),
              ),
              child: isCompleted ? Icon(Icons.check, size: 16, color: colorScheme.primary) : null,
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
    final textTheme = Theme.of(context).textTheme;
    final streakAsync = ref.watch(streakProvider);
    final completedTodayAsync = ref.watch(todayCompletionCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "統計スナップショット",
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            streakAsync.when(
              data: (streak) => _StatCircle(value: (streak % 7) / 7, label: "継続日数", stat: "$streak"),
              loading: () => const _StatCircle(value: 0, label: "継続日数", stat: "-"),
              error: (_, __) => const _StatCircle(value: 0, label: "継続日数", stat: "!"),
            ),
            completedTodayAsync.when(
              data: (count) => _StatCircle(value: count > 0 ? 1 : 0, label: "クエスト完了", stat: "$count"),
              loading: () => const _StatCircle(value: 0, label: "クエスト完了", stat: "-"),
              error: (_, __) => const _StatCircle(value: 0, label: "クエスト完了", stat: "!"),
            ),
            const _StatCircle(value: 0.0, label: "パートナー進捗", stat: ""), // TODO: Implement partner progress
          ],
        ),
      ],
    );
  }
}

class _StatCircle extends StatelessWidget {
  const _StatCircle({required this.value, required this.label, required this.stat});

  final double value;
  final String label;
  final String stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
              if (stat.isNotEmpty)
                Text(stat, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _WeeklyStreakSection extends ConsumerWidget {
  const _WeeklyStreakSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final recentLogsAsync = ref.watch(recentLogsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "週間ストリーク",
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: recentLogsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text("エラー: $err"),
              data: (logs) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _buildDayItems(context, logs),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDayItems(BuildContext context, List<QuestLog> logs) {
    final now = DateTime.now();
    final todayWeekday = now.weekday;
    final List<Widget> items = [];

    for (int i = 1; i <= 7; i++) {
      final dayToDisplay = now.subtract(Duration(days: todayWeekday - i));
      final isCompleted = logs.any((log) =>
          log.ts.year == dayToDisplay.year &&
          log.ts.month == dayToDisplay.month &&
          log.ts.day == dayToDisplay.day);
      
      items.add(
        _DayItem(
          day: ["月", "火", "水", "木", "金", "土", "日"][dayToDisplay.weekday - 1],
          isCompleted: isCompleted,
          isToday: dayToDisplay.day == now.day && dayToDisplay.month == now.month,
        ),
      );
    }
    return items;
  }
}

class _DayItem extends StatelessWidget {
  const _DayItem({required this.day, required this.isCompleted, this.isToday = false});

  final String day;
  final bool isCompleted;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          day,
          style: textTheme.bodyMedium?.copyWith(
            color: isToday ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
      ],
    );
  }
}
