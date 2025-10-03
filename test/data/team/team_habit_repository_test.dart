import 'package:flutter_test/flutter_test.dart';

import 'package:minq/data/team/team_habit_repository.dart';
import 'package:minq/domain/team/team_habit.dart';

void main() {
  group('InMemoryTeamHabitRepository', () {
    late InMemoryTeamHabitRepository repository;

    setUp(() {
      repository = InMemoryTeamHabitRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('creates a habit with owner as member', () async {
      final habit = await repository.createTeamHabit(
        ownerId: 'owner-1',
        ownerName: 'Owner',
        name: 'Morning Stretch',
        now: DateTime.utc(2024, 1, 1),
      );

      expect(habit.members.length, 1);
      expect(habit.members['owner-1']?.role, TeamHabitRole.owner);
      expect(repository.getById(habit.id), isNotNull);
    });

    test('allows joining and leaving a team habit', () async {
      final habit = await repository.createTeamHabit(
        ownerId: 'owner',
        ownerName: 'Owner',
        name: 'Habit',
        now: DateTime.utc(2024, 1, 1),
      );

      await repository.joinTeam(
        habitId: habit.id,
        uid: 'member',
        displayName: 'Member',
        joinedAt: DateTime.utc(2024, 1, 2),
      );

      var stored = repository.getById(habit.id)!;
      expect(stored.members['member']?.status, TeamHabitMemberStatus.active);

      await repository.leaveTeam(habitId: habit.id, uid: 'member');
      stored = repository.getById(habit.id)!;
      expect(stored.members['member']?.status, TeamHabitMemberStatus.left);
    });

    test('records completions for members', () async {
      final habit = await repository.createTeamHabit(
        ownerId: 'owner',
        ownerName: 'Owner',
        name: 'Habit',
        now: DateTime.utc(2024, 1, 1),
      );

      await repository.joinTeam(
        habitId: habit.id,
        uid: 'member',
        displayName: 'Member',
      );

      await repository.recordCompletion(
        habitId: habit.id,
        uid: 'member',
        date: DateTime.utc(2024, 1, 3, 9),
      );

      final stored = repository.getById(habit.id)!;
      expect(stored.completions.length, 1);
      expect(stored.completions.first.completedBy, contains('member'));
    });
  });
}
