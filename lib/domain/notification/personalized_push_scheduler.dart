class UserEngagementSnapshot {
  const UserEngagementSnapshot({
    required this.completedQuests,
    required this.missedQuests,
    required this.lastEngagedAt,
    required this.optedIn,
  });

  final int completedQuests;
  final int missedQuests;
  final DateTime? lastEngagedAt;
  final bool optedIn;

  double get completionRate {
    final total = completedQuests + missedQuests;
    if (total == 0) return 0;
    return completedQuests / total;
  }
}

class PushSchedulePlan {
  PushSchedulePlan({
    required this.nextSchedule,
    required this.interval,
    required this.reason,
  });

  final DateTime nextSchedule;
  final Duration interval;
  final String reason;
}

class PersonalizedPushScheduler {
  const PersonalizedPushScheduler({
    this.minimumInterval = const Duration(hours: 4),
    this.maximumInterval = const Duration(days: 3),
  });

  final Duration minimumInterval;
  final Duration maximumInterval;

  PushSchedulePlan buildPlan({
    required UserEngagementSnapshot engagement,
    required DateTime now,
  }) {
    if (!engagement.optedIn) {
      return PushSchedulePlan(
        nextSchedule: now.add(maximumInterval),
        interval: maximumInterval,
        reason: 'ユーザーが通知をオプトアウトしています。',
      );
    }

    final completionRate = engagement.completionRate;
    final timeSinceEngagement = engagement.lastEngagedAt == null
        ? maximumInterval
        : now.difference(engagement.lastEngagedAt!);

    final urgency = _urgency(completionRate: completionRate, inactivity: timeSinceEngagement);
    final interval = _interpolateInterval(urgency);
    final nextSchedule = now.add(interval);

    final reason = _buildReason(
      completionRate: completionRate,
      inactivity: timeSinceEngagement,
      interval: interval,
    );

    return PushSchedulePlan(
      nextSchedule: nextSchedule,
      interval: interval,
      reason: reason,
    );
  }

  double _urgency({required double completionRate, required Duration inactivity}) {
    final completionPenalty = 1 - completionRate;
    final inactivityHours = inactivity.inHours.clamp(0, 72);
    final inactivityScore = inactivityHours / 72;
    return (completionPenalty * 0.6) + (inactivityScore * 0.4);
  }

  Duration _interpolateInterval(double urgency) {
    final clamped = urgency.clamp(0.0, 1.0);
    final minMs = minimumInterval.inMilliseconds.toDouble();
    final maxMs = maximumInterval.inMilliseconds.toDouble();
    final interpolated = maxMs - (maxMs - minMs) * clamped;
    return Duration(milliseconds: interpolated.round());
  }

  String _buildReason({
    required double completionRate,
    required Duration inactivity,
    required Duration interval,
  }) {
    final buffer = StringBuffer();
    if (completionRate < 0.4) {
      buffer.write('達成率が下がっているため、リマインドを増やします。');
    } else {
      buffer.write('安定しているため、ゆるやかなペースで通知します。');
    }

    if (inactivity > const Duration(hours: 12)) {
      buffer.write(' 最終利用から${inactivity.inHours}時間が経過しています。');
    }

    buffer.write(' 次回通知まで${interval.inHours}時間です。');
    return buffer.toString();
  }
}
