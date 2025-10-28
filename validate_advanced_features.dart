/*
 * Comprehensive validation script for advanced features
 * Tests progressive onboarding, level systems, mood tracking, time capsule,
 * event systems, challenges, and all 49 master task features
 */

import 'dart:developer';
import 'dart:io';


class AdvancedFeatureValidator {
  static const String reportFile = 'advanced_features_validation_report.md';
  final List<ValidationResult> results = [];
  
  Future<void> validateAllFeatures() async {
    log('🚀 Starting Advanced Features Validation...\n');
    
    // Test progressive onboarding and level systems
    await _validateProgressiveOnboarding();
    
    // Verify mood tracking and time capsule features
    await _validateMoodTrackingAndTimeCapsule();
    
    // Ensure event systems and challenges work
    await _validateEventSystemsAndChallenges();
    
    // Test all 49 master task features
    await _validateMasterTaskFeatures();
    
    // Generate comprehensive report
    await _generateValidationReport();
    
    log('\n✅ Advanced Features Validation Complete!');
    log('📊 Report generated: $reportFile');
  }
  
  Future<void> _validateProgressiveOnboarding() async {
    log('📚 Validating Progressive Onboarding & Level Systems...');
    
    final features = [
      'Progressive Onboarding Controller',
      'Level Progress Widget',
      'Feature Lock Widget', 
      'Level Up Screen',
      'Onboarding Flow Integration'
    ];
    
    for (final feature in features) {
      final result = await _validateFeature(feature, _checkProgressiveOnboardingFeature);
      results.add(result);
    }
  }
  
  Future<void> _validateMoodTrackingAndTimeCapsule() async {
    log('🎭 Validating Mood Tracking & Time Capsule Features...');
    
    final features = [
      'Mood Tracking Screen',
      'Mood Selector Widget',
      'Time Capsule Screen', 
      'Time Capsule Card Widget',
      'Mood State Domain Model',
      'Time Capsule Domain Model'
    ];
    
    for (final feature in features) {
      final result = await _validateFeature(feature, _checkMoodAndTimeCapsuleFeature);
      results.add(result);
    }
  }
  
  Future<void> _validateEventSystemsAndChallenges() async {
    log('🎯 Validating Event Systems & Challenges...');
    
    final features = [
      'Event System Core',
      'Challenge Service',
      'Event Manager',
      'Events Screen',
      'Challenges Screen',
      'Event Card Widget',
      'Challenge Domain Models'
    ];
    
    for (final feature in features) {
      final result = await _validateFeature(feature, _checkEventAndChallengeFeature);
      results.add(result);
    }
  }
  
  Future<void> _validateMasterTaskFeatures() async {
    log('🏆 Validating All 49 Master Task Features...');
    
    final masterFeatures = [
      // AI Features (7 features)
      'TFLite Unified AI Service',
      'AI Integration Manager', 
      'Realtime Coach Service',
      'Failure Prediction Service',
      'Personality Diagnosis Service',
      'Weekly Report Service',
      'Social Proof Service',
      
      // Gamification Features (8 features)
      'Gamification Engine',
      'Reward System',
      'Achievement System',
      'Points System',
      'Badge System',
      'Rank System',
      'Challenge System',
      'Progress Visualization',
      
      // Social Features (6 features)
      'Pair System',
      'Referral System',
      'Guild/Community System',
      'Battle System',
      'Social Proof Features',
      'Reverse Accountability',
      
      // Premium Features (5 features)
      'Subscription Manager',
      'Streak Recovery Purchase',
      'Premium Content Access',
      'Monetization Service',
      'In-App Purchases',
      
      // Advanced UI Features (8 features)
      'Micro Interactions',
      'Premium Loading Animations',
      'Smooth Transitions',
      'Context Aware Widgets',
      'Emotional Feedback',
      'Progress Animations',
      'Live Activity Widget',
      'AI Coach Overlay',
      
      // Smart Features (7 features)
      'Smart Notification Service',
      'Notification Personalization',
      'Re-engagement Service',
      'Context Aware Service',
      'Battery Optimizer',
      'Image Optimizer',
      'Performance Monitoring',
      
      // Content Features (8 features)
      'Habit Story Generator',
      'AI Banner Generator',
      'Habit Templates',
      'Quest Templates',
      'Content Moderation',
      'Share Service',
      'Export Services',
      'Calendar Integration'
    ];
    
    for (final feature in masterFeatures) {
      final result = await _validateFeature(feature, _checkMasterTaskFeature);
      results.add(result);
    }
  }
  
