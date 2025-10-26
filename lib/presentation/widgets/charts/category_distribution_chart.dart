import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:minq/domain/ai/ai_insights.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Chart widget for displaying category distribution
class CategoryDistributionChart extends StatelessWidget {
  const CategoryDistributionChart({
    super.key,
    required this.trends,
  });

  final HabitCompletionTrends trends;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final categories = trends.categoryDistribution;

    if (categories.isEmpty) {
      return _buildEmptyState(tokens);
    }

    final total = categories.values.reduce((a, b) => a + b);
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: tokens.brandPrimary,
                size: 20,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                'カテゴリ別分布',
                style: tokens.typography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.lg),
          
          // Pie chart representation using stacked bars
          Row(
            children: [
              // Visual representation
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Stacked bar chart
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(tokens.radius.md),
                      ),
                      child: Row(
                        children: sortedCategories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          final percentage = category.value / total;
                          
                          return Expanded(
                            flex: (percentage * 100).round(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getCategoryColor(index),
                                borderRadius: BorderRadius.horizontal(
                                  left: index == 0 
                                      ? Radius.circular(tokens.radius.md) 
                                      : Radius.zero,
                                  right: index == sortedCategories.length - 1 
                                      ? Radius.circular(tokens.radius.md) 
                                      : Radius.zero,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: tokens.spacing.lg),
                    
                    // Circular progress indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: sortedCategories.asMap().entries.take(3).map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final percentage = category.value / total;
                        
                        return _buildCircularIndicator(
                          category.key,
                          percentage,
                          _getCategoryColor(index),
                          tokens,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              SizedBox(width: tokens.spacing.lg),
              
              // Legend
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sortedCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final percentage = (category.value / total * 100).toStringAsFixed(0);
                    
                    return _buildLegendItem(
                      category.key,
                      category.value,
                      '$percentage%',
                      _getCategoryColor(index),
                      tokens,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          
          SizedBox(height: tokens.spacing.md),
          
          // Summary text
          Text(
            '合計 $total 個の習慣が ${categories.length} カテゴリに分散',
            style: tokens.typography.caption.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIndicator(
    String category,
    double percentage,
    Color color,
    MinqTheme tokens,
  ) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 6,
                backgroundColor: tokens.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(tokens.surfaceVariant),
              ),
              CircularProgressIndicator(
                value: percentage,
                strokeWidth: 6,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Center(
                child: Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: tokens.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spacing.xs),
        Text(
          category,
          style: tokens.typography.caption.copyWith(
            color: tokens.textSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    String category,
    int count,
    String percentage,
    Color color,
    MinqTheme tokens,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.sm),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
          ),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: tokens.typography.body.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$count個 ($percentage)',
                  style: tokens.typography.caption.copyWith(
                    color: tokens.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            'カテゴリデータがありません',
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            '習慣を追加すると、カテゴリ別の分布が表示されます',
            style: tokens.typography.caption.copyWith(
              color: tokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFFEC4899), // Pink
      const Color(0xFF84CC16), // Lime
    ];
    
    return colors[index % colors.length];
  }
}