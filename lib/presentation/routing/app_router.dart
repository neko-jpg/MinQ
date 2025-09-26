import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:minq/presentation/screens/support_screen.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

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
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/record/:questId',
        builder: (context, state) {
          final questId = int.tryParse(state.pathParameters['questId'] ?? '') ?? 0;
          return RecordScreen(questId: questId);
        },
      ),
      GoRoute(
        path: '/celebration',
        builder: (context, state) => const CelebrationScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/policy/:id',
        builder: (context, state) {
          final rawId = state.pathParameters['id'];
          final documentId = PolicyDocumentId.values.firstWhere(
            (PolicyDocumentId value) => value.name == rawId,
            orElse: () => PolicyDocumentId.terms,
          );
          return PolicyViewerScreen(documentId: documentId);
        },
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      // Main navigation shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/pair',
            builder: (context, state) => const PairScreen(),
          ),
          GoRoute(
            path: '/quests',
            builder: (context, state) => const QuestsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});