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
        label = '新機能';
        icon = Icons.new_releases;
        break;
      case ChangelogType.improvement:
        color = Colors.orange;
        label = '改善';
        icon = Icons.trending_up;
        break;
      case ChangelogType.bugfix:
        color = Colors.red;
        label = 'バグ修正';
        icon = Icons.bug_report;
        break;
      case ChangelogType.maintenance:
        color = Colors.grey;
        label = 'メンテナンス';
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
    return '${date.year}年${date.month}月${date.day}日';
  }

  List<ChangelogItem> _getAnnouncements() {
    return [
      ChangelogItem(
        type: ChangelogType.announcement,
        title: 'MiniQ v1.0.0 リリース！',
        date: DateTime(2025, 10, 2),
        description: 'MiniQの最初のバージョンをリリースしました。'
            '習慣を楽しく継続できる機能が満載です。',
        changes: [
          '習慣管理機能',
          '進捗統計表示',
          'ペア機能',
          'プッシュ通知',
          'データエクスポート',
        ],
      ),
    ];
  }

  List<ChangelogItem> _getChangelogs() {
    return [
      ChangelogItem(
        type: ChangelogType.feature,
        title: 'バージョン 1.0.0',
        date: DateTime(2025, 10, 2),
        description: '初回リリース',
        changes: [
          '習慣（MiniQuest）の作成・編集・削除機能',
          '達成記録とストリーク表示',
          '週間・月間の統計グラフ',
          'ペア機能による励まし合い',
          'カスタマイズ可能な通知設定',
          'ライト・ダークモード対応',
          'データのバックアップ・復元',
          'CSV/JSONエクスポート',
        ],
      ),
      ChangelogItem(
        type: ChangelogType.improvement,
        title: 'パフォーマンス改善',
        date: DateTime(2025, 9, 25),
        description: 'アプリの起動速度とレスポンスを改善しました。',
        changes: [
          '起動時間を30%短縮',
          '画面遷移のアニメーションを最適化',
          'メモリ使用量を削減',
        ],
      ),
      ChangelogItem(
        type: ChangelogType.bugfix,
        title: 'バグ修正',
        date: DateTime(2025, 9, 20),
        description: 'いくつかのバグを修正しました。',
        changes: [
          '通知が届かない問題を修正',
          'ダークモードでの表示崩れを修正',
          'データ同期の遅延を改善',
        ],
      ),
    ];
  }
}

/// 変更履歴アイテム
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

/// 変更履歴のタイプ
enum ChangelogType {
  announcement,
  feature,
  improvement,
  bugfix,
  maintenance,
}
