import 'package:flutter/material.dart';

/// ペアの進捗比較画面
class PairProgressComparisonScreen extends StatelessWidget {
  final String pairId;

  const PairProgressComparisonScreen({
    super.key,
    required this.pairId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('進捗比較'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildComparisonCard(
            context,
            title: '今週の達成率',
            myValue: 85,
            pairValue: 72,
          ),
          const SizedBox(height: 16),
          _buildComparisonCard(
            context,
            title: '連続達成日数',
            myValue: 12,
            pairValue: 8,
          ),
          const SizedBox(height: 16),
          _buildComparisonCard(
            context,
            title: '今月の完了数',
            myValue: 45,
            pairValue: 38,
          ),
          const SizedBox(height: 24),
          _buildProgressChart(context),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    BuildContext context, {
    required String title,
    required int myValue,
    required int pairValue,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildValueColumn(
                    context,
                    label: 'あなた',
                    value: myValue,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildValueColumn(
                    context,
                    label: 'ペア',
                    value: pairValue,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueColumn(
    BuildContext context, {
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildProgressChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '週間進捗グラフ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(
                child: Text('グラフ表示エリア'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
