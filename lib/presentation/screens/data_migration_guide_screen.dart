import 'package:flutter/material.dart';

/// データ移行ガイド画面
class DataMigrationGuideScreen extends StatelessWidget {
  const DataMigrationGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('データ移行ガイド')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: '機種変更前の準備',
            icon: Icons.backup,
            steps: [
              'MinQアプリを最新版に更新してください',
              '設定画面から「バックアップ」をタップ',
              'Google Driveへのバックアップを実行',
              'バックアップ完了を確認',
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: '新しい端末での復元',
            icon: Icons.restore,
            steps: [
              '新しい端末にMinQアプリをインストール',
              '同じGoogleアカウントでログイン',
              '設定画面から「復元」をタップ',
              'Google Driveから最新のバックアップを選択',
              '復元完了を待つ',
            ],
          ),
          const SizedBox(height: 24),
          _buildWarningCard(context),
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> steps,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '注意: バックアップを取らずに機種変更すると、データが失われる可能性があります。',
                style: TextStyle(color: Colors.orange.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // バックアップ画面へ
            Navigator.pop(context);
          },
          icon: const Icon(Icons.backup),
          label: const Text('バックアップを実行'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            // 復元画面へ
            Navigator.pop(context);
          },
          icon: const Icon(Icons.restore),
          label: const Text('バックアップから復元'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}
