import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/controllers/home_data_controller.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class CreateMiniQuestScreen extends ConsumerStatefulWidget {
  const CreateMiniQuestScreen({super.key});

  @override
  ConsumerState<CreateMiniQuestScreen> createState() =>
      _CreateMiniQuestScreenState();
}

class _CreateMiniQuestScreenState extends ConsumerState<CreateMiniQuestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _goalValueController = TextEditingController(
    text: '10',
  );

  String _selectedIconKey = 'spa';
  Color _selectedColor = const Color(0xFF37CBFA);
  bool _isTimeGoal = true;

  @override
  void dispose() {
    _titleController.dispose();
    _goalValueController.dispose();
    super.dispose();
  }

  Future<void> _saveMiniQuest() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final uid = ref.read(uidProvider);
    if (uid == null || uid.isEmpty) {
      FeedbackMessenger.showErrorSnackBar(
        context,
        'MiniQuestを作成するにはサインインが必要です。',
      );
      return;
    }

    final quest =
        Quest()
          ..owner = uid
          ..title = _titleController.text.trim()
          ..category = 'MiniQuest'
          ..estimatedMinutes =
              _isTimeGoal
                  ? (int.tryParse(_goalValueController.text.trim()) ?? 0)
                  : 0
          ..iconKey = _selectedIconKey
          ..status = QuestStatus.active
          ..createdAt = DateTime.now();

    try {
      await ref.read(questRepositoryProvider).addQuest(quest);

      // プロバイダーを無効化してデータを再読み込み
      ref.invalidate(homeDataProvider);
      ref.invalidate(recentLogsProvider);
      ref.invalidate(userQuestsProvider);

      if (!mounted) {
        return;
      }

      // 成功メッセージを表示
      FeedbackMessenger.showSuccessToast(context, 'MiniQuestを作成しました！');

      // 少し待ってからホーム画面に遷移（プロバイダーの更新を待つ）
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) {
        return;
      }

      // ホーム画面に遷移
      ref.read(navigationUseCaseProvider).goHome();
    } catch (e) {
      if (!mounted) {
        return;
      }
      FeedbackMessenger.showErrorSnackBar(context, 'MiniQuestの作成に失敗しました: $e');
    }
  }

  Future<void> _onChooseIcon() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => const _IconPickerDialog(),
    );
    if (selected != null && selected != _selectedIconKey) {
      setState(() => _selectedIconKey = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '戻る',
          onPressed: () => context.pop(),
        ),
        title: Text(
          'MiniQuestを作成',
          style: tokens.typography.h4.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MiniQuestのタイトル',
                style: tokens.typography.body.copyWith(
                  color: tokens.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: tokens.spacing.sm),
              TextFormField(
                controller: _titleController,
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'タイトルを入力してください。'
                            : null,
                decoration: InputDecoration(
                  hintText: '例：朝のストレッチ10分',
                  prefixIcon: const Icon(Icons.edit),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(
                      color: tokens.brandPrimary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: tokens.spacing.lg),
              Text(
                'アイコンとカラー',
                style: tokens.typography.body.copyWith(
                  color: tokens.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: tokens.spacing.sm),
              Row(
                children: [
                  GestureDetector(
                    onTap: _onChooseIcon,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: BorderRadius.circular(tokens.radius.lg),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Icon(
                        iconDataForKey(_selectedIconKey),
                        size: 40,
                        color: tokens.brandPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.spacing.lg),
                  Expanded(
                    child: Wrap(
                      spacing: tokens.spacing.sm,
                      runSpacing: tokens.spacing.sm,
                      children:
                          _miniQuestColors
                              .map(
                                (color) => GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => _selectedColor = color,
                                      ),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border:
                                          _selectedColor == color
                                              ? Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              )
                                              : null,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.spacing.lg),
              Text(
                '目標タイプ',
                style: tokens.typography.body.copyWith(
                  color: tokens.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: tokens.spacing.sm),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(value: true, label: Text('時間で記録')),
                  ButtonSegment<bool>(value: false, label: Text('回数で記録')),
                ],
                selected: {_isTimeGoal},
                onSelectionChanged: (selection) {
                  setState(() => _isTimeGoal = selection.first);
                },
              ),
              SizedBox(height: tokens.spacing.md),
              Text(
                '目標値',
                style: tokens.typography.body.copyWith(
                  color: tokens.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: tokens.spacing.sm),
              TextFormField(
                controller: _goalValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixText: _isTimeGoal ? '分' : '回',
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    borderSide: BorderSide(
                      color: tokens.brandPrimary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: tokens.spacing.xxl),
              FilledButton(
                onPressed: _saveMiniQuest,
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.brandPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('MiniQuestを保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconPickerDialog extends StatelessWidget {
  const _IconPickerDialog();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AlertDialog(
      backgroundColor: tokens.surface,
      title: const Text('アイコンを選択'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: questIconCatalog.length,
          itemBuilder: (context, index) {
            final icon = questIconCatalog[index];
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(icon.key),
              child: Container(
                decoration: BoxDecoration(
                  color: tokens.surfaceVariant,
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
                child: Icon(icon.icon, size: 28),
              ),
            );
          },
        ),
      ),
    );
  }
}

const List<Color> _miniQuestColors = <Color>[
  Color(0xFF37CBFA),
  Color(0xFFFF6B6B),
  Color(0xFF4ECDC4),
  Color(0xFFFFA07A),
  Color(0xFF9B59B6),
  Color(0xFFFFD166),
];
