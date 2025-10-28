import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:minq/core/challenges/challenge_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/challenges/challenge.dart';
import 'package:minq/domain/challenges/challenge_progress.dart';
import 'package:minq/presentation/common/layout/responsive_layout.dart';
import 'package:minq/presentation/common/layout/safe_scaffold.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// Calculate reward points based on challenge difficulty and duration
int calculateReward(Challenge challenge) {
  final duration = challenge.endDate.difference(challenge.startDate).inDays;
  final baseReward = challenge.goal * 10; // 10 points per goal unit
  final durationBonus = (duration / 7).ceil() * 25; // 25 points per week

  switch (challenge.type) {
    case 'daily':
      return baseReward + durationBonus;
    case 'weekly':
      return (baseReward * 1.5).round() + durationBonus;
    case 'event':
      return (baseReward * 2).round() + durationBonus;
    default:
      return baseReward + durationBonus;
  }
}

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
    return SafeScaffold(
      enableResponsiveLayout: false, // Let TabBarView handle its own layout
      appBar: AppBar(
        title: const Text('チャレンジ'),
        backgroundColor: MinqTokens.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: MinqTokens.textPrimary,
          unselectedLabelColor: MinqTokens.textSecondary,
          indicatorColor: MinqTokens.brandPrimary,
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
        return ResponsiveLayout.constrainedContainer(
          child: ListView.builder(
            padding: EdgeInsets.all(MinqTokens.spacing(4)),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              return _ChallengeCard(challenge: challenges[index]);
            },
          ),
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
        return ResponsiveLayout.constrainedContainer(
          child: ListView.builder(
            padding: EdgeInsets.all(MinqTokens.spacing(4)),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              return _ChallengeCard(
                challenge: challenges[index],
                isCompleted: true,
              );
            },
          ),
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
    final userId = ref.watch(uidProvider);
    final progressState = ref.watch(
      challengeProgressProvider(
        ChallengeProgressIdentity(userId: userId!, challengeId: challenge.id),
      ),
    );

    return Card(
      margin: EdgeInsets.only(bottom: MinqTokens.spacing(3)),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: MinqTokens.cornerLarge(),
        side: const BorderSide(color: Colors.transparent),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: MinqTokens.cornerLarge(),
          gradient: _getGradient(),
        ),
        child: Padding(
          padding: EdgeInsets.all(MinqTokens.spacing(4)),
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
                      borderRadius: MinqTokens.cornerMedium(),
                    ),
                    child: Icon(
                      _getChallengeIcon(challenge.type),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: MinqTokens.spacing(3)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.name,
                          style: MinqTokens.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: MinqTokens.spacing(1)),
                        Text(
                          challenge.description,
                          style: MinqTokens.bodySmall.copyWith(
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
              SizedBox(height: MinqTokens.spacing(3)),
              progressState.when(
                data: (progress) => _buildProgressSection(
                  context,
                  progress,
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))),
                error: (e, s) => Text(
                  '進捗の読み込み失敗',
                  style: MinqTokens.bodySmall.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: MinqTokens.spacing(3)),
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.white.withAlpha((255 * 0.9).round()),
                    size: 16,
                  ),
                  SizedBox(width: MinqTokens.spacing(1)),
                  Text(
                    '報酬: ${calculateReward(challenge)}ポイント',
                    style: MinqTokens.bodySmall.copyWith(
                      color: Colors.white.withAlpha((255 * 0.9).round()),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    color: Colors.white.withAlpha((255 * 0.9).round()),
                    size: 16,
                  ),
                  SizedBox(width: MinqTokens.spacing(1)),
                  Text(
                    _formatEndDate(challenge.endDate),
                    style: MinqTokens.bodySmall.copyWith(
                      color: Colors.white.withAlpha((255 * 0.9).round()),
                    ),
                  ),
                ],
              ),
              if (!isCompleted) ...[
                SizedBox(height: MinqTokens.spacing(3)),
                SizedBox(
                  width: double.infinity,
                  child: ResponsiveLayout.ensureTouchTarget(
                    child: ElevatedButton(
                      onPressed: () => _showChallengeDetails(context, challenge),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: MinqTokens.brandPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: MinqTokens.cornerMedium(),
                        ),
                      ),
                      child: Text(
                        '詳細を見る',
                        style: MinqTokens.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
              style: MinqTokens.bodySmall.copyWith(
                color: Colors.white.withAlpha((255 * 0.9).round()),
              ),
            ),
            Text(
              '$progressValue/$goal',
              style: MinqTokens.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: MinqTokens.spacing(1)),
        ClipRRect(
          borderRadius: MinqTokens.cornerSmall(),
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

  LinearGradient _getGradient() {
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
        MinqTokens.brandPrimary,
        MinqTokens.brandPrimary.withAlpha((255 * 0.8).round()),
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
    final userId = ref.watch(uidProvider);
    final progressState = ref.watch(
      challengeProgressProvider(
        ChallengeProgressIdentity(userId: userId!, challengeId: challenge.id),
      ),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.all(MinqTokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MinqTokens.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: MinqTokens.spacing(4)),
          Text(
            challenge.name,
            style: MinqTokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: MinqTokens.spacing(1)),
          Text(
            challenge.description,
            style: MinqTokens.bodyMedium.copyWith(color: MinqTokens.textSecondary),
          ),
          SizedBox(height: MinqTokens.spacing(4)),
          progressState.when(
            data: (progress) {
              final progressValue = progress?.progress ?? 0;
              final goal = challenge.goal;
              final percentage = goal > 0 ? progressValue / goal : 0.0;
              return Container(
                padding: EdgeInsets.all(MinqTokens.spacing(3)),
                decoration: BoxDecoration(
                  color: MinqTokens.background,
                  borderRadius: MinqTokens.cornerMedium(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '進捗状況',
                      style:
                          MinqTokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: MinqTokens.spacing(1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$progressValue / $goal',
                          style: MinqTokens.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          NumberFormat.percentPattern().format(percentage),
                          style: MinqTokens.bodyMedium.copyWith(
                            color: MinqTokens.brandPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MinqTokens.spacing(1)),
                    ClipRRect(
                      borderRadius: MinqTokens.cornerSmall(),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor:
                            MinqTokens.brandPrimary.withAlpha((255 * 0.2).round()),
                        valueColor:
                            const AlwaysStoppedAnimation(MinqTokens.brandPrimary),
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
          SizedBox(height: MinqTokens.spacing(4)),
          Container(
            padding: EdgeInsets.all(MinqTokens.spacing(3)),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha((255 * 0.1).round()),
              borderRadius: MinqTokens.cornerMedium(),
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
                SizedBox(width: MinqTokens.spacing(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '報酬',
                        style: MinqTokens.bodySmall.copyWith(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${calculateReward(challenge)}ポイント',
                        style: MinqTokens.titleMedium.copyWith(
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(MinqTokens.spacing(6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: MinqTokens.textSecondary,
            ),
            SizedBox(height: MinqTokens.spacing(4)),
            Text(
              message,
              style: MinqTokens.bodyMedium.copyWith(color: MinqTokens.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MinqTokens.spacing(4)),
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(MinqTokens.spacing(6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: MinqTokens.textSecondary),
            SizedBox(height: MinqTokens.spacing(4)),
            Text(
              title,
              style: MinqTokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MinqTokens.spacing(1)),
            Text(
              message,
              style: MinqTokens.bodyMedium.copyWith(color: MinqTokens.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
