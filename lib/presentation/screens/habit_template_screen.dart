import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/templates/habit_templates.dart';
import '../routing/navigation_extensions.dart';
import '../theme/app_theme.dart';

/// 習慣テンプレート選択画面
class HabitTemplateScreen extends ConsumerStatefulWidget {
  const HabitTemplateScreen({super.key});

  @override
  ConsumerState<HabitTemplateScreen> createState() => _HabitTemplateScreenState();
}

class _HabitTemplateScreenState extends ConsumerState<HabitTemplateScreen> {
  HabitCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final templates = _selectedCategory == null
        ? HabitTemplates.all
        : HabitTemplates.getByCategory(_selectedCategory!);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          '習慣テンプレート',
          style: tokens.typography.h3.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.safePop(),
        ),
        backgroundColor: tokens.background.withOpacity(0.9),
        elevation: 0,
      ),
      body: Column(
        children: [
          // カテゴリーフィルター
          _buildCategoryFilter(tokens),
          // テンプレートリスト
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(tokens.spacing.md),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _TemplateCard(
                  template: template,
                  tokens: tokens,
                  onTap: () => _selectTemplate(template),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(MinqTheme tokens) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: tokens.spacing.sm),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md),
        children: [
          _CategoryChip(
            label: 'すべて',
            icon: '📋',
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
            tokens: tokens,
          ),
          ...HabitCategory.values.map((category) {
            return _CategoryChip(
              label: category.displayName,
              icon: category.icon,
              isSelected: _selectedCategory == category,
              onTap: () => setState(() => _selectedCategory = category),
              tokens: tokens,
            );
          }),
        ],
      ),
    );
  }

  void _selectTemplate(HabitTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TemplateDetailSheet(
        template: template,
        onUse: () {
          context.safePop(); // シートを閉じる
          context.safePop(template); // テンプレートを返す
        },
      ),
    );
  }
}

/// カテゴリーチップ
class _CategoryChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  final MinqTheme tokens;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: tokens.spacing.sm),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            SizedBox(width: tokens.spacing.xs),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: tokens.surface,
        selectedColor: tokens.primary.withOpacity(0.2),
        checkmarkColor: tokens.primary,
      ),
    );
  }
}

/// テンプレートカード
class _TemplateCard extends StatelessWidget {
  final HabitTemplate template;
  final MinqTheme tokens;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing.md),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Row(
            children: [
              // アイコン
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tokens.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                child: Center(
                  child: Text(
                    template.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              // テキスト
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: tokens.typography.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      template.description,
                      style: tokens.typography.caption.copyWith(
                        color: tokens.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.timer_outlined,
                          label: '${template.estimatedMinutes}分',
                          tokens: tokens,
                        ),
                        SizedBox(width: tokens.spacing.xs),
                        _InfoChip(
                          icon: Icons.star_outline,
                          label: template.difficulty.displayName,
                          tokens: tokens,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: tokens.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 情報チップ
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final MinqTheme tokens;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.xs,
        vertical: tokens.spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tokens.textSecondary),
          SizedBox(width: tokens.spacing.xxs),
          Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: tokens.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// テンプレート詳細シート
class _TemplateDetailSheet extends StatelessWidget {
  final HabitTemplate template;
  final VoidCallback onUse;

  const _TemplateDetailSheet({
    required this.template,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radius.xl),
        ),
      ),
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ハンドル
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            // アイコンとタイトル
            Row(
              children: [
                Text(template.icon, style: const TextStyle(fontSize: 48)),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: tokens.typography.h3.copyWith(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        template.category.displayName,
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.lg),
            // 説明
            Text(
              template.description,
              style: tokens.typography.body.copyWith(
                color: tokens.textPrimary,
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            // 詳細情報
            _DetailRow(
              icon: Icons.timer_outlined,
              label: '推定時間',
              value: '${template.estimatedMinutes}分',
              tokens: tokens,
            ),
            _DetailRow(
              icon: Icons.star_outline,
              label: '難易度',
              value: template.difficulty.displayName,
              tokens: tokens,
            ),
            _DetailRow(
              icon: Icons.schedule,
              label: 'おすすめ時間',
              value: template.suggestedTimes.join(', '),
              tokens: tokens,
            ),
            SizedBox(height: tokens.spacing.lg),
            // ヒント
            Container(
              padding: EdgeInsets.all(tokens.spacing.md),
              decoration: BoxDecoration(
                color: tokens.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(tokens.radius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: tokens.primary),
                  SizedBox(width: tokens.spacing.sm),
                  Expanded(
                    child: Text(
                      template.tips,
                      style: tokens.typography.body.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.spacing.xl),
            // ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.primary,
                  padding: EdgeInsets.symmetric(vertical: tokens.spacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.full),
                  ),
                ),
                child: Text(
                  'このテンプレートを使う',
                  style: tokens.typography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 詳細行
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final MinqTheme tokens;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: tokens.textSecondary),
          SizedBox(width: tokens.spacing.sm),
          Text(
            label,
            style: tokens.typography.body.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: tokens.typography.body.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
