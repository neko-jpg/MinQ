import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';
import 'package:minq/presentation/providers/analytics_providers.dart';

class CompletionRateWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;

  const CompletionRateWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continuityRate = ref.watch(currentContinuityRateProvider);

    return continuityRate.when(
      data: (rate) => _buildCompletionRateDisplay(context, rate),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context),
    );
  }

  Widget _buildCompletionRateDisplay(BuildContext context, double rate) {
    final percentage = (rate * 100).toInt();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: rate,
                strokeWidth: 8,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(_getRateColor(rate)),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getRateColor(rate),
                  ),
                ),
                Text(
                  '完了率',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRateMessage(context, rate),
      ],
    );
  }

  Widget _buildRateMessage(BuildContext context, double rate) {
    String message;
    Color color;

    if (rate >= 0.9) {
      message = '完璧！';
      color = Colors.green;
    } else if (rate >= 0.7) {
      message = '良好';
      color = Colors.blue;
    } else if (rate >= 0.5) {
      message = '改善の余地あり';
      color = Colors.orange;
    } else {
      message = '要改善';
      color = Colors.red;
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

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(height: 8),
          Text('計算中...', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 32, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            'エラー',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Color _getRateColor(double rate) {
    if (rate >= 0.8) {
      return Colors.green;
    } else if (rate >= 0.6) {
      return Colors.blue;
    } else if (rate >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