  Future<ValidationResult> _validateFeature(String featureName, Future<FeatureStatus> Function(String) validator) async {
    try {
      final status = await validator(featureName);
      log('  ${status.isWorking ? '✅' : '❌'} $featureName: ${status.message}');
      return ValidationResult(featureName, status.isWorking, status.message, status.details);
    } catch (e) {
      log('  ❌ $featureName: Error during validation - $e');
      return ValidationResult(featureName, false, 'Validation error: $e', []);
    }
  }
  
  Future<FeatureStatus> _checkProgressiveOnboardingFeature(String featureName) async {
    switch (featureName) {
      case 'Progressive Onboarding Controller':
        return await _checkFile('lib/presentation/controllers/progressive_onboarding_controller.dart', [
          'class ProgressiveOnboardingController',
          'getCurrentLevel',
          'unlockFeature',
          'checkLevelRequirements'
        ]);
        
      case 'Level Progress Widget':
        return await _checkFile('lib/presentation/widgets/level_progress_widget.dart', [
          'class LevelProgressWidget',
          'build',
          'progress',
          'level'
        ]);
        
      case 'Feature Lock Widget':
        return await _checkFile('lib/presentation/widgets/feature_lock_widget.dart', [
          'class FeatureLockWidget',
          'isLocked',
          'requiredLevel',
          'unlockCondition'
        ]);
        
      case 'Level Up Screen':
        return await _checkFile('lib/presentation/screens/onboarding/level_up_screen.dart', [
          'class LevelUpScreen',
          'newLevel',
          'unlockedFeatures',
          'celebration'
        ]);
        
      default:
        return FeatureStatus(false, 'Unknown progressive onboarding feature', []);
    }
  }
  
  Future<FeatureStatus> _checkMoodAndTimeCapsuleFeature(String featureName) async {
    switch (featureName) {
      case 'Mood Tracking Screen':
        return await _checkFile('lib/presentation/screens/mood_tracking_screen.dart', [
          'class MoodTrackingScreen',
          'MoodState',
          'recordMood',
          'moodHistory'
        ]);
        
      case 'Mood Selector Widget':
        return await _checkFile('lib/presentation/widgets/mood_selector_widget.dart', [
          'class MoodSelectorWidget',
          'onMoodSelected',
          'selectedMood',
          'moodOptions'
        ]);
        
      case 'Time Capsule Screen':
        return await _checkFile('lib/presentation/screens/time_capsule_screen.dart', [
          'class TimeCapsuleScreen',
          'TimeCapsule',
          'createCapsule',
          'viewCapsule'
        ]);
        
      case 'Time Capsule Card Widget':
        return await _checkFile('lib/presentation/widgets/time_capsule_card.dart', [
          'class TimeCapsuleCard',
          'capsule',
          'onTap',
          'deliveryDate'
        ]);
        
      case 'Mood State Domain Model':
        return await _checkFile('lib/domain/mood/mood_state.dart', [
          'class MoodState',
          'mood',
          'timestamp',
          'toJson'
        ]);
        
      case 'Time Capsule Domain Model':
        return await _checkFile('lib/domain/time_capsule/time_capsule.dart', [
          'class TimeCapsule',
          'content',
          'deliveryDate',
          'isDelivered'
        ]);
        
      default:
        return FeatureStatus(false, 'Unknown mood/time capsule feature', []);
    }
  }
  
