import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/controllers/sync_status_controller.dart';
import 'package:minq/presentation/controllers/home_data_controller.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class CreateMiniQuestScreen extends ConsumerStatefulWidget {
  const CreateMiniQuestScreen({super.key});

  @override
  ConsumerState<CreateMiniQuestScreen> createState() =>
      _CreateMiniQuestScreenState();
}

class _CreateMiniQuestScreenState extends ConsumerState<CreateMiniQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _goalController = TextEditingController(text: '10');

  String _iconKey = questIconCatalog.first.key;
  Color _accentColor = _miniQuestColors.first;
  bool _isTimeGoal = true;

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: '戻る',
        ),
        title: const Text('MiniQuest を作成'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(tokens.spacing.lg),
          children: [
            if (syncStatus.phase == SyncPhase.offline)
              _OfflineHint(tokens: tokens),
            SizedBox(height: tokens.spacing.lg),
            _PreviewCard(
              iconKey: _iconKey,
              accentColor: _accentColor,
              title: _titleController.text,
              isTimeGoal: _isTimeGoal,
              goalValue: _goalController.text,
            ),
            SizedBox(height: tokens.spacing.xl),
            const _SectionHeader(
              title: 'クエストの概要',
              subtitle: '習慣にしたいアクションを短い言葉で表現しましょう。',
            ),
            SizedBox(height: tokens.spacing.md),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                hintText: '例：朝のストレッチを5分',
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'タイトルを入力してください。';
                }
                return null;
              },
            ),
            SizedBox(height: tokens.spacing.xl),
            const _SectionHeader(
              title: '目標タイプ',
              subtitle: '計測したい単位を選び、目標値を設定します。',
            ),
            SizedBox(height: tokens.spacing.md),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: true, label: Text('時間で管理')),
                ButtonSegment<bool>(value: false, label: Text('回数で管理')),
              ],
              selected: {_isTimeGoal},
              onSelectionChanged: (selection) {
                setState(() => _isTimeGoal = selection.first);
              },
            ),
            SizedBox(height: tokens.spacing.md),
            TextFormField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '目標値',
                suffixText: _isTimeGoal ? '分' : '回',
              ),
              validator: (value) {
                final parsed = int.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return '1以上の数値を入力してください。';
                }
                return null;
              },
            ),
            SizedBox(height: tokens.spacing.xl),
            const _SectionHeader(
              title: 'アイコンとカラー',
              subtitle: '視覚的なモチベーションにつながります。',
            ),
            SizedBox(height: tokens.spacing.md),
            _IconSelector(
              selectedKey: _iconKey,
              onChanged: (key) => setState(() => _iconKey = key),
            ),
            SizedBox(height: tokens.spacing.md),
            _ColorSelector(
              selected: _accentColor,
              onChanged: (color) => setState(() => _accentColor = color),
            ),
            SizedBox(height: tokens.spacing.xl),
            FilledButton(
              onPressed: _saveMiniQuest,
              style: FilledButton.styleFrom(
                backgroundColor: tokens.brandPrimary,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                'MiniQuest を保存',
                style: tokens.typography.button.copyWith(
                  color: tokens.primaryForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMiniQuest() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final uid = ref.read(uidProvider);
    if (uid == null || uid.isEmpty) {
      FeedbackMessenger.showErrorSnackBar(
        context,
        'MiniQuest を保存するにはログインが必要です。',
      );
      return;
    }

    final quest =
        Quest()
          ..owner = uid
          ..title = _titleController.text.trim()
          ..category = 'MiniQuest'
          ..estimatedMinutes =
              _isTimeGoal ? int.parse(_goalController.text.trim()) : 0
          ..iconKey = _iconKey
          ..status = QuestStatus.active
          ..createdAt = DateTime.now();

    try {
      await ref.read(questRepositoryProvider).addQuest(quest);
      ref.invalidate(homeDataProvider);
      ref.invalidate(recentLogsProvider);
      ref.invalidate(userQuestsProvider);

      if (!mounted) return;
      FeedbackMessenger.showSuccessToast(context, 'MiniQuest を保存しました。');
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      ref.read(navigationUseCaseProvider).goHome();
    } catch (error) {
      if (!mounted) return;
      FeedbackMessenger.showErrorSnackBar(context, '保存に失敗しました: $error');
    }
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.iconKey,
    required this.accentColor,
    required this.title,
    required this.isTimeGoal,
    required this.goalValue,
  });

  final String iconKey;
  final Color accentColor;
  final String title;
  final bool isTimeGoal;
  final String goalValue;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final icon = questIconCatalog.firstWhere(
      (entry) => entry.key == iconKey,
      orElse: () => questIconCatalog.first,
    );

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        boxShadow: tokens.shadow.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.15),
            ),
            child: Icon(icon.icon, color: accentColor),
          ),
          SizedBox(width: tokens.spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? '新しい MiniQuest' : title,
                  style: tokens.typography.titleMedium.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  '${goalValue.isEmpty ? '-' : goalValue}'
                  '${isTimeGoal ? '分' : '回'}',
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: tokens.typography.titleMedium.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: tokens.spacing.xs),
          Text(
            subtitle!,
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _IconSelector extends StatelessWidget {
  const _IconSelector({required this.selectedKey, required this.onChanged});

  final String selectedKey;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: questIconCatalog.length,
        separatorBuilder: (_, __) => SizedBox(width: tokens.spacing.md),
        itemBuilder: (context, index) {
          final item = questIconCatalog[index];
          final isSelected = item.key == selectedKey;
          return GestureDetector(
            onTap: () => onChanged(item.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? tokens.brandPrimary.withOpacity(0.15)
                        : tokens.surface,
                borderRadius: BorderRadius.circular(tokens.radius.lg),
                border: Border.all(
                  color: isSelected ? tokens.brandPrimary : tokens.border,
                ),
              ),
              child: Icon(
                item.icon,
                color: isSelected ? tokens.brandPrimary : tokens.textMuted,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ColorSelector extends StatelessWidget {
  const _ColorSelector({required this.selected, required this.onChanged});

  final Color selected;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Wrap(
      spacing: tokens.spacing.md,
      runSpacing: tokens.spacing.md,
      children:
          _miniQuestColors.map((color) {
            final isSelected = color == selected;
            return GestureDetector(
              onTap: () => onChanged(color),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: isSelected ? tokens.primaryForeground : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _OfflineHint extends StatelessWidget {
  const _OfflineHint({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.orange),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Text(
              'オフラインで作成した MiniQuest は、接続が復帰した際に自動で同期します。',
              style: tokens.typography.bodySmall.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<Color> _miniQuestColors = [
  Color(0xFF4F46E5),
  Color(0xFF22D3EE),
  Color(0xFFEF4444),
  Color(0xFFF59E0B),
  Color(0xFF10B981),
  Color(0xFF6366F1),
];
