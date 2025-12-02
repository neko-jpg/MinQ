import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/recommendation/recommendation_engine.dart';
import 'package:minq/features/quest/data/quest_providers.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final navigation = ref.read(navigationUseCaseProvider);

    final questsAsync = ref.watch(userQuestsProvider);
    final logsAsync = ref.watch(allLogsProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      body: questsAsync.when(
        data: (quests) {
          return logsAsync.when(
            data: (logs) {
              if (quests.isEmpty) {
                return Center(
                  child: Text(
                    "クエストを追加しましょう",
                    style: tokens.bodyLarge,
                  ),
                );
              }

              // Recommendation Logic
              final engine = RecommendationEngine();
              final contextObj = UserContext(
                now: DateTime.now(),
                allLogs: logs,
              );
              final recommendations = engine.recommend(quests, contextObj);

              if (recommendations.isEmpty) {
                 return const Center(child: Text("No recommendations"));
              }

              final heroQuest = recommendations.first;
              final otherQuests = recommendations.skip(1).take(5).toList();

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      tokens.spacing(5),
                      MediaQuery.of(context).padding.top + tokens.spacing(2),
                      tokens.spacing(5),
                      tokens.spacing(4),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _HomeHeader(
                          onSettingsTap: navigation.goToSettings,
                        ),
                        SizedBox(height: tokens.spacing(6)),
                        const _SectionTitle(title: "今日のイチオシ"),
                        SizedBox(height: tokens.spacing(3)),
                        _HeroQuestCard(
                          title: heroQuest.quest.title,
                          category: heroQuest.quest.category,
                          duration: heroQuest.quest.estimatedMinutes,
                          streak: heroQuest.currentStreak,
                          icon: iconDataForKey(heroQuest.quest.iconKey),
                          onTap: () => navigation.goToRecord(heroQuest.quest.id),
                          reason: heroQuest.reasons.isNotEmpty ? heroQuest.reasons.first : null,
                        ),
                        SizedBox(height: tokens.spacing(6)),
                        const _SectionTitle(title: "クエストリスト"),
                        SizedBox(height: tokens.spacing(3)),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spacing(5)),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final scored = otherQuests[index];
                          final q = scored.quest;
                          return Padding(
                            padding: EdgeInsets.only(bottom: tokens.spacing(3)),
                            child: _QuestListItem(
                              title: q.title,
                              duration: q.estimatedMinutes,
                              icon: iconDataForKey(q.iconKey),
                              onTap: () => navigation.goToRecord(q.id),
                              reason: scored.reasons.isNotEmpty ? scored.reasons.first : null,
                            ),
                          );
                        },
                        childCount: otherQuests.length,
                      ),
                    ),
                  ),
                  // Add some bottom padding for the floating navigation bar
                  SliverPadding(padding: EdgeInsets.only(bottom: tokens.spacing(12))),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    // TODO: Get real user name
    const userName = "User";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "おはようございます",
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            ),
            Text(
              "$userNameさん",
              style: tokens.titleLarge.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        InkWell(
          onTap: onSettingsTap,
          borderRadius: tokens.cornerFull(),
          child: Container(
            padding: EdgeInsets.all(tokens.spacing(2)),
            decoration: BoxDecoration(
              color: tokens.surface,
              shape: BoxShape.circle,
              border: Border.all(color: tokens.border),
            ),
            child: Icon(
              Icons.settings_outlined,
              color: tokens.textPrimary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return Text(
      title,
      style: tokens.titleSmall.copyWith(
        color: tokens.textMuted,
        letterSpacing: 1.0,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _HeroQuestCard extends StatelessWidget {
  const _HeroQuestCard({
    required this.title,
    required this.category,
    required this.duration,
    required this.streak,
    required this.icon,
    required this.onTap,
    this.reason,
  });

  final String title;
  final String category;
  final int duration;
  final int streak;
  final IconData icon;
  final VoidCallback onTap;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.cornerXLarge(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(tokens.spacing(6)),
          decoration: BoxDecoration(
            color: tokens.brandPrimary,
            borderRadius: tokens.cornerXLarge(),
            boxShadow: [
              BoxShadow(
                color: tokens.brandPrimary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            gradient: LinearGradient(
              colors: [
                tokens.brandPrimary,
                Color.lerp(tokens.brandPrimary, Colors.white, 0.1)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing(3),
                      vertical: tokens.spacing(1),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: tokens.cornerFull(),
                    ),
                    child: Text(
                      category,
                      style: tokens.labelSmall.copyWith(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(tokens.spacing(2)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                ],
              ),
              SizedBox(height: tokens.spacing(4)),
              Text(
                title,
                style: tokens.displaySmall.copyWith(
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (reason != null) ...[
                SizedBox(height: tokens.spacing(2)),
                Text(
                  reason!,
                  style: tokens.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9), fontStyle: FontStyle.italic),
                ),
              ],
              SizedBox(height: tokens.spacing(4)),
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
                  SizedBox(width: tokens.spacing(1)),
                  Text(
                    "$duration min",
                    style: tokens.bodyMedium.copyWith(color: Colors.white),
                  ),
                  SizedBox(width: tokens.spacing(4)),
                  Icon(Icons.local_fire_department, color: Colors.white70, size: 16),
                  SizedBox(width: tokens.spacing(1)),
                  Text(
                    "$streak day streak",
                    style: tokens.bodyMedium.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing(4),
                      vertical: tokens.spacing(2),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: tokens.cornerFull(),
                    ),
                    child: Text(
                      "Start",
                      style: tokens.titleSmall.copyWith(
                        color: tokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestListItem extends StatelessWidget {
  const _QuestListItem({
    required this.title,
    required this.duration,
    required this.icon,
    required this.onTap,
    this.reason,
  });

  final String title;
  final int duration;
  final IconData icon;
  final VoidCallback onTap;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.cornerLarge(),
        child: Container(
          padding: EdgeInsets.all(tokens.spacing(4)),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: tokens.cornerLarge(),
            border: Border.all(color: tokens.border.withOpacity(0.5)),
            boxShadow: tokens.shadowSoft,
          ),
          child: Row(
            children: [
              Container(
                width: tokens.spacing(12),
                height: tokens.spacing(12),
                decoration: BoxDecoration(
                  color: tokens.surfaceAlt,
                  borderRadius: tokens.cornerMedium(),
                ),
                child: Icon(icon, color: tokens.textSecondary, size: 24),
              ),
              SizedBox(width: tokens.spacing(4)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tokens.titleSmall.copyWith(
                        color: tokens.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tokens.spacing(1)),
                    Row(
                      children: [
                        Text(
                          "$duration min",
                          style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                        ),
                        if (reason != null) ...[
                           SizedBox(width: tokens.spacing(2)),
                           Expanded(
                             child: Text(
                               reason!,
                               style: tokens.bodySmall.copyWith(color: tokens.brandPrimary),
                               overflow: TextOverflow.ellipsis,
                             ),
                           ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: tokens.spacing(10),
                height: tokens.spacing(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.border, width: 2),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: tokens.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