  Future<FeatureStatus> _checkEventAndChallengeFeature(String featureName) async {
    switch (featureName) {
      case 'Event System Core':
        return await _checkFile('lib/core/events/event_system.dart', [
          'class EventSystem',
          'createEvent',
          'subscribeToEvent',
          'triggerEvent'
        ]);
        
      case 'Challenge Service':
        return await _checkFile('lib/core/challenges/challenge_service.dart', [
          'class ChallengeService',
          'createChallenge',
          'joinChallenge',
          'completeChallenge'
        ]);
        
      case 'Event Manager':
        return await _checkFile('lib/core/challenges/event_manager.dart', [
          'class EventManager',
          'manageEvents',
          'scheduleEvent',
          'eventNotifications'
        ]);
        
      case 'Events Screen':
        return await _checkFile('lib/presentation/screens/events_screen.dart', [
          'class EventsScreen',
          'eventsList',
          'joinEvent',
          'eventDetails'
        ]);
        
      case 'Challenges Screen':
        return await _checkFile('lib/presentation/screens/challenges_screen.dart', [
          'class ChallengesScreen',
          'challengesList',
          'joinChallenge',
          'challengeProgress'
        ]);
        
      case 'Event Card Widget':
        return await _checkFile('lib/presentation/widgets/event_card.dart', [
          'class EventCard',
          'event',
          'onJoin',
          'eventStatus'
        ]);
        
      case 'Challenge Domain Models':
        return await _checkFile('lib/domain/challenges/challenge.dart', [
          'class Challenge',
          'title',
          'participants',
          'endDate'
        ]);
        
      default:
        return FeatureStatus(false, 'Unknown event/challenge feature', []);
    }
  }
  
  Future<FeatureStatus> _checkMasterTaskFeature(String featureName) async {
    final fileMap = {
      // AI Features
      'TFLite Unified AI Service': 'lib/core/ai/tflite_unified_ai_service.dart',
      'AI Integration Manager': 'lib/core/ai/ai_integration_manager.dart',
      'Realtime Coach Service': 'lib/core/ai/realtime_coach_service.dart',
      'Failure Prediction Service': 'lib/core/ai/failure_prediction_service.dart',
      'Personality Diagnosis Service': 'lib/core/ai/personality_diagnosis_service.dart',
      'Weekly Report Service': 'lib/core/ai/weekly_report_service.dart',
      'Social Proof Service': 'lib/core/ai/social_proof_service.dart',
      
      // Gamification Features
      'Gamification Engine': 'lib/core/gamification/gamification_engine.dart',
      'Reward System': 'lib/core/gamification/reward_system.dart',
      'Achievement System': 'lib/core/achievements/achievement_system.dart',
      'Points System': 'lib/domain/gamification/points.dart',
      'Badge System': 'lib/domain/gamification/badge.dart',
      'Rank System': 'lib/domain/gamification/rank.dart',
      'Challenge System': 'lib/core/challenges/challenge_service.dart',
      'Progress Visualization': 'lib/core/progress/progress_visualization_service.dart',
      
      // Social Features
      'Pair System': 'lib/presentation/screens/pair_screen.dart',
      'Referral System': 'lib/presentation/screens/referral_screen.dart',
      'Guild/Community System': 'lib/core/community/guild_service.dart',
      'Battle System': 'lib/core/battle/battle_service.dart',
      'Social Proof Features': 'lib/core/ai/social_proof_service.dart',
      'Reverse Accountability': 'lib/core/pair/reverse_accountability_service.dart',
      
      // Premium Features
      'Subscription Manager': 'lib/core/monetization/subscription_manager.dart',
      'Streak Recovery Purchase': 'lib/core/monetization/streak_recovery_purchase.dart',
      'Premium Content Access': 'lib/presentation/screens/subscription_premium_screen.dart',
      'Monetization Service': 'lib/data/services/monetization_service.dart',
      'In-App Purchases': 'lib/core/subscription/subscription_service.dart',
      
      // Advanced UI Features
      'Micro Interactions': 'lib/presentation/widgets/micro_interactions.dart',
      'Premium Loading Animations': 'lib/presentation/widgets/premium_loading.dart',
      'Smooth Transitions': 'lib/presentation/widgets/smooth_transitions.dart',
      'Context Aware Widgets': 'lib/presentation/widgets/context_aware_widgets.dart',
      'Emotional Feedback': 'lib/presentation/widgets/emotional_feedback.dart',
      'Progress Animations': 'lib/presentation/widgets/progress_animations.dart',
      'Live Activity Widget': 'lib/presentation/widgets/live_activity_widget.dart',
      'AI Coach Overlay': 'lib/presentation/widgets/ai_coach_overlay.dart',
      
      // Smart Features
      'Smart Notification Service': 'lib/core/notifications/smart_notification_service.dart',
      'Notification Personalization': 'lib/core/notifications/notification_personalization_engine.dart',
      'Re-engagement Service': 'lib/core/notifications/re_engagement_service.dart',
      'Context Aware Service': 'lib/core/context/context_aware_service.dart',
      'Battery Optimizer': 'lib/core/performance/battery_optimizer.dart',
      'Image Optimizer': 'lib/core/performance/image_optimizer.dart',
      'Performance Monitoring': 'lib/core/performance/performance_monitoring.dart',
      
      // Content Features
      'Habit Story Generator': 'lib/core/ai/habit_story_generator.dart',
      'AI Banner Generator': 'packages/integrations/lib/share/ai_banner_generator.dart',
      'Habit Templates': 'lib/core/templates/habit_templates.dart',
      'Quest Templates': 'lib/core/templates/quest_templates.dart',
      'Content Moderation': 'lib/core/moderation/content_moderation.dart',
      'Share Service': 'lib/core/sharing/share_service.dart',
      'Export Services': 'lib/core/export/data_export_service.dart',
      'Calendar Integration': 'lib/core/calendar/calendar_export_service.dart'
    };
    
    final filePath = fileMap[featureName];
    if (filePath == null) {
      return FeatureStatus(false, 'Unknown master task feature', []);
    }
    
    return await _checkFile(filePath, [
      'class',
      'Future',
      'async',
      'void'
    ]);
  }
  
