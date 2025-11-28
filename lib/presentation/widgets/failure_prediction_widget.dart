import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/ai/failure_prediction_service.dart';
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
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade400.withValues(alpha: 0.1),
            Colors.orange.shade400.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Container(
                width: tokens.spacing(12),
                height: tokens.spacing(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: tokens.spacing(6),
                ),
              ),

              SizedBox(width: tokens.spacing(3)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI失敗予測',
                      style: tokens.titleMedium.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(1)),
                    Text(
                      '${highRiskHabits.length}個の習慣で失敗リスクが検出されました',
                      style: tokens.bodySmall.copyWith(
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                color: Colors.red.shade600,
                size: tokens.spacing(4),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing(4)),

          // リスク習慣リスト
          ...highRiskHabits.take(3).map((habitId) {
            return _buildRiskHabitItem(tokens, habitId, navigation);
          }),

          if (highRiskHabits.length > 3) ...[
            SizedBox(height: tokens.spacing(2)),
            Text(
              '他${highRiskHabits.length - 3}個の習慣',
              style: tokens.bodySmall.copyWith(
                color: Colors.red.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          SizedBox(height: tokens.spacing(4)),

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
                  child: const Text('詳細分析'),
                ),
              ),

              SizedBox(width: tokens.spacing(3)),

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
                  child: const Text('改善提案'),
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
        margin: EdgeInsets.only(bottom: tokens.spacing(2)),
        padding: EdgeInsets.all(tokens.spacing(3)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: tokens.cornerMedium(),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.trending_down,
              color: Colors.red.shade600,
              size: tokens.spacing(4),
            ),

            SizedBox(width: tokens.spacing(2)),

            Expanded(
              child: Text(
                habitName,
                style: tokens.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing(2),
                vertical: tokens.spacing(1),
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: tokens.cornerSmall(),
              ),
              child: Text(
                '高リスク',
                style: tokens.bodySmall.copyWith(
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
                  size: tokens.spacing(6),
                ),
                SizedBox(width: tokens.spacing(2)),
                const Text('AI改善提案'),
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

                SizedBox(height: tokens.spacing(3)),

                _buildSuggestionItem(
                  tokens,
                  '習慣を簡単に',
                  'より小さく、達成しやすい目標に調整しましょう',
                  Icons.tune,
                ),

                SizedBox(height: tokens.spacing(3)),

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
                child: const Text('閉じる'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 詳細分析画面に遷移
                },
                child: const Text('詳細を見る'),
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
        Icon(icon, color: Colors.orange, size: tokens.spacing(5)),

        SizedBox(width: tokens.spacing(2)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tokens.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: tokens.spacing(1)),
              Text(
                description,
                style: tokens.bodySmall.copyWith(color: tokens.textMuted),
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
              horizontal: tokens.spacing(3),
              vertical: tokens.spacing(2),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.orange.shade500],
              ),
              borderRadius: tokens.cornerMedium(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: tokens.spacing(4),
                ),
                SizedBox(width: tokens.spacing(2)),
                Text(
                  'リスク$riskCount件',
                  style: tokens.bodySmall.copyWith(
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
