import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/theme/spacing_system.dart';
import 'package:minq/presentation/theme/typography_system.dart';

/// 螟画峩螻･豁ｴ繝ｻ縺顔衍繧峨○繧ｻ繝ｳ繧ｿ繝ｼ逕ｻ髱｢
class ChangelogScreen extends ConsumerWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('縺顔衍繧峨○繝ｻ螟画峩螻･豁ｴ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSection(
            context,
            title: '譛譁ｰ縺ｮ縺顔衍繧峨○',
            items: _getAnnouncements(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
            context,
            title: '螟画峩螻･豁ｴ',
            items: _getChangelogs(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<ChangelogItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h2,
        ),
        const SizedBox(height: AppSpacing.md),
        ...items.map((item) => _buildChangelogCard(context, item)),
      ],
    );
  }

  Widget _buildChangelogCard(BuildContext context, ChangelogItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              _buildTypeChip(item.type),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTypography.h3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatDate(item.date),
            style: AppTypography.caption.copyWith(
              color: Colors.grey,
            ),
          ),
          if (item.description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.description!,
              style: AppTypography.body,
            ),
          ],
          if (item.changes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ...item.changes.map((change) => Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    bottom: AppSpacing.xs,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('窶｢ ', style: AppTypography.body),
                      Expanded(
                        child: Text(
                          change,
                          style: AppTypography.body,
                        ),
                      ),
                    ],
                  ),
                ),),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeChip(ChangelogType type) {
    Color color;
    String label;
    IconData icon;

    switch (type) {
      case ChangelogType.announcement:
        color = Colors.blue;
        label = '縺顔衍繧峨○';
        icon = Icons.campaign;
        break;
      case ChangelogType.feature:
        color = Colors.green;
        label = '譁ｰ讖溯・';
        icon = Icons.new_releases;
        break;
      case ChangelogType.improvement:
        color = Colors.orange;
        label = '謾ｹ蝟・;
        icon = Icons.trending_up;
        break;
      case ChangelogType.bugfix:
        color = Colors.red;
        label = '繝舌げ菫ｮ豁｣';
        icon = Icons.bug_report;
        break;
      case ChangelogType.maintenance:
        color = Colors.grey;
        label = '繝｡繝ｳ繝・リ繝ｳ繧ｹ';
        icon = Icons.build;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}蟷ｴ${date.month}譛・{date.day}譌･';
  }

  List<ChangelogItem> _getAnnouncements() {
    return [
      ChangelogItem(
        type: ChangelogType.announcement,
        title: 'MiniQ v1.0.0 繝ｪ繝ｪ繝ｼ繧ｹ・・,
        date: DateTime(2025, 10, 2),
        description: 'MiniQ縺ｮ譛蛻昴・繝舌・繧ｸ繝ｧ繝ｳ繧偵Μ繝ｪ繝ｼ繧ｹ縺励∪縺励◆縲・
            '鄙呈・繧呈･ｽ縺励￥邯咏ｶ壹〒縺阪ｋ讖溯・縺梧ｺ霈峨〒縺吶・,
        changes: [
          '鄙呈・邂｡逅・ｩ溯・',
          '騾ｲ謐礼ｵｱ險郁｡ｨ遉ｺ',
          '繝壹い讖溯・',
          '繝励ャ繧ｷ繝･騾夂衍',
          '繝・・繧ｿ繧ｨ繧ｯ繧ｹ繝昴・繝・,
        ],
      ),
    ];
  }

  List<ChangelogItem> _getChangelogs() {
    return [
      ChangelogItem(
        type: ChangelogType.feature,
        title: '繝舌・繧ｸ繝ｧ繝ｳ 1.0.0',
        date: DateTime(2025, 10, 2),
        description: '蛻晏屓繝ｪ繝ｪ繝ｼ繧ｹ',
        changes: [
          '鄙呈・・・iniQuest・峨・菴懈・繝ｻ邱ｨ髮・・蜑企勁讖溯・',
          '驕疲・險倬鹸縺ｨ繧ｹ繝医Μ繝ｼ繧ｯ陦ｨ遉ｺ',
          '騾ｱ髢薙・譛磯俣縺ｮ邨ｱ險医げ繝ｩ繝・,
          '繝壹い讖溯・縺ｫ繧医ｋ蜉ｱ縺ｾ縺怜粋縺・,
          '繧ｫ繧ｹ繧ｿ繝槭う繧ｺ蜿ｯ閭ｽ縺ｪ騾夂衍險ｭ螳・,
          '繝ｩ繧､繝医・繝繝ｼ繧ｯ繝｢繝ｼ繝牙ｯｾ蠢・,
          '繝・・繧ｿ縺ｮ繝舌ャ繧ｯ繧｢繝・・繝ｻ蠕ｩ蜈・,
          'CSV/JSON繧ｨ繧ｯ繧ｹ繝昴・繝・,
        ],
      ),
      ChangelogItem(
        type: ChangelogType.improvement,
        title: '繝代ヵ繧ｩ繝ｼ繝槭Φ繧ｹ謾ｹ蝟・,
        date: DateTime(2025, 9, 25),
        description: '繧｢繝励Μ縺ｮ襍ｷ蜍暮溷ｺｦ縺ｨ繝ｬ繧ｹ繝昴Φ繧ｹ繧呈隼蝟・＠縺ｾ縺励◆縲・,
        changes: [
          '襍ｷ蜍墓凾髢薙ｒ30%遏ｭ邵ｮ',
          '逕ｻ髱｢驕ｷ遘ｻ縺ｮ繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ繧呈怙驕ｩ蛹・,
          '繝｡繝｢繝ｪ菴ｿ逕ｨ驥上ｒ蜑頑ｸ・,
        ],
      ),
      ChangelogItem(
        type: ChangelogType.bugfix,
        title: '繝舌げ菫ｮ豁｣',
        date: DateTime(2025, 9, 20),
        description: '縺・￥縺､縺九・繝舌げ繧剃ｿｮ豁｣縺励∪縺励◆縲・,
        changes: [
          '騾夂衍縺悟ｱ翫°縺ｪ縺・撫鬘後ｒ菫ｮ豁｣',
          '繝繝ｼ繧ｯ繝｢繝ｼ繝峨〒縺ｮ陦ｨ遉ｺ蟠ｩ繧後ｒ菫ｮ豁｣',
          '繝・・繧ｿ蜷梧悄縺ｮ驕・ｻｶ繧呈隼蝟・,
        ],
      ),
    ];
  }
}

/// 螟画峩螻･豁ｴ繧｢繧､繝・Β
class ChangelogItem {
  final ChangelogType type;
  final String title;
  final DateTime date;
  final String? description;
  final List<String> changes;

  ChangelogItem({
    required this.type,
    required this.title,
    required this.date,
    this.description,
    this.changes = const [],
  });
}

/// 螟画峩螻･豁ｴ縺ｮ繧ｿ繧､繝・
enum ChangelogType {
  announcement,
  feature,
  improvement,
  bugfix,
  maintenance,
}
