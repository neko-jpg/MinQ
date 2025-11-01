import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Extended user profile model with comprehensive profile data
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String uid,
    required String displayName,
    required String email,
    String? handle,
    String? bio,
    @Default('seed-01') String avatarSeed,
    @Default([]) List<String> focusTags,
    @Default([]) List<String> notificationTimes,
    @Default('public') String privacy,
    @Default(0) int longestStreak,
    @Default(0) int currentStreak,
    DateTime? longestStreakReachedAt,
    String? pairId,
    @Default(false) bool onboardingCompleted,
    int? onboardingLevel,
    @Default(1) int currentLevel,
    @Default(0) int totalPoints,
    @Default(0) int weeklyXP,
    @Default('bronze') String currentLeague,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool needsSync,
    @Default('synced') String syncStatus,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

/// Profile validation result
class ProfileValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  const ProfileValidationResult({required this.isValid, required this.errors});

  factory ProfileValidationResult.valid() {
    return const ProfileValidationResult(isValid: true, errors: {});
  }

  factory ProfileValidationResult.invalid(Map<String, String> errors) {
    return ProfileValidationResult(isValid: false, errors: errors);
  }
}

/// Profile update request
class ProfileUpdateRequest {
  final String? displayName;
  final String? handle;
  final String? bio;
  final String? avatarSeed;
  final List<String>? focusTags;
  final List<String>? notificationTimes;
  final String? privacy;

  const ProfileUpdateRequest({
    this.displayName,
    this.handle,
    this.bio,
    this.avatarSeed,
    this.focusTags,
    this.notificationTimes,
    this.privacy,
  });

  Map<String, dynamic> toJson() {
    return {
      if (displayName != null) 'displayName': displayName,
      if (handle != null) 'handle': handle,
      if (bio != null) 'bio': bio,
      if (avatarSeed != null) 'avatarSeed': avatarSeed,
      if (focusTags != null) 'focusTags': focusTags,
      if (notificationTimes != null) 'notificationTimes': notificationTimes,
      if (privacy != null) 'privacy': privacy,
    };
  }
}