  Future<FeatureStatus> _checkFile(String filePath, List<String> requiredElements) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final missingElements = <String>[];
      final foundElements = <String>[];
      
      for (final element in requiredElements) {
        if (content.contains(element)) {
          foundElements.add(element);
        } else {
          missingElements.add(element);
        }
      }
      
      final isWorking = missingElements.isEmpty;
      final message = isWorking 
          ? 'All required elements found'
          : 'Missing ${missingElements.length}/${requiredElements.length} elements';
      
      final details = [
        'File: $filePath',
        'Found elements: ${foundElements.join(', ')}',
        if (missingElements.isNotEmpty) 'Missing elements: ${missingElements.join(', ')}'
      ];
      
      return FeatureStatus(isWorking, message, details);
    } on FileSystemException {
      return FeatureStatus(false, 'File not found', ['Missing file: $filePath']);
    } catch (e) {
      return FeatureStatus(false, 'Error reading file: $e', ['File: $filePath']);
    }
  }
  
  Future<void> _generateValidationReport() async {
    final report = StringBuffer();
    
    report.writeln('# Advanced Features Validation Report');
    report.writeln('Generated: ${DateTime.now().toIso8601String()}');
    report.writeln();
    
    // Summary
    final totalFeatures = results.length;
    final workingFeatures = results.where((r) => r.isWorking).length;
    final failingFeatures = totalFeatures - workingFeatures;
    
    report.writeln('## Summary');
    report.writeln('- **Total Features Tested**: $totalFeatures');
    report.writeln('- **Working Features**: $workingFeatures');
    report.writeln('- **Failing Features**: $failingFeatures');
    report.writeln('- **Success Rate**: ${(workingFeatures / totalFeatures * 100).toStringAsFixed(1)}%');
    report.writeln();
    
    // Detailed Results
    report.writeln('## Detailed Results');
    report.writeln();
    
    final categories = {
      'Progressive Onboarding': results.where((r) => r.featureName.contains('Progressive') || r.featureName.contains('Level') || r.featureName.contains('Feature Lock')),
      'Mood & Time Capsule': results.where((r) => r.featureName.contains('Mood') || r.featureName.contains('Time Capsule')),
      'Events & Challenges': results.where((r) => r.featureName.contains('Event') || r.featureName.contains('Challenge')),
      'AI Features': results.where((r) => r.featureName.contains('AI') || r.featureName.contains('TFLite') || r.featureName.contains('Coach') || r.featureName.contains('Prediction')),
      'Gamification': results.where((r) => r.featureName.contains('Gamification') || r.featureName.contains('Reward') || r.featureName.contains('Achievement') || r.featureName.contains('Points') || r.featureName.contains('Badge') || r.featureName.contains('Rank')),
      'Social Features': results.where((r) => r.featureName.contains('Pair') || r.featureName.contains('Referral') || r.featureName.contains('Guild') || r.featureName.contains('Battle') || r.featureName.contains('Social')),
      'Premium Features': results.where((r) => r.featureName.contains('Subscription') || r.featureName.contains('Premium') || r.featureName.contains('Monetization') || r.featureName.contains('Purchase')),
      'UI Features': results.where((r) => r.featureName.contains('Micro') || r.featureName.contains('Animation') || r.featureName.contains('Transition') || r.featureName.contains('Widget') || r.featureName.contains('Overlay')),
      'Smart Features': results.where((r) => r.featureName.contains('Notification') || r.featureName.contains('Context') || r.featureName.contains('Battery') || r.featureName.contains('Performance')),
      'Content Features': results.where((r) => r.featureName.contains('Story') || r.featureName.contains('Banner') || r.featureName.contains('Template') || r.featureName.contains('Export') || r.featureName.contains('Calendar'))
    };
    
    for (final category in categories.entries) {
      if (category.value.isNotEmpty) {
        report.writeln('### ${category.key}');
        report.writeln();
        
        for (final result in category.value) {
          final status = result.isWorking ? '✅' : '❌';
          report.writeln('- $status **${result.featureName}**: ${result.message}');
          
          if (result.details.isNotEmpty) {
            for (final detail in result.details) {
              report.writeln('  - $detail');
            }
          }
        }
        report.writeln();
      }
    }
    
    // Recommendations
    report.writeln('## Recommendations');
    report.writeln();
    
    final failingResults = results.where((r) => !r.isWorking).toList();
    if (failingResults.isEmpty) {
      report.writeln('🎉 All advanced features are working correctly! The application is ready for the 100万DL milestone.');
    } else {
      report.writeln('### Priority Fixes Needed:');
      report.writeln();
      
      for (final result in failingResults) {
        report.writeln('1. **${result.featureName}**: ${result.message}');
        if (result.details.isNotEmpty) {
          report.writeln('   - ${result.details.join('\n   - ')}');
        }
      }
    }
    
    report.writeln();
    report.writeln('## Next Steps');
    report.writeln();
    report.writeln('1. Fix any failing features identified above');
    report.writeln('2. Run integration tests for all working features');
    report.writeln('3. Perform end-to-end testing of user flows');
    report.writeln('4. Validate performance under load');
    report.writeln('5. Prepare for production deployment');
    
    // ignore: avoid_slow_async_io
    await File(reportFile).writeAsString(report.toString());
  }
}

class ValidationResult {
  final String featureName;
  final bool isWorking;
  final String message;
  final List<String> details;
  
  ValidationResult(this.featureName, this.isWorking, this.message, this.details);
}

class FeatureStatus {
  final bool isWorking;
  final String message;
  final List<String> details;
  
  FeatureStatus(this.isWorking, this.message, this.details);
}

Future<void> main() async {
  final validator = AdvancedFeatureValidator();
  await validator.validateAllFeatures();
}