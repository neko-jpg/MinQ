// This test file serves as a compile-time validation for AI feature integration.
// By importing all the necessary components, we ensure that the classes, methods,
// and structures are available and correctly defined. If any of these imports
// fail, or if the code within the test fails to compile, it indicates a
// problem with the AI feature integration.

import 'package:flutter_test/flutter_test.dart';
import 'package:minq/features/ai/application/ai_integration_manager.dart';
import 'package:minq/features/ai/application/realtime_coach_service.dart';
import 'package:minq/features/ai/application/social_proof_service.dart';
import 'package:minq/features/ai/application/weekly_report_service.dart';
import 'package:minq/features/ai/application/personality_diagnosis_service.dart';
import 'package:minq/features/ai/application/habit_story_generator.dart';
import 'package:minq/features/ai/application/failure_prediction_service.dart';
import 'package:minq/features/ai/domain/tflite_unified_ai_service.dart';
import 'package:minq/features/ai/presentation/screens/ai_concierge_chat_screen.dart';
import 'package:minq/features/ai/presentation/screens/ai_insights_screen.dart';
import 'package:minq/features/ai/presentation/screens/habit_analysis_screen.dart';
import 'package:minq/features/ai/presentation/screens/weekly_report_screen.dart';
import 'package:minq/features/ai/presentation/screens/personality_diagnosis_screen.dart';
import 'package:minq/features/ai/presentation/screens/battle_screen.dart';
import 'package:minq/features/ai/presentation/screens/habit_story_screen.dart';
import 'package:minq/features/ai/presentation/screens/mood_tracking_screen.dart';
import 'package:minq/features/ai/presentation/screens/smart_notification_settings_screen.dart';
import 'package:minq/features/ai/presentation/widgets/ai_concierge_card.dart';
import 'package:minq/features/ai/presentation/widgets/failure_prediction_widget.dart';
import 'package:minq/features/ai/presentation/widgets/compact_failure_prediction_widget.dart';
import 'package:minq/features/ai/presentation/widgets/ai_coach_overlay.dart';
import 'package:minq/features/ai/presentation/widgets/live_activity_widget.dart';
import 'package:minq/features/ai/presentation/widgets/mood_selector_widget.dart';
import 'package:minq/presentation/widgets/time_capsule_card.dart';
import 'package:minq/features/ai/presentation/widgets/event_card.dart';
import 'package:minq/features/ai/presentation/widgets/streak_protection_widget.dart';
import 'package:minq/features/ai/presentation/controllers/ai_concierge_chat_controller.dart';
import 'package:minq/features/onboarding/application/progressive_onboarding_controller.dart';
import 'package:minq/features/ai/domain/models/sentiment_result.dart';
import 'package:minq/features/ai/domain/models/habit_recommendation.dart';
import 'package:minq/features/ai/domain/models/failure_prediction.dart';
import 'package:minq/features/ai/domain/models/completion_record.dart';
import 'package:minq/features/ai/domain/models/ai_concierge_message.dart';
import 'package:minq/features/ai/domain/models/coaching_message.dart';
import 'package:minq/features/ai/domain/models/weekly_report.dart';
import 'package:minq/features/ai/domain/models/live_activity_update.dart';
import 'package:minq/features/ai/domain/models/activity_event.dart';
import 'package:minq/features/ai/domain/models/ai_settings.dart';
import 'package:minq/features/ai/domain/models/coaching_settings.dart';
import 'package:minq/features/ai/domain/models/social_settings.dart';
import 'package:minq/data/providers.dart';

void main() {
  testWidgets('AI Integration Compile-Time Validation',
      (WidgetTester tester) async {
    // This test simply checks that all the imported AI-related classes can be
    // referenced without causing compile-time errors. It doesn't instantiate
    // them, but it does confirm their existence.

    // AI Services
    expect(TFLiteUnifiedAIService, isA<Type>());
    expect(AIIntegrationManager, isA<Type>());
    expect(RealtimeCoachService, isA<Type>());
    expect(SocialProofService, isA<Type>());
    expect(WeeklyReportService, isA<Type>());
    expect(PersonalityDiagnosisService, isA<Type>());
    expect(HabitStoryGenerator, isA<Type>());
    expect(FailurePredictionService, isA<Type>());

    // AI Screens
    expect(AiConciergeChatScreen, isA<Type>());
    expect(AiInsightsScreen, isA<Type>());
    expect(HabitAnalysisScreen, isA<Type>());
    expect(WeeklyReportScreen, isA<Type>());
    expect(PersonalityDiagnosisScreen, isA<Type>());
    expect(BattleScreen, isA<Type>());
    expect(HabitStoryScreen, isA<Type>());
    expect(MoodTrackingScreen, isA<Type>());
    expect(SmartNotificationSettingsScreen, isA<Type>());

    // AI Widgets
    expect(AiConciergeCard, isA<Type>());
    expect(FailurePredictionWidget, isA<Type>());
    expect(CompactFailurePredictionWidget, isA<Type>());
    expect(AiCoachOverlay, isA<Type>());
    expect(LiveActivityWidget, isA<Type>());
    expect(MoodSelectorWidget, isA<Type>());
    expect(TimeCapsuleCard, isA<Type>());
    expect(EventCard, isA<Type>());
    expect(StreakProtectionWidget, isA<Type>());

    // AI Controllers
    expect(AiConciergeChatController, isA<Type>());
    expect(ProgressiveOnboardingController, isA<Type>());

    // Data Models
    expect(SentimentResult, isA<Type>());
    expect(HabitRecommendation, isA<Type>());
    expect(FailurePrediction, isA<Type>());
    expect(CompletionRecord, isA<Type>());
    expect(AiConciergeMessage, isA<Type>());
    expect(CoachingMessage, isA<Type>());
    expect(WeeklyReport, isA<Type>());
    expect(LiveActivityUpdate, isA<Type>());
    expect(ActivityEvent, isA<Type>());

    // Enums (checking one value from each)
    expect(SentimentType.positive, isA<SentimentType>());
    expect(FailureRiskLevel.low, isA<FailureRiskLevel>());
    expect(CoachingMessageType.encouragement, isA<CoachingMessageType>());
    expect(ActivityType.habitCompletion, isA<ActivityType>());
    expect(ActivityUpdateType.newUser, isA<ActivityUpdateType>());
    expect(EncouragementType.text, isA<EncouragementType>());

    // Providers
    expect(aiIntegrationManagerProvider, isNotNull);
    expect(aiEventStreamProvider, isNotNull);
    expect(aiConciergeChatControllerProvider, isNotNull);
    expect(failurePredictionServiceProvider, isNotNull);

    // Settings
    expect(AISettings, isA<Type>());
    expect(CoachingSettings, isA<Type>());
    expect(SocialSettings, isA<Type>());
  });
}
