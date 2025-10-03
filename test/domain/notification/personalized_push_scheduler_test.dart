import 'package:flutter_test/flutter_test.dart';

import 'package:minq/domain/notification/personalized_push_scheduler.dart';

void main() {
  group('PersonalizedPushScheduler', () {
    const scheduler = PersonalizedPushScheduler();
    final now = DateTime.utc(2024, 4, 1, 12);

    test('backs off when user opted out', () {
      final plan = scheduler.buildPlan(
        engagement: const UserEngagementSnapshot(
          completedQuests: 0,
          missedQuests: 0,
          lastEngagedAt: null,
          optedIn: false,
        ),
        now: now,
      );

      expect(plan.interval, scheduler.maximumInterval);
      expect(plan.nextSchedule, now.add(scheduler.maximumInterval));
    });

    test('shortens interval when completion rate is low', () {
      final plan = scheduler.buildPlan(
        engagement: const UserEngagementSnapshot(
          completedQuests: 1,
          missedQuests: 4,
          lastEngagedAt: null,
          optedIn: true,
        ),
        now: now,
      );

      expect(plan.interval, lessThan(scheduler.maximumInterval));
    });

    test('keeps interval long for consistent users', () {
      final plan = scheduler.buildPlan(
        engagement: UserEngagementSnapshot(
          completedQuests: 10,
          missedQuests: 1,
          lastEngagedAt: now.subtract(const Duration(hours: 2)),
          optedIn: true,
        ),
        now: now,
      );

      expect(plan.interval, greaterThan(const Duration(hours: 12)));
    });
  });
}
