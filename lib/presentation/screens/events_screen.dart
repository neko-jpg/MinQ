import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/challenges/event_manager.dart';
import 'package:minq/core/events/event_system.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/event_card.dart';

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
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
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
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 注目イベント
          if (activeEvents.isNotEmpty) ...[
            _FeaturedEventCard(event: activeEvents.first),
            SizedBox(height: tokens.spacing(4)),
          ],

          // イベント一覧
          Text(
            '参加可能なイベント',
            style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing(3)),
          ...activeEvents.map(
            (event) => Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing(3)),
              child: EventCard(
                event: event,
                onTap: () => _showEventDetail(context, event),
                onJoin: () => _joinEvent(context, ref, event),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetail(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventDetailSheet(event: event),
    );
  }

  Future<void> _joinEvent(
    BuildContext context,
    WidgetRef ref,
    Event event,
  ) async {
    final uid = ref.read(uidProvider);
    if (uid == null) {
      FeedbackMessenger.showErrorSnackBar(context, 'ユーザーがサインインしていません');
      return;
    }

    try {
      final eventManager = ref.read(eventManagerProvider);
      await eventManager.registerForEvent(userId: uid, eventId: event.id);

      if (context.mounted) {
        FeedbackMessenger.showSuccessToast(context, '${event.title}に参加しました！');
      }
    } catch (e) {
      if (context.mounted) {
        FeedbackMessenger.showErrorSnackBar(context, 'イベント参加に失敗しました');
      }
    }
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
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今後のイベント',
            style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing(3)),
          ...upcomingEvents.map(
            (event) => Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing(3)),
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
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '過去のイベント',
            style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing(3)),
          ...pastEvents.map(
            (event) => Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing(3)),
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
          colors: [tokens.brandPrimary, tokens.brandPrimary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: tokens.cornerLarge(),
        boxShadow: tokens.shadowSoft,
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(tokens.spacing(2)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: tokens.cornerMedium(),
                  ),
                  child: Text(event.icon, style: const TextStyle(fontSize: 24)),
                ),
                SizedBox(width: tokens.spacing(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '注目イベント',
                        style: tokens.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        event.title,
                        style: tokens.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing(2),
                    vertical: tokens.spacing(1),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: tokens.cornerSmall(),
                  ),
                  child: Text(
                    '残り$daysLeft日',
                    style: tokens.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing(3)),
            Text(
              event.description,
              style: tokens.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: tokens.spacing(4)),
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
                SizedBox(width: tokens.spacing(2)),
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
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(tokens.spacing(2)),
                  decoration: BoxDecoration(
                    color: tokens.textMuted.withOpacity(0.1),
                    borderRadius: tokens.cornerMedium(),
                  ),
                  child: Text(event.icon, style: const TextStyle(fontSize: 24)),
                ),
                SizedBox(width: tokens.spacing(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: tokens.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        event.description,
                        style: tokens.bodyMedium.copyWith(
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
                    horizontal: tokens.spacing(2),
                    vertical: tokens.spacing(1),
                  ),
                  decoration: BoxDecoration(
                    color: tokens.textMuted.withOpacity(0.1),
                    borderRadius: tokens.cornerSmall(),
                  ),
                  child: Text(
                    '$daysUntil日後',
                    style: tokens.bodySmall.copyWith(
                      color: tokens.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing(3)),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: tokens.textMuted),
                SizedBox(width: tokens.spacing(1)),
                Text(
                  '${event.startDate.month}月${event.startDate.day}日開始',
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
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
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(tokens.spacing(2)),
                  decoration: BoxDecoration(
                    color: tokens.textMuted.withOpacity(0.1),
                    borderRadius: tokens.cornerMedium(),
                  ),
                  child: Text(
                    event.icon,
                    style: TextStyle(
                      fontSize: 24,
                      color: tokens.textMuted.withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacing(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: tokens.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: tokens.textMuted,
                        ),
                      ),
                      Text(
                        '${event.startDate.month}月${event.startDate.day}日 - ${event.endDate.month}月${event.endDate.day}日',
                        style: tokens.bodySmall.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing(2),
                    vertical: tokens.spacing(1),
                  ),
                  decoration: BoxDecoration(
                    color: tokens.encouragement.withOpacity(0.1),
                    borderRadius: tokens.cornerSmall(),
                  ),
                  child: Text(
                    '完了', // TODO: 実際の参加状況を表示
                    style: tokens.bodySmall.copyWith(
                      color: tokens.encouragement,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing(3)),
            // 報酬表示
            if (event.rewards.isNotEmpty) ...[
              Text(
                '獲得した報酬',
                style: tokens.bodySmall.copyWith(color: tokens.textMuted),
              ),
              SizedBox(height: tokens.spacing(1)),
              Wrap(
                spacing: tokens.spacing(2),
                children:
                    event.rewards.map((reward) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.spacing(2),
                          vertical: tokens.spacing(1),
                        ),
                        decoration: BoxDecoration(
                          color: tokens.joyAccent.withOpacity(0.1),
                          borderRadius: tokens.cornerSmall(),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reward.icon,
                              style: const TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: tokens.spacing(1)),
                            Text(
                              reward.title,
                              style: tokens.bodySmall.copyWith(
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
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: tokens.textMuted),
            SizedBox(height: tokens.spacing(4)),
            Text(
              title,
              style: tokens.titleMedium.copyWith(
                color: tokens.textMuted,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              subtitle,
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: BorderRadius.vertical(top: tokens.cornerXLarge().topLeft),
      ),
      child: Column(
        children: [
          // ハンドル
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: tokens.spacing(2)),
            decoration: BoxDecoration(
              color: tokens.border,
              borderRadius: tokens.cornerSmall(),
            ),
          ),

          // ヘッダー
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacing(4)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'イベント詳細',
                    style: tokens.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Divider(color: tokens.border),

          // コンテンツ
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // イベント情報
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(tokens.spacing(3)),
                        decoration: BoxDecoration(
                          color: tokens.brandPrimary.withOpacity(0.1),
                          borderRadius: tokens.cornerLarge(),
                        ),
                        child: Text(
                          event.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      SizedBox(width: tokens.spacing(4)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: tokens.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: tokens.spacing(1)),
                            Text(
                              _getEventTypeLabel(event.type),
                              style: tokens.bodySmall.copyWith(
                                color: tokens.brandPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: tokens.spacing(4)),

                  // 説明
                  Text(
                    '説明',
                    style: tokens.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  Text(
                    event.description,
                    style: tokens.bodyMedium.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),

                  SizedBox(height: tokens.spacing(4)),

                  // 期間
                  _InfoRow(
                    icon: Icons.schedule,
                    label: '開催期間',
                    value:
                        '${event.startDate.month}月${event.startDate.day}日 - ${event.endDate.month}月${event.endDate.day}日',
                  ),

                  SizedBox(height: tokens.spacing(2)),

                  // 要件
                  _InfoRow(
                    icon: Icons.flag,
                    label: '達成条件',
                    value: '${event.requirements.minCompletions}回完了',
                  ),

                  if (event.requirements.minStreak > 0) ...[
                    SizedBox(height: tokens.spacing(2)),
                    _InfoRow(
                      icon: Icons.local_fire_department,
                      label: '必要ストリーク',
                      value: '${event.requirements.minStreak}日連続',
                    ),
                  ],

                  SizedBox(height: tokens.spacing(4)),

                  // 報酬
                  if (event.rewards.isNotEmpty) ...[
                    Text(
                      '報酬',
                      style: tokens.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(2)),
                    ...event.rewards.map(
                      (reward) => Padding(
                        padding: EdgeInsets.only(bottom: tokens.spacing(2)),
                        child: Container(
                          padding: EdgeInsets.all(tokens.spacing(3)),
                          decoration: BoxDecoration(
                            color: tokens.joyAccent.withOpacity(0.1),
                            borderRadius: tokens.cornerMedium(),
                            border: Border.all(
                              color: tokens.joyAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                reward.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                              SizedBox(width: tokens.spacing(3)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reward.title,
                                      style: tokens.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      reward.description,
                                      style: tokens.bodySmall.copyWith(
                                        color: tokens.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: tokens.spacing(6)),

                  // 参加ボタン
                  if (event.isActive)
                    MinqPrimaryButton(
                      label: 'イベントに参加',
                      icon: Icons.event_available,
                      onPressed: () {
                        // TODO: イベント参加処理
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.challenge:
        return 'チャレンジ';
      case EventType.seasonal:
        return '季節イベント';
      case EventType.weekly:
        return '週次イベント';
      case EventType.special:
        return '特別イベント';
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Icon(icon, size: 16, color: tokens.textMuted),
        SizedBox(width: tokens.spacing(2)),
        Text(label, style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
        SizedBox(width: tokens.spacing(2)),
        Expanded(
          child: Text(
            value,
            style: tokens.bodySmall.copyWith(color: tokens.textPrimary),
          ),
        ),
      ],
    );
  }
}
