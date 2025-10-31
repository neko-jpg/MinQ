import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/storage/local_storage_service.dart';
import 'package:minq/domain/premium/premium_plan.dart';

class PremiumService {
  final LocalStorageService _localStorage;
  final StreamController<PremiumSubscription?> _subscriptionController;

  PremiumService(this._localStorage)
      : _subscriptionController = StreamController<PremiumSubscription?>.broadcast();

  Stream<PremiumSubscription?> get subscriptionStream => _subscriptionController.stream;

  // Premium Plans Configuration
  static final List<PremiumPlan> availablePlans = [
    const PremiumPlan(
      id: 'basic',
      name: 'Basic',
      description: 'Essential features for habit building',
      monthlyPrice: 4.99,
      yearlyPrice: 49.99,
      tier: PremiumTier.basic,
      features: [
        'Up to 50 quests',
        'Basic themes',
        'Standard AI coach',
        'Basic analytics',
      ],
    ),
    const PremiumPlan(
      id: 'premium',
      name: 'Premium',
      description: 'Advanced features for serious habit builders',
      monthlyPrice: 9.99,
      yearlyPrice: 99.99,
      tier: PremiumTier.premium,
      isPopular: true,
      features: [
        'Unlimited quests',
        'Premium themes & animations',
        'Priority AI coach',
        'Advanced analytics & insights',
        'Data export & backup',
        'Custom dashboard',
        'Priority support',
      ],
    ),
    const PremiumPlan(
      id: 'family',
      name: 'Family',
      description: 'Perfect for families building habits together',
      monthlyPrice: 14.99,
      yearlyPrice: 149.99,
      tier: PremiumTier.family,
      isFamilyPlan: true,
      maxUsers: 6,
      features: [
        'All Premium features',
        'Up to 6 family members',
        'Family challenges',
        'Shared progress tracking',
        'Parental controls',
      ],
    ),
    const PremiumPlan(
      id: 'student',
      name: 'Student',
      description: 'Special pricing for students',
      monthlyPrice: 4.99,
      yearlyPrice: 39.99,
      tier: PremiumTier.student,
      isStudentPlan: true,
      discountPercentage: 50,
      features: [
        'All Premium features',
        '50% student discount',
        'Study-focused templates',
        'Academic calendar integration',
      ],
    ),
  ];

  // Premium Features Configuration
  static final List<PremiumFeature> premiumFeatures = [
    const PremiumFeature(
      id: 'unlimited_quests',
      name: 'Unlimited Quests',
      description: 'Create as many quests as you need',
      requiredTier: PremiumTier.premium,
      type: FeatureType.questLimit,
    ),
    const PremiumFeature(
      id: 'priority_ai_coach',
      name: 'Priority AI Coach',
      description: 'Get faster and more detailed AI responses',
      requiredTier: PremiumTier.basic,
      type: FeatureType.aiCoach,
    ),
    const PremiumFeature(
      id: 'advanced_analytics',
      name: 'Advanced Analytics',
      description: 'Detailed insights and predictions',
      requiredTier: PremiumTier.premium,
      type: FeatureType.analytics,
    ),
    const PremiumFeature(
      id: 'premium_themes',
      name: 'Premium Themes',
      description: 'Exclusive themes and animations',
      requiredTier: PremiumTier.basic,
      type: FeatureType.themes,
    ),
    const PremiumFeature(
      id: 'data_export',
      name: 'Data Export',
      description: 'Export your data in various formats',
      requiredTier: PremiumTier.premium,
      type: FeatureType.export,
    ),
    const PremiumFeature(
      id: 'cloud_backup',
      name: 'Cloud Backup',
      description: 'Automatic cloud backup and restore',
      requiredTier: PremiumTier.premium,
      type: FeatureType.backup,
    ),
    const PremiumFeature(
      id: 'priority_support',
      name: 'Priority Support',
      description: 'Get priority customer support',
      requiredTier: PremiumTier.premium,
      type: FeatureType.priority,
    ),
    const PremiumFeature(
      id: 'advanced_customization',
      name: 'Advanced Customization',
      description: 'Customize every aspect of the app',
      requiredTier: PremiumTier.premium,
      type: FeatureType.customization,
    ),
  ];

  Future<PremiumSubscription?> getCurrentSubscription() async {
    try {
      final subscriptionData = await _localStorage.getString('premium_subscription');
      if (subscriptionData != null) {
        final json = Map<String, dynamic>.from(subscriptionData as Map);
        return PremiumSubscription.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<PremiumTier> getCurrentTier() async {
    final subscription = await getCurrentSubscription();
    if (subscription != null && subscription.status == SubscriptionStatus.active) {
      return subscription.tier;
    }
    return PremiumTier.free;
  }

  Future<bool> hasFeature(FeatureType feature) async {
    final tier = await getCurrentTier();
    return tier.hasFeature(feature);
  }

  Future<bool> canCreateQuest() async {
    final tier = await getCurrentTier();
    if (tier.questLimit == -1) return true; // Unlimited
    
    // Check current quest count (this would be implemented with actual quest service)
    final currentQuestCount = await _getCurrentQuestCount();
    return currentQuestCount < tier.questLimit;
  }

  Future<int> getRemainingQuests() async {
    final tier = await getCurrentTier();
    if (tier.questLimit == -1) return -1; // Unlimited
    
    final currentQuestCount = await _getCurrentQuestCount();
    return (tier.questLimit - currentQuestCount).clamp(0, tier.questLimit);
  }

  Future<bool> hasUnlimitedQuests() async {
    final tier = await getCurrentTier();
    return tier.questLimit == -1;
  }

  Future<bool> hasPriorityAICoach() async {
    return await hasFeature(FeatureType.aiCoach);
  }

  Future<bool> hasAdvancedCustomization() async {
    return await hasFeature(FeatureType.customization);
  }

  Future<bool> hasAdvancedAnalytics() async {
    return await hasFeature(FeatureType.analytics);
  }

  Future<bool> hasPrioritySupport() async {
    return await hasFeature(FeatureType.priority);
  }

  Future<bool> canUseFamily() async {
    final subscription = await getCurrentSubscription();
    return subscription?.tier == PremiumTier.family;
  }

  Future<bool> isStudentPlan() async {
    final subscription = await getCurrentSubscription();
    return subscription?.tier == PremiumTier.student;
  }

  Future<int> getFamilyMemberLimit() async {
    final tier = await getCurrentTier();
    return tier.familyMemberLimit;
  }

  Future<List<FamilyMember>> getFamilyMembers() async {
    if (!await canUseFamily()) return [];
    
    // Mock implementation - would fetch from actual family service
    return [
      FamilyMember(
        id: 'member_1',
        name: 'Parent',
        email: 'parent@example.com',
        role: FamilyRole.admin,
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        isActive: true,
      ),
      FamilyMember(
        id: 'member_2',
        name: 'Child 1',
        email: 'child1@example.com',
        role: FamilyRole.member,
        joinedAt: DateTime.now().subtract(const Duration(days: 20)),
        isActive: true,
      ),
    ];
  }

  Future<bool> inviteFamilyMember(String email, FamilyRole role) async {
    if (!await canUseFamily()) return false;
    
    final currentMembers = await getFamilyMembers();
    final limit = await getFamilyMemberLimit();
    
    if (currentMembers.length >= limit) return false;
    
    // Mock implementation - would send actual invitation
    return true;
  }

  Future<bool> removeFamilyMember(String memberId) async {
    if (!await canUseFamily()) return false;
    
    // Mock implementation - would remove from actual family service
    return true;
  }

  Future<StudentVerificationStatus> getStudentVerificationStatus() async {
    if (!await isStudentPlan()) {
      return StudentVerificationStatus.notApplicable;
    }
    
    // Mock implementation - would check actual verification status
    final verificationData = await _localStorage.getString('student_verification');
    if (verificationData == null) {
      return StudentVerificationStatus.pending;
    }
    
    final data = Map<String, dynamic>.from(verificationData as Map);
    final status = data['status'] as String;
    
    return StudentVerificationStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => StudentVerificationStatus.pending,
    );
  }

  Future<bool> submitStudentVerification({
    required String schoolName,
    required String studentId,
    required String documentUrl,
  }) async {
    if (!await isStudentPlan()) return false;
    
    final verificationData = {
      'schoolName': schoolName,
      'studentId': studentId,
      'documentUrl': documentUrl,
      'submittedAt': DateTime.now().toIso8601String(),
      'status': StudentVerificationStatus.pending.name,
    };
    
    await _localStorage.setString('student_verification', jsonEncode(verificationData));
    return true;
  }

  Future<PremiumUsageStats> getUsageStats() async {
    // Mock implementation - would fetch actual usage statistics
    return PremiumUsageStats(
      questsCreated: 45,
      questLimit: await getCurrentTier().then((t) => t.questLimit),
      aiCoachInteractions: 120,
      dataExports: 3,
      backupsCreated: 8,
      themesUsed: 5,
      familyMembersActive: await canUseFamily() ? 4 : 0,
      storageUsed: 2.5, // GB
      storageLimit: 10.0, // GB
    );
  }

  Future<List<PremiumBenefit>> getActiveBenefits() async {
    final tier = await getCurrentTier();
    final benefits = <PremiumBenefit>[];
    
    if (tier.questLimit == -1) {
      benefits.add(const PremiumBenefit(
        id: 'unlimited_quests',
        title: 'Unlimited Quests',
        description: 'Create as many quests as you need',
        icon: 'infinity',
        isActive: true,
      ));
    }
    
    if (await hasPriorityAICoach()) {
      benefits.add(const PremiumBenefit(
        id: 'priority_ai',
        title: 'Priority AI Coach',
        description: 'Faster response times and advanced insights',
        icon: 'robot',
        isActive: true,
      ));
    }
    
    if (await hasAdvancedAnalytics()) {
      benefits.add(const PremiumBenefit(
        id: 'advanced_analytics',
        title: 'Advanced Analytics',
        description: 'Detailed insights and predictions',
        icon: 'chart',
        isActive: true,
      ));
    }
    
    if (await hasFeature(FeatureType.export)) {
      benefits.add(const PremiumBenefit(
        id: 'data_export',
        title: 'Data Export',
        description: 'Export your data in multiple formats',
        icon: 'download',
        isActive: true,
      ));
    }
    
    if (await hasFeature(FeatureType.backup)) {
      benefits.add(const PremiumBenefit(
        id: 'cloud_backup',
        title: 'Cloud Backup',
        description: 'Automatic backup and restore',
        icon: 'cloud',
        isActive: true,
      ));
    }
    
    if (await canUseFamily()) {
      benefits.add(const PremiumBenefit(
        id: 'family_plan',
        title: 'Family Sharing',
        description: 'Share with up to 6 family members',
        icon: 'family',
        isActive: true,
      ));
    }
    
    return benefits;
  }

  Future<void> activateSubscription(PremiumSubscription subscription) async {
    await _localStorage.setString('premium_subscription', jsonEncode(subscription.toJson()));
    _subscriptionController.add(subscription);
  }

  Future<void> cancelSubscription(String reason) async {
    final subscription = await getCurrentSubscription();
    if (subscription != null) {
      final cancelledSubscription = subscription.copyWith(
        status: SubscriptionStatus.cancelled,
        cancellationReason: reason,
        cancellationDate: DateTime.now(),
        autoRenew: false,
      );
      
      await _localStorage.setString('premium_subscription', jsonEncode(cancelledSubscription.toJson()));
      _subscriptionController.add(cancelledSubscription);
    }
  }

  Future<void> renewSubscription() async {
    final subscription = await getCurrentSubscription();
    if (subscription != null && subscription.status == SubscriptionStatus.expired) {
      final renewedSubscription = subscription.copyWith(
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(
          subscription.billingCycle == BillingCycle.monthly
              ? const Duration(days: 30)
              : const Duration(days: 365),
        ),
        lastPaymentDate: DateTime.now(),
        nextPaymentDate: DateTime.now().add(
          subscription.billingCycle == BillingCycle.monthly
              ? const Duration(days: 30)
              : const Duration(days: 365),
        ),
      );
      
      await _localStorage.setString('premium_subscription', jsonEncode(renewedSubscription.toJson()));
      _subscriptionController.add(renewedSubscription);
    }
  }

  Future<List<PremiumPlan>> getAvailablePlans() async {
    return availablePlans;
  }

  Future<PremiumPlan?> getPlan(String planId) async {
    try {
      return availablePlans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  Future<List<PremiumFeature>> getAvailableFeatures() async {
    return premiumFeatures;
  }

  Future<List<PremiumFeature>> getUnlockedFeatures() async {
    final tier = await getCurrentTier();
    return premiumFeatures.where((feature) => tier.hasFeature(feature.type)).toList();
  }

  Future<bool> isTrialAvailable() async {
    final hasUsedTrial = await _localStorage.getBool('has_used_trial') ?? false;
    return !hasUsedTrial;
  }

  Future<void> startTrial(String planId) async {
    final plan = await getPlan(planId);
    if (plan != null) {
      final trialSubscription = PremiumSubscription(
        id: 'trial_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user', // This would come from auth service
        planId: planId,
        tier: plan.tier,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)), // 7-day trial
        status: SubscriptionStatus.trial,
        billingCycle: BillingCycle.monthly,
        autoRenew: false,
      );
      
      await activateSubscription(trialSubscription);
      await _localStorage.setBool('has_used_trial', true);
    }
  }

  Future<int> _getCurrentQuestCount() async {
    // This would be implemented with actual quest service
    // For now, return a mock value
    return 5;
  }

  void dispose() {
    _subscriptionController.close();
  }
}

final premiumServiceProvider = Provider<PremiumService>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return PremiumService(localStorage);
});

final currentSubscriptionProvider = StreamProvider<PremiumSubscription?>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.subscriptionStream;
});

final currentTierProvider = FutureProvider<PremiumTier>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.getCurrentTier();
});

final availablePlansProvider = FutureProvider<List<PremiumPlan>>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.getAvailablePlans();
});

final unlockedFeaturesProvider = FutureProvider<List<PremiumFeature>>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.getUnlockedFeatures();
});

final premiumUsageStatsProvider = FutureProvider<PremiumUsageStats>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.getUsageStats();
});

final activeBenefitsProvider = FutureProvider<List<PremiumBenefit>>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.getActiveBenefits();
});

final familyMembersLimitProvider = FutureProvider<int>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.getFamilyMemberLimit();
});

final canCreateQuestProvider = FutureProvider<bool>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.canCreateQuest();
});

final remainingQuestsProvider = FutureProvider<int>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  return premiumService.getRemainingQuests();
});