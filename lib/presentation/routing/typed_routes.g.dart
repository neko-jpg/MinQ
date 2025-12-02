// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typed_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $onboardingRoute,
      $loginRoute,
      $recordRoute,
      $celebrationRoute,
      $profileRoute,
      $policyRoute,
      $supportRoute,
      $communityBoardRoute,
      $createQuestRoute,
      $editQuestRoute,
      $questDetailRoute,
      $notificationSettingsRoute,
      $profileSettingsRoute,
      $pairMatchingRoute,
      $pairChatRoute,
      $accountDeletionRoute,
      $battleRoute,
      $createMiniQuestRoute,
      $questTimerRoute,
      $referralRoute,
      $timeCapsuleRoute,
      $moodTrackingRoute,
      $streakRecoveryRoute,
      $mainShellRoute,
    ];

RouteBase get $onboardingRoute => GoRouteData.$route(
      path: '/onboarding',
      factory: $OnboardingRouteExtension._fromState,
    );

extension $OnboardingRouteExtension on OnboardingRoute {
  static OnboardingRoute _fromState(GoRouterState state) =>
      const OnboardingRoute();

  String get location => GoRouteData.$location(
        '/onboarding',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $loginRoute => GoRouteData.$route(
      path: '/login',
      factory: $LoginRouteExtension._fromState,
    );

extension $LoginRouteExtension on LoginRoute {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  String get location => GoRouteData.$location(
        '/login',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $recordRoute => GoRouteData.$route(
      path: '/record/:questId',
      factory: $RecordRouteExtension._fromState,
    );

extension $RecordRouteExtension on RecordRoute {
  static RecordRoute _fromState(GoRouterState state) => RecordRoute(
        questId: int.parse(state.pathParameters['questId']!),
      );

  String get location => GoRouteData.$location(
        '/record/${Uri.encodeComponent(questId.toString())}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $celebrationRoute => GoRouteData.$route(
      path: '/celebration',
      factory: $CelebrationRouteExtension._fromState,
    );

extension $CelebrationRouteExtension on CelebrationRoute {
  static CelebrationRoute _fromState(GoRouterState state) =>
      const CelebrationRoute();

  String get location => GoRouteData.$location(
        '/celebration',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $profileRoute => GoRouteData.$route(
      path: '/profile',
      factory: $ProfileRouteExtension._fromState,
    );

extension $ProfileRouteExtension on ProfileRoute {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  String get location => GoRouteData.$location(
        '/profile',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $policyRoute => GoRouteData.$route(
      path: '/policy/:id',
      factory: $PolicyRouteExtension._fromState,
    );

extension $PolicyRouteExtension on PolicyRoute {
  static PolicyRoute _fromState(GoRouterState state) => PolicyRoute(
        id: state.pathParameters['id']!,
      );

  String get location => GoRouteData.$location(
        '/policy/${Uri.encodeComponent(id)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $supportRoute => GoRouteData.$route(
      path: '/support',
      factory: $SupportRouteExtension._fromState,
    );

extension $SupportRouteExtension on SupportRoute {
  static SupportRoute _fromState(GoRouterState state) => const SupportRoute();

  String get location => GoRouteData.$location(
        '/support',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $communityBoardRoute => GoRouteData.$route(
      path: '/community-board',
      factory: $CommunityBoardRouteExtension._fromState,
    );

extension $CommunityBoardRouteExtension on CommunityBoardRoute {
  static CommunityBoardRoute _fromState(GoRouterState state) =>
      const CommunityBoardRoute();

  String get location => GoRouteData.$location(
        '/community-board',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $createQuestRoute => GoRouteData.$route(
      path: '/quests/create',
      factory: $CreateQuestRouteExtension._fromState,
    );

extension $CreateQuestRouteExtension on CreateQuestRoute {
  static CreateQuestRoute _fromState(GoRouterState state) =>
      const CreateQuestRoute();

  String get location => GoRouteData.$location(
        '/quests/create',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $editQuestRoute => GoRouteData.$route(
      path: '/quests/:questId/edit',
      factory: $EditQuestRouteExtension._fromState,
    );

extension $EditQuestRouteExtension on EditQuestRoute {
  static EditQuestRoute _fromState(GoRouterState state) => EditQuestRoute(
        questId: int.parse(state.pathParameters['questId']!),
      );

  String get location => GoRouteData.$location(
        '/quests/${Uri.encodeComponent(questId.toString())}/edit',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $questDetailRoute => GoRouteData.$route(
      path: '/quest/:questId',
      factory: $QuestDetailRouteExtension._fromState,
    );

extension $QuestDetailRouteExtension on QuestDetailRoute {
  static QuestDetailRoute _fromState(GoRouterState state) => QuestDetailRoute(
        questId: int.parse(state.pathParameters['questId']!),
      );

  String get location => GoRouteData.$location(
        '/quest/${Uri.encodeComponent(questId.toString())}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $notificationSettingsRoute => GoRouteData.$route(
      path: '/settings/notifications',
      factory: $NotificationSettingsRouteExtension._fromState,
    );

extension $NotificationSettingsRouteExtension on NotificationSettingsRoute {
  static NotificationSettingsRoute _fromState(GoRouterState state) =>
      const NotificationSettingsRoute();

  String get location => GoRouteData.$location(
        '/settings/notifications',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $profileSettingsRoute => GoRouteData.$route(
      path: '/settings/profile',
      factory: $ProfileSettingsRouteExtension._fromState,
    );

extension $ProfileSettingsRouteExtension on ProfileSettingsRoute {
  static ProfileSettingsRoute _fromState(GoRouterState state) =>
      const ProfileSettingsRoute();

  String get location => GoRouteData.$location(
        '/settings/profile',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pairMatchingRoute => GoRouteData.$route(
      path: '/pair/matching',
      factory: $PairMatchingRouteExtension._fromState,
    );

extension $PairMatchingRouteExtension on PairMatchingRoute {
  static PairMatchingRoute _fromState(GoRouterState state) => PairMatchingRoute(
        code: state.uri.queryParameters['code'],
      );

  String get location => GoRouteData.$location(
        '/pair/matching',
        queryParams: {
          if (code != null) 'code': code,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pairChatRoute => GoRouteData.$route(
      path: '/pair/chat/:pairId',
      factory: $PairChatRouteExtension._fromState,
    );

extension $PairChatRouteExtension on PairChatRoute {
  static PairChatRoute _fromState(GoRouterState state) => PairChatRoute(
        pairId: state.pathParameters['pairId']!,
      );

  String get location => GoRouteData.$location(
        '/pair/chat/${Uri.encodeComponent(pairId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $accountDeletionRoute => GoRouteData.$route(
      path: '/settings/delete-account',
      factory: $AccountDeletionRouteExtension._fromState,
    );

extension $AccountDeletionRouteExtension on AccountDeletionRoute {
  static AccountDeletionRoute _fromState(GoRouterState state) =>
      const AccountDeletionRoute();

  String get location => GoRouteData.$location(
        '/settings/delete-account',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $battleRoute => GoRouteData.$route(
      path: '/battle',
      factory: $BattleRouteExtension._fromState,
    );

extension $BattleRouteExtension on BattleRoute {
  static BattleRoute _fromState(GoRouterState state) => const BattleRoute();

  String get location => GoRouteData.$location(
        '/battle',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $createMiniQuestRoute => GoRouteData.$route(
      path: '/mini-quest/create',
      factory: $CreateMiniQuestRouteExtension._fromState,
    );

extension $CreateMiniQuestRouteExtension on CreateMiniQuestRoute {
  static CreateMiniQuestRoute _fromState(GoRouterState state) =>
      const CreateMiniQuestRoute();

  String get location => GoRouteData.$location(
        '/mini-quest/create',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $questTimerRoute => GoRouteData.$route(
      path: '/quest/:questId/timer',
      factory: $QuestTimerRouteExtension._fromState,
    );

extension $QuestTimerRouteExtension on QuestTimerRoute {
  static QuestTimerRoute _fromState(GoRouterState state) => QuestTimerRoute(
        questId: int.parse(state.pathParameters['questId']!),
      );

  String get location => GoRouteData.$location(
        '/quest/${Uri.encodeComponent(questId.toString())}/timer',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $referralRoute => GoRouteData.$route(
      path: '/referral',
      factory: $ReferralRouteExtension._fromState,
    );

extension $ReferralRouteExtension on ReferralRoute {
  static ReferralRoute _fromState(GoRouterState state) => const ReferralRoute();

  String get location => GoRouteData.$location(
        '/referral',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $timeCapsuleRoute => GoRouteData.$route(
      path: '/time-capsule',
      factory: $TimeCapsuleRouteExtension._fromState,
    );

extension $TimeCapsuleRouteExtension on TimeCapsuleRoute {
  static TimeCapsuleRoute _fromState(GoRouterState state) =>
      const TimeCapsuleRoute();

  String get location => GoRouteData.$location(
        '/time-capsule',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $moodTrackingRoute => GoRouteData.$route(
      path: '/mood-tracking',
      factory: $MoodTrackingRouteExtension._fromState,
    );

extension $MoodTrackingRouteExtension on MoodTrackingRoute {
  static MoodTrackingRoute _fromState(GoRouterState state) =>
      const MoodTrackingRoute();

  String get location => GoRouteData.$location(
        '/mood-tracking',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $streakRecoveryRoute => GoRouteData.$route(
      path: '/streak-recovery/:questId',
      factory: $StreakRecoveryRouteExtension._fromState,
    );

extension $StreakRecoveryRouteExtension on StreakRecoveryRoute {
  static StreakRecoveryRoute _fromState(GoRouterState state) =>
      StreakRecoveryRoute(
        questId: int.parse(state.pathParameters['questId']!),
      );

  String get location => GoRouteData.$location(
        '/streak-recovery/${Uri.encodeComponent(questId.toString())}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mainShellRoute => ShellRouteData.$route(
      factory: $MainShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/',
          factory: $HomeRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/stats',
          factory: $StatsRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/pair',
          factory: $PairRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/quests',
          factory: $QuestsRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/settings',
          factory: $SettingsRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/challenges',
          factory: $ChallengesRouteExtension._fromState,
        ),
      ],
    );

extension $MainShellRouteExtension on MainShellRoute {
  static MainShellRoute _fromState(GoRouterState state) =>
      const MainShellRoute();
}

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $StatsRouteExtension on StatsRoute {
  static StatsRoute _fromState(GoRouterState state) => const StatsRoute();

  String get location => GoRouteData.$location(
        '/stats',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PairRouteExtension on PairRoute {
  static PairRoute _fromState(GoRouterState state) => const PairRoute();

  String get location => GoRouteData.$location(
        '/pair',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $QuestsRouteExtension on QuestsRoute {
  static QuestsRoute _fromState(GoRouterState state) => const QuestsRoute();

  String get location => GoRouteData.$location(
        '/quests',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SettingsRouteExtension on SettingsRoute {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  String get location => GoRouteData.$location(
        '/settings',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ChallengesRouteExtension on ChallengesRoute {
  static ChallengesRoute _fromState(GoRouterState state) =>
      const ChallengesRoute();

  String get location => GoRouteData.$location(
        '/challenges',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
