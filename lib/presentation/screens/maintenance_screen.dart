import 'package:flutter/material.dart';

/// 繝｡繝ｳ繝・リ繝ｳ繧ｹ逕ｻ髱｢
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
                '繝｡繝ｳ繝・リ繝ｳ繧ｹ荳ｭ',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                message ?? '縺溘□縺・∪繝｡繝ｳ繝・リ繝ｳ繧ｹ荳ｭ縺ｧ縺吶・n縺励・繧峨￥縺雁ｾ・■縺上□縺輔＞縲・,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (estimatedEndTime != null) ...[
                const SizedBox(height: 16),
                Text(
                  '邨ゆｺ・ｺ亥ｮ・ ${_formatDateTime(estimatedEndTime!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // 繧｢繝励Μ繧貞・襍ｷ蜍・
                },
                icon: const Icon(Icons.refresh),
                label: const Text('蜀崎ｪｭ縺ｿ霎ｼ縺ｿ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}譛・{dateTime.day}譌･ ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
