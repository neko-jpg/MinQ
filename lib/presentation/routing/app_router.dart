import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/screens/shell_screen.dart';
import 'package:minq/presentation/screens/home_screen.dart';
import 'package:minq/presentation/screens/stats_screen.dart';
import 'package:minq/presentation/screens/quests_screen.dart';
import 'package:minq/presentation/screens/settings_screen.dart';
import 'package:minq/presentation/screens/onboarding_screen.dart';
import 'package:minq/presentation/screens/login_screen.dart';
import 'package:minq/presentation/screens/record_screen.dart';
import 'package:minq/presentation/screens/celebration_screen.dart';
import 'package:minq/presentation/screens/profile_screen.dart';
import 'package:minq/presentation/screens/policy_viewer_screen.dart';
import 'package:minq/presentation/common/policy_documents.dart';
import 'package:minq/presentation/screens/create_quest_screen.dart';
import 'package:minq/presentation/screens/edit_quest_screen.dart';
import 'package:minq/presentation/screens/support_screen.dart';
import 'package:minq/presentation/screens/notification_settings_screen.dart';
import 'package:minq/presentation/screens/pair/pair_matching_screen.dart';
import 'package:minq/presentation/screens/pair/buddy_list_screen.dart';
import 'package:minq/presentation/screens/pair/chat_screen.dart';
import 'package:minq/presentation/common/sharing/social_sharing_demo.dart';
import 'package:minq/presentation/screens/account_deletion_screen.dart';
import 'package:minq/presentation/screens/profile_setting_screen.dart';
import 'package:minq/presentation/screens/profile_setting_screen.dart';
import 'package:minq/presentation/screens/quest_detail_screen.dart';
import 'package:minq/presentation/screens/community_board_screen.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

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
  static const socialSharingDemo = '/social-sharing-demo';
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
  static const home = '/';
  static const stats = '/stats';
  static const pair = '/pair';
  static const quests = '/quests';
  static const settings = '/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  // 認証状態を監視
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    navigatorKey: _rootNavigatorKey,
    // refreshListenable: GoRouterRefreshStream(
    //   ref.watch(authStateProvider.notifier).stream,
    // ),
    redirect: (context, state) {
      // マーケティングアトリビューション
      unawaited(
        ref.read(marketingAttributionServiceProvider).captureUri(state.uri),
      );

      // 認証ガード
      final isAuthenticated = authRepo.getCurrentUser() != null;

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
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const OnboardingScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.accountDeletion,
        pageBuilder: (context, state) => buildPageWithTransition<void>(
          context: context,
          state: state,
          child: const AccountDeletionScreen(),
          transitionType: SharedAxisTransitionType.vertical,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const LoginScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.record,
        pageBuilder: (context, state) {
          final questId =
              int.tryParse(state.pathParameters['questId'] ?? '') ?? 0;
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: RecordScreen(questId: questId),
            transitionType: SharedAxisTransitionType.vertical,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.celebration,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const CelebrationScreen(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
      ),
      GoRoute(
        path: AppRoutes.socialSharingDemo,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const SocialSharingDemo(),
            ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const ProfileScreen(),
              transitionType: SharedAxisTransitionType.vertical,
            ),
      ),
      GoRoute(
        path: AppRoutes.policy,
        pageBuilder: (context, state) {
          final rawId = state.pathParameters['id'];
          final documentId = PolicyDocumentId.values.firstWhere(
            (PolicyDocumentId value) => value.name == rawId,
            orElse: () => PolicyDocumentId.terms,
          );
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: PolicyViewerScreen(documentId: documentId),
            transitionType: SharedAxisTransitionType.vertical,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.support,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const SupportScreen(),
              transitionType: SharedAxisTransitionType.vertical,
            ),
      ),
      GoRoute(
        path: AppRoutes.communityBoard,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const CommunityBoardScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.createQuest,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const CreateQuestScreen(),
              transitionType: SharedAxisTransitionType.vertical,
            ),
      ),
      GoRoute(
        path: AppRoutes.editQuest,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: EditQuestScreen(
                questId: int.parse(state.pathParameters['questId']!),
              ),
              transitionType: SharedAxisTransitionType.vertical,
            ),
      ),
      GoRoute(
        path: AppRoutes.questDetail,
        pageBuilder: (context, state) {
          final questId =
              int.tryParse(state.pathParameters['questId'] ?? '') ?? 0;
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: QuestDetailScreen(questId: questId),
            transitionType: SharedAxisTransitionType.vertical,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const NotificationSettingsScreen(),
              transitionType: SharedAxisTransitionType.vertical,
            ),
      ),
      GoRoute(
        path: AppRoutes.profileSettings,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const ProfileSettingScreen(),
              transitionType: SharedAxisTransitionType.vertical,
            ),
      ),
      GoRoute(
        path: AppRoutes.pairMatching,
        pageBuilder: (context, state) {
          final code = state.uri.queryParameters['code'];
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: PairMatchingScreen(code: code),
            transitionType: SharedAxisTransitionType.vertical,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pairChat,
        pageBuilder: (context, state) {
          // final buddyId = state.pathParameters['buddyId']!;
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: ChatScreen(pairId: state.pathParameters['pairId'] ?? ''),
          );
        },
      ),
      // Main navigation shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder:
            (context, state, child) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: ShellScreen(child: child),
            ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder:
                (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.stats,
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: StatsScreen()),
          ),
          GoRoute(
            path: AppRoutes.pair,
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: BuddyListScreen()),
          ),
          GoRoute(
            path: AppRoutes.quests,
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: QuestsScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
  );
});

