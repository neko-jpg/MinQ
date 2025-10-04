import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/controllers/usage_limit_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen>
    with WidgetsBindingObserver {
  DateTime? _lastNavTap;
  static const Duration _navThrottle = Duration(milliseconds: 500);
  DateTime? _sessionStartedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStartedAt = DateTime.now();
  }

  @override
  void dispose() {
    _recordSessionUsage();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sessionStartedAt = DateTime.now();
      _checkAndScheduleAuxiliaryNotification();
      ref.read(usageLimitControllerProvider.notifier).refresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _recordSessionUsage();
    }
  }

  Future<void> _recordSessionUsage() async {
    if (_sessionStartedAt == null) return;
    final duration = DateTime.now().difference(_sessionStartedAt!);
    _sessionStartedAt = null;
    if (duration.isNegative || duration.inSeconds == 0) return;
    await ref
        .read(usageLimitControllerProvider.notifier)
        .recordUsage(duration);
  }

  Future<void> _checkAndScheduleAuxiliaryNotification() async {
    final now = DateTime.now();
    if (now.hour < 20 || (now.hour == 20 && now.minute < 30)) {
      return; // It's not yet time for the auxiliary notification
    }

    final uid = ref.read(uidProvider);
    if (uid == null) return;

    final completed = await ref
        .read(questLogRepositoryProvider)
        .hasCompletedDailyGoal(uid);
    if (!completed) {
      await ref
          .read(notificationServiceProvider)
          .scheduleAuxiliaryReminder('20:30');
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
    final now = DateTime.now();
    if (_lastNavTap != null && now.difference(_lastNavTap!) < _navThrottle) {
      return;
    }
    _lastNavTap = now;
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
    FeedbackManager.selected();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final currentIndex = _calculateSelectedIndex(context);
    final usageLimitState = ref.watch(usageLimitControllerProvider);

    const navItems = <BottomNavigationBarItem>[
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
    ];
    assert(navItems.length <= 5, 'ボトムナビゲーションのタブ数は5個以下にしてください。');

    final scaffold = Scaffold(
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
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: tokens.spacing(6)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (int index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: tokens.brandPrimary,
          unselectedItemColor: tokens.textMuted,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          backgroundColor: tokens.surface,
          elevation: 0,
          items: navItems,
        ),
      ),
    );

    if (!usageLimitState.isBlocked) {
      return scaffold;
    }

    return Stack(
      children: [
        scaffold,
        _UsageLimitOverlay(state: usageLimitState),
      ],
    );
  }
}

class _UsageLimitOverlay extends ConsumerWidget {
  const _UsageLimitOverlay({required this.state});

  final UsageLimitViewState state;

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--';
    if (duration.inHours >= 1) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '$hours時間$minutes分';
    }
    return '${duration.inMinutes}分';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final navigation = ref.read(navigationUseCaseProvider);
    final dailyLimit = state.dailyLimit ?? Duration.zero;
    final used = state.usedToday;
    final remaining = state.remaining;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: EdgeInsets.all(tokens.spacing(5)),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: tokens.cornerXLarge(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.lock_clock,
                    size: tokens.spacing(10), color: tokens.brandPrimary,),
                SizedBox(height: tokens.spacing(3)),
                Text(
                  '利用時間制限に達しました',
                  style: tokens.titleLarge.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.spacing(2)),
                Text(
                  '本日の利用 ${_formatDuration(used)} / ${_formatDuration(dailyLimit)}',
                  style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                ),
                SizedBox(height: tokens.spacing(1)),
                Text(
                  remaining == Duration.zero
                      ? '今日はこれ以上操作できません。'
                      : '残り時間: ${_formatDuration(remaining)}',
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                ),
                SizedBox(height: tokens.spacing(4)),
                MinqSecondaryButton(
                  label: '設定を開く',
                  onPressed: () async {
                    navigation.goToSettings();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
