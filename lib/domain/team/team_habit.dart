
import 'package:collection/collection.dart';

/// Role of a member inside a [TeamHabit].
enum TeamHabitRole { owner, member }

/// Participation status of a member inside a [TeamHabit].
enum TeamHabitMemberStatus { active, invited, left }

/// Represents a member participating in a [TeamHabit].
class TeamHabitMember {
  TeamHabitMember({
    required this.uid,
    required this.displayName,
    required this.joinedAt,
    this.role = TeamHabitRole.member,
    this.status = TeamHabitMemberStatus.active,
    this.notificationsEnabled = true,
  });

  final String uid;
  final String displayName;
  final DateTime joinedAt;
  final TeamHabitRole role;
  final TeamHabitMemberStatus status;
  final bool notificationsEnabled;

  TeamHabitMember copyWith({
    TeamHabitRole? role,
    TeamHabitMemberStatus? status,
    bool? notificationsEnabled,
  }) {
    return TeamHabitMember(
      uid: uid,
      displayName: displayName,
      joinedAt: joinedAt,
      role: role ?? this.role,
      status: status ?? this.status,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

/// Completion state of a member for a given date.
class TeamHabitCompletion {
  TeamHabitCompletion({
    required this.date,
    required this.completedBy,
  });

  final DateTime date;
  final Set<String> completedBy;

  TeamHabitCompletion markCompleted(String uid) {
    return TeamHabitCompletion(
      date: date,
      completedBy: {...completedBy, uid},
    );
  }
}

/// Represents a collaborative habit that multiple members can work on.
class TeamHabit {
  TeamHabit({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.members,
    List<TeamHabitCompletion>? completions,
    DateTime? archivedAt,
  })  : _completions = completions ?? <TeamHabitCompletion>[],
        archivedAt = archivedAt;

  final String id;
  final String name;
  final DateTime createdAt;
  final Map<String, TeamHabitMember> members;
  final DateTime? archivedAt;
  final List<TeamHabitCompletion> _completions;

  UnmodifiableListView<TeamHabitCompletion> get completions =>
      UnmodifiableListView(_completions);

  bool get isArchived => archivedAt != null;

  bool isMember(String uid) => members.containsKey(uid);

  TeamHabitMember? member(String uid) => members[uid];

  TeamHabit copyWith({
    String? name,
    Map<String, TeamHabitMember>? members,
    List<TeamHabitCompletion>? completions,
    DateTime? archivedAt,
  }) {
    return TeamHabit(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      members: members ?? this.members,
      completions: completions ?? _completions,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  TeamHabit addMember(TeamHabitMember member) {
    final updatedMembers = Map<String, TeamHabitMember>.from(members);
    updatedMembers[member.uid] = member;
    return copyWith(members: updatedMembers);
  }

  TeamHabit updateMember(TeamHabitMember member) {
    if (!members.containsKey(member.uid)) {
      throw StateError('Member ${member.uid} is not part of team $id');
    }
    final updatedMembers = Map<String, TeamHabitMember>.from(members);
    updatedMembers[member.uid] = member;
    return copyWith(members: updatedMembers);
  }

  TeamHabit markCompleted({
    required String uid,
    required DateTime date,
  }) {
    if (!members.containsKey(uid)) {
      throw StateError('Member $uid cannot complete habit for team $id');
    }

    final normalizedDate = DateTime.utc(date.year, date.month, date.day);
    final existing = _completions
        .firstWhereOrNull((completion) => completion.date == normalizedDate);

    final List<TeamHabitCompletion> updated = List.of(_completions);
    if (existing == null) {
      updated.add(
        TeamHabitCompletion(
          date: normalizedDate,
          completedBy: {uid},
        ),
      );
    } else {
      final index = updated.indexOf(existing);
      updated[index] = existing.markCompleted(uid);
    }

    return copyWith(completions: updated);
  }
}
