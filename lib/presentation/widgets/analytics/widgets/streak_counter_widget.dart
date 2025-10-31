import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';

class StreakCounterWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;

  const StreakCounterWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 実際のストリークデータプロバイダーを実装
    return _buildStreakDisplay(context, 7); // 仮のデータ
  }

  Widget _buildStreakDisplay(BuildContext context, int streakCount) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              color: _getStreakColor(streakCount),
              size: 32,
            ),
            const SizedBox(width: 8),
            Text(
              '$streakCount',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: _getStreakColor(streakCount),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '日連続',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _buildStreakMessage(context, streakCount),
      ],
    );
  }

  Widget _buildStreakMessage(BuildContext context, int streakCount) {
    String message;
    Color color;

    if (streakCount == 0) {
      message = '今日から始めよう！';
      color = Colors.grey;
    } else if (streakCount < 7) {
      message = '良いスタート！';
      color = Colors.blue;
    } else if (streakCount < 30) {
      message = '素晴らしい継続力！';
      color = Colors.green;
    } else {
      message = '驚異的なストリーク！';
      color = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStreakColor(int streakCount) {
    if (streakCount == 0) {
      return Colors.grey;
    } else if (streakCount < 7) {
      return Colors.blue;
    } else if (streakCount < 30) {
      return Colors.green;
    } else {
      return Colors.purple;
    }
  }
}