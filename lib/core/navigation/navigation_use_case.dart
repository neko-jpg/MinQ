import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:minq/presentation/common/policy_documents.dart';
import 'package:minq/presentation/routing/app_router.dart';

class NavigationUseCase {
  final GoRouter _router;
  NavigationUseCase(this._router);

  void goToOnboarding() => _router.go(AppRoutes.onboarding);
  void goToLogin() => _router.push(AppRoutes.login);
  void goToRecord(int questId) => _router.push(
    AppRoutes.record.replaceFirst(':questId', questId.toString()),
  );
  void goToCelebration() => _router.push(AppRoutes.celebration);
  void goToSocialSharingDemo() => _router.push(AppRoutes.socialSharingDemo);
  void goToProfile() => _router.go(AppRoutes.profile);
  void goToProfileManagement() => _router.push('/profile-management');
  void goToPolicy(PolicyDocumentId documentId) =>
      _router.push(AppRoutes.policy.replaceFirst(':id', documentId.name));
  void goToSupport() => _router.push(AppRoutes.support);
  void goToCommunityBoard() => _router.push(AppRoutes.communityBoard);
  void goToCreateQuest() => _router.push(AppRoutes.createQuest);
  void goToEditQuest(int questId) => _router.push(
    AppRoutes.editQuest.replaceFirst(':questId', questId.toString()),
  );
  // 詳細画面への遷移 - context.pushを使用してタブ履歴を保持
  void goToQuestDetail(int questId) => _router.push(
    AppRoutes.questDetail.replaceFirst(':questId', questId.toString()),
  );
  void goToNotificationSettings() =>
      _router.push(AppRoutes.notificationSettings);
  void goToProfileSettings() => _router.push(AppRoutes.profileSettings);
  void goToAccountDeletion() => _router.push(AppRoutes.accountDeletion);
  void goToPairMatching({String? code}) {
    final uri = Uri(
      path: AppRoutes.pairMatching,
      queryParameters: code != null ? {'code': code} : null,
    );
    _router.push(uri.toString());
  }

  void goToPairChat(String pairId) =>
      _router.push(AppRoutes.pairChat.replaceFirst(':pairId', pairId));
  void goToAiConciergeChat() => _router.push(AppRoutes.aiConciergeChat);
  void goToAiInsights() => _router.push(AppRoutes.aiInsights);
  void goToHabitStory() => _router.push(AppRoutes.habitStory);
  void goToBattle() => _router.push(AppRoutes.battle);
  void goToPersonalityDiagnosis() =>
      _router.push(AppRoutes.personalityDiagnosis);
  void goToWeeklyReport() => _router.push(AppRoutes.weeklyReport);
  void goToGuild() => _router.push(AppRoutes.guild);
  void goToCreateMiniQuest() => _router.push(AppRoutes.createMiniQuest);
  void goToQuestTimer(int questId) => _router.push(
    AppRoutes.questTimer.replaceFirst(':questId', questId.toString()),
  );
  void goToReferral() => _router.push(AppRoutes.referral);
  void goToHabitAnalysis(String habitId, String habitName) => _router.push(
    '${AppRoutes.habitAnalysis.replaceFirst(':habitId', habitId)}?name=${Uri.encodeComponent(habitName)}',
  );
  void goToMoodTracking() => _router.push(AppRoutes.moodTracking);
  void goToStreakRecovery(int questId) => _router.push(
    AppRoutes.streakRecovery.replaceFirst(':questId', questId.toString()),
  );
  void goToEvents() => _router.push(AppRoutes.events);
  void goToAICoachSettings() => _router.push(AppRoutes.aiCoachSettings);
  void goToLiveActivitySettings() =>
      _router.push(AppRoutes.liveActivitySettings);
  
  // タブ画面への遷移 - context.goを使用
  void goToChallenges() => _router.go(AppRoutes.challenges);
  void goHome() => _router.go(AppRoutes.home);
  void goToStats() => _router.go(AppRoutes.stats);
  void goToPair() => _router.go(AppRoutes.pair);
  void goToQuests() => _router.go(AppRoutes.quests);
  void goToSettings() => _router.go(AppRoutes.settings);
  void goToHelpCenter() => _router.push(AppRoutes.support);
  void goToBugReport() => _router.push(AppRoutes.support);
}

/// Provider for navigation use case
final navigationUseCaseProvider = Provider<NavigationUseCase>((ref) {
  final router = ref.read(routerProvider);
  return NavigationUseCase(router);
});
