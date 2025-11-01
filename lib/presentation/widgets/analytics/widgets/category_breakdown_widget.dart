import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';

class CategoryBreakdownWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;

  const CategoryBreakdownWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 実際のカテゴリデータプロバイダーを実装
    final categoryData = _getMockCategoryData();

    return _buildPieChart(context, categoryData);
  }

  Widget _buildPieChart(
    BuildContext context,
    Map<String, double> categoryData,
  ) {
    if (categoryData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: _createPieChartSections(categoryData),
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildLegend(context, categoryData),
      ],
    );
  }

  List<PieChartSectionData> _createPieChartSections(
    Map<String, double> categoryData,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return categoryData.entries.map((entry) {
      final index = categoryData.keys.toList().indexOf(entry.key);
      final color = colors[index % colors.length];

      return PieChartSectionData(
        value: entry.value,
        title: '${entry.value.toStringAsFixed(0)}%',
        color: color,
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(BuildContext context, Map<String, double> categoryData) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children:
          categoryData.entries.map((entry) {
            final index = categoryData.keys.toList().indexOf(entry.key);
            final color = colors[index % colors.length];

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(entry.key, style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pie_chart, size: 32, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'データなし',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getMockCategoryData() {
    // TODO: 実際のデータソースから取得
    return {'健康': 35.0, '学習': 25.0, '仕事': 20.0, '趣味': 15.0, 'その他': 5.0};
  }
}
