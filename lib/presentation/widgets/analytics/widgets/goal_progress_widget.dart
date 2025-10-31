import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';

class GoalProgressWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;

  const GoalProgressWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 実際の目標データプロバイダーを実装
    final goals = _getMockGoals();
    
    return _buildGoalsList(context, goals);
  }

  Widget _buildGoalsList(BuildContext context, List<Goal> goals) {
    if (goals.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      itemCount: goals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _buildGoalCard(context, goal);
      },
    );
  }

  Widget _buildGoalCard(BuildContext context, Goal goal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${goal.current}/${goal.target}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(goal.progress)),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}% 完了',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                goal.deadline,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.track_changes,
            size: 32,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            '目標なし',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          Text(
            '目標を設定して\n進捗を追跡しましょう',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) {
      return Colors.green;
    } else if (progress >= 0.5) {
      return Colors.blue;
    } else if (progress >= 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  List<Goal> _getMockGoals() {
    // TODO: 実際のデータソースから取得
    return [
      Goal(
        title: '週間運動目標',
        current: 4,
        target: 7,
        progress: 4 / 7,
        deadline: '今週末',
      ),
      Goal(
        title: '読書目標',
        current: 2,
        target: 5,
        progress: 2 / 5,
        deadline: '今月末',
      ),
    ];
  }
}

class Goal {
  final String title;
  final int current;
  final int target;
  final double progress;
  final String deadline;

  Goal({
    required this.title,
    required this.current,
    required this.target,
    required this.progress,
    required this.deadline,
  });
}