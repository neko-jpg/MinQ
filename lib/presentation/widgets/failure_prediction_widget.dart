import 'package:flutter/material.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/data/providers.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// 失敗予測ウィジェット
/// ホーム画面に表示される失敗リスク警告カード
class FailurePredictionWidget extends ConsumerWidget {
  const FailurePredictionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final uid = ref.watch(uidProvider);

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<String>>(
      future: _loadHighRiskHabits(ref, uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final highRiskHabits = snapshot.data!;
        return _buildPredictionCard(context, tokens, ref, highRiskHabits);
      },
    );
  }

  Widget _buildPredictionCard(
    BuildContext context,
    MinqTheme tokens,
    WidgetRef ref,
    List<String> highRiskHabits,
  ) {
    final navigation = ref.read(navigationUseCaseProvider);

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade400.withAlpha((255 * 0.1).round()),
            Colors.orange.shade400.withAlpha((255 * 0.1).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(
            color: Colors.red.withAlpha((255 * 0.3).round()), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Container(
                width: tokens.spacing.xl,
                height: tokens.spacing.xl,
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha((255 * 0.2).round()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: tokens.spacing.lg,
                ),
              ),

              SizedBox(width: tokens.spacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI失敗予測',
                      style: tokens.typography.h3.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      '${highRiskHabits.length}個の習慣で失敗リスクが検出されました',
                      style: tokens.typography.caption.copyWith(
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                color: Colors.red.shade600,
                size: tokens.spacing.lg,
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.lg),

          // リスク習慣リスト
          ...highRiskHabits.take(3).map((habitId) {
            return _buildRiskHabitItem(tokens, habitId, navigation);
          }),

          if (highRiskHabits.length > 3) ...[
            SizedBox(height: tokens.spacing.sm),
            Text(
              '他${highRiskHabits.length - 3}個の習慣',
              style: tokens.typography.caption.copyWith(
                color: Colors.red.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          SizedBox(height: tokens.spacing.lg),

          // アクションボタン
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // 詳細分析画面に遷移
                    if (highRiskHabits.isNotEmpty) {
                      navigation.goToHabitAnalysis(
                        highRiskHabits.first,
                        'リスク習慣',
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade600),
                    foregroundColor: Colors.red.shade600,
                  ),
                  child: Text(AppLocalizations.of(context)!.detailedAnalysis),
                ),
              ),

              SizedBox(width: tokens.spacing.md),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 改善提案を表示
                    _showImprovementSuggestions(context, tokens);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.improvementSuggestion),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskHabitItem(
    MinqTheme tokens,
    String habitId,
    NavigationUseCase navigation,
  ) {
    // TODO: 実際の習慣名を取得
    final habitName = 'クエスト #$habitId';

    return GestureDetector(
      onTap: () => navigation.goToHabitAnalysis(habitId, habitName),
      child: Container(
        margin: EdgeInsets.only(bottom: tokens.spacing.sm),
        padding: EdgeInsets.all(tokens.spacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((255 * 0.7).round()),
          borderRadius: BorderRadius.circular(tokens.radius.md),
          border: Border.all(
              color: Colors.red.withAlpha((255 * 0.2).round())),
        ),
        child: Row(
          children: [
            Icon(
              Icons.trending_down,
              color: Colors.red.shade600,
              size: tokens.spacing.lg,
            ),

            SizedBox(width: tokens.spacing.sm),

            Expanded(
              child: Text(
                habitName,
                style: tokens.typography.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.sm,
                vertical: tokens.spacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
              child: Text(
                '高リスク',
                style: tokens.typography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImprovementSuggestions(BuildContext context, MinqTheme tokens) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange,
                  size: tokens.spacing.lg,
                ),
                SizedBox(width: tokens.spacing.sm),
                Text(AppLocalizations.of(context)!.aiImprovementSuggestion),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSuggestionItem(
                  tokens,
                  '時間帯を変更',
                  '成功率の高い朝の時間帯に変更してみましょう',
                  Icons.schedule,
                ),

                SizedBox(height: tokens.spacing.md),

                _buildSuggestionItem(
                  tokens,
                  '習慣を簡単に',
                  'より小さく、達成しやすい目標に調整しましょう',
                  Icons.tune,
                ),

                SizedBox(height: tokens.spacing.md),

                _buildSuggestionItem(
                  tokens,
                  'リマインダー設定',
                  '忘れないように通知を設定しましょう',
                  Icons.notifications,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.close),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 詳細分析画面に遷移
                },
                child: Text(AppLocalizations.of(context)!.viewDetails),
              ),
            ],
          ),
    );
  }

  Widget _buildSuggestionItem(
    MinqTheme tokens,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.orange, size: tokens.spacing.md),

        SizedBox(width: tokens.spacing.sm),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tokens.typography.body.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: tokens.spacing.xs),
              Text(
                description,
                style: tokens.typography.caption.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<List<String>> _loadHighRiskHabits(WidgetRef ref, String uid) async {
    try {
      final service = ref.read(failurePredictionServiceProvider);
      return await service.getHighRiskHabits(uid);
    } catch (e) {
      return [];
    }
  }
}

/// コンパクト失敗予測ウィジェット
class CompactFailurePredictionWidget extends ConsumerWidget {
  const CompactFailurePredictionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final uid = ref.watch(uidProvider);

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<String>>(
      future: _loadHighRiskHabits(ref, uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final riskCount = snapshot.data!.length;

        return GestureDetector(
          onTap: () {
            final navigation = ref.read(navigationUseCaseProvider);
            if (snapshot.data!.isNotEmpty) {
              navigation.goToHabitAnalysis(snapshot.data!.first, 'リスク習慣');
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.md,
              vertical: tokens.spacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.orange.shade500],
              ),
              borderRadius: BorderRadius.circular(tokens.radius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: tokens.spacing.lg,
                ),
                SizedBox(width: tokens.spacing.sm),
                Text(
                  'リスク$riskCount件',
                  style: tokens.typography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<String>> _loadHighRiskHabits(WidgetRef ref, String uid) async {
    try {
      final service = ref.read(failurePredictionServiceProvider);
      return await service.getHighRiskHabits(uid);
    } catch (e) {
      return [];
    }
  }
}
