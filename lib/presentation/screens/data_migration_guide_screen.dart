import 'package:flutter/material.dart';

import 'package:minq/presentation/theme/minq_theme.dart';

/// チE�Eタ移行ガイド画面
class DataMigrationGuideScreen extends StatelessWidget {
  const DataMigrationGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('チE�Eタ移行ガイチE)),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing(4)),
        children: [
          _buildSection(
            context,
            title: '機種変更前�E準備',
            icon: Icons.backup,
            steps: [
              'MinQアプリを最新版に更新してください',
              '設定画面から「バチE��アチE�E」をタチE�E',
              'Google DriveへのバックアチE�Eを実衁E,
              'バックアチE�E完亁E��確誁E,
            ],
          ),
          SizedBox(height: tokens.spacing(6)),
          _buildSection(
            context,
            title: '新しい端末での復允E,
            icon: Icons.restore,
            steps: [
              '新しい端末にMinQアプリをインスト�Eル',
              '同じGoogleアカウントでログイン',
              '設定画面から「復允E��をタチE�E',
              'Google Driveから最新のバックアチE�Eを選抁E,
              '復允E��亁E��征E��',
            ],
          ),
          SizedBox(height: tokens.spacing(6)),
          _buildWarningCard(context),
          SizedBox(height: tokens.spacing(6)),
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
    final tokens = context.tokens;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: tokens.brandPrimary),
                SizedBox(width: tokens.spacing(2)),
                Text(title, style: tokens.titleLarge),
              ],
            ),
            SizedBox(height: tokens.spacing(4)),
            ...steps.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing(2)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: tokens.spacing(6),
                      height: tokens.spacing(6),
                      decoration: BoxDecoration(color: tokens.brandPrimary, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: tokens.labelMedium.copyWith(
                            color: tokens.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spacing(3)),
                    Expanded(child: Text(entry.value, style: tokens.bodyMedium)),
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
    final tokens = context.tokens;
    final warningBackground = tokens.accentWarning.withValues(alpha: 0.12);
    final warningBorder = tokens.accentWarning.withValues(alpha: 0.3);
    return Card(
      color: tokens.surface,
      child: Container(
        decoration: BoxDecoration(
          color: warningBackground,
          borderRadius: tokens.cornerMedium(),
          border: Border.all(color: warningBorder),
        ),
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning, color: tokens.accentWarning),
            SizedBox(width: tokens.spacing(3)),
            Expanded(
              child: Text(
                '注愁E バックアチE�Eを取らずに機種変更すると、データが失われる可能性があります、E,
                style: tokens.bodyMedium.copyWith(
                  color: tokens.accentWarning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // バックアチE�E画面へ
            Navigator.pop(context);
          },
          icon: const Icon(Icons.backup),
          label: const Text('バックアチE�Eを実衁E),
          style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, tokens.spacing(12))),
        ),
        SizedBox(height: tokens.spacing(3)),
        OutlinedButton.icon(
          onPressed: () {
            // 復允E��面へ
            Navigator.pop(context);
          },
          icon: const Icon(Icons.restore),
          label: const Text('バックアチE�Eから復允E),
          style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, tokens.spacing(12))),
        ),
      ],
    );
  }
}
