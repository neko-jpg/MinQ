import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/challenges/challenge_service.dart';
import 'package:minq/domain/challenges/challenge.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/badge_notification_widget.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
          tabs: const [
            Tab(text: 'アクティブ'),
            Tab(text: '参加可能'),
            Tab(text: '完了済み'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ActiveChallengesTab(),
          _AvailableChallengesTab(),
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
    final challengeService = ref.watch(challengeServiceProvider);

    return FutureBuilder<List<Challenge>>(
      future: challengeService.getActiveChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _ErrorWidget(
            message: 'チャレンジの読み込みに失敗しました',
            onRetry: () => setState(() {}),
          );
        }

        final challenges = snapshot.data ?? [];

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
            return _ChallengeCard(challenge: challenges[index], isActive: true);
          },
        );
      },
    );
  }
}

/// 参加可能チャレンジタブ
class _AvailableChallengesTab extends ConsumerWidget {
  const _AvailableChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeService = ref.watch(challengeServiceProvider);

    return FutureBuilder<List<Challenge>>(
      future: challengeService.getAvailableChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _ErrorWidget(
            message: 'チャレンジの読み込みに失敗しました',
            onRetry: () => setState(() {}),
          );
        }

        final challenges = snapshot.data ?? [];

        if (challenges.isEmpty) {
          return const _EmptyStateWidget(
            icon: Icons.schedule,
            title: '参加可能なチャレンジはありません',
            message: '新しいチャレンジが追加されるまでお待ちください。',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            return _ChallengeCard(
              challenge: challenges[index],
              isActive: false,
            );
          },
        );
      },
    );
  }
}

/// 完了済みチャレンジタブ
class _CompletedChallengesTab extends ConsumerWidget {
  const _CompletedChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeService = ref.watch(challengeServiceProvider);

    return FutureBuilder<List<Challenge>>(
      future: challengeService.getCompletedChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _ErrorWidget(
            message: 'チャレンジの読み込みに失敗しました',
            onRetry: () => setState(() {}),
          );
        }

        final challenges = snapshot.data ?? [];

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
              isActive: false,
              isCompleted: true,
            );
          },
        );
      },
    );
  }
}

/// チャレンジカード
class _ChallengeCard extends ConsumerWidget {
  const _ChallengeCard({
    required this.challenge,
    required this.isActive,
    this.isCompleted = false,
  });

  final Challenge challenge;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing(3)),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerLarge(),
        side: BorderSide(color: tokens.border),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: tokens.cornerLarge(),
          gradient: _getGradient(tokens),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: tokens.spacing(12),
                    height: tokens.spacing(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: tokens.cornerMedium(),
                    ),
                    child: Icon(
                      _getChallengeIcon(),
                      color: Colors.white,
                      size: tokens.spacing(6),
                    ),
                  ),
                  SizedBox(width: tokens.spacing(3)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: tokens.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: tokens.spacing(1)),
                        Text(
                          challenge.description,
                          style: tokens.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: tokens.spacing(6),
                    ),
                ],
              ),

              SizedBox(height: tokens.spacing(3)),

              // 進捗バー
              if (isActive || isCompleted) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '進捗',
                      style: tokens.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '${challenge.currentProgress}/${challenge.targetValue}',
                      style: tokens.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacing(2)),
                ClipRRect(
                  borderRadius: tokens.cornerSmall(),
                  child: LinearProgressIndicator(
                    value: challenge.currentProgress / challenge.targetValue,
                    minHeight: tokens.spacing(2),
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                SizedBox(height: tokens.spacing(3)),
              ],

              // 報酬情報
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.white.withOpacity(0.9),
                    size: tokens.spacing(4),
                  ),
                  SizedBox(width: tokens.spacing(1)),
                  Text(
                    '報酬: ${challenge.rewardPoints}ポイント',
                    style: tokens.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const Spacer(),
                  ...[
                    Icon(
                      Icons.schedule,
                      color: Colors.white.withOpacity(0.9),
                      size: tokens.spacing(4),
                    ),
                    SizedBox(width: tokens.spacing(1)),
                    Text(
                      _formatEndDate(challenge.endDate),
                      style: tokens.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: tokens.spacing(3)),

              // アクションボタン
              if (!isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleChallengeAction(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: tokens.brandPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: tokens.cornerMedium(),
                      ),
                    ),
                    child: Text(
                      isActive ? 'チャレンジ中' : '参加する',
                      style: tokens.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getGradient(MinqTokens tokens) {
    if (isCompleted) {
      return LinearGradient(
        colors: [Colors.green, Colors.green.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (isActive) {
      return LinearGradient(
        colors: [tokens.brandPrimary, tokens.brandPrimary.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return LinearGradient(
      colors: [Colors.grey.shade600, Colors.grey.shade500],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData _getChallengeIcon() {
    switch (challenge.type) {
      case ChallengeType.daily:
        return Icons.today;
      case ChallengeType.weekly:
        return Icons.date_range;
      case ChallengeType.streak:
        return Icons.local_fire_department;
      case ChallengeType.completion:
        return Icons.task_alt;
      case ChallengeType.social:
        return Icons.people;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatEndDate(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.inDays > 0) {
      return '残り${difference.inDays}日';
    } else if (difference.inHours > 0) {
      return '残り${difference.inHours}時間';
    } else if (difference.inMinutes > 0) {
      return '残り${difference.inMinutes}分';
    } else {
      return '終了';
    }
  }

  Future<void> _handleChallengeAction(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final challengeService = ref.read(challengeServiceProvider);

    try {
      if (isActive) {
        // チャレンジ詳細画面に遷移
        _showChallengeDetails(context);
      } else {
        // チャレンジに参加
        await challengeService.joinChallenge(challenge.id);

        // 成功通知
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${challenge.title}に参加しました！'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showChallengeDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ChallengeDetailsSheet(challenge: challenge),
    );
  }
}

/// チャレンジ詳細シート
class _ChallengeDetailsSheet extends StatelessWidget {
  const _ChallengeDetailsSheet({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ハンドル
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

          SizedBox(height: tokens.spacing(4)),

          // タイトル
          Text(
            challenge.title,
            style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: tokens.spacing(2)),

          // 説明
          Text(
            challenge.description,
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
          ),

          SizedBox(height: tokens.spacing(4)),

          // 進捗情報
          Container(
            padding: EdgeInsets.all(tokens.spacing(3)),
            decoration: BoxDecoration(
              color: tokens.surfaceVariant,
              borderRadius: tokens.cornerMedium(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '進捗状況',
                  style: tokens.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${challenge.currentProgress}/${challenge.targetValue}',
                      style: tokens.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${((challenge.currentProgress / challenge.targetValue) * 100).toStringAsFixed(1)}%',
                      style: tokens.bodyMedium.copyWith(
                        color: tokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacing(2)),
                ClipRRect(
                  borderRadius: tokens.cornerSmall(),
                  child: LinearProgressIndicator(
                    value: challenge.currentProgress / challenge.targetValue,
                    minHeight: tokens.spacing(2),
                    backgroundColor: tokens.brandPrimary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(tokens.brandPrimary),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: tokens.spacing(4)),

          // 報酬情報
          Container(
            padding: EdgeInsets.all(tokens.spacing(3)),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: tokens.cornerMedium(),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber.shade700,
                  size: tokens.spacing(6),
                ),
                SizedBox(width: tokens.spacing(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '報酬',
                        style: tokens.bodySmall.copyWith(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${challenge.rewardPoints}ポイント',
                        style: tokens.titleMedium.copyWith(
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

          // 閉じるボタン
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
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: tokens.spacing(16),
              color: tokens.textMuted,
            ),
            SizedBox(height: tokens.spacing(4)),
            Text(
              message,
              style: tokens.titleMedium.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing(4)),
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
        padding: EdgeInsets.all(tokens.spacing(6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: tokens.spacing(16), color: tokens.textMuted),
            SizedBox(height: tokens.spacing(4)),
            Text(
              title,
              style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              message,
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
