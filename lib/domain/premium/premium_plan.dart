import 'package:freezed_annotation/freezed_annotation.dart';

part 'premium_plan.freezed.dart';
part 'premium_plan.g.dart';

@freezed
class PremiumPlan with _$PremiumPlan {
  const factory PremiumPlan({
    required String id,
    required String name,
    required String description,
    required double monthlyPrice,
    required double yearlyPrice,
    required List<String> features,
    required PremiumTier tier,
    @Default(false) bool isPopular,
    @Default(false) bool isStudentPlan,
    @Default(false) bool isFamilyPlan,
    @Default(1) int maxUsers,
    String? discountCode,
    double? discountPercentage,
  }) = _PremiumPlan;

  factory PremiumPlan.fromJson(Map<String, dynamic> json) =>
      _$PremiumPlanFromJson(json);
}

@freezed
class PremiumSubscription with _$PremiumSubscription {
  const factory PremiumSubscription({
    required String id,
    required String userId,
    required String planId,
    required PremiumTier tier,
    required DateTime startDate,
    required DateTime endDate,
    required SubscriptionStatus status,
    required BillingCycle billingCycle,
    @Default(false) bool autoRenew,
    String? paymentMethodId,
    DateTime? lastPaymentDate,
    DateTime? nextPaymentDate,
    double? lastPaymentAmount,
    String? cancellationReason,
    DateTime? cancellationDate,
  }) = _PremiumSubscription;

  factory PremiumSubscription.fromJson(Map<String, dynamic> json) =>
      _$PremiumSubscriptionFromJson(json);
}

@freezed
class PremiumFeature with _$PremiumFeature {
  const factory PremiumFeature({
    required String id,
    required String name,
    required String description,
    required PremiumTier requiredTier,
    required FeatureType type,
    @Default(true) bool isEnabled,
    Map<String, dynamic>? configuration,
  }) = _PremiumFeature;

  factory PremiumFeature.fromJson(Map<String, dynamic> json) =>
      _$PremiumFeatureFromJson(json);
}

enum PremiumTier {
  free,
  basic,
  premium,
  family,
  student,
}

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  suspended,
  trial,
}

enum BillingCycle {
  monthly,
  yearly,
}

enum FeatureType {
  questLimit,
  aiCoach,
  analytics,
  themes,
  export,
  backup,
  priority,
  customization,
}

@freezed
class FamilyMember with _$FamilyMember {
  const factory FamilyMember({
    required String id,
    required String name,
    required String email,
    required FamilyRole role,
    required DateTime joinedAt,
    required bool isActive,
    String? avatarUrl,
    DateTime? lastActiveAt,
  }) = _FamilyMember;

  factory FamilyMember.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberFromJson(json);
}

@freezed
class PremiumUsageStats with _$PremiumUsageStats {
  const factory PremiumUsageStats({
    required int questsCreated,
    required int questLimit,
    required int aiCoachInteractions,
    required int dataExports,
    required int backupsCreated,
    required int themesUsed,
    required int familyMembersActive,
    required double storageUsed,
    required double storageLimit,
  }) = _PremiumUsageStats;

  factory PremiumUsageStats.fromJson(Map<String, dynamic> json) =>
      _$PremiumUsageStatsFromJson(json);
}

@freezed
class PremiumBenefit with _$PremiumBenefit {
  const factory PremiumBenefit({
    required String id,
    required String title,
    required String description,
    required String icon,
    required bool isActive,
    String? badgeText,
    DateTime? unlockedAt,
  }) = _PremiumBenefit;

  factory PremiumBenefit.fromJson(Map<String, dynamic> json) =>
      _$PremiumBenefitFromJson(json);
}

enum FamilyRole {
  admin,
  member,
}

enum StudentVerificationStatus {
  notApplicable,
  pending,
  verified,
  rejected,
  expired,
}

extension PremiumTierExtension on PremiumTier {
  String get displayName {
    switch (this) {
      case PremiumTier.free:
        return 'Free';
      case PremiumTier.basic:
        return 'Basic';
      case PremiumTier.premium:
        return 'Premium';
      case PremiumTier.family:
        return 'Family';
      case PremiumTier.student:
        return 'Student';
    }
  }

  bool hasFeature(FeatureType feature) {
    switch (this) {
      case PremiumTier.free:
        return false;
      case PremiumTier.basic:
        return [
          FeatureType.questLimit,
          FeatureType.themes,
          FeatureType.aiCoach,
        ].contains(feature);
      case PremiumTier.premium:
      case PremiumTier.family:
      case PremiumTier.student:
        return true;
    }
  }

  int get questLimit {
    switch (this) {
      case PremiumTier.free:
        return 10;
      case PremiumTier.basic:
        return 50;
      case PremiumTier.premium:
      case PremiumTier.family:
      case PremiumTier.student:
        return -1; // Unlimited
    }
  }

  int get familyMemberLimit {
    switch (this) {
      case PremiumTier.family:
        return 6;
      case PremiumTier.premium:
      case PremiumTier.student:
        return 2;
      case PremiumTier.basic:
      case PremiumTier.free:
        return 1;
    }
  }

  double get storageLimit {
    switch (this) {
      case PremiumTier.free:
        return 1.0; // 1GB
      case PremiumTier.basic:
        return 5.0; // 5GB
      case PremiumTier.premium:
      case PremiumTier.family:
      case PremiumTier.student:
        return 50.0; // 50GB
    }
  }

  bool get hasAdvancedCustomization {
    switch (this) {
      case PremiumTier.premium:
      case PremiumTier.family:
      case PremiumTier.student:
        return true;
      case PremiumTier.basic:
      case PremiumTier.free:
        return false;
    }
  }

  bool get hasPrioritySupport {
    switch (this) {
      case PremiumTier.premium:
      case PremiumTier.family:
      case PremiumTier.student:
        return true;
      case PremiumTier.basic:
      case PremiumTier.free:
        return false;
    }
  }
}