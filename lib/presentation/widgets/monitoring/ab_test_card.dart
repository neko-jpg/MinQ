import 'package:flutter/material.dart';
import 'package:minq/core/notifications/notification_ab_testing_service.dart';

class ABTestCard extends StatelessWidget {
  final ABTest test;
  final ABTestAnalysis? result;
  final String? userVariant;

  const ABTestCard({
    super.key,
    required this.test,
    this.result,
    this.userVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildVariants(context),
            if (result != null) ...[
              const SizedBox(height: 12),
              _buildResults(context),
            ],
            const SizedBox(height: 12),
            _buildStatus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(test.name, style: Theme.of(context).textTheme.titleMedium),
              if (userVariant != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha((255 * 0.2).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'You: $userVariant',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
          ),
        ),
        _buildStatusIcon(),
      ],
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (test.status) {
      case ABTestStatus.active:
        icon = Icons.play_circle;
        color = Colors.green;
        break;
      case ABTestStatus.stopped:
        icon = Icons.pause_circle;
        color = Colors.orange;
        break;
      case ABTestStatus.completed:
        icon = Icons.check_circle;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 24);
  }

  Widget _buildVariants(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Variants', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ...test.variants.map((variant) => _buildVariantTile(variant)),
      ],
    );
  }

  Widget _buildVariantTile(ABTestVariant variant) {
    final isUserVariant = userVariant == variant.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isUserVariant
                ? Colors.blue.withAlpha((255 * 0.1).round())
                : Colors.grey.withAlpha((255 * 0.05).round()),
        borderRadius: BorderRadius.circular(8),
        border: isUserVariant ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUserVariant ? Colors.blue : null,
                  ),
                ),
                Text(variant.title, style: const TextStyle(fontSize: 12)),
                Text(variant.body, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isUserVariant ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${(variant.weight * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (result == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Results', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                (result!.statisticalSignificance > 0.95)
                    ? Colors.green.withAlpha((255 * 0.1).round())
                    : Colors.orange.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (result!.statisticalSignificance > 0.95) ? Colors.green : Colors.orange,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Statistical Significance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    (result!.statisticalSignificance > 0.95) ? Icons.check_circle : Icons.warning,
                    color: (result!.statisticalSignificance > 0.95) ? Colors.green : Colors.orange,
                  ),
                ],
              ),
              if (result!.winner != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Winner:'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        result!.winner!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              _buildResultsGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsGrid() {
    if (result == null) return const SizedBox();

    final totalParticipants = result!.variantStats.values
        .fold(0, (sum, stat) => sum + stat.impressions);
    final totalConversions = result!.variantStats.values
        .fold(0, (sum, stat) => sum + stat.conversions);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildResultMetric(
          'Participants',
          totalParticipants.toString(),
          Icons.people,
        ),
        _buildResultMetric(
          'Conversions',
          totalConversions.toString(),
          Icons.trending_up,
        ),
        _buildResultMetric(
          'Significance',
          '${(result!.statisticalSignificance * 100).toStringAsFixed(1)}%',
          Icons.analytics,
        ),
        _buildResultMetric(
          'Confidence',
          '${(result!.confidence * 100).toStringAsFixed(1)}%',
          Icons.verified,
        ),
      ],
    );
  }

  Widget _buildResultMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Started: ${_formatDate(test.startDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Ends: ${_formatDate(test.endDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
