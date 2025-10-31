import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';
import 'package:minq/domain/premium/premium_plan.dart';

class FamilyPlanService {
  final PremiumService _premiumService;
  final LocalStorageService _localStorage;

  FamilyPlanService(this._premiumService, this._localStorage);

  Future<bool> canManageFamily() async {
    return await _premiumService.canUseFamily();
  }

  Future<bool> isAdmin() async {
    if (!await canManageFamily()) return false;
    
    final familyData = await _getFamilyData();
    final currentUserId = await _getCurrentUserId();
    
    return familyData?['adminId'] == currentUserId;
  }

  Future<List<FamilyMember>> getFamilyMembers() async {
    if (!await canManageFamily()) return [];
    
    try {
      final membersData = await _localStorage.getString('family_members');
      if (membersData == null) return [];
      
      final List<dynamic> membersList = jsonDecode(membersData);
      return membersList.map((json) => FamilyMember.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<FamilyInvitation> createInvitation({
    required String email,
    required FamilyRole role,
    String? customMessage,
  }) async {
    if (!await isAdmin()) {
      throw const FamilyException('Only family admin can create invitations');
    }

    final currentMembers = await getFamilyMembers();
    final limit = await _premiumService.getFamilyMemberLimit();
    
    if (currentMembers.length >= limit) {
      throw const FamilyException('Family member limit reached');
    }

    final invitation = FamilyInvitation(
      id: _generateInvitationId(),
      familyId: await _getFamilyId(),
      inviterName: await _getCurrentUserName(),
      inviteeEmail: email,
      role: role,
      customMessage: customMessage,
      inviteCode: _generateInviteCode(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now(),
      status: InvitationStatus.pending,
    );

    await _saveInvitation(invitation);
    await _sendInvitationEmail(invitation);

    return invitation;
  }

  Future<bool> acceptInvitation(String inviteCode) async {
    final invitation = await _getInvitationByCode(inviteCode);
    
    if (invitation == null) {
      throw const FamilyException('Invalid invitation code');
    }
    
    if (invitation.isExpired) {
      throw const FamilyException('Invitation has expired');
    }
    
    if (invitation.status != InvitationStatus.pending) {
      throw const FamilyException('Invitation is no longer valid');
    }

    // Add user to family
    final newMember = FamilyMember(
      id: await _getCurrentUserId(),
      name: await _getCurrentUserName(),
      email: invitation.inviteeEmail,
      role: invitation.role,
      joinedAt: DateTime.now(),
      isActive: true,
      avatarUrl: await _getCurrentUserAvatar(),
    );

    await _addFamilyMember(newMember);
    
    // Update invitation status
    final updatedInvitation = invitation.copyWith(
      status: InvitationStatus.accepted,
      acceptedAt: DateTime.now(),
    );
    await _updateInvitation(updatedInvitation);

    // Notify family admin
    await _notifyFamilyAdmin(
      'New family member joined',
      '${newMember.name} has joined your family plan',
    );

    return true;
  }

  Future<bool> removeFamilyMember(String memberId) async {
    if (!await isAdmin()) {
      throw const FamilyException('Only family admin can remove members');
    }

    final members = await getFamilyMembers();
    final memberToRemove = members.where((m) => m.id == memberId).firstOrNull;
    
    if (memberToRemove == null) {
      throw const FamilyException('Member not found');
    }

    if (memberToRemove.role == FamilyRole.admin) {
      throw const FamilyException('Cannot remove family admin');
    }

    final updatedMembers = members.where((m) => m.id != memberId).toList();
    await _saveFamilyMembers(updatedMembers);

    // Notify removed member
    await _notifyMember(
      memberToRemove.email,
      'Removed from family plan',
      'You have been removed from the family plan',
    );

    return true;
  }

  Future<bool> updateMemberRole(String memberId, FamilyRole newRole) async {
    if (!await isAdmin()) {
      throw const FamilyException('Only family admin can update member roles');
    }

    final members = await getFamilyMembers();
    final memberIndex = members.indexWhere((m) => m.id == memberId);
    
    if (memberIndex == -1) {
      throw const FamilyException('Member not found');
    }

    final updatedMember = members[memberIndex].copyWith(role: newRole);
    members[memberIndex] = updatedMember;
    
    await _saveFamilyMembers(members);

    // Notify member of role change
    await _notifyMember(
      updatedMember.email,
      'Role updated',
      'Your family plan role has been updated to ${newRole.displayName}',
    );

    return true;
  }

  Future<List<FamilyInvitation>> getPendingInvitations() async {
    if (!await isAdmin()) return [];
    
    try {
      final invitationsData = await _localStorage.getString('family_invitations');
      if (invitationsData == null) return [];
      
      final List<dynamic> invitationsList = jsonDecode(invitationsData);
      final invitations = invitationsList
          .map((json) => FamilyInvitation.fromJson(json))
          .where((inv) => inv.status == InvitationStatus.pending && !inv.isExpired)
          .toList();
      
      return invitations;
    } catch (e) {
      return [];
    }
  }

  Future<bool> cancelInvitation(String invitationId) async {
    if (!await isAdmin()) {
      throw const FamilyException('Only family admin can cancel invitations');
    }

    final invitations = await _getAllInvitations();
    final invitationIndex = invitations.indexWhere((inv) => inv.id == invitationId);
    
    if (invitationIndex == -1) {
      throw const FamilyException('Invitation not found');
    }

    final updatedInvitation = invitations[invitationIndex].copyWith(
      status: InvitationStatus.cancelled,
    );
    invitations[invitationIndex] = updatedInvitation;
    
    await _saveInvitations(invitations);
    return true;
  }

  Future<FamilyUsageStats> getFamilyUsageStats() async {
    if (!await canManageFamily()) {
      throw const FamilyException('Not a family plan member');
    }

    final members = await getFamilyMembers();
    final activeMembers = members.where((m) => m.isActive).length;
    final totalQuests = await _getTotalFamilyQuests();
    final totalXP = await _getTotalFamilyXP();
    final averageStreak = await _getAverageFamilyStreak();
    
    return FamilyUsageStats(
      totalMembers: members.length,
      activeMembers: activeMembers,
      memberLimit: await _premiumService.getFamilyMemberLimit(),
      totalQuests: totalQuests,
      totalXP: totalXP,
      averageStreak: averageStreak,
      topPerformer: await _getTopPerformer(members),
      monthlyActivity: await _getMonthlyActivity(),
    );
  }

  Future<List<FamilyChallenge>> getFamilyChallenges() async {
    if (!await canManageFamily()) return [];
    
    try {
      final challengesData = await _localStorage.getString('family_challenges');
      if (challengesData == null) return [];
      
      final List<dynamic> challengesList = jsonDecode(challengesData);
      return challengesList.map((json) => FamilyChallenge.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<FamilyChallenge> createFamilyChallenge({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int targetValue,
    required String metric,
    List<String>? participantIds,
  }) async {
    if (!await isAdmin()) {
      throw const FamilyException('Only family admin can create challenges');
    }

    final challenge = FamilyChallenge(
      id: _generateChallengeId(),
      familyId: await _getFamilyId(),
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      targetValue: targetValue,
      metric: metric,
      participantIds: participantIds ?? (await getFamilyMembers()).map((m) => m.id).toList(),
      createdBy: await _getCurrentUserId(),
      createdAt: DateTime.now(),
      status: ChallengeStatus.active,
      progress: {},
    );

    await _saveFamilyChallenge(challenge);
    
    // Notify family members
    await _notifyFamilyMembers(
      'New Family Challenge',
      'A new challenge "$title" has been created!',
    );

    return challenge;
  }

  Future<bool> joinFamilyChallenge(String challengeId) async {
    if (!await canManageFamily()) return false;

    final challenges = await getFamilyChallenges();
    final challengeIndex = challenges.indexWhere((c) => c.id == challengeId);
    
    if (challengeIndex == -1) return false;

    final challenge = challenges[challengeIndex];
    final userId = await _getCurrentUserId();
    
    if (challenge.participantIds.contains(userId)) return true;

    final updatedChallenge = challenge.copyWith(
      participantIds: [...challenge.participantIds, userId],
    );
    challenges[challengeIndex] = updatedChallenge;
    
    await _saveFamilyChallenges(challenges);
    return true;
  }

  Future<ParentalControls> getParentalControls(String childId) async {
    if (!await isAdmin()) {
      throw const FamilyException('Only family admin can access parental controls');
    }

    try {
      final controlsData = await _localStorage.getString('parental_controls_$childId');
      if (controlsData == null) {
        return ParentalControls.defaultControls();
      }
      
      final json = jsonDecode(controlsData);
      return ParentalControls.fromJson(json);
    } catch (e) {
      return ParentalControls.defaultControls();
    }
  }

  Future<bool> updateParentalControls(String childId, ParentalControls controls) async {
    if (!await isAdmin()) {
      throw const FamilyException('Only family admin can update parental controls');
    }

    try {
      final controlsJson = jsonEncode(controls.toJson());
      await _localStorage.setString('parental_controls_$childId', controlsJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Private helper methods
  Future<Map<String, dynamic>?> _getFamilyData() async {
    try {
      final familyData = await _localStorage.getString('family_data');
      if (familyData == null) return null;
      return jsonDecode(familyData);
    } catch (e) {
      return null;
    }
  }

  Future<String> _getFamilyId() async {
    final familyData = await _getFamilyData();
    return familyData?['id'] ?? 'family_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> _getCurrentUserId() async {
    // Mock implementation - would get from auth service
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> _getCurrentUserName() async {
    // Mock implementation - would get from user service
    return 'Current User';
  }

  Future<String?> _getCurrentUserAvatar() async {
    // Mock implementation - would get from user service
    return null;
  }

  String _generateInvitationId() {
    return 'inv_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateInviteCode() {
    // Generate a 6-character alphanumeric code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length]).join();
  }

  String _generateChallengeId() {
    return 'challenge_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _saveInvitation(FamilyInvitation invitation) async {
    final invitations = await _getAllInvitations();
    invitations.add(invitation);
    await _saveInvitations(invitations);
  }

  Future<void> _updateInvitation(FamilyInvitation invitation) async {
    final invitations = await _getAllInvitations();
    final index = invitations.indexWhere((inv) => inv.id == invitation.id);
    if (index != -1) {
      invitations[index] = invitation;
      await _saveInvitations(invitations);
    }
  }

  Future<List<FamilyInvitation>> _getAllInvitations() async {
    try {
      final invitationsData = await _localStorage.getString('family_invitations');
      if (invitationsData == null) return [];
      
      final List<dynamic> invitationsList = jsonDecode(invitationsData);
      return invitationsList.map((json) => FamilyInvitation.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveInvitations(List<FamilyInvitation> invitations) async {
    final invitationsJson = jsonEncode(invitations.map((inv) => inv.toJson()).toList());
    await _localStorage.setString('family_invitations', invitationsJson);
  }

  Future<FamilyInvitation?> _getInvitationByCode(String code) async {
    final invitations = await _getAllInvitations();
    try {
      return invitations.firstWhere((inv) => inv.inviteCode == code);
    } catch (e) {
      return null;
    }
  }

  Future<void> _addFamilyMember(FamilyMember member) async {
    final members = await getFamilyMembers();
    members.add(member);
    await _saveFamilyMembers(members);
  }

  Future<void> _saveFamilyMembers(List<FamilyMember> members) async {
    final membersJson = jsonEncode(members.map((m) => m.toJson()).toList());
    await _localStorage.setString('family_members', membersJson);
  }

  Future<void> _sendInvitationEmail(FamilyInvitation invitation) async {
    // Mock implementation - would send actual email
    print('Sending invitation email to ${invitation.inviteeEmail}');
  }

  Future<void> _notifyFamilyAdmin(String title, String message) async {
    // Mock implementation - would send actual notification
    print('Notifying family admin: $title - $message');
  }

  Future<void> _notifyMember(String email, String title, String message) async {
    // Mock implementation - would send actual notification
    print('Notifying member $email: $title - $message');
  }

  Future<void> _notifyFamilyMembers(String title, String message) async {
    // Mock implementation - would send actual notifications
    print('Notifying family members: $title - $message');
  }

  Future<int> _getTotalFamilyQuests() async {
    // Mock implementation - would calculate from actual data
    return 150;
  }

  Future<int> _getTotalFamilyXP() async {
    // Mock implementation - would calculate from actual data
    return 5000;
  }

  Future<double> _getAverageFamilyStreak() async {
    // Mock implementation - would calculate from actual data
    return 12.5;
  }

  Future<FamilyMember?> _getTopPerformer(List<FamilyMember> members) async {
    // Mock implementation - would determine from actual performance data
    return members.isNotEmpty ? members.first : null;
  }

  Future<Map<String, int>> _getMonthlyActivity() async {
    // Mock implementation - would get actual monthly activity data
    return {
      'January': 45,
      'February': 52,
      'March': 38,
    };
  }

  Future<void> _saveFamilyChallenge(FamilyChallenge challenge) async {
    final challenges = await getFamilyChallenges();
    challenges.add(challenge);
    await _saveFamilyChallenges(challenges);
  }

  Future<void> _saveFamilyChallenges(List<FamilyChallenge> challenges) async {
    final challengesJson = jsonEncode(challenges.map((c) => c.toJson()).toList());
    await _localStorage.setString('family_challenges', challengesJson);
  }
}

// Additional classes for family functionality
class FamilyInvitation {
  final String id;
  final String familyId;
  final String inviterName;
  final String inviteeEmail;
  final FamilyRole role;
  final String? customMessage;
  final String inviteCode;
  final DateTime expiresAt;
  final DateTime createdAt;
  final InvitationStatus status;
  final DateTime? acceptedAt;

  const FamilyInvitation({
    required this.id,
    required this.familyId,
    required this.inviterName,
    required this.inviteeEmail,
    required this.role,
    this.customMessage,
    required this.inviteCode,
    required this.expiresAt,
    required this.createdAt,
    required this.status,
    this.acceptedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  FamilyInvitation copyWith({
    InvitationStatus? status,
    DateTime? acceptedAt,
  }) {
    return FamilyInvitation(
      id: id,
      familyId: familyId,
      inviterName: inviterName,
      inviteeEmail: inviteeEmail,
      role: role,
      customMessage: customMessage,
      inviteCode: inviteCode,
      expiresAt: expiresAt,
      createdAt: createdAt,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'familyId': familyId,
    'inviterName': inviterName,
    'inviteeEmail': inviteeEmail,
    'role': role.name,
    'customMessage': customMessage,
    'inviteCode': inviteCode,
    'expiresAt': expiresAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'acceptedAt': acceptedAt?.toIso8601String(),
  };

  factory FamilyInvitation.fromJson(Map<String, dynamic> json) => FamilyInvitation(
    id: json['id'],
    familyId: json['familyId'],
    inviterName: json['inviterName'],
    inviteeEmail: json['inviteeEmail'],
    role: FamilyRole.values.firstWhere((r) => r.name == json['role']),
    customMessage: json['customMessage'],
    inviteCode: json['inviteCode'],
    expiresAt: DateTime.parse(json['expiresAt']),
    createdAt: DateTime.parse(json['createdAt']),
    status: InvitationStatus.values.firstWhere((s) => s.name == json['status']),
    acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
  );
}

class FamilyUsageStats {
  final int totalMembers;
  final int activeMembers;
  final int memberLimit;
  final int totalQuests;
  final int totalXP;
  final double averageStreak;
  final FamilyMember? topPerformer;
  final Map<String, int> monthlyActivity;

  const FamilyUsageStats({
    required this.totalMembers,
    required this.activeMembers,
    required this.memberLimit,
    required this.totalQuests,
    required this.totalXP,
    required this.averageStreak,
    this.topPerformer,
    required this.monthlyActivity,
  });
}

class FamilyChallenge {
  final String id;
  final String familyId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int targetValue;
  final String metric;
  final List<String> participantIds;
  final String createdBy;
  final DateTime createdAt;
  final ChallengeStatus status;
  final Map<String, int> progress;

  const FamilyChallenge({
    required this.id,
    required this.familyId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.targetValue,
    required this.metric,
    required this.participantIds,
    required this.createdBy,
    required this.createdAt,
    required this.status,
    required this.progress,
  });

  FamilyChallenge copyWith({
    List<String>? participantIds,
    ChallengeStatus? status,
    Map<String, int>? progress,
  }) {
    return FamilyChallenge(
      id: id,
      familyId: familyId,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      targetValue: targetValue,
      metric: metric,
      participantIds: participantIds ?? this.participantIds,
      createdBy: createdBy,
      createdAt: createdAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'familyId': familyId,
    'title': title,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'targetValue': targetValue,
    'metric': metric,
    'participantIds': participantIds,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'progress': progress,
  };

  factory FamilyChallenge.fromJson(Map<String, dynamic> json) => FamilyChallenge(
    id: json['id'],
    familyId: json['familyId'],
    title: json['title'],
    description: json['description'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    targetValue: json['targetValue'],
    metric: json['metric'],
    participantIds: List<String>.from(json['participantIds']),
    createdBy: json['createdBy'],
    createdAt: DateTime.parse(json['createdAt']),
    status: ChallengeStatus.values.firstWhere((s) => s.name == json['status']),
    progress: Map<String, int>.from(json['progress']),
  );
}

class ParentalControls {
  final bool allowSocialFeatures;
  final bool allowDataSharing;
  final List<String> blockedCategories;
  final int maxDailyQuests;
  final TimeOfDay? bedtime;
  final bool requireApprovalForNewQuests;

  const ParentalControls({
    required this.allowSocialFeatures,
    required this.allowDataSharing,
    required this.blockedCategories,
    required this.maxDailyQuests,
    this.bedtime,
    required this.requireApprovalForNewQuests,
  });

  Map<String, dynamic> toJson() => {
    'allowSocialFeatures': allowSocialFeatures,
    'allowDataSharing': allowDataSharing,
    'blockedCategories': blockedCategories,
    'maxDailyQuests': maxDailyQuests,
    'bedtime': bedtime != null ? {
      'hour': bedtime!.hour,
      'minute': bedtime!.minute,
    } : null,
    'requireApprovalForNewQuests': requireApprovalForNewQuests,
  };

  factory ParentalControls.fromJson(Map<String, dynamic> json) => ParentalControls(
    allowSocialFeatures: json['allowSocialFeatures'],
    allowDataSharing: json['allowDataSharing'],
    blockedCategories: List<String>.from(json['blockedCategories']),
    maxDailyQuests: json['maxDailyQuests'],
    bedtime: json['bedtime'] != null ? TimeOfDay(
      hour: json['bedtime']['hour'],
      minute: json['bedtime']['minute'],
    ) : null,
    requireApprovalForNewQuests: json['requireApprovalForNewQuests'],
  );

  static ParentalControls defaultControls() => const ParentalControls(
    allowSocialFeatures: false,
    allowDataSharing: false,
    blockedCategories: [],
    maxDailyQuests: 5,
    requireApprovalForNewQuests: true,
  );
}

enum InvitationStatus {
  pending,
  accepted,
  declined,
  cancelled,
  expired,
}

enum ChallengeStatus {
  active,
  completed,
  cancelled,
}

class FamilyException implements Exception {
  final String message;
  const FamilyException(this.message);
  
  @override
  String toString() => 'FamilyException: $message';
}

class TimeOfDay {
  final int hour;
  final int minute;
  
  const TimeOfDay({required this.hour, required this.minute});
}

extension FamilyRoleExtension on FamilyRole {
  String get displayName {
    switch (this) {
      case FamilyRole.admin:
        return 'Admin';
      case FamilyRole.member:
        return 'Member';
    }
  }
}

extension FamilyMemberExtension on FamilyMember {
  FamilyMember copyWith({
    String? name,
    String? email,
    FamilyRole? role,
    bool? isActive,
    String? avatarUrl,
    DateTime? lastActiveAt,
  }) {
    return FamilyMember(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      joinedAt: joinedAt,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

final familyPlanServiceProvider = Provider<FamilyPlanService>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return FamilyPlanService(premiumService, localStorage);
});

final familyMembersProvider = FutureProvider<List<FamilyMember>>((ref) {
  final familyService = ref.watch(familyPlanServiceProvider);
  return familyService.getFamilyMembers();
});

final familyUsageStatsProvider = FutureProvider<FamilyUsageStats>((ref) {
  final familyService = ref.watch(familyPlanServiceProvider);
  return familyService.getFamilyUsageStats();
});

final familyChallengesProvider = FutureProvider<List<FamilyChallenge>>((ref) {
  final familyService = ref.watch(familyPlanServiceProvider);
  return familyService.getFamilyChallenges();
});

final pendingInvitationsProvider = FutureProvider<List<FamilyInvitation>>((ref) {
  final familyService = ref.watch(familyPlanServiceProvider);
  return familyService.getPendingInvitations();
});