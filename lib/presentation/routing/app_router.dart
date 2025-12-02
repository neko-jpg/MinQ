import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/routing/typed_routes.dart';
import 'package:minq/presentation/common/policy_documents.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouterのrefreshListenableとして使用するStreamラッパー
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

CustomTransitionPage<T> buildPageWithTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: transitionType,
        child: child,
      );
    },
  );
}

class AppRoutes {
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const record = '/record/:questId';
  static const celebration = '/celebration';
  static const profile = '/profile';
  static const policy = '/policy/:id';
  static const support = '/support';
  static const createQuest = '/quests/create';
  static const editQuest = '/quests/:questId/edit';
  static const questDetail = '/quest/:questId';
  static const notificationSettings = '/settings/notifications';
  static const profileSettings = '/settings/profile';
  static const pairMatching = '/pair/matching';
  static const pairChat = '/pair/chat/:pairId';
  static const accountDeletion = '/settings/delete-account';
  static const communityBoard = '/community-board';
  static const battle = '/battle';
  static const createMiniQuest = '/mini-quest/create';
  static const challenges = '/challenges';
  static const questTimer = '/quest/:questId/timer';
  static const referral = '/referral';
  static const timeCapsule = '/time-capsule';
  static const moodTracking = '/mood-tracking';
  static const streakRecovery = '/streak-recovery/:questId';
  static const home = '/';
  static const stats = '/stats';
  static const pair = '/pair';
  static const quests = '/quests';
  static const settings = '/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  // 認証状態を監視
  final authRepo = ref.watch(authRepositoryProvider);
  final guestUserId = ref.watch(guestUserIdProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    navigatorKey: _rootNavigatorKey,
    // refreshListenable: GoRouterRefreshStream(
    //   ref.watch(authStateProvider.notifier).stream,
    // ),
    redirect: (context, state) {
      debugPrint(
        'DEBUG: Router redirect check. Location: ${state.matchedLocation}',
      );
      // マーケティングアトリビューション
      unawaited(
        ref.read(marketingAttributionServiceProvider).captureUri(state.uri),
      );

      // 認証ガード
      final isAuthenticated =
          authRepo.getCurrentUser() != null || guestUserId != null;

      final isOnboardingRoute = state.matchedLocation == AppRoutes.onboarding;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      final isPublicRoute = isOnboardingRoute || isLoginRoute;

      // 未認証で保護されたルートにアクセスしようとした場合
      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.onboarding;
      }

      // 認証済みでログイン画面にアクセスしようとした場合
      if (isAuthenticated && isPublicRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: $appRoutes,
  );
});

class NavigationUseCase {
  final GoRouter _router;
  NavigationUseCase(this._router);

  void goToOnboarding() => _router.go(const OnboardingRoute().location);
  void goToLogin() {
    debugPrint('DEBUG: NavigationUseCase.goToLogin called');
    try {
      final location = const LoginRoute().location;
      _router.push(location);
    } catch (e) {
      debugPrint('DEBUG: Error in goToLogin: $e');
      _router.push(AppRoutes.login);
    }
  }

  void goToRecord(int questId) =>
      _router.push(RecordRoute(questId: questId).location);
  void goToCelebration() => _router.push(const CelebrationRoute().location);
  void goToProfile() => _router.push(const ProfileRoute().location);
  void goToPolicy(PolicyDocumentId documentId) =>
      _router.push(PolicyRoute(id: documentId.name).location);
  void goToSupport() => _router.push(const SupportRoute().location);
  void goToCommunityBoard() =>
      _router.push(const CommunityBoardRoute().location);
  void goToCreateQuest() => _router.push(const CreateQuestRoute().location);
  void goToEditQuest(int questId) =>
      _router.push(EditQuestRoute(questId: questId).location);
  void goToQuestDetail(int questId) =>
      _router.push(QuestDetailRoute(questId: questId).location);
  void goToNotificationSettings() =>
      _router.push(const NotificationSettingsRoute().location);
  void goToProfileSettings() =>
      _router.push(const ProfileSettingsRoute().location);
  void goToAccountDeletion() =>
      _router.push(const AccountDeletionRoute().location);
  void goToPairMatching({String? code}) {
    _router.push(PairMatchingRoute(code: code).location);
  }

  void goToPairChat(String pairId) =>
      _router.push(PairChatRoute(pairId: pairId).location);
  void goToBattle() => _router.push(const BattleRoute().location);
  void goToCreateMiniQuest() =>
      _router.push(const CreateMiniQuestRoute().location);
  void goToChallenges() => _router.go(const ChallengesRoute().location);
  void goToQuestTimer(int questId) =>
      _router.push(QuestTimerRoute(questId: questId).location);
  void goToReferral() => _router.push(const ReferralRoute().location);
  void goToTimeCapsule() => _router.push(const TimeCapsuleRoute().location);
  void goToMoodTracking() => _router.push(const MoodTrackingRoute().location);
  void goToStreakRecovery(int questId) =>
      _router.push(StreakRecoveryRoute(questId: questId).location);

  void goHome() => _router.go(const HomeRoute().location);
  void goToStats() => _router.go(const StatsRoute().location);
  void goToPair() => _router.go(const PairRoute().location);
  void goToQuests() => _router.go(const QuestsRoute().location);
  void goToSettings() => _router.go(const SettingsRoute().location);

  void pop() => _router.pop();
}

final navigationUseCaseProvider = Provider<NavigationUseCase>((ref) {
  final router = ref.watch(routerProvider);
  return NavigationUseCase(router);
});
