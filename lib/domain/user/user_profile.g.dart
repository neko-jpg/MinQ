// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      handle: json['handle'] as String?,
      bio: json['bio'] as String?,
      avatarSeed: json['avatarSeed'] as String? ?? 'seed-01',
      focusTags: (json['focusTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notificationTimes: (json['notificationTimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      privacy: json['privacy'] as String? ?? 'public',
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreakReachedAt: json['longestStreakReachedAt'] == null
          ? null
          : DateTime.parse(json['longestStreakReachedAt'] as String),
      pairId: json['pairId'] as String?,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      onboardingLevel: (json['onboardingLevel'] as num?)?.toInt(),
      currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 1,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      weeklyXP: (json['weeklyXP'] as num?)?.toInt() ?? 0,
      currentLeague: json['currentLeague'] as String? ?? 'bronze',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      needsSync: json['needsSync'] as bool? ?? false,
      syncStatus: json['syncStatus'] as String? ?? 'synced',
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'displayName': instance.displayName,
      'email': instance.email,
      'handle': instance.handle,
      'bio': instance.bio,
      'avatarSeed': instance.avatarSeed,
      'focusTags': instance.focusTags,
      'notificationTimes': instance.notificationTimes,
      'privacy': instance.privacy,
      'longestStreak': instance.longestStreak,
      'currentStreak': instance.currentStreak,
      'longestStreakReachedAt':
          instance.longestStreakReachedAt?.toIso8601String(),
      'pairId': instance.pairId,
      'onboardingCompleted': instance.onboardingCompleted,
      'onboardingLevel': instance.onboardingLevel,
      'currentLevel': instance.currentLevel,
      'totalPoints': instance.totalPoints,
      'weeklyXP': instance.weeklyXP,
      'currentLeague': instance.currentLeague,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'needsSync': instance.needsSync,
      'syncStatus': instance.syncStatus,
    };
