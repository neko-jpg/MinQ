import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/community/guild_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class GuildScreen extends ConsumerStatefulWidget {
  const GuildScreen({super.key});

  @override
  ConsumerState<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends ConsumerState<GuildScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeGuildService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeGuildService() async {
    final uid = ref.read(uidProvider);
    if (uid != null) {
      final guildService = ref.read(guildServiceProvider);
      await guildService.initialize(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final guildService = ref.watch(guildServiceProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'ギルド',
          style: tokens.typography.h3.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: tokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '参加', icon: Icon(Icons.groups)),
            Tab(text: '作成', icon: Icon(Icons.add_circle_outline)),
            Tab(text: '検索', icon: Icon(Icons.search)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJoinTab(guildService, tokens),
          _buildCreateTab(guildService, tokens),
          _buildSearchTab(guildService, tokens),
        ],
      ),
    );
  }

  Widget _buildJoinTab(GuildService guildService, MinqTheme tokens) {
    return ValueListenableBuilder<Guild?>(
      valueListenable: guildService.currentGuild,
      builder: (context, currentGuild, child) {
        if (currentGuild != null) {
          return _buildCurrentGuildView(currentGuild, guildService, tokens);
        }

        return ValueListenableBuilder<List<Guild>>(
          valueListenable: guildService.availableGuilds,
          builder: (context, availableGuilds, child) {
            if (availableGuilds.isEmpty) {
              return _buildEmptyState(tokens, 'ギルドがありません', '新しいギルドを作成するか、検索してみてください');
            }

            return ListView.builder(
              padding: EdgeInsets.all(tokens.spacing.lg),
              itemCount: availableGuilds.length,
              itemBuilder: (context, index) {
                return _buildGuildCard(availableGuilds[index], guildService, tokens);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCurrentGuildView(Guild guild, GuildService guildService, MinqTheme tokens) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guild info card
          Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: tokens.brandPrimary.withAlpha(26),
                        child: Icon(
                          Icons.groups,
                          size: 30,
                          color: tokens.brandPrimary,
                        ),
                      ),
                      SizedBox(width: tokens.spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guild.name,
                              style: tokens.typography.h3.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              guild.description,
                              style: tokens.typography.body.copyWith(
                                color: tokens.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(tokens, 'メンバー', '${guild.memberCount}', Icons.people),
                      _buildStatItem(tokens, 'レベル', '${guild.level}', Icons.star),
                      _buildStatItem(tokens, 'EXP', '${guild.experience}', Icons.trending_up),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: tokens.spacing.lg),

          // Active challenges
          ValueListenableBuilder<List<GuildChallenge>>(
            valueListenable: guildService.activeChallenges,
            builder: (context, challenges, child) {
              return Card(
                elevation: 0,
                color: tokens.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                  side: BorderSide(color: tokens.border),
                ),
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'アクティブチャレンジ',
                        style: tokens.typography.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: tokens.spacing.md),
                      if (challenges.isEmpty)
                        Text(
                          'アクティブなチャレンジはありません',
                          style: tokens.typography.body.copyWith(
                            color: tokens.textMuted,
                          ),
                        )
                      else
                        ...challenges.map((challenge) => _buildChallengeItem(challenge, tokens)),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: tokens.spacing.lg),

          // Leave guild button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _leaveGuild(guild, guildService),
              style: OutlinedButton.styleFrom(
                foregroundColor: tokens.accentError,
                side: BorderSide(color: tokens.accentError),
              ),
              child: const Text('ギルドを退出'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTab(GuildService guildService, MinqTheme tokens) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ギルドを作成',
            style: tokens.typography.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            '同じ目標を持つ仲間と一緒に習慣を継続しましょう',
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
          ),
          SizedBox(height: tokens.spacing.xl),

          // Create guild form would go here
          Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.construction,
                    size: 64,
                    color: tokens.textMuted,
                  ),
                  SizedBox(height: tokens.spacing.md),
                  Text(
                    'ギルド作成機能',
                    style: tokens.typography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.sm),
                  Text(
                    'この機能は現在開発中です。\n近日中に利用可能になります。',
                    style: tokens.typography.body.copyWith(
                      color: tokens.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(GuildService guildService, MinqTheme tokens) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ギルドを検索',
            style: tokens.typography.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.md),

          // Search functionality would go here
          Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: tokens.textMuted,
                  ),
                  SizedBox(height: tokens.spacing.md),
                  Text(
                    'ギルド検索機能',
                    style: tokens.typography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.sm),
                  Text(
                    'カテゴリやキーワードでギルドを検索できます。\n機能は現在開発中です。',
                    style: tokens.typography.body.copyWith(
                      color: tokens.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuildCard(Guild guild, GuildService guildService, MinqTheme tokens) {
    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing.md),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      child: InkWell(
        onTap: () => _joinGuild(guild, guildService),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: tokens.brandPrimary.withAlpha(26),
                    child: Icon(
                      Icons.groups,
                      color: tokens.brandPrimary,
                    ),
                  ),
                  SizedBox(width: tokens.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guild.name,
                          style: tokens.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          guild.category,
                          style: tokens.typography.caption.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.sm,
                      vertical: tokens.spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.brandPrimary.withAlpha(26),
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                    ),
                    child: Text(
                      'Lv.${guild.level}',
                      style: tokens.typography.caption.copyWith(
                        color: tokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.spacing.sm),
              Text(
                guild.description,
                style: tokens.typography.body.copyWith(
                  color: tokens.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: tokens.spacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: tokens.textMuted,
                  ),
                  SizedBox(width: tokens.spacing.xs),
                  Text(
                    '${guild.memberCount}/${guild.maxMembers}',
                    style: tokens.typography.caption.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '参加する',
                    style: tokens.typography.bodyMedium.copyWith(
                      color: tokens.brandPrimary,
                      fontWeight: FontWeight.bold,
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

  Widget _buildStatItem(MinqTheme tokens, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: tokens.brandPrimary, size: 24),
        SizedBox(height: tokens.spacing.xs),
        Text(
          value,
          style: tokens.typography.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: tokens.typography.caption.copyWith(
            color: tokens.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeItem(GuildChallenge challenge, MinqTheme tokens) {
    return Container(
      margin: EdgeInsets.only(bottom: tokens.spacing.sm),
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withAlpha(13),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.brandPrimary.withAlpha(26)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: tokens.brandPrimary,
            size: 20,
          ),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: tokens.typography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${challenge.currentCount}/${challenge.targetCount} 完了',
                  style: tokens.typography.caption.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(MinqTheme tokens, String title, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 80,
              color: tokens.textMuted,
            ),
            SizedBox(height: tokens.spacing.md),
            Text(
              title,
              style: tokens.typography.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing.sm),
            Text(
              message,
              style: tokens.typography.body.copyWith(
                color: tokens.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinGuild(Guild guild, GuildService guildService) async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    try {
      await guildService.joinGuild(guild.id, uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ギルドに参加しました！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('参加に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _leaveGuild(Guild guild, GuildService guildService) async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ギルドを退出'),
        content: const Text('本当にギルドを退出しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('退出'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await guildService.leaveGuild(guild.id, uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ギルドを退出しました')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('退出に失敗しました: $e')),
          );
        }
      }
    }
  }
}
