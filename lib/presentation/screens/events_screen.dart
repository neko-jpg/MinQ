import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/events/event_system.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final EventSystem _eventSystem = EventSystem();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'イベント',
          style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: tokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '開催中'), Tab(text: '予定'), Tab(text: '過去')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ActiveEventsTab(eventSystem: _eventSystem),
          _UpcomingEventsTab(eventSystem: _eventSystem),
          _PastEventsTab(eventSystem: _eventSystem),
        ],
      ),
    );
  }
}

class _ActiveEventsTab extends ConsumerWidget {
  const _ActiveEventsTab({required this.eventSystem});

  final EventSystem eventSystem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final activeEvents = eventSystem.getActiveEvents();

    if (activeEvents.isEmpty) {
      return const _EmptyEventState(
        icon: Icons.event_busy,
        title: '開催中のイベントはありません',
        subtitle: '新しいイベントをお楽しみに！',
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 注目イベント
          if (activeEvents.isNotEmpty) ...[
            _FeaturedEventCard(event: activeEvents.first),
            SizedBox(height: tokens.spacing.lg),
          ],

          // イベント一覧
          Text(
            '参加可能なイベント',
            style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing.md),
          ...activeEvents.map(
            (event) => Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing.md),
              child: _FeaturedEventCard(
                event: event,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEventsTab extends ConsumerWidget {
  const _UpcomingEventsTab({required this.eventSystem});

  final EventSystem eventSystem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final upcomingEvents = eventSystem.getUpcomingEvents();

    if (upcomingEvents.isEmpty) {
      return const _EmptyEventState(
        icon: Icons.schedule,
        title: '予定されているイベントはありません',
        subtitle: '新しいイベントの企画をお待ちください',
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今後のイベント',
            style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing.md),
          ...upcomingEvents.map(
            (event) => Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing.md),
              child: _UpcomingEventCard(event: event),
            ),
          ),
        ],
      ),
    );
  }
}

class _PastEventsTab extends ConsumerWidget {
  const _PastEventsTab({required this.eventSystem});

  final EventSystem eventSystem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final pastEvents = eventSystem.getPastEvents();

    if (pastEvents.isEmpty) {
      return const _EmptyEventState(
        icon: Icons.history,
        title: '過去のイベントはありません',
        subtitle: 'イベントに参加して履歴を作りましょう',
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '過去のイベント',
            style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing.md),
          ...pastEvents.map(
            (event) => Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing.md),
              child: _PastEventCard(event: event),
            ),
          ),
        ],
      ),
    );
  }
}

// 補助ウィジェット
class _FeaturedEventCard extends StatelessWidget {
  const _FeaturedEventCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final daysLeft = event.endDate.difference(DateTime.now()).inDays;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tokens.brandPrimary, tokens.brandPrimary.withAlpha(204)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        boxShadow: tokens.shadow.soft,
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(tokens.spacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(tokens.radius.md),
                  ),
                  child: Text(event.icon, style: const TextStyle(fontSize: 24)),
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '注目イベント',
                        style: tokens.typography.caption.copyWith(
                          color: Colors.white.withAlpha(204),
                        ),
                      ),
                      Text(
                        event.title,
                        style: tokens.typography.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.sm,
                    vertical: tokens.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(tokens.radius.sm),
                  ),
                  child: Text(
                    '残り$daysLeft日',
                    style: tokens.typography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.md),
            Text(
              event.description,
              style: tokens.typography.body.copyWith(
                color: Colors.white.withAlpha(230),
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: イベント詳細画面に遷移
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: tokens.brandPrimary,
                    ),
                    child: const Text('詳細を見る'),
                  ),
                ),
                SizedBox(width: tokens.spacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: イベント参加処理
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    child: const Text('参加する'),
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

class _UpcomingEventCard extends StatelessWidget {
  const _UpcomingEventCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final daysUntil = event.startDate.difference(DateTime.now()).inDays;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(tokens.spacing.sm),
                  decoration: BoxDecoration(
                    color: tokens.textMuted.withAlpha(26),
                    borderRadius: BorderRadius.circular(tokens.radius.md),
                  ),
                  child: Text(event.icon, style: const TextStyle(fontSize: 24)),
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: tokens.typography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        event.description,
                        style: tokens.typography.body.copyWith(
                          color: tokens.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.sm,
                    vertical: tokens.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.textMuted.withAlpha(26),
                    borderRadius: BorderRadius.circular(tokens.radius.sm),
                  ),
                  child: Text(
                    '$daysUntil日後',
                    style: tokens.typography.caption.copyWith(
                      color: tokens.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.md),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: tokens.textMuted),
                SizedBox(width: tokens.spacing.xs),
                Text(
                  '${event.startDate.month}月${event.startDate.day}日開始',
                  style: tokens.typography.caption.copyWith(color: tokens.textMuted),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: リマインダー設定
                  },
                  child: const Text('リマインダー設定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PastEventCard extends StatelessWidget {
  const _PastEventCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(tokens.spacing.sm),
                  decoration: BoxDecoration(
                    color: tokens.textMuted.withAlpha(26),
                    borderRadius: BorderRadius.circular(tokens.radius.md),
                  ),
                  child: Text(
                    event.icon,
                    style: TextStyle(
                      fontSize: 24,
                      color: tokens.textMuted.withAlpha(153),
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: tokens.typography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: tokens.textMuted,
                        ),
                      ),
                      Text(
                        '${event.startDate.month}月${event.startDate.day}日 - ${event.endDate.month}月${event.endDate.day}日',
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.sm,
                    vertical: tokens.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.encouragement.withAlpha(26),
                    borderRadius: BorderRadius.circular(tokens.radius.sm),
                  ),
                  child: Text(
                    '完了', // TODO: 実際の参加状況を表示
                    style: tokens.typography.caption.copyWith(
                      color: tokens.encouragement,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.md),
            // 報酬表示
            if (event.rewards.isNotEmpty) ...[
              Text(
                '獲得した報酬',
                style: tokens.typography.caption.copyWith(color: tokens.textMuted),
              ),
              SizedBox(height: tokens.spacing.xs),
              Wrap(
                spacing: tokens.spacing.sm,
                children:
                    event.rewards.map((reward) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.spacing.sm,
                          vertical: tokens.spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.joyAccent.withAlpha(26),
                          borderRadius: BorderRadius.circular(tokens.radius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reward.icon,
                              style: const TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: tokens.spacing.xs),
                            Text(
                              reward.title,
                              style: tokens.typography.caption.copyWith(
                                color: tokens.joyAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyEventState extends StatelessWidget {
  const _EmptyEventState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: tokens.textMuted),
            SizedBox(height: tokens.spacing.lg),
            Text(
              title,
              style: tokens.typography.h4.copyWith(
                color: tokens.textMuted,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing.sm),
            Text(
              subtitle,
              style: tokens.typography.body.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
