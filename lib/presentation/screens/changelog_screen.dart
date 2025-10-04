import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/theme/spacing_system.dart';
import 'package:minq/presentation/theme/typography_system.dart';

/// 変更履歴・お知らせセンター画面
class ChangelogScreen extends ConsumerWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お知らせ・変更履歴'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSection(
            context,
            title: '最新のお知らせ',
            items: _getAnnouncements(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
            context,
            title: '変更履歴',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text('• ', style: AppTypography.body),
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
        label = 'お知らせ';
        icon = Icons.campaign;
        break;
      case ChangelogType.feature:
        color = Colors.green;
        label = '新機�E';
        icon = Icons.new_releases;
        break;
      case ChangelogType.improvement:
        color = Colors.orange;
        label = '改喁E;
        icon = Icons.trending_up;
        break;
      case ChangelogType.bugfix:
        color = Colors.red;
        label = 'バグ修正';
        icon = Icons.bug_report;
        break;
      case ChangelogType.maintenance:
        color = Colors.grey;
        label = 'メンチE��ンス';
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
    return '${date.year}年${date.month}朁E{date.day}日';
  }

  List<ChangelogItem> _getAnnouncements() {
    return [
      ChangelogItem(
        type: ChangelogType.announcement,
        title: 'MiniQ v1.0.0 リリース�E�E,
        date: DateTime(2025, 10, 2),
        description: 'MiniQの最初�Eバ�Eジョンをリリースしました、E
            '習�Eを楽しく継続できる機�Eが満載です、E,
        changes: [
          '習�E管琁E���E',
          '進捗統計表示',
          'ペア機�E',
          'プッシュ通知',
          'チE�Eタエクスポ�EチE,
        ],
      ),
    ];
  }

  List<ChangelogItem> _getChangelogs() {
    return [
      ChangelogItem(
        type: ChangelogType.feature,
        title: 'バ�Eジョン 1.0.0',
        date: DateTime(2025, 10, 2),
        description: '初回リリース',
        changes: [
          '習�E�E�EiniQuest�E��E作�E・編雁E�E削除機�E',
          '達�E記録とストリーク表示',
          '週間�E月間の統計グラチE,
          'ペア機�Eによる励まし合ぁE,
          'カスタマイズ可能な通知設宁E,
          'ライト�Eダークモード対忁E,
          'チE�EタのバックアチE�E・復允E,
          'CSV/JSONエクスポ�EチE,
        ],
      ),
      ChangelogItem(
        type: ChangelogType.improvement,
        title: 'パフォーマンス改喁E,
        date: DateTime(2025, 9, 25),
        description: 'アプリの起動速度とレスポンスを改喁E��ました、E,
        changes: [
          '起動時間を30%短縮',
          '画面遷移のアニメーションを最適匁E,
          'メモリ使用量を削渁E,
        ],
      ),
      ChangelogItem(
        type: ChangelogType.bugfix,
        title: 'バグ修正',
        date: DateTime(2025, 9, 20),
        description: 'ぁE��つか�Eバグを修正しました、E,
        changes: [
          '通知が届かなぁE��題を修正',
          'ダークモードでの表示崩れを修正',
          'チE�Eタ同期の遁E��を改喁E,
        ],
      ),
    ];
  }
}

/// 変更履歴アイチE��
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

/// 変更履歴のタイチE
enum ChangelogType {
  announcement,
  feature,
  improvement,
  bugfix,
  maintenance,
}
