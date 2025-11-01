import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/analytics_insight.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';
import 'package:minq/presentation/providers/analytics_providers.dart';

class PredictionsWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;

  const PredictionsWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictions = ref.watch(goalPredictionsProvider);
    final riskWarnings = ref.watch(riskWarningsProvider);

    return Column(
      children: [
        Expanded(
          child: predictions.when(
            data:
                (predictionList) =>
                    _buildPredictionsList(context, predictionList),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(context),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: riskWarnings.when(
            data: (warningList) => _buildRiskWarnings(context, warningList),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionsList(
    BuildContext context,
    List<GoalPrediction> predictions,
  ) {
    if (predictions.isEmpty) {
      return _buildEmptyPredictionsState(context);
    }

    return ListView.builder(
      itemCount: predictions.length,
      itemBuilder: (context, index) {
        final prediction = predictions[index];
        return _buildPredictionCard(context, prediction);
      },
    );
  }

  Widget _buildPredictionCard(BuildContext context, GoalPrediction prediction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            prediction.isOnTrack
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              prediction.isOnTrack
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                prediction.isOnTrack ? Icons.trending_up : Icons.warning,
                size: 16,
                color: prediction.isOnTrack ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  prediction.goalType,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${(prediction.confidence * 100).toStringAsFixed(0)}%',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: prediction.progressPercentage,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              prediction.isOnTrack ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '予想完了: ${_formatDate(prediction.predictedCompletionDate)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskWarnings(
    BuildContext context,
    List<AnalyticsInsight> warnings,
  ) {
    final riskWarnings =
        warnings.where((w) => w.type == InsightType.riskWarning).toList();

    if (riskWarnings.isEmpty) {
      return _buildNoRisksState(context);
    }

    return ListView.builder(
      itemCount: riskWarnings.length,
      itemBuilder: (context, index) {
        final warning = riskWarnings[index];
        return _buildRiskWarningCard(context, warning);
      },
    );
  }

  Widget _buildRiskWarningCard(BuildContext context, AnalyticsInsight warning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getPriorityColor(warning.priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getPriorityColor(warning.priority).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                size: 16,
                color: _getPriorityColor(warning.priority),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  warning.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getPriorityColor(warning.priority),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            warning.description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPredictionsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.track_changes, size: 24, color: Colors.grey),
          const SizedBox(height: 4),
          Text(
            '予測なし',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRisksState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 24, color: Colors.green),
          const SizedBox(height: 4),
          Text(
            'リスクなし',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return const Center(
      child: Icon(Icons.error_outline, size: 24, color: Colors.red),
    );
  }

  Color _getPriorityColor(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.critical:
        return Colors.red;
      case InsightPriority.high:
        return Colors.orange;
      case InsightPriority.medium:
        return Colors.blue;
      case InsightPriority.low:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return '今日';
    } else if (difference == 1) {
      return '明日';
    } else if (difference < 7) {
      return '$difference日後';
    } else if (difference < 30) {
      return '${(difference / 7).round()}週間後';
    } else {
      return '${(difference / 30).round()}ヶ月後';
    }
  }
}
