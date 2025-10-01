import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/routing/app_router.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndScheduleAuxiliaryNotification();
    }
  }

  Future<void> _checkAndScheduleAuxiliaryNotification() async {
    final now = DateTime.now();
    if (now.hour < 20 || (now.hour == 20 && now.minute < 30)) {
      return; // It's not yet time for the auxiliary notification
    }

    final uid = ref.read(uidProvider);
    if (uid == null) return;

    final completed = await ref.read(questLogRepositoryProvider).hasCompletedDailyGoal(uid);
    if (!completed) {
      await ref.read(notificationServiceProvider).scheduleAuxiliaryReminder('20:30');
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.stats)) return 1;
    if (location.startsWith(AppRoutes.pair)) return 2;
    if (location.startsWith(AppRoutes.quests)) return 3;
    if (location.startsWith(AppRoutes.settings)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final navigation = ref.read(navigationUseCaseProvider);
    switch (index) {
      case 0:
        navigation.goHome();
        break;
      case 1:
        navigation.goToStats();
        break;
      case 2:
        navigation.goToPair();
        break;
      case 3:
        navigation.goToQuests();
        break;
      case 4:
        navigation.goToSettings();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: tokens.background,
            child: child,
          );
        },
        child: widget.child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: tokens.brandPrimary,
        unselectedItemColor: tokens.textMuted,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: tokens.surface,
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: '進捗',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'ペア',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist),
            label: 'クエスト',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}