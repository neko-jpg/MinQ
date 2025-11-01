import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/reminders/multiple_reminder_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class EditQuestScreen extends ConsumerStatefulWidget {
  const EditQuestScreen({super.key, required this.questId});

  final int questId;

  @override
  ConsumerState<EditQuestScreen> createState() => _EditQuestScreenState();
}

class _EditQuestScreenState extends ConsumerState<EditQuestScreen> {
  static const List<String> _stepTitles = <String>['基本情報', '目標と頻度', 'リマインダー'];
  static const Set<int> _defaultSelectedDays = <int>{0, 1, 2, 3, 6};

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _goalValueController = TextEditingController();
  final _contactLinkController = TextEditingController();
  final PageController _pageController = PageController();
  final ListEquality<_ReminderFormEntry> _reminderListEquality =
      const ListEquality<_ReminderFormEntry>(_ReminderFormEntryEquality());

  String _selectedIconKey = 'spa';
  bool _isTimeGoal = true;
  final Set<int> _selectedDays = <int>{..._defaultSelectedDays};
  final List<_ReminderFormEntry> _reminderEntries = <_ReminderFormEntry>[];
  List<_ReminderFormEntry> _initialReminderEntries = <_ReminderFormEntry>[];
  bool _isRemindersLoading = true;
  String? _reminderLoadError;
  int _currentStep = 0;

  Quest? _originalQuest;
  bool _isLoading = true;
  String? _originalContactLink;

  bool get _reduceMotion =>
      WidgetsBinding
          .instance
          .platformDispatcher
          .accessibilityFeatures
          .disableAnimations;

  bool get _isLastStep => _currentStep == _stepTitles.length - 1;

  bool get _hasUnsavedChanges {
    if (_originalQuest == null) return false;

    return _titleController.text.trim() != _originalQuest!.title ||
        _selectedIconKey != _originalQuest!.iconKey ||
        _isTimeGoal != (_originalQuest!.estimatedMinutes > 0) ||
        (_isTimeGoal &&
            int.tryParse(_goalValueController.text) !=
                _originalQuest!.estimatedMinutes) ||
        _contactLinkController.text.trim() != (_originalContactLink ?? '') ||
        !_reminderListEquality.equals(
          _initialReminderEntries,
          _reminderEntries,
        );
  }

  @override
  void initState() {
    super.initState();
    _loadQuest();
    _loadReminders();
    _contactLinkController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadQuest() async {
    try {
      final quest = await ref.read(questByIdProvider(widget.questId).future);
      if (!mounted) return;

      if (quest != null) {
        final link = await ref
            .read(contactLinkRepositoryProvider)
            .getLink(widget.questId);
        if (!mounted) return;

        setState(() {
          _originalQuest = quest;
          _titleController.text = quest.title;
          _selectedIconKey = quest.iconKey ?? 'default';
          _isTimeGoal = quest.estimatedMinutes > 0;
          _goalValueController.text =
              quest.estimatedMinutes > 0
                  ? quest.estimatedMinutes.toString()
                  : '10';
          _originalContactLink = link;
          _contactLinkController.text = link ?? '';
          _isLoading = false;
        });
      } else {
        FeedbackMessenger.showErrorSnackBar(context, 'クエストが見つかりませんでした。');
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      FeedbackMessenger.showErrorSnackBar(context, 'クエストの読み込みに失敗しました。');
      context.pop();
    }
  }

  Future<void> _loadReminders() async {
    final uid = ref.read(uidProvider);
    if (uid == null || uid.isEmpty) {
      setState(() {
        _reminderEntries.clear();
        _initialReminderEntries = <_ReminderFormEntry>[];
        _isRemindersLoading = false;
        _reminderLoadError = null;
      });
      return;
    }

    setState(() {
      _isRemindersLoading = true;
      _reminderLoadError = null;
    });

    try {
      final service = ref.read(multipleReminderServiceProvider);
      final reminders =
          await service.getReminders(uid, widget.questId.toString()).first;

      if (!mounted) {
        return;
      }

      setState(() {
        _reminderEntries
          ..clear()
          ..addAll(reminders.map(_ReminderFormEntry.fromReminder));
        _sortReminderEntries();
        _initialReminderEntries = _cloneReminders(_reminderEntries);
        _isRemindersLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _reminderEntries.clear();
        _initialReminderEntries = <_ReminderFormEntry>[];
        _reminderLoadError = 'リマインダーの読み込みに失敗しました';
        _isRemindersLoading = false;
      });
    }
  }

  void _sortReminderEntries() {
    _reminderEntries.sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  List<_ReminderFormEntry> _cloneReminders(List<_ReminderFormEntry> source) {
    return source.map((entry) => entry.copy()).toList();
  }

  Future<void> _handleAddReminder() async {
    final defaultTime =
        _reminderEntries.isNotEmpty
            ? _reminderEntries.last.time
            : const TimeOfDay(hour: 7, minute: 30);
    final picked = await showTimePicker(
      context: context,
      initialTime: defaultTime,
    );

    if (picked == null) {
      return;
    }

    if (!mounted) return;

    final exists = _reminderEntries.any((entry) => entry.time == picked);
    if (exists) {
      FeedbackMessenger.showInfoToast(context, '同じ時刻のリマインダーが既に存在します');
      return;
    }

    setState(() {
      _reminderEntries.add(_ReminderFormEntry(time: picked, enabled: true));
      _sortReminderEntries();
    });
  }

  Future<void> _handleEditReminder(int index) async {
    final current = _reminderEntries[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: current.time,
    );

    if (picked == null || picked == current.time) {
      return;
    }

    if (!mounted) return;

    final hasDuplicate = _reminderEntries.asMap().entries.any(
      (entry) => entry.key != index && entry.value.time == picked,
    );

    if (hasDuplicate) {
      FeedbackMessenger.showInfoToast(context, '同じ時刻のリマインダーが既に存在します');
      return;
    }

    setState(() {
      _reminderEntries[index] = current.copyWith(time: picked);
      _sortReminderEntries();
    });
  }

  void _handleToggleReminder(int index, bool enabled) {
    setState(() {
      _reminderEntries[index] = _reminderEntries[index].copyWith(
        enabled: enabled,
      );
    });
  }

  void _handleRemoveReminder(int index) {
    setState(() {
      _reminderEntries.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalValueController.dispose();
    _contactLinkController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToStep(int step) async {
    if (_reduceMotion) {
      _pageController.jumpToPage(step);
    } else {
      await _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => _DiscardChangesDialog(),
    );
    return shouldLeave ?? false;
  }

  Future<void> _handleBackRequest() async {
    final shouldLeave = await _confirmDiscardChanges();
    if (shouldLeave && mounted) {
      context.pop();
    }
  }

  Future<void> _updateQuest() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      await _goToStep(0);
      return;
    }

    if (_originalQuest == null) return;

    final uid = ref.read(uidProvider);
    if (uid == null || uid.isEmpty) {
      if (!mounted) return;
      FeedbackMessenger.showErrorSnackBar(context, 'ユーザーがサインインしていません。');
      return;
    }

    final updatedQuest =
        _originalQuest!
          ..title = _titleController.text
          ..estimatedMinutes =
              _isTimeGoal ? (int.tryParse(_goalValueController.text) ?? 0) : 0
          ..iconKey = _selectedIconKey;

    await ref.read(questRepositoryProvider).updateQuest(updatedQuest);
    if (!mounted) return;

    final contactLink = _contactLinkController.text.trim();
    final contactRepository = ref.read(contactLinkRepositoryProvider);
    if (contactLink.isNotEmpty) {
      await contactRepository.setLink(updatedQuest.id, contactLink);
      _originalContactLink = contactLink;
    } else {
      await contactRepository.removeLink(updatedQuest.id);
      _originalContactLink = null;
    }
    if (!mounted) return;

    try {
      final reminderService = ref.read(multipleReminderServiceProvider);
      final drafts =
          _reminderEntries
              .map(
                (entry) => ReminderDraft(
                  id: entry.id,
                  time: entry.time,
                  enabled: entry.enabled,
                ),
              )
              .toList();

      await reminderService.saveReminders(
        userId: uid,
        questId: widget.questId.toString(),
        reminders: drafts,
      );
      if (!mounted) return;

      setState(() {
        _initialReminderEntries = _cloneReminders(_reminderEntries);
      });
    } catch (e) {
      if (!mounted) return;
      FeedbackMessenger.showErrorSnackBar(
        context,
        'リマインダーの保存に失敗しました。もう一度お試しください。',
      );
      return;
    }

    FeedbackMessenger.showSuccessToast(context, '習慣を更新しました！');
    context.pop();
  }

  Future<void> _deleteQuest() async {
    if (_originalQuest == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('習慣を削除'),
            content: Text('「${_originalQuest!.title}」を削除しますか？この操作は取り消せません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('削除'),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;
    if (!mounted) return;

    final contactRepo = ref.read(contactLinkRepositoryProvider);
    final questRepo = ref.read(questRepositoryProvider);

    await contactRepo.removeLink(_originalQuest!.id);
    await questRepo.deleteQuest(_originalQuest!.id);

    if (!mounted) return;

    FeedbackMessenger.showSuccessToast(context, '習慣を削除しました');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: tokens.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        final shouldLeave = await _confirmDiscardChanges();
        if (shouldLeave) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: tokens.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Header(onBack: _handleBackRequest, onDelete: _deleteQuest),
                  SizedBox(height: tokens.spacing.lg),
                  _StepIndicator(
                    currentStep: _currentStep,
                    totalSteps: _stepTitles.length,
                    titles: _stepTitles,
                  ),
                  SizedBox(height: tokens.spacing.lg),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const ClampingScrollPhysics(),
                      onPageChanged: (int value) {
                        setState(() {
                          _currentStep = value;
                        });
                      },
                      children: _buildStepPages(tokens),
                    ),
                  ),
                  SizedBox(height: tokens.spacing.lg),
                  _StepperActions(
                    currentStep: _currentStep,
                    totalSteps: _stepTitles.length,
                    onPrevious:
                        _currentStep > 0
                            ? () async => await _goToStep(_currentStep - 1)
                            : null,
                    onNext: () async {
                      if (_isLastStep) {
                        await _updateQuest();
                      } else {
                        await _goToStep(_currentStep + 1);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStepPages(MinqTheme tokens) {
    return <Widget>[
      _StepPage(
        index: 0,
        label: 'ステップ1: 基本情報',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _HabitNameInput(controller: _titleController),
            SizedBox(height: tokens.spacing.xl),
            _IconSelector(
              selectedIconKey: _selectedIconKey,
              onIconSelected: (String iconKey) {
                setState(() {
                  _selectedIconKey = iconKey;
                });
              },
            ),
            SizedBox(height: tokens.spacing.xl),
            _ContactLinkInput(controller: _contactLinkController),
          ],
        ),
      ),
      _StepPage(
        index: 1,
        label: 'ステップ2: 目標と頻度',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _GoalTypeSelector(
              isTimeGoal: _isTimeGoal,
              goalValueController: _goalValueController,
              onGoalTypeChanged: (bool isTimeGoal) {
                setState(() {
                  _isTimeGoal = isTimeGoal;
                });
              },
            ),
            SizedBox(height: tokens.spacing.xl),
            _DaySelector(
              selectedDays: _selectedDays,
              onDaysChanged: (Set<int> days) {
                setState(() {
                  _selectedDays.clear();
                  _selectedDays.addAll(days);
                });
              },
            ),
          ],
        ),
      ),
      _StepPage(
        index: 2,
        label: 'ステップ3: リマインダー',
        child: _ReminderSettings(
          entries: _reminderEntries,
          isLoading: _isRemindersLoading,
          errorMessage: _reminderLoadError,
          onAdd: _handleAddReminder,
          onEdit: _handleEditReminder,
          onToggle: _handleToggleReminder,
          onRemove: _handleRemoveReminder,
          onRetry: _loadReminders,
        ),
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onDelete});

  final VoidCallback onBack;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
        SizedBox(width: tokens.spacing.sm),
        Expanded(
          child: Text(
            '習慣を編集',
            style: tokens.typography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          style: IconButton.styleFrom(foregroundColor: tokens.accentError),
        ),
      ],
    );
  }
}

// Reuse components from create_quest_screen.dart
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.titles,
  });

  final int currentStep;
  final int totalSteps;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        for (int i = 0; i < totalSteps; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= currentStep ? tokens.brandPrimary : tokens.border,
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
            ),
          ),
          if (i < totalSteps - 1) SizedBox(width: tokens.spacing.sm),
        ],
      ],
    );
  }
}

class _StepPage extends StatelessWidget {
  const _StepPage({
    required this.index,
    required this.label,
    required this.child,
  });

  final int index;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tokens.typography.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing.lg),
          child,
        ],
      ),
    );
  }
}

class _StepperActions extends StatelessWidget {
  const _StepperActions({
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    this.onPrevious,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bool isLastStep = currentStep == totalSteps - 1;

    return Row(
      children: [
        if (onPrevious != null) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: onPrevious,
              child: const Text('戻る'),
            ),
          ),
          SizedBox(width: tokens.spacing.md),
        ],
        Expanded(
          flex: onPrevious != null ? 1 : 2,
          child: ElevatedButton(
            onPressed: onNext,
            child: Text(isLastStep ? '更新する' : '次へ'),
          ),
        ),
      ],
    );
  }
}

class _DiscardChangesDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AlertDialog(
      title: const Text('変更を破棄しますか？'),
      content: const Text('保存されていない変更は失われます。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: tokens.accentError),
          child: const Text('破棄'),
        ),
      ],
    );
  }
}

// These components would be shared with create_quest_screen.dart
// For now, we'll create simplified versions

class _HabitNameInput extends StatelessWidget {
  const _HabitNameInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '習慣名',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        TextFormField(
          controller: controller,
          validator:
              (String? value) =>
                  value?.trim().isEmpty == true ? '習慣名を入力してください' : null,
          decoration: InputDecoration(
            hintText: '例: 朝のランニング',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactLinkInput extends StatelessWidget {
  const _ContactLinkInput({required this.controller});

  final TextEditingController controller;

  bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ペアへの連絡先リンク (任意)',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: '例：https://line.me/R/xxxxx',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
            ),
            prefixIcon: const Icon(Icons.link),
          ),
          validator: (String? value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return null;
            return _isValidUrl(trimmed) ? null : '正しいURLを入力してください';
          },
        ),
      ],
    );
  }
}

class _IconSelector extends StatelessWidget {
  const _IconSelector({
    required this.selectedIconKey,
    required this.onIconSelected,
  });

  final String selectedIconKey;
  final ValueChanged<String> onIconSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final icons = questIconCatalog.take(12).toList();
    final selectedDefinition = questIconByKey(selectedIconKey);
    if (selectedDefinition != null &&
        icons.every((definition) => definition.key != selectedDefinition.key)) {
      icons.insert(0, selectedDefinition);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'アイコン',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        Wrap(
          spacing: tokens.spacing.md,
          runSpacing: tokens.spacing.md,
          children:
              icons
                  .map(
                    (definition) => _IconChoice(
                      definition: definition,
                      isSelected: definition.key == selectedIconKey,
                      onSelected: () => onIconSelected(definition.key),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.definition,
    required this.isSelected,
    required this.onSelected,
  });

  final QuestIconDefinition definition;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final backgroundColor =
        isSelected
            ? tokens.brandPrimary.withAlpha((255 * 0.12).round())
            : tokens.surface;
    final borderColor = isSelected ? tokens.brandPrimary : tokens.border;
    final iconColor = isSelected ? tokens.brandPrimary : tokens.textPrimary;
    final textColor = isSelected ? tokens.brandPrimary : tokens.textMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      label: definition.label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(tokens.radius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 108,
            padding: EdgeInsets.symmetric(
              vertical: tokens.spacing.md,
              horizontal: tokens.spacing.md,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: tokens.brandPrimary.withAlpha(
                            (255 * 0.2).round(),
                          ),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                      : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  definition.icon,
                  color: iconColor,
                  size: tokens.spacing.xl,
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  definition.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.typography.caption.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalTypeSelector extends StatelessWidget {
  const _GoalTypeSelector({
    required this.isTimeGoal,
    required this.goalValueController,
    required this.onGoalTypeChanged,
  });

  final bool isTimeGoal;
  final TextEditingController goalValueController;
  final ValueChanged<bool> onGoalTypeChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '目標値',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        TextFormField(
          controller: goalValueController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '10',
            suffixText: '分',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
            ),
          ),
        ),
      ],
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.selectedDays, required this.onDaysChanged});

  final Set<int> selectedDays;
  final ValueChanged<Set<int>> onDaysChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const List<String> days = <String>['月', '火', '水', '木', '金', '土', '日'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '実行する曜日',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        Wrap(
          spacing: tokens.spacing.sm,
          children: List.generate(7, (index) {
            final isSelected = selectedDays.contains(index);
            return GestureDetector(
              onTap: () {
                final newDays = Set<int>.from(selectedDays);
                if (isSelected) {
                  newDays.remove(index);
                } else {
                  newDays.add(index);
                }
                onDaysChanged(newDays);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? tokens.brandPrimary : tokens.surface,
                  border: Border.all(color: tokens.border),
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: tokens.typography.body.copyWith(
                      color: isSelected ? Colors.white : tokens.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ReminderSettings extends StatelessWidget {
  const _ReminderSettings({
    required this.entries,
    required this.isLoading,
    required this.errorMessage,
    required this.onAdd,
    required this.onEdit,
    required this.onToggle,
    required this.onRemove,
    this.onRetry,
  });

  final List<_ReminderFormEntry> entries;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onAdd;
  final Future<void> Function(int index) onEdit;
  final void Function(int index, bool enabled) onToggle;
  final void Function(int index) onRemove;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;
    final isEmptyState = !isLoading && entries.isEmpty && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'リマインダー',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.md),
        if (hasError)
          Card(
            color: tokens.accentError.withAlpha((255 * 0.08).round()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              side: BorderSide(
                color: tokens.accentError.withAlpha((255 * 0.4).round()),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errorMessage!,
                    style: tokens.typography.body.copyWith(
                      color: tokens.accentError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (onRetry != null) ...[
                    SizedBox(height: tokens.spacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async => await onRetry!(),
                        style: TextButton.styleFrom(
                          foregroundColor: tokens.accentError,
                        ),
                        child: const Text('再読み込み'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        if (isLoading)
          Card(
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.lg,
                vertical: tokens.spacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: tokens.spacing.lg,
                    height: tokens.spacing.lg,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: tokens.spacing.md),
                  Text('リマインダーを読み込み中…', style: tokens.typography.body),
                ],
              ),
            ),
          )
        else if (isEmptyState)
          Card(
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'まだリマインダーはありません',
                    style: tokens.typography.h5.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.sm),
                  Text(
                    '朝や夜など複数の時間を登録すると、習慣の記録を忘れずに続けられます。',
                    style: tokens.typography.body.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (entries.isNotEmpty)
          Column(
            children:
                entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reminder = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          index == entries.length - 1 ? 0 : tokens.spacing.md,
                    ),
                    child: _ReminderListTile(
                      entry: reminder,
                      onTap: () async => onEdit(index),
                      onToggle: (value) => onToggle(index, value),
                      onRemove: () => onRemove(index),
                    ),
                  );
                }).toList(),
          ),
        SizedBox(height: tokens.spacing.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () async => await onAdd(),
            icon: const Icon(Icons.add),
            label: const Text('時間を追加'),
            style: OutlinedButton.styleFrom(
              foregroundColor: tokens.brandPrimary,
              side: BorderSide(color: tokens.brandPrimary),
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.lg,
                vertical: tokens.spacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radius.lg),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderListTile extends StatelessWidget {
  const _ReminderListTile({
    required this.entry,
    required this.onTap,
    required this.onToggle,
    required this.onRemove,
  });

  final _ReminderFormEntry entry;
  final Future<void> Function() onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isEnabled = entry.enabled;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.xs,
        ),
        onTap: () async => await onTap(),
        leading: Icon(
          isEnabled
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined,
          color: isEnabled ? tokens.brandPrimary : tokens.textMuted,
        ),
        title: Text(
          entry.time.format(context),
          style: tokens.typography.h4.copyWith(
            color: isEnabled ? tokens.textPrimary : tokens.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'タップして時間を編集',
          style: tokens.typography.caption.copyWith(color: tokens.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: isEnabled, onChanged: onToggle),
            IconButton(
              tooltip: '削除',
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove,
              style: IconButton.styleFrom(foregroundColor: tokens.accentError),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderFormEntry {
  _ReminderFormEntry({this.id, required this.time, required this.enabled});

  final String? id;
  final TimeOfDay time;
  final bool enabled;

  _ReminderFormEntry copy() =>
      _ReminderFormEntry(id: id, time: time, enabled: enabled);

  _ReminderFormEntry copyWith({String? id, TimeOfDay? time, bool? enabled}) {
    return _ReminderFormEntry(
      id: id ?? this.id,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
    );
  }

  static _ReminderFormEntry fromReminder(Reminder reminder) =>
      _ReminderFormEntry(
        id: reminder.id,
        time: reminder.time,
        enabled: reminder.enabled,
      );
}

class _ReminderFormEntryEquality implements Equality<_ReminderFormEntry> {
  const _ReminderFormEntryEquality();

  @override
  bool equals(_ReminderFormEntry e1, _ReminderFormEntry e2) {
    return e1.id == e2.id && e1.time == e2.time && e1.enabled == e2.enabled;
  }

  @override
  int hash(_ReminderFormEntry e) =>
      Object.hash(e.id, e.time.hour, e.time.minute, e.enabled);

  @override
  bool isValidKey(Object? o) => o is _ReminderFormEntry;
}
