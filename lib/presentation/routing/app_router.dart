import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/screens/shell_screen.dart';
import 'package:minq/presentation/screens/home_screen.dart';
import 'package:minq/presentation/screens/stats_screen.dart';
import 'package:minq/presentation/screens/pair_screen.dart';
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
import 'package:minq/presentation/screens/support_screen.dart';
import 'package:minq/presentation/screens/notification_settings_screen.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

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

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      unawaited(
        ref.read(marketingAttributionServiceProvider).captureUri(state.uri),
      );
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => buildPageWithTransition<void>(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildPageWithTransition<void>(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/record/:questId',
        pageBuilder: (context, state) {
          final questId = int.tryParse(state.pathParameters['questId'] ?? '') ?? 0;
          return buildPageWithTransition<void>(
            context: context,
            state: state,
            child: RecordScreen(questId: questId),
            transitionType: SharedAxisTransitionType.vertical,
          );
        },
      ),
      GoRoute(
        path: '/celebration',
        pageBuilder: (context, state) => buildPageWithTransition<void>(
          context: context,
          state: state,
          child: const CelebrationScreen(),
          transitionType: SharedAxisTransitionType.scaled,
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => buildPageWithTransition<void>(
          context: context,
          state: state,
          child: const ProfileScreen(),
          transitionType: SharedAxisTransitionType.vertical,
        ),
      ),
      GoRoute(
        path: '/policy/:id',
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
        path: '/support',
        pageBuilder: (context, state) => buildPageWithTransition<void>(
          context: context,
          state: state,
          child: const SupportScreen(),
          transitionType: SharedAxisTransitionType.vertical,
        ),
      ),
      GoRoute(
        path: '/quests/create',
        pageBuilder: (context, state) => buildPageWithTransition<void>(
          context: context,
          state: state,
          child: const CreateQuestScreen(),
          transitionType: SharedAxisTransitionType.vertical,
        ),
      ),
      GoRoute(
        path: '/settings/notifications',
        pageBuilder: (context, state) => buildPageWithTransition<void>(
          context: context,
          state: state,
          child: const NotificationSettingsScreen(),
          transitionType: SharedAxisTransitionType.vertical,
        ),
      ),
      // Main navigation shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) => buildPageWithTransition<void>(
          context: context,
          state: state,
          child: ShellScreen(child: child),
        ),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/stats',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StatsScreen(),
            ),
          ),
          GoRoute(
            path: '/pair',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PairScreen(),
            ),
          ),
          GoRoute(
            path: '/quests',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuestsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});