// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PremiumPlanImpl _$$PremiumPlanImplFromJson(Map<String, dynamic> json) =>
    _$PremiumPlanImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      yearlyPrice: (json['yearlyPrice'] as num).toDouble(),
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      tier: $enumDecode(_$PremiumTierEnumMap, json['tier']),
      isPopular: json['isPopular'] as bool? ?? false,
      isStudentPlan: json['isStudentPlan'] as bool? ?? false,
      isFamilyPlan: json['isFamilyPlan'] as bool? ?? false,
      maxUsers: (json['maxUsers'] as num?)?.toInt() ?? 1,
      discountCode: json['discountCode'] as String?,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PremiumPlanImplToJson(_$PremiumPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'monthlyPrice': instance.monthlyPrice,
      'yearlyPrice': instance.yearlyPrice,
      'features': instance.features,
      'tier': _$PremiumTierEnumMap[instance.tier]!,
      'isPopular': instance.isPopular,
      'isStudentPlan': instance.isStudentPlan,
      'isFamilyPlan': instance.isFamilyPlan,
      'maxUsers': instance.maxUsers,
      'discountCode': instance.discountCode,
      'discountPercentage': instance.discountPercentage,
    };

const _$PremiumTierEnumMap = {
  PremiumTier.free: 'free',
  PremiumTier.basic: 'basic',
  PremiumTier.premium: 'premium',
  PremiumTier.family: 'family',
  PremiumTier.student: 'student',
};

_$PremiumSubscriptionImpl _$$PremiumSubscriptionImplFromJson(
        Map<String, dynamic> json) =>
    _$PremiumSubscriptionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      planId: json['planId'] as String,
      tier: $enumDecode(_$PremiumTierEnumMap, json['tier']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
      billingCycle: $enumDecode(_$BillingCycleEnumMap, json['billingCycle']),
      autoRenew: json['autoRenew'] as bool? ?? false,
      paymentMethodId: json['paymentMethodId'] as String?,
      lastPaymentDate: json['lastPaymentDate'] == null
          ? null
          : DateTime.parse(json['lastPaymentDate'] as String),
      nextPaymentDate: json['nextPaymentDate'] == null
          ? null
          : DateTime.parse(json['nextPaymentDate'] as String),
      lastPaymentAmount: (json['lastPaymentAmount'] as num?)?.toDouble(),
      cancellationReason: json['cancellationReason'] as String?,
      cancellationDate: json['cancellationDate'] == null
          ? null
          : DateTime.parse(json['cancellationDate'] as String),
    );

Map<String, dynamic> _$$PremiumSubscriptionImplToJson(
        _$PremiumSubscriptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'planId': instance.planId,
      'tier': _$PremiumTierEnumMap[instance.tier]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'billingCycle': _$BillingCycleEnumMap[instance.billingCycle]!,
      'autoRenew': instance.autoRenew,
      'paymentMethodId': instance.paymentMethodId,
      'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
      'nextPaymentDate': instance.nextPaymentDate?.toIso8601String(),
      'lastPaymentAmount': instance.lastPaymentAmount,
      'cancellationReason': instance.cancellationReason,
      'cancellationDate': instance.cancellationDate?.toIso8601String(),
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.suspended: 'suspended',
  SubscriptionStatus.trial: 'trial',
};

const _$BillingCycleEnumMap = {
  BillingCycle.monthly: 'monthly',
  BillingCycle.yearly: 'yearly',
};

_$PremiumFeatureImpl _$$PremiumFeatureImplFromJson(Map<String, dynamic> json) =>
    _$PremiumFeatureImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      requiredTier: $enumDecode(_$PremiumTierEnumMap, json['requiredTier']),
      type: $enumDecode(_$FeatureTypeEnumMap, json['type']),
      isEnabled: json['isEnabled'] as bool? ?? true,
      configuration: json['configuration'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$PremiumFeatureImplToJson(
        _$PremiumFeatureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'requiredTier': _$PremiumTierEnumMap[instance.requiredTier]!,
      'type': _$FeatureTypeEnumMap[instance.type]!,
      'isEnabled': instance.isEnabled,
      'configuration': instance.configuration,
    };

const _$FeatureTypeEnumMap = {
  FeatureType.questLimit: 'questLimit',
  FeatureType.aiCoach: 'aiCoach',
  FeatureType.analytics: 'analytics',
  FeatureType.themes: 'themes',
  FeatureType.export: 'export',
  FeatureType.backup: 'backup',
  FeatureType.priority: 'priority',
  FeatureType.customization: 'customization',
};

_$FamilyMemberImpl _$$FamilyMemberImplFromJson(Map<String, dynamic> json) =>
    _$FamilyMemberImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$FamilyRoleEnumMap, json['role']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isActive: json['isActive'] as bool,
      avatarUrl: json['avatarUrl'] as String?,
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
    );

Map<String, dynamic> _$$FamilyMemberImplToJson(_$FamilyMemberImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': _$FamilyRoleEnumMap[instance.role]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'isActive': instance.isActive,
      'avatarUrl': instance.avatarUrl,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
    };

const _$FamilyRoleEnumMap = {
  FamilyRole.admin: 'admin',
  FamilyRole.member: 'member',
};

_$PremiumUsageStatsImpl _$$PremiumUsageStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$PremiumUsageStatsImpl(
      questsCreated: (json['questsCreated'] as num).toInt(),
      questLimit: (json['questLimit'] as num).toInt(),
      aiCoachInteractions: (json['aiCoachInteractions'] as num).toInt(),
      dataExports: (json['dataExports'] as num).toInt(),
      backupsCreated: (json['backupsCreated'] as num).toInt(),
      themesUsed: (json['themesUsed'] as num).toInt(),
      familyMembersActive: (json['familyMembersActive'] as num).toInt(),
      storageUsed: (json['storageUsed'] as num).toDouble(),
      storageLimit: (json['storageLimit'] as num).toDouble(),
    );

Map<String, dynamic> _$$PremiumUsageStatsImplToJson(
        _$PremiumUsageStatsImpl instance) =>
    <String, dynamic>{
      'questsCreated': instance.questsCreated,
      'questLimit': instance.questLimit,
      'aiCoachInteractions': instance.aiCoachInteractions,
      'dataExports': instance.dataExports,
      'backupsCreated': instance.backupsCreated,
      'themesUsed': instance.themesUsed,
      'familyMembersActive': instance.familyMembersActive,
      'storageUsed': instance.storageUsed,
      'storageLimit': instance.storageLimit,
    };

_$PremiumBenefitImpl _$$PremiumBenefitImplFromJson(Map<String, dynamic> json) =>
    _$PremiumBenefitImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      isActive: json['isActive'] as bool,
      badgeText: json['badgeText'] as String?,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
    );

Map<String, dynamic> _$$PremiumBenefitImplToJson(
        _$PremiumBenefitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'isActive': instance.isActive,
      'badgeText': instance.badgeText,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
    };
