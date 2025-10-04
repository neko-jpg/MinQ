import 'package:flutter/material.dart';

import 'package:minq/presentation/theme/minq_theme.dart';

/// 繝・・繧ｿ遘ｻ陦後ぎ繧､繝臥判髱｢
class DataMigrationGuideScreen extends StatelessWidget {
  const DataMigrationGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('繝・・繧ｿ遘ｻ陦後ぎ繧､繝・)),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing(4)),
        children: [
          _buildSection(
            context,
            title: '讖溽ｨｮ螟画峩蜑阪・貅門ｙ',
            icon: Icons.backup,
            steps: [
              'MinQ繧｢繝励Μ繧呈怙譁ｰ迚医↓譖ｴ譁ｰ縺励※縺上□縺輔＞',
              '險ｭ螳夂判髱｢縺九ｉ縲後ヰ繝・け繧｢繝・・縲阪ｒ繧ｿ繝・・',
              'Google Drive縺ｸ縺ｮ繝舌ャ繧ｯ繧｢繝・・繧貞ｮ溯｡・,
              '繝舌ャ繧ｯ繧｢繝・・螳御ｺ・ｒ遒ｺ隱・,
            ],
          ),
          SizedBox(height: tokens.spacing(6)),
          _buildSection(
            context,
            title: '譁ｰ縺励＞遶ｯ譛ｫ縺ｧ縺ｮ蠕ｩ蜈・,
            icon: Icons.restore,
            steps: [
              '譁ｰ縺励＞遶ｯ譛ｫ縺ｫMinQ繧｢繝励Μ繧偵う繝ｳ繧ｹ繝医・繝ｫ',
              '蜷後§Google繧｢繧ｫ繧ｦ繝ｳ繝医〒繝ｭ繧ｰ繧､繝ｳ',
              '險ｭ螳夂判髱｢縺九ｉ縲悟ｾｩ蜈・阪ｒ繧ｿ繝・・',
              'Google Drive縺九ｉ譛譁ｰ縺ｮ繝舌ャ繧ｯ繧｢繝・・繧帝∈謚・,
              '蠕ｩ蜈・ｮ御ｺ・ｒ蠕・▽',
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
                '豕ｨ諢・ 繝舌ャ繧ｯ繧｢繝・・繧貞叙繧峨★縺ｫ讖溽ｨｮ螟画峩縺吶ｋ縺ｨ縲√ョ繝ｼ繧ｿ縺悟､ｱ繧上ｌ繧句庄閭ｽ諤ｧ縺後≠繧翫∪縺吶・,
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
            // 繝舌ャ繧ｯ繧｢繝・・逕ｻ髱｢縺ｸ
            Navigator.pop(context);
          },
          icon: const Icon(Icons.backup),
          label: const Text('繝舌ャ繧ｯ繧｢繝・・繧貞ｮ溯｡・),
          style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, tokens.spacing(12))),
        ),
        SizedBox(height: tokens.spacing(3)),
        OutlinedButton.icon(
          onPressed: () {
            // 蠕ｩ蜈・判髱｢縺ｸ
            Navigator.pop(context);
          },
          icon: const Icon(Icons.restore),
          label: const Text('繝舌ャ繧ｯ繧｢繝・・縺九ｉ蠕ｩ蜈・),
          style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, tokens.spacing(12))),
        ),
      ],
    );
  }
}
