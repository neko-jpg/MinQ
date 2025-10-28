import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/navigation/navigation_use_case.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/l10n/app_localizations.dart';

/// 失敗予測ウィジェット
/// ホーム画面に表示される失敗リスク警告カード
class FailurePredictionWidget extends ConsumerWidget {
  const FailurePredictionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        return _buildPredictionCard(context, ref, highRiskHabits);
      },
    );
  }

  Widget _buildPredictionCard(
    BuildContext context,
    WidgetRef ref,
    List<String> highRiskHabits,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final navigation = ref.read(navigationUseCaseProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade400.withAlpha((255 * 0.1).round()),
            Colors.orange.shade400.withAlpha((255 * 0.1).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha((255 * 0.2).round()),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 16,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI失敗予測',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${highRiskHabits.length}個の習慣で失敗リスクが検出されました',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                color: Colors.red.shade600,
                size: 16,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // リスク習慣リスト
          ...highRiskHabits.take(3).map((habitId) {
            return _buildRiskHabitItem(context, habitId, navigation);
          }),

          if (highRiskHabits.length > 3) ...[
            const SizedBox(height: 8),
            Text(
              '他${highRiskHabits.length - 3}個の習慣',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.red.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 16),

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

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 改善提案を表示
                    _showImprovementSuggestions(context);
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
    BuildContext context,
    String habitId,
    NavigationUseCase navigation,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // TODO: 実際の習慣名を取得
    final habitName = 'クエスト #$habitId';

    return GestureDetector(
      onTap: () => navigation.goToHabitAnalysis(habitId, habitName),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((255 * 0.7).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.red.withAlpha((255 * 0.2).round())),
        ),
        child: Row(
          children: [
            Icon(
              Icons.trending_down,
              color: Colors.red.shade600,
              size: 24,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                habitName,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '高リスク',
                style: textTheme.bodySmall?.copyWith(
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

  void _showImprovementSuggestions(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.aiImprovementSuggestion),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSuggestionItem(
                  context,
                  '時間帯を変更',
                  '成功率の高い朝の時間帯に変更してみましょう',
                  Icons.schedule,
                ),

                const SizedBox(height: 12),

                _buildSuggestionItem(
                  context,
                  '習慣を簡単に',
                  'より小さく、達成しやすい目標に調整しましょう',
                  Icons.tune,
                ),

                const SizedBox(height: 12),

                _buildSuggestionItem(
                  context,
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
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.orange, size: 20),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
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
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.orange.shade500],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'リスク$riskCount件',
                  style: textTheme.bodySmall?.copyWith(
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
