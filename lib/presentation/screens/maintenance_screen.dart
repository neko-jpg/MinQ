import 'package:flutter/material.dart';

/// メンテナンス画面
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
                'メンテナンス中',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'ただいまメンテナンス中です。\nしばらくお待ちください。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (estimatedEndTime != null) ...[
                const SizedBox(height: 16),
                Text(
                  '終了予定: ${_formatDateTime(estimatedEndTime!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // アプリを再起動
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
    return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
