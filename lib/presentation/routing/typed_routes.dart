import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/common/policy_documents.dart';
import 'package:minq/presentation/screens/account_deletion_screen.dart';
import 'package:minq/presentation/screens/battle_screen.dart';
import 'package:minq/presentation/screens/celebration_screen.dart';
import 'package:minq/presentation/screens/challenges_screen.dart';
import 'package:minq/presentation/screens/community_board_screen.dart';
import 'package:minq/presentation/screens/create_mini_quest_screen.dart';
import 'package:minq/presentation/screens/create_quest_screen.dart';
import 'package:minq/presentation/screens/edit_quest_screen.dart';
import 'package:minq/presentation/screens/home_screen.dart';
import 'package:minq/presentation/screens/login_screen.dart';
import 'package:minq/presentation/screens/mood_tracking_screen.dart';
import 'package:minq/presentation/screens/notification_settings_screen.dart';
import 'package:minq/presentation/screens/onboarding_screen.dart';
import 'package:minq/presentation/screens/pair/buddy_list_screen.dart';
import 'package:minq/presentation/screens/pair/chat_screen.dart';
import 'package:minq/presentation/screens/pair/pair_matching_screen.dart';
import 'package:minq/presentation/screens/policy_viewer_screen.dart';
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
import 'package:minq/presentation/screens/time_capsule_screen.dart';

part 'typed_routes.g.dart';

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingScreen();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginScreen();
}

@TypedGoRoute<RecordRoute>(path: '/record/:questId')
class RecordRoute extends GoRouteData {
  const RecordRoute({required this.questId});
  final int questId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RecordScreen(questId: questId);
}

@TypedGoRoute<CelebrationRoute>(path: '/celebration')
class CelebrationRoute extends GoRouteData {
  const CelebrationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CelebrationScreen();
}

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}

@TypedGoRoute<PolicyRoute>(path: '/policy/:id')
class PolicyRoute extends GoRouteData {
  const PolicyRoute({required this.id});
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final documentId = PolicyDocumentId.values.firstWhere(
      (value) => value.name == id,
      orElse: () => PolicyDocumentId.terms,
    );
    return PolicyViewerScreen(documentId: documentId);
  }
}

@TypedGoRoute<SupportRoute>(path: '/support')
class SupportRoute extends GoRouteData {
  const SupportRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SupportScreen();
}

@TypedGoRoute<CommunityBoardRoute>(path: '/community-board')
class CommunityBoardRoute extends GoRouteData {
  const CommunityBoardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CommunityBoardScreen();
}

@TypedGoRoute<CreateQuestRoute>(path: '/quests/create')
class CreateQuestRoute extends GoRouteData {
  const CreateQuestRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateQuestScreen();
}

@TypedGoRoute<EditQuestRoute>(path: '/quests/:questId/edit')
class EditQuestRoute extends GoRouteData {
  const EditQuestRoute({required this.questId});
  final int questId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EditQuestScreen(questId: questId);
}

@TypedGoRoute<QuestDetailRoute>(path: '/quest/:questId')
class QuestDetailRoute extends GoRouteData {
  const QuestDetailRoute({required this.questId});
  final int questId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      QuestDetailScreen(questId: questId);
}

@TypedGoRoute<NotificationSettingsRoute>(path: '/settings/notifications')
class NotificationSettingsRoute extends GoRouteData {
  const NotificationSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NotificationSettingsScreen();
}

@TypedGoRoute<ProfileSettingsRoute>(path: '/settings/profile')
class ProfileSettingsRoute extends GoRouteData {
  const ProfileSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileSettingScreen();
}

@TypedGoRoute<PairMatchingRoute>(path: '/pair/matching')
class PairMatchingRoute extends GoRouteData {
  const PairMatchingRoute({this.code});
  final String? code;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PairMatchingScreen(code: code);
}

@TypedGoRoute<PairChatRoute>(path: '/pair/chat/:pairId')
class PairChatRoute extends GoRouteData {
  const PairChatRoute({required this.pairId});
  final String pairId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ChatScreen(pairId: pairId);
}

@TypedGoRoute<AccountDeletionRoute>(path: '/settings/delete-account')
class AccountDeletionRoute extends GoRouteData {
  const AccountDeletionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AccountDeletionScreen();
}

@TypedGoRoute<BattleRoute>(path: '/battle')
class BattleRoute extends GoRouteData {
  const BattleRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BattleScreen();
}

@TypedGoRoute<CreateMiniQuestRoute>(path: '/mini-quest/create')
class CreateMiniQuestRoute extends GoRouteData {
  const CreateMiniQuestRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateMiniQuestScreen();
}

@TypedGoRoute<QuestTimerRoute>(path: '/quest/:questId/timer')
class QuestTimerRoute extends GoRouteData {
  const QuestTimerRoute({required this.questId});
  final int questId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      QuestTimerScreen(questId: questId);
}

@TypedGoRoute<ReferralRoute>(path: '/referral')
class ReferralRoute extends GoRouteData {
  const ReferralRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ReferralScreen();
}

@TypedGoRoute<TimeCapsuleRoute>(path: '/time-capsule')
class TimeCapsuleRoute extends GoRouteData {
  const TimeCapsuleRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const TimeCapsuleScreen();
}

@TypedGoRoute<MoodTrackingRoute>(path: '/mood-tracking')
class MoodTrackingRoute extends GoRouteData {
  const MoodTrackingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MoodTrackingScreen();
}

@TypedGoRoute<StreakRecoveryRoute>(path: '/streak-recovery/:questId')
class StreakRecoveryRoute extends GoRouteData {
  const StreakRecoveryRoute({required this.questId});
  final int questId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      StreakRecoveryScreen(questId: questId);
}

@TypedShellRoute<MainShellRoute>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<HomeRoute>(path: '/'),
    TypedGoRoute<StatsRoute>(path: '/stats'),
    TypedGoRoute<PairRoute>(path: '/pair'),
    TypedGoRoute<QuestsRoute>(path: '/quests'),
    TypedGoRoute<SettingsRoute>(path: '/settings'),
    TypedGoRoute<ChallengesRoute>(path: '/challenges'),
  ],
)
class MainShellRoute extends ShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return ShellScreen(child: navigator);
  }
}

class HomeRoute extends GoRouteData {
  const HomeRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class StatsRoute extends GoRouteData {
  const StatsRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const StatsScreen();
}

class PairRoute extends GoRouteData {
  const PairRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BuddyListScreen();
}

class QuestsRoute extends GoRouteData {
  const QuestsRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const QuestsScreen();
}

class SettingsRoute extends GoRouteData {
  const SettingsRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsScreen();
}

class ChallengesRoute extends GoRouteData {
  const ChallengesRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChallengesScreen();
}
