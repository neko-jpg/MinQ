import 'package:flutter/material.dart';
import 'package:minq/core/monitoring/app_monitoring_service.dart';

class HealthStatusCard extends StatelessWidget {
  final AppHealthStatus status;
  final Map<String, dynamic> metrics;

  const HealthStatusCard({
    super.key,
    required this.status,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Health Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    
    switch (status) {
      case AppHealthStatus.healthy:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case AppHealthStatus.warning:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case AppHealthStatus.critical:
        icon = Icons.error;
        color = Colors.red;
        break;
    }
    
    return Icon(icon, color: color, size: 32);
  }

  String _getStatusText() {
    switch (status) {
      case AppHealthStatus.healthy:
        return 'Healthy';
      case AppHealthStatus.warning:
        return 'Warning';
      case AppHealthStatus.critical:
        return 'Critical';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case AppHealthStatus.healthy:
        return Colors.green;
      case AppHealthStatus.warning:
        return Colors.orange;
      case AppHealthStatus.critical:
        return Colors.red;
    }
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildMetricTile(
          'Memory Usage',
          '${(metrics['memory_usage_mb'] ?? 0).toStringAsFixed(1)} MB',
          Icons.memory,
        ),
        _buildMetricTile(
          'Frame Rate',
          '${(60 - (metrics['frame_drop_rate'] ?? 0) * 60).toStringAsFixed(1)} fps',
          Icons.speed,
        ),
        _buildMetricTile(
          'Uptime',
          '${(metrics['uptime_minutes'] ?? 0).toInt()} min',
          Icons.timer,
        ),
        _buildMetricTile(
          'Battery',
          '${(metrics['battery_level'] ?? 100).toInt()}%',
          Icons.battery_full,
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}