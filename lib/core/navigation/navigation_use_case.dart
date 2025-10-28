import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/routing/app_router.dart';

/// Navigation use case for handling app navigation
class NavigationUseCase {
  const NavigationUseCase(this._router);

  final GoRouter _router;

  /// Navigate to home screen
  void goHome() {
    _router.go(AppRoutes.home);
  }

  /// Navigate to stats screen
  void goToStats() {
    _router.go(AppRoutes.stats);
  }

  /// Navigate to challenges screen
  void goToChallenges() {
    _router.go(AppRoutes.challenges);
  }

  /// Navigate to profile screen
  void goToProfile() {
    _router.go(AppRoutes.profile);
  }

  /// Navigate to settings screen
  void goToSettings() {
    _router.go(AppRoutes.settings);
  }

  /// Navigate to AI insights screen
  void goToAiInsights() {
    _router.go(AppRoutes.aiInsights);
  }

  /// Navigate to profile management screen
  void goToProfileManagement() {
    _router.go(AppRoutes.profileManagement);
  }

  /// Navigate to create mini quest screen
  void goToCreateMiniQuest() {
    _router.go(AppRoutes.createMiniQuest);
  }

  /// Navigate to quests screen
  void goToQuests() {
    _router.go(AppRoutes.quests);
  }

  /// Navigate to login screen
  void goToLogin() {
    _router.go(AppRoutes.login);
  }

  /// Navigate to quest detail screen
  void goToQuestDetail(String questId) {
    _router.go(AppRoutes.questDetail.replaceAll(':questId', questId));
  }

  /// Navigate to create quest screen
  void goToCreateQuest() {
    _router.go(AppRoutes.createQuest);
  }

  /// Navigate to celebration screen
  void goToCelebration() {
    _router.go(AppRoutes.celebration);
  }

  /// Navigate to referral screen
  void goToReferral() {
    _router.go(AppRoutes.referral);
  }

  /// Navigate to habit analysis screen
  void goToHabitAnalysis(String habitId, String analysisType) {
    _router.go(AppRoutes.habitAnalysis.replaceAll(':habitId', habitId));
  }
}

/// Provider for navigation use case
final navigationUseCaseProvider = Provider<NavigationUseCase>((ref) {
  final router = ref.read(routerProvider);
  return NavigationUseCase(router);
});