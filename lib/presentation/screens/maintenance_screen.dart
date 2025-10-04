import 'package:flutter/material.dart';

/// メンチE��ンス画面
class MaintenanceScreen extends StatelessWidget {
  final String? message;
  final DateTime? estimatedEndTime;

  const MaintenanceScreen({
    super.key,
    this.message,
    this.estimatedEndTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'メンチE��ンス中',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'ただぁE��メンチE��ンス中です、Enし�Eらくお征E��ください、E,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (estimatedEndTime != null) ...[
                const SizedBox(height: 16),
                Text(
                  '終亁E��宁E ${_formatDateTime(estimatedEndTime!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // アプリを�E起勁E
                },
                icon: const Icon(Icons.refresh),
                label: const Text('再読み込み'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}朁E{dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
