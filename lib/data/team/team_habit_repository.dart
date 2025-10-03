import 'dart:async';

import 'package:collection/collection.dart';

import '../../domain/team/team_habit.dart';

/// Repository contract for managing [TeamHabit]s.
abstract class TeamHabitRepository {
  Future<TeamHabit> createTeamHabit({
    required String ownerId,
    required String ownerName,
    required String name,
    DateTime? now,
  });

  Future<void> joinTeam({
    required String habitId,
    required String uid,
    required String displayName,
    DateTime? joinedAt,
  });

  Future<void> leaveTeam({
    required String habitId,
    required String uid,
  });

  Future<void> recordCompletion({
    required String habitId,
    required String uid,
    required DateTime date,
  });

  Stream<List<TeamHabit>> watchTeamHabits(String uid);
}

/// In-memory repository used for offline mode and testing.
class InMemoryTeamHabitRepository implements TeamHabitRepository {
  final Map<String, TeamHabit> _storage = {};
  final StreamController<List<TeamHabit>> _controller =
      StreamController<List<TeamHabit>>.broadcast();

  void _emitFor(String uid) {
    final habits = _storage.values
        .where((habit) => habit.members.containsKey(uid))
        .sortedBy((habit) => habit.createdAt)
        .toList(growable: false);
    _controller.add(habits);
  }

  @override
  Future<TeamHabit> createTeamHabit({
    required String ownerId,
    required String ownerName,
    required String name,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now().toUtc();
    final habit = TeamHabit(
      id: 'team_${_storage.length + 1}',
      name: name,
      createdAt: timestamp,
      members: {
        ownerId: TeamHabitMember(
          uid: ownerId,
          displayName: ownerName,
          joinedAt: timestamp,
          role: TeamHabitRole.owner,
        ),
      },
    );
    _storage[habit.id] = habit;
    _emitFor(ownerId);
    return habit;
  }

  @override
  Future<void> joinTeam({
    required String habitId,
    required String uid,
    required String displayName,
    DateTime? joinedAt,
  }) async {
    final habit = _storage[habitId];
    if (habit == null) {
      throw StateError('Team habit $habitId does not exist');
    }
    final member = TeamHabitMember(
      uid: uid,
      displayName: displayName,
      joinedAt: (joinedAt ?? DateTime.now()).toUtc(),
    );
    _storage[habitId] = habit.addMember(member);
    _emitFor(uid);
  }

  @override
  Future<void> leaveTeam({
    required String habitId,
    required String uid,
  }) async {
    final habit = _storage[habitId];
    if (habit == null) {
      throw StateError('Team habit $habitId does not exist');
    }
    if (!habit.members.containsKey(uid)) {
      return;
    }
    final updatedMember = habit
        .member(uid)! // ignore: avoid-non-null-assertion, safe due to check
        .copyWith(status: TeamHabitMemberStatus.left);
    _storage[habitId] = habit.updateMember(updatedMember);
    _emitFor(uid);
  }

  @override
  Future<void> recordCompletion({
    required String habitId,
    required String uid,
    required DateTime date,
  }) async {
    final habit = _storage[habitId];
    if (habit == null) {
      throw StateError('Team habit $habitId does not exist');
    }
    final updated = habit.markCompleted(uid: uid, date: date);
    _storage[habitId] = updated;
    _emitFor(uid);
  }

  @override
  Stream<List<TeamHabit>> watchTeamHabits(String uid) {
    Future.microtask(() => _emitFor(uid));
    return _controller.stream
        .map((habits) => habits.where((habit) => habit.isMember(uid)).toList())
        .distinct(const IterableEquality<TeamHabit>().equals);
  }

  /// Utility that exposes the current state for testing purposes.
  TeamHabit? getById(String id) => _storage[id];

  void dispose() {
    _controller.close();
  }
}