class NavigationUseCase {
  final GoRouter _router;
  NavigationUseCase(this._router);

  void goToOnboarding() => _router.go(AppRoutes.onboarding);
  void goToLogin() => _router.go(AppRoutes.login);
  void goToRecord(int questId) =>
      _router.go(AppRoutes.record.replaceFirst(':questId', questId.toString()));
  void goToCelebration() => _router.go(AppRoutes.celebration);
  void goToSocialSharingDemo() => _router.go(AppRoutes.socialSharingDemo);
  void goToProfile() => _router.go(AppRoutes.profile);
  void goToPolicy(PolicyDocumentId documentId) =>
      _router.go(AppRoutes.policy.replaceFirst(':id', documentId.name));
  void goToSupport() => _router.go(AppRoutes.support);
  void goToCommunityBoard() => _router.go(AppRoutes.communityBoard);
  void goToCreateQuest() => _router.go(AppRoutes.createQuest);
  void goToEditQuest(int questId) => _router.go(AppRoutes.editQuest.replaceFirst(':questId', questId.toString()));
  void goToQuestDetail(int questId) =>
      _router.go(AppRoutes.questDetail
          .replaceFirst(':questId', questId.toString()));
  void goToNotificationSettings() => _router.go(AppRoutes.notificationSettings);
  void goToProfileSettings() => _router.go(AppRoutes.profileSettings);
  void goToAccountDeletion() => _router.go(AppRoutes.accountDeletion);
  void goToPairMatching({String? code}) {
    final uri = Uri(path: AppRoutes.pairMatching, queryParameters: code != null ? {'code': code} : null);
    _router.go(uri.toString());
  }
  void goToPairChat(String pairId) =>
      _router.go(AppRoutes.pairChat.replaceFirst(':pairId', pairId));
  void goHome() => _router.go(AppRoutes.home);
  void goToStats() => _router.go(AppRoutes.stats);
  void goToPair() => _router.go(AppRoutes.pair);
  void goToQuests() => _router.go(AppRoutes.quests);
  void goToSettings() => _router.go(AppRoutes.settings);
}

final navigationUseCaseProvider = Provider<NavigationUseCase>((ref) {
  final router = ref.watch(routerProvider);
  return NavigationUseCase(router);
});
