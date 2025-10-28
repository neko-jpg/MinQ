import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/policy_documents.dart';
import 'package:minq/presentation/common/sharing/social_sharing_demo.dart';
import 'package:minq/presentation/screens/account_deletion_screen.dart';
import 'package:minq/presentation/screens/ai_concierge_chat_screen.dart';
import 'package:minq/presentation/screens/ai_insights_screen.dart';
import 'package:minq/presentation/screens/battle_screen.dart';
import 'package:minq/presentation/screens/celebration_screen.dart';
import 'package:minq/presentation/screens/challenges_screen.dart';
import 'package:minq/presentation/screens/community_board_screen.dart';
import 'package:minq/presentation/screens/create_mini_quest_screen.dart';
import 'package:minq/presentation/screens/create_quest_screen.dart';
import 'package:minq/presentation/screens/edit_quest_screen.dart';
import 'package:minq/presentation/screens/events_screen.dart';
import 'package:minq/presentation/screens/guild_screen.dart';
import 'package:minq/presentation/screens/habit_analysis_screen.dart';
import 'package:minq/presentation/screens/habit_story_screen.dart';
import 'package:minq/presentation/screens/home_screen.dart';
import 'package:minq/presentation/screens/login_screen.dart';
import 'package:minq/presentation/screens/mood_tracking_screen.dart';
import 'package:minq/presentation/screens/notification_settings_screen.dart';
import 'package:minq/presentation/screens/onboarding_screen.dart';
import 'package:minq/presentation/screens/pair/buddy_list_screen.dart';
import 'package:minq/presentation/screens/pair/chat_screen.dart';
import 'package:minq/presentation/screens/pair/pair_matching_screen.dart';
import 'package:minq/presentation/screens/personality_diagnosis_screen.dart';
import 'package:minq/presentation/screens/policy_viewer_screen.dart';
import 'package:minq/presentation/screens/profile_management_screen.dart';
import 'package:minq/presentation/screens/profile_screen.dart';
import 'package:minq/presentation/screens/profile_setting_screen.dart';
import 'package:minq/presentation/screens/quest_detail_screen.dart';
import 'package:minq/presentation/screens/quest_timer_screen.dart';
import 'package:minq/presentation/screens/quests_screen.dart';
import 'package:minq/presentation/screens/record_screen.dart';
import 'package:minq/presentation/screens/referral_screen.dart';
import 'package:minq/presentation/screens/settings_screen.dart';
import 'package:minq/presentation/screens/shell_screen.dart';
import 'package:minq/presentation/screens/stats_screen.dart';
import 'package:minq/presentation/screens/streak_recovery_screen.dart';
import 'package:minq/presentation/screens/support_screen.dart';
import 'package:minq/presentation/screens/weekly_report_screen.dart';

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
  static const profileManagement = '/profile/management';
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
  static const aiConciergeChat = '/ai-concierge-chat';
  static const aiInsights = '/ai-insights';
  static const habitStory = '/habit-story';
  static const battle = '/battle';
  static const personalityDiagnosis = '/personality-diagnosis';
  static const weeklyReport = '/weekly-report';
  static const guild = '/guild';
  static const createMiniQuest = '/mini-quest/create';
  static const challenges = '/challenges';
  static const questTimer = '/quest/:questId/timer';
  static const referral = '/referral';
  static const habitAnalysis = '/habit/:habitId/analysis';
  static const moodTracking = '/mood-tracking';
  static const streakRecovery = '/streak-recovery/:questId';
  static const events = '/events';
  static const aiCoachSettings = '/ai-coach-settings';
  static const liveActivitySettings = '/live-activity-settings';
  static const home = '/';
  static const stats = '/stats';
  static const quests = '/quests';
  static const settings = '/settings';
  static const pair = '/pair';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authChanges = ref.watch(authRepositoryProvider).authStateChanges;
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(authChanges),
    redirect: (context, state) {
      // マーケティングアトリビューション
      unawaited(
        ref.read(marketingAttributionServiceProvider).captureUri(state.uri),
      );

      // 認証ガード
      final authRepo = ref.read(authRepositoryProvider);
      final guestUserId = ref.read(guestUserIdProvider);
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
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
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
        path: AppRoutes.pair,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const BuddyListScreen(),
              transitionType: SharedAxisTransitionType.horizontal,
            ),
      ),
      GoRoute(
        path: AppRoutes.quests,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const QuestsScreen(),
              transitionType: SharedAxisTransitionType.horizontal,
            ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const SettingsScreen(),
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
      GoRoute(
        path: AppRoutes.aiConciergeChat,
        pageBuilder: (context, state) {
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: const AiConciergeChatScreen(),
            transitionType: SharedAxisTransitionType.vertical,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.aiInsights,
        pageBuilder: (context, state) {
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: const AiInsightsScreen(),
            transitionType: SharedAxisTransitionType.horizontal,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.habitStory,
        pageBuilder: (context, state) {
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: const HabitStoryScreen(),
            transitionType: SharedAxisTransitionType.horizontal,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.battle,
        pageBuilder: (context, state) {
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: const BattleScreen(),
            transitionType: SharedAxisTransitionType.horizontal,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.personalityDiagnosis,
        pageBuilder: (context, state) {
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: const PersonalityDiagnosisScreen(),
            transitionType: SharedAxisTransitionType.horizontal,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.weeklyReport,
        pageBuilder: (context, state) {
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: const WeeklyReportScreen(),
            transitionType: SharedAxisTransitionType.horizontal,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.guild,
        pageBuilder: (context, state) {
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: const GuildScreen(),
            transitionType: SharedAxisTransitionType.horizontal,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createMiniQuest,
        pageBuilder: (context, state) {
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: const CreateMiniQuestScreen(),
            transitionType: SharedAxisTransitionType.vertical,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.questTimer,
        pageBuilder: (context, state) {
          final questId =
              int.tryParse(state.pathParameters['questId'] ?? '') ?? 0;
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: QuestTimerScreen(questId: questId),
            transitionType: SharedAxisTransitionType.vertical,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.referral,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const ReferralScreen(),
              transitionType: SharedAxisTransitionType.horizontal,
            ),
      ),
      GoRoute(
        path: AppRoutes.habitAnalysis,
        pageBuilder: (context, state) {
          final habitId = state.pathParameters['habitId'] ?? '';
          final habitName = state.uri.queryParameters['name'] ?? '習慣';
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: HabitAnalysisScreen(habitId: habitId, habitName: habitName),
            transitionType: SharedAxisTransitionType.vertical,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.moodTracking,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const MoodTrackingScreen(),
              transitionType: SharedAxisTransitionType.horizontal,
            ),
      ),
      GoRoute(
        path: AppRoutes.streakRecovery,
        pageBuilder: (context, state) {
          final questId =
              int.tryParse(state.pathParameters['questId'] ?? '') ?? 0;
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: StreakRecoveryScreen(questId: questId),
            transitionType: SharedAxisTransitionType.vertical,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.events,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const EventsScreen(),
              transitionType: SharedAxisTransitionType.horizontal,
            ),
      ),
      GoRoute(
        path: AppRoutes.aiCoachSettings,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const PersonalityDiagnosisScreen(),
              transitionType: SharedAxisTransitionType.horizontal,
            ),
      ),
      GoRoute(
        path: AppRoutes.liveActivitySettings,
        pageBuilder:
            (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const MoodTrackingScreen(),
              transitionType: SharedAxisTransitionType.horizontal,
            ),
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
            path: AppRoutes.challenges,
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: ChallengesScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: '/profile-management',
            pageBuilder: (context, state) => buildPageWithTransition<void>(
              context: context,
              state: state,
              child: const ProfileManagementScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});


