import 'package:flutter/material.dart';
import 'package:minq/core/events/event_system.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onJoin,
    this.progress,
  });

  final Event event;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final EventProgress? progress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final daysLeft = event.endDate.difference(DateTime.now()).inDays;
    final isActive = event.isActive;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(
          color: isActive ? tokens.brandPrimary : tokens.border,
          width: isActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.cornerLarge(),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(tokens.spacing(2)),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? tokens.brandPrimary.withOpacity(0.1)
                          : tokens.textMuted.withOpacity(0.1),
                      borderRadius: tokens.cornerMedium(),
                    ),
                    child: Text(
                      event.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  SizedBox(width: tokens.spacing(3)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: tokens.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _EventStatusBadge(event: event),
                          ],
                        ),
                        SizedBox(height: tokens.spacing(1)),
                        Text(
                          _getEventTypeLabel(event.type),
                          style: tokens.bodySmall.copyWith(
                            color: isActive ? tokens.brandPrimary : tokens.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: tokens.spacing(3)),

              // 説明
              Text(
                event.description,
                style: tokens.bodyMedium.copyWith(
                  color: tokens.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: tokens.spacing(3)),

              // 進捗表示（参加中の場合）
              if (progress != null) ...[
                _EventProgressWidget(progress: progress!),
                SizedBox(height: tokens.spacing(3)),
              ],

              // 期間と報酬
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: tokens.textMuted,
                  ),
                  SizedBox(width: tokens.spacing(1)),
                  Text(
                    isActive 
                        ? '残り${daysLeft}日'
                        : '${event.startDate.month}/${event.startDate.day} - ${event.endDate.month}/${event.endDate.day}',
                    style: tokens.bodySmall.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                  const Spacer(),
                  if (event.rewards.isNotEmpty) ...[
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: tokens.joyAccent,
                    ),
                    SizedBox(width: tokens.spacing(1)),
                    Text(
                      '報酬${event.rewards.length}個',
                      style: tokens.bodySmall.copyWith(
                        color: tokens.joyAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: tokens.spacing(3)),

              // アクションボタン
              if (isActive) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onTap,
                        child: const Text('詳細'),
                      ),
                    ),
                    SizedBox(width: tokens.spacing(2)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onJoin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.brandPrimary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          progress != null ? '継続中' : '参加',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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

class _EventStatusBadge extends StatelessWidget {
  const _EventStatusBadge({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final now = DateTime.now();

    String label;
    Color color;

    if (now.isBefore(event.startDate)) {
      label = '予定';
      color = tokens.textMuted;
    } else if (now.isAfter(event.endDate)) {
      label = '終了';
      color = tokens.textMuted;
    } else {
      label = '開催中';
      color = tokens.encouragement;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(2),
        vertical: tokens.spacing(1),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: tokens.cornerSmall(),
      ),
      child: Text(
        label,
        style: tokens.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EventProgressWidget extends StatelessWidget {
  const _EventProgressWidget({required this.progress});

  final EventProgress progress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withOpacity(0.1),
        borderRadius: tokens.cornerMedium(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '進捗状況',
                style: tokens.bodySmall.copyWith(
                  color: tokens.brandPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${progress.completionCount}回完了',
                style: tokens.bodySmall.copyWith(
                  color: tokens.brandPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing(2)),
          LinearProgressIndicator(
            value: progress.progress.clamp(0.0, 1.0),
            backgroundColor: tokens.border,
            valueColor: AlwaysStoppedAnimation(tokens.brandPrimary),
          ),
          SizedBox(height: tokens.spacing(1)),
          if (progress.currentStreak > 0)
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 12,
                  color: tokens.encouragement,
                ),
                SizedBox(width: tokens.spacing(1)),
                Text(
                  '${progress.currentStreak}日連続',
                  style: tokens.bodySmall.copyWith(
                    color: tokens.encouragement,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// コンパクトなイベントカード
class CompactEventCard extends StatelessWidget {
  const CompactEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final daysLeft = event.endDate.difference(DateTime.now()).inDays;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerMedium(),
        side: BorderSide(color: tokens.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.cornerMedium(),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing(3)),
          child: Row(
            children: [
              Text(
                event.icon,
                style: const TextStyle(fontSize: 20),
              ),
              SizedBox(width: tokens.spacing(2)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: tokens.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '残り${daysLeft}日',
                      style: tokens.bodySmall.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: tokens.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// イベント参加者数表示ウィジェット
class EventParticipantCount extends StatelessWidget {
  const EventParticipantCount({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(2),
        vertical: tokens.spacing(1),
      ),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withOpacity(0.1),
        borderRadius: tokens.cornerSmall(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people,
            size: 12,
            color: tokens.brandPrimary,
          ),
          SizedBox(width: tokens.spacing(1)),
          Text(
            '$count人参加中',
            style: tokens.bodySmall.copyWith(
              color: tokens.brandPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// イベント報酬プレビューウィジェット
class EventRewardPreview extends StatelessWidget {
  const EventRewardPreview({
    super.key,
    required this.rewards,
  });

  final List<EventReward> rewards;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (rewards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(tokens.spacing(2)),
      decoration: BoxDecoration(
        color: tokens.joyAccent.withOpacity(0.1),
        borderRadius: tokens.cornerSmall(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...rewards.take(3).map((reward) => Padding(
                padding: EdgeInsets.only(right: tokens.spacing(1)),
                child: Text(
                  reward.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              )),
          if (rewards.length > 3) ...[
            Text(
              '+${rewards.length - 3}',
              style: tokens.bodySmall.copyWith(
                color: tokens.joyAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// イベント難易度表示ウィジェット
class EventDifficultyIndicator extends StatelessWidget {
  const EventDifficultyIndicator({
    super.key,
    required this.requirements,
  });

  final EventRequirements requirements;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    // 難易度を計算（簡易版）
    int difficulty = 1;
    if (requirements.minCompletions > 20) difficulty = 3;
    else if (requirements.minCompletions > 10) difficulty = 2;
    
    if (requirements.minStreak > 7) difficulty = 3;
    else if (requirements.minStreak > 3) difficulty = math.max(difficulty, 2);

    Color color;
    String label;
    
    switch (difficulty) {
      case 1:
        color = tokens.encouragement;
        label = '初級';
        break;
      case 2:
        color = tokens.joyAccent;
        label = '中級';
        break;
      case 3:
        color = tokens.warmth;
        label = '上級';
        break;
      default:
        color = tokens.textMuted;
        label = '不明';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(2),
        vertical: tokens.spacing(1),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: tokens.cornerSmall(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(3, (index) {
            return Icon(
              index < difficulty ? Icons.star : Icons.star_border,
              size: 12,
              color: color,
            );
          }),
          SizedBox(width: tokens.spacing(1)),
          Text(
            label,
            style: tokens.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math' as math;