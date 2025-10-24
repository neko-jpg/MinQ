import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/core/challenges/challenge_service.dart';
import 'package:minq/domain/challenges/challenge.dart';
import 'package:minq/domain/challenges/challenge_progress.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// チャレンジ画面
/// 期間限定チャレンジやイベントを表示・参加できる画面
class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('チャレンジ'),
        backgroundColor: tokens.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: tokens.onSurface,
          unselectedLabelColor: tokens.textMuted,
          indicatorColor: tokens.brandPrimary,
          tabs: const [
            Tab(text: 'アクティブ'),
            Tab(text: '完了済み'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ActiveChallengesTab(),
          _CompletedChallengesTab(),
        ],
      ),
    );
  }
}

/// アクティブチャレンジタブ
class _ActiveChallengesTab extends ConsumerWidget {
  const _ActiveChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeState = ref.watch(activeChallengesProvider);

    return challengeState.when(
      data: (challenges) {
        if (challenges.isEmpty) {
          return const _EmptyStateWidget(
            icon: Icons.emoji_events,
            title: 'アクティブなチャレンジはありません',
            message: '新しいチャレンジに参加して、特別な報酬を獲得しましょう！',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            return _ChallengeCard(challenge: challenges[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _ErrorWidget(
        message: 'チャレンジの読み込みに失敗しました',
        onRetry: () => ref.refresh(activeChallengesProvider),
      ),
    );
  }
}

/// 完了済みチャレンジタブ
class _CompletedChallengesTab extends ConsumerWidget {
  const _CompletedChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeState = ref.watch(completedChallengesProvider);

    return challengeState.when(
      data: (challenges) {
        if (challenges.isEmpty) {
          return const _EmptyStateWidget(
            icon: Icons.check_circle_outline,
            title: '完了したチャレンジはありません',
            message: 'チャレンジに参加して、達成の喜びを味わいましょう！',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            return _ChallengeCard(
              challenge: challenges[index],
              isCompleted: true,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _ErrorWidget(
        message: '完了済みチャレンジの読み込みに失敗しました',
        onRetry: () => ref.refresh(completedChallengesProvider),
      ),
    );
  }
}

/// チャレンジカード
class _ChallengeCard extends ConsumerWidget {
  const _ChallengeCard({
    required this.challenge,
    this.isCompleted = false,
  });

  final Challenge challenge;
  final bool isCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final userId = ref.watch(uidProvider);
    final progressState = ref.watch(
      challengeProgressProvider(
        ChallengeProgressIdentity(userId: userId!, challengeId: challenge.id),
      ),
    );

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radius.lg),
          gradient: _getGradient(tokens),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((255 * 0.2).round()),
                      borderRadius: BorderRadius.circular(tokens.radius.md),
                    ),
                    child: Icon(
                      _getChallengeIcon(challenge.type),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: tokens.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.name,
                          style: tokens.typography.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: tokens.spacing.xs),
                        Text(
                          challenge.description,
                          style: tokens.typography.caption.copyWith(
                            color: Colors.white.withAlpha((255 * 0.9).round()),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                ],
              ),
              SizedBox(height: tokens.spacing.md),
              progressState.when(
                data: (progress) => _buildProgressSection(
                  context,
                  tokens,
                  progress,
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))),
                error: (e, s) => Text(
                  '進捗の読み込み失敗',
                  style: tokens.typography.caption.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: tokens.spacing.md),
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.white.withAlpha((255 * 0.9).round()),
                    size: 16,
                  ),
                  SizedBox(width: tokens.spacing.xs),
                  Text(
                    '報酬: 100ポイント', // FIXME: Hardcoded value
                    style: tokens.typography.caption.copyWith(
                      color: Colors.white.withAlpha((255 * 0.9).round()),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    color: Colors.white.withAlpha((255 * 0.9).round()),
                    size: 16,
                  ),
                  SizedBox(width: tokens.spacing.xs),
                  Text(
                    _formatEndDate(challenge.endDate),
                    style: tokens.typography.caption.copyWith(
                      color: Colors.white.withAlpha((255 * 0.9).round()),
                    ),
                  ),
                ],
              ),
              if (!isCompleted) ...[
                SizedBox(height: tokens.spacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showChallengeDetails(context, challenge),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: tokens.brandPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(tokens.radius.md),
                      ),
                    ),
                    child: Text(
                      '詳細を見る',
                      style: tokens.typography.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    MinqTheme tokens,
    ChallengeProgress? progress,
  ) {
    final progressValue = progress?.progress ?? 0;
    final goal = challenge.goal;
    final percentage = goal > 0 ? progressValue / goal : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '進捗',
              style: tokens.typography.caption.copyWith(
                color: Colors.white.withAlpha((255 * 0.9).round()),
              ),
            ),
            Text(
              '$progressValue/$goal',
              style: tokens.typography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius.sm),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.white.withAlpha((255 * 0.3).round()),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ],
    );
  }

  LinearGradient _getGradient(MinqTheme tokens) {
    if (isCompleted) {
      return LinearGradient(
        colors: [
          Colors.green,
          Colors.green.withAlpha((255 * 0.8).round()),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [
        tokens.brandPrimary,
        tokens.brandPrimary.withAlpha((255 * 0.8).round()),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData _getChallengeIcon(String type) {
    switch (type) {
      case 'daily':
        return Icons.today;
      case 'weekly':
        return Icons.date_range;
      case 'streak':
        return Icons.local_fire_department;
      case 'completion':
        return Icons.task_alt;
      case 'social':
        return Icons.people;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatEndDate(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return '終了';
    }
    if (difference.inDays > 0) {
      return '残り${difference.inDays}日';
    }
    if (difference.inHours > 0) {
      return '残り${difference.inHours}時間';
    }
    return '残り${difference.inMinutes}分';
  }

  void _showChallengeDetails(BuildContext context, Challenge challenge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ChallengeDetailsSheet(challenge: challenge),
    );
  }
}

/// チャレンジ詳細シート
class _ChallengeDetailsSheet extends ConsumerWidget {
  const _ChallengeDetailsSheet({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final userId = ref.watch(uidProvider);
    final progressState = ref.watch(
      challengeProgressProvider(
        ChallengeProgressIdentity(userId: userId!, challengeId: challenge.id),
      ),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: tokens.spacing.lg),
          Text(
            challenge.name,
            style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            challenge.description,
            style: tokens.typography.body.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing.lg),
          progressState.when(
            data: (progress) {
              final progressValue = progress?.progress ?? 0;
              final goal = challenge.goal;
              final percentage = goal > 0 ? progressValue / goal : 0.0;
              return Container(
                padding: EdgeInsets.all(tokens.spacing.md),
                decoration: BoxDecoration(
                  color: tokens.surfaceVariant,
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '進捗状況',
                      style:
                          tokens.typography.h5.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$progressValue / $goal',
                          style: tokens.typography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          NumberFormat.percentPattern().format(percentage),
                          style: tokens.typography.body.copyWith(
                            color: tokens.brandPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor:
                            tokens.brandPrimary.withAlpha((255 * 0.2).round()),
                        valueColor:
                            AlwaysStoppedAnimation(tokens.brandPrimary),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Text('進捗の読み込みに失敗しました'),
          ),
          SizedBox(height: tokens.spacing.lg),
          Container(
            padding: EdgeInsets.all(tokens.spacing.md),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(tokens.radius.md),
              border: Border.all(
                color: Colors.amber.withAlpha((255 * 0.3).round()),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber.shade700,
                  size: 24,
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '報酬',
                        style: tokens.typography.caption.copyWith(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '100ポイント', // FIXME: Hardcoded
                        style: tokens.typography.h5.copyWith(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ),
        ],
      ),
    );
  }
}

/// エラーウィジェット
class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: tokens.textMuted,
            ),
            SizedBox(height: tokens.spacing.lg),
            Text(
              message,
              style: tokens.typography.body.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 空状態ウィジェット
class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: tokens.textMuted),
            SizedBox(height: tokens.spacing.lg),
            Text(
              title,
              style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing.sm),
            Text(
              message,
              style: tokens.typography.body.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
