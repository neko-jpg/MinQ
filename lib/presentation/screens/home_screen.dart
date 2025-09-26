import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/config/feature_flags.dart';
import 'package:minq/presentation/common/debouncer.dart';
import 'package:minq/presentation/common/minq_copy.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Quest {
  const Quest({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isCompleted = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
}

class QuestSuggestion {
  const QuestSuggestion({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

final List<Quest> _todayQuests = <Quest>[
  const Quest(
    title: 'Read 1 page of a book',
    subtitle: 'Learning',
    icon: Icons.auto_stories,
  ),
  const Quest(
    title: 'Do 5 push-ups',
    subtitle: 'Exercise',
    icon: Icons.fitness_center,
    isCompleted: true,
  ),
  const Quest(
    title: 'Tidy one surface',
    subtitle: 'Tidying',
    icon: Icons.countertops,
  ),
];

final List<QuestSuggestion> _suggestionPool = <QuestSuggestion>[
  const QuestSuggestion(
    title: 'Deep breathing',
    subtitle: '1 minute • Calm mind',
    icon: Icons.self_improvement,
  ),
  const QuestSuggestion(
    title: 'Inbox zero',
    subtitle: '5 emails • Focus',
    icon: Icons.mail_outline,
  ),
  const QuestSuggestion(
    title: 'Stretch break',
    subtitle: '2 minutes • Mobility',
    icon: Icons.accessibility_new,
  ),
  const QuestSuggestion(
    title: 'Water reminder',
    subtitle: '1 glass • Hydration',
    icon: Icons.local_drink_outlined,
  ),
  const QuestSuggestion(
    title: 'Gratitude note',
    subtitle: '30 seconds • Reflection',
    icon: Icons.sentiment_satisfied_alt_outlined,
  ),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _debouncer = Debouncer(milliseconds: 500);
  final List<int> _slotIndices = <int>[0, 1, 2];
  final Set<int> _snoozedSlots = <int>{};
  bool _showHelpBanner = true;
  bool _isLoading = true;
  bool _snoozeEnabled = true;

  @override
  void initState() {
    super.initState();
    final flags = ref.read(featureFlagsProvider);
    _snoozeEnabled = flags.homeSuggestionSnoozeEnabled;
    ref.listen<FeatureFlags>(featureFlagsProvider, (previous, next) {
      if (previous?.homeSuggestionSnoozeEnabled !=
          next.homeSuggestionSnoozeEnabled) {
        setState(() {
          _snoozeEnabled = next.homeSuggestionSnoozeEnabled;
        });
      }
    });
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _swapSuggestion(int slot) {
    setState(() {
      final nextIndex = (_slotIndices[slot] + 1) % _suggestionPool.length;
      _slotIndices[slot] = nextIndex;
      _snoozedSlots.remove(slot);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.replacedRecommendation)));
  }

  void _snoozeSuggestion(int slot) {
    setState(() => _snoozedSlots.add(slot));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.snoozedRecommendation)));
  }

  void _undoSnooze(int slot) {
    setState(() => _snoozedSlots.remove(slot));
  }

  QuestSuggestion _suggestionFor(int slot) {
    return _suggestionPool[_slotIndices[slot] % _suggestionPool.length];
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final hasQuests = _todayQuests.isNotEmpty;

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: _isLoading
            ? _HomeSkeleton(tokens: tokens)
            : ListView(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing(5)),
                children: <Widget>[
                  if (_showHelpBanner)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: tokens.spacing(5)),
                      child: Card(
                        elevation: 0,
                        color: tokens.brandPrimary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: tokens.cornerLarge()),
                        child: ListTile(
                          leading:
                              Icon(Icons.info_outline, color: tokens.brandPrimary),
                          title: Text(
                            '毎日3つのQuestをこなして、PairとHigh-fiveを送り合おう！',
                            style: tokens.bodySmall
                                .copyWith(color: tokens.textPrimary),
                          ),
                          trailing: Semantics(
                            button: true,
                            label: AppLocalizations.of(context)!.dismissHelpBanner,
                            child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .dismissHelpBanner,
                              icon: Icon(Icons.close, color: tokens.textPrimary),
                              onPressed: () =>
                                  setState(() => _showHelpBanner = false),
                            ),
                          ),
                        ),
                      ),
                    ),
                  _buildHeader(context, l10n),
                  SizedBox(height: tokens.spacing(7)),
                  _buildRecommendations(context, l10n),
                  SizedBox(height: tokens.spacing(7)),
                  _buildSectionHeader(context, l10n.todaysQuests),
                  SizedBox(height: tokens.spacing(4)),
                  if (!hasQuests)
                    MinqEmptyState(
                      icon: Icons.flag_circle_outlined,
                      title: l10n.noQuestsToday,
                      message: l10n.chooseFromTemplate,
                      actionLabel: l10n.findAQuest,
                      onAction: () => context.go('/quests'),
                    ),
                  if (hasQuests)
                    ..._todayQuests
                        .map((Quest quest) => _QuestCard(quest: quest)),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final tokens = context.tokens;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.goodMorning,
                  style: tokens.titleLarge.copyWith(color: tokens.textPrimary),
                ),
                SizedBox(height: tokens.spacing(1)),
                Text(
                  MinqCopy.valuePropositionSubheadline,
                  style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          SizedBox(width: tokens.spacing(3)),
          Semantics(
            label: l10n.openProfile,
            button: true,
            child: InkWell(
              onTap: () => context.go('/profile'),
              borderRadius: BorderRadius.circular(tokens.spacing(6)),
              child: Padding(
                padding: EdgeInsets.all(tokens.spacing(1)),
                child: CircleAvatar(
                  radius: tokens.spacing(6),
                  backgroundImage: const NetworkImage(
                    'https://i.pravatar.cc/150?img=3',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, AppLocalizations l10n) {
    final tokens = context.tokens;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.todays3Recommendations,
            style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            l10n.swapOrSnooze,
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing(4)),
          ...List<Widget>.generate(3, (int slot) {
            final snoozed = _snoozedSlots.contains(slot);
            final suggestion = _suggestionFor(slot);
            return _SuggestionCard(
              suggestion: suggestion,
              snoozed: snoozed,
              onSwap: () => _debouncer.run(() => _swapSuggestion(slot)),
              onSnooze: () => _debouncer.run(() => _snoozeSuggestion(slot)),
              onUndoSnooze: () => _undoSnooze(slot),
              l10n: l10n,
              snoozeEnabled: _snoozeEnabled,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final tokens = context.tokens;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing(5)),
      child: Text(
        title,
        style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(5),
        vertical: tokens.spacing(5),
      ),
      children: <Widget>[
        MinqSkeleton(
          height: tokens.spacing(12),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(6)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const MinqSkeletonLine(width: 140, height: 24),
                SizedBox(height: tokens.spacing(2)),
                const MinqSkeletonLine(width: 200, height: 18),
              ],
            ),
            MinqSkeletonAvatar(size: tokens.spacing(12)),
          ],
        ),
        SizedBox(height: tokens.spacing(7)),
        const MinqSkeletonLine(width: 180, height: 20),
        SizedBox(height: tokens.spacing(2.5)),
        const MinqSkeletonLine(width: 220, height: 14),
        SizedBox(height: tokens.spacing(4)),
        const MinqSkeletonList(itemCount: 3, itemHeight: 88),
        SizedBox(height: tokens.spacing(6)),
        const MinqSkeletonLine(width: 160, height: 20),
        SizedBox(height: tokens.spacing(3)),
        const MinqSkeletonList(itemCount: 3, itemHeight: 96),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.snoozed,
    required this.onSwap,
    required this.onSnooze,
    required this.onUndoSnooze,
    required this.l10n,
    required this.snoozeEnabled,
  });

  final QuestSuggestion suggestion;
  final bool snoozed;
  final VoidCallback onSwap;
  final VoidCallback onSnooze;
  final VoidCallback onUndoSnooze;
  final AppLocalizations l10n;
  final bool snoozeEnabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing(3)),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child:
            snoozed
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.snoozed,
                      style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                    ),
                    SizedBox(height: tokens.spacing(2)),
                    TextButton(
                      onPressed: onUndoSnooze,
                      child: Text(l10n.undo),
                    ),
                  ],
                )
                : Row(
                  children: <Widget>[
                    Container(
                      width: tokens.spacing(10),
                      height: tokens.spacing(10),
                      decoration: BoxDecoration(
                        color: tokens.brandPrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        suggestion.icon,
                        color: tokens.brandPrimary,
                        size: tokens.spacing(6),
                      ),
                    ),
                    SizedBox(width: tokens.spacing(4)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            suggestion.title,
                            style: tokens.titleSmall.copyWith(
                              color: tokens.textPrimary,
                            ),
                          ),
                          SizedBox(height: tokens.spacing(1)),
                          Text(
                            suggestion.subtitle,
                            style: tokens.bodySmall.copyWith(
                              color: tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          tooltip: l10n.swapRecommendation,
                          icon: const Icon(Icons.autorenew),
                          color: tokens.brandPrimary,
                          onPressed: onSwap,
                        ),
                        IconButton(
                          tooltip: snoozeEnabled
                              ? l10n.snoozeUntilTomorrow
                              : l10n.snoozeTemporarilyDisabled,
                          icon: const Icon(Icons.snooze),
                          color: tokens.textMuted,
                          onPressed: snoozeEnabled ? onSnooze : null,
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.go('/record'),
      borderRadius: tokens.cornerLarge(),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: tokens.spacing(5),
          vertical: tokens.spacing(2),
        ),
        padding: EdgeInsets.all(tokens.spacing(4)),
        decoration: BoxDecoration(
          color:
              quest.isCompleted
                  ? tokens.brandPrimary.withValues(alpha: 0.08)
                  : tokens.surface,
          borderRadius: tokens.cornerLarge(),
          boxShadow: tokens.shadowSoft,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: tokens.spacing(13),
              height: tokens.spacing(13),
              decoration: BoxDecoration(
                color:
                    quest.isCompleted
                        ? Colors.transparent
                        : tokens.brandPrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                quest.icon,
                color: tokens.brandPrimary,
                size: tokens.spacing(7),
              ),
            ),
            SizedBox(width: tokens.spacing(4)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    quest.title,
                    style: tokens.titleSmall.copyWith(
                      color: tokens.textPrimary,
                      decoration:
                          quest.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: tokens.spacing(1)),
                  Text(
                    quest.subtitle,
                    style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            SizedBox(width: tokens.spacing(4)),
            Container(
              width: tokens.spacing(6),
              height: tokens.spacing(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      quest.isCompleted
                          ? tokens.brandPrimary
                          : theme.dividerColor,
                  width: 2,
                ),
                color:
                    quest.isCompleted
                        ? tokens.brandPrimary
                        : Colors.transparent,
              ),
              child:
                  quest.isCompleted
                      ? Icon(
                        Icons.check,
                        color: tokens.surface,
                        size: tokens.spacing(4),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
