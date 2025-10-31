import 'package:flutter/material.dart';
import 'package:minq/domain/ai/ai_insights.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Card widget for displaying personalized recommendations
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
  });

  final PersonalizedRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final typeColor = _getTypeColor(recommendation.type);
    final typeIcon = _getTypeIcon(recommendation.type);

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type and confidence
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(tokens.spacing.sm),
                decoration: BoxDecoration(
                  color: typeColor.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: 20,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: tokens.typography.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      _getTypeLabel(recommendation.type),
                      style: tokens.typography.caption.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Confidence indicator
              _buildConfidenceIndicator(recommendation.confidence, tokens),
            ],
          ),
          
          SizedBox(height: tokens.spacing.md),
          
          // Description
          Text(
            recommendation.description,
            style: tokens.typography.body.copyWith(
              color: tokens.textSecondary,
              height: 1.5,
            ),
          ),
          
          // Related habits (if any)
          if (recommendation.relatedHabits.isNotEmpty) ...[
            SizedBox(height: tokens.spacing.md),
            Text(
              '関連する習慣:',
              style: tokens.typography.caption.copyWith(
                color: tokens.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: tokens.spacing.xs),
            Wrap(
              spacing: tokens.spacing.xs,
              runSpacing: tokens.spacing.xs,
              children: recommendation.relatedHabits.take(3).map((habit) =>
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.sm,
                    vertical: tokens.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.surfaceVariant,
                    borderRadius: BorderRadius.circular(tokens.radius.sm),
                  ),
                  child: Text(
                    habit,
                    style: tokens.typography.caption.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
          
          SizedBox(height: tokens.spacing.lg),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleAction(context, recommendation),
              icon: Icon(
                recommendation.iconKey != null 
                    ? _getIconFromKey(recommendation.iconKey!)
                    : Icons.arrow_forward,
                size: 16,
              ),
              label: Text(recommendation.actionText),
              style: OutlinedButton.styleFrom(
                foregroundColor: typeColor,
                side: BorderSide(color: typeColor),
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.lg,
                  vertical: tokens.spacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence, MinqTheme tokens) {
    final color = _getConfidenceColor(confidence);
    
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 4,
                backgroundColor: tokens.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(tokens.surfaceVariant),
              ),
              CircularProgressIndicator(
                value: confidence,
                strokeWidth: 4,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Center(
                child: Text(
                  '${(confidence * 100).toStringAsFixed(0)}%',
                  style: tokens.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spacing.xs),
        Text(
          '信頼度',
          style: tokens.typography.caption.copyWith(
            color: tokens.textMuted,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.habitSuggestion:
        return Colors.blue;
      case RecommendationType.timeOptimization:
        return Colors.orange;
      case RecommendationType.streakRecovery:
        return Colors.red;
      case RecommendationType.categoryBalance:
        return Colors.purple;
      case RecommendationType.motivationalBoost:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.habitSuggestion:
        return Icons.lightbulb_outline;
      case RecommendationType.timeOptimization:
        return Icons.schedule;
      case RecommendationType.streakRecovery:
        return Icons.refresh;
      case RecommendationType.categoryBalance:
        return Icons.balance;
      case RecommendationType.motivationalBoost:
        return Icons.emoji_events;
    }
  }

  String _getTypeLabel(RecommendationType type) {
    switch (type) {
      case RecommendationType.habitSuggestion:
        return '習慣提案';
      case RecommendationType.timeOptimization:
        return '時間最適化';
      case RecommendationType.streakRecovery:
        return 'ストリーク回復';
      case RecommendationType.categoryBalance:
        return 'バランス調整';
      case RecommendationType.motivationalBoost:
        return 'モチベーション向上';
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.blue;
    if (confidence >= 0.4) return Colors.orange;
    return Colors.red;
  }

  IconData _getIconFromKey(String iconKey) {
    switch (iconKey) {
      case 'tune':
        return Icons.tune;
      case 'add_circle':
        return Icons.add_circle;
      case 'refresh':
        return Icons.refresh;
      case 'timer':
        return Icons.timer;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.arrow_forward;
    }
  }

  void _handleAction(BuildContext context, PersonalizedRecommendation recommendation) {
    // Handle different recommendation actions
    switch (recommendation.type) {
      case RecommendationType.habitSuggestion:
        // Navigate to habit creation/editing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).editHabitScreen),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      case RecommendationType.categoryBalance:
        // Navigate to habit templates or creation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).addNewHabit),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      case RecommendationType.streakRecovery:
        // Navigate to today's habits
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).executeHabitToday),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      case RecommendationType.timeOptimization:
        // Navigate to mini habit creation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).createMiniHabit),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      case RecommendationType.motivationalBoost:
        // Navigate to challenges
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).navigateToChallenges),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
    }
  }
}