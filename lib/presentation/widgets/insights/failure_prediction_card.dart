import 'package:flutter/material.dart';
import 'package:minq/domain/ai/ai_insights.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Card widget for displaying failure prediction alerts
class FailurePredictionCard extends StatelessWidget {
  const FailurePredictionCard({
    super.key,
    required this.prediction,
  });

  final FailurePrediction prediction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final riskColor = _getRiskColor(prediction.riskLevel);
    final riskIcon = _getRiskIcon(prediction.riskLevel);

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: riskColor.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with risk level
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(tokens.spacing.sm),
                decoration: BoxDecoration(
                  color: riskColor.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                child: Icon(
                  riskIcon,
                  color: riskColor,
                  size: 24,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '継続リスク予測',
                      style: tokens.typography.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.sm,
                        vertical: tokens.spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withAlpha((255 * 0.1).round()),
                        borderRadius: BorderRadius.circular(tokens.radius.sm),
                      ),
                      child: Text(
                        _getRiskLevelText(prediction.riskLevel),
                        style: tokens.typography.caption.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Risk score circle
              _buildRiskScoreCircle(prediction.riskScore, riskColor, tokens),
            ],
          ),
          
          SizedBox(height: tokens.spacing.lg),
          
          // Risk factors section
          if (prediction.riskFactors.isNotEmpty) ...[
            Text(
              'リスク要因',
              style: tokens.typography.body.copyWith(
                fontWeight: FontWeight.bold,
                color: tokens.textPrimary,
              ),
            ),
            SizedBox(height: tokens.spacing.sm),
            ...prediction.riskFactors.map((factor) =>
              _buildRiskFactorItem(factor, tokens),
            ),
            SizedBox(height: tokens.spacing.md),
          ],
          
          // Prevention strategies section
          if (prediction.preventionStrategies.isNotEmpty) ...[
            Text(
              '改善提案',
              style: tokens.typography.body.copyWith(
                fontWeight: FontWeight.bold,
                color: tokens.textPrimary,
              ),
            ),
            SizedBox(height: tokens.spacing.sm),
            ...prediction.preventionStrategies.map((strategy) =>
              _buildPreventionStrategyItem(strategy, tokens),
            ),
            SizedBox(height: tokens.spacing.md),
          ],
          
          // Predicted date
          Container(
            padding: EdgeInsets.all(tokens.spacing.md),
            decoration: BoxDecoration(
              color: tokens.surfaceVariant,
              borderRadius: BorderRadius.circular(tokens.radius.md),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: tokens.textMuted,
                  size: 16,
                ),
                SizedBox(width: tokens.spacing.sm),
                Text(
                  '予測日: ${_formatDate(prediction.predictedDate)}',
                  style: tokens.typography.caption.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: tokens.spacing.lg),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handlePreventAction(context),
                  icon: const Icon(Icons.shield, size: 16),
                  label: Text(AppLocalizations.of(context).executePrevention),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _handleStartHabit(context),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: Text(AppLocalizations.of(context).executeNow),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskScoreCircle(double riskScore, Color color, MinqTheme tokens) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 4,
            backgroundColor: tokens.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(tokens.surfaceVariant),
          ),
          CircularProgressIndicator(
            value: riskScore,
            strokeWidth: 4,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(riskScore * 100).toStringAsFixed(0)}%',
                  style: tokens.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 10,
                  ),
                ),
                Text(
                  'リスク',
                  style: tokens.typography.caption.copyWith(
                    color: tokens.textMuted,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactorItem(String factor, MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Text(
              factor,
              style: tokens.typography.body.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreventionStrategyItem(String strategy, MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Text(
              strategy,
              style: tokens.typography.body.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _getRiskLevelText(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return '高リスク';
      case 'medium':
        return '中リスク';
      case 'low':
        return '低リスク';
      default:
        return '不明';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  void _handlePreventAction(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).showPreventionPlan),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleStartHabit(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).navigateToHabitExecution),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}