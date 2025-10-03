import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final SetEquality<int> _setEquality = const SetEquality<int>();

  String _selectedIconKey = 'spa';
  static const Color _defaultColor = Color(0xFF37CBFA);

  Color _selectedColor = _defaultColor;
  bool _isTimeGoal = true;
  final Set<int> _selectedDays = <int>{..._defaultSelectedDays};
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);
  bool _isReminderOn = true;
  int _currentStep = 0;

  Quest? _originalQuest;
  bool _isLoading = true;
  String? _originalContactLink;

  bool get _reduceMotion =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;

  bool get _isLastStep => _currentStep == _stepTitles.length - 1;

  bool get _hasUnsavedChanges {
    if (_originalQuest == null) return false;
    
    return _titleController.text.trim() != _originalQuest!.title ||
        _selectedIconKey != _originalQuest!.iconKey ||
        _isTimeGoal != (_originalQuest!.estimatedMinutes > 0) ||
        (_isTimeGoal &&
            int.tryParse(_goalValueController.text) !=
                _originalQuest!.estimatedMinutes) ||
        _contactLinkController.text.trim() !=
            (_originalContactLink ?? '');
  }

  @override
  void initState() {
    super.initState();
    _loadQuest();
    _contactLinkController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadQuest() async {
    try {
      final quest = await ref.read(questByIdProvider(widget.questId).future);
      if (quest != null && mounted) {
        final link =
            await ref.read(contactLinkRepositoryProvider).getLink(widget.questId);
        setState(() {
          _originalQuest = quest;
          _titleController.text = quest.title;
          _selectedIconKey = quest.iconKey ?? 'default';
          _isTimeGoal = quest.estimatedMinutes > 0;
          _goalValueController.text = quest.estimatedMinutes > 0
              ? quest.estimatedMinutes.toString()
              : '10';
          _originalContactLink = link;
          _contactLinkController.text = link ?? '';
          _isLoading = false;
        });
      } else if (mounted) {
        FeedbackMessenger.showErrorSnackBar(
          context,
          'クエストが見つかりませんでした。',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(
          context,
          'クエストの読み込みに失敗しました。',
        );
        context.pop();
      }
    }
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
      FeedbackMessenger.showErrorSnackBar(
        context,
        'ユーザーがサインインしていません。',
      );
      return;
    }

    final updatedQuest = _originalQuest!
      ..title = _titleController.text
      ..estimatedMinutes =
          _isTimeGoal ? (int.tryParse(_goalValueController.text) ?? 0) : 0
      ..iconKey = _selectedIconKey;

    await ref.read(questRepositoryProvider).updateQuest(updatedQuest);

    final contactLink = _contactLinkController.text.trim();
    final contactRepository = ref.read(contactLinkRepositoryProvider);
    if (contactLink.isNotEmpty) {
      await contactRepository.setLink(updatedQuest.id, contactLink);
      _originalContactLink = contactLink;
    } else {
      await contactRepository.removeLink(updatedQuest.id);
      _originalContactLink = null;
    }

    // Update notifications if reminder settings changed
    if (_isReminderOn) {
      try {
        final notificationService = ref.read(notificationServiceProvider);
        final timeString = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';
        
        final userRepository = ref.read(userRepositoryProvider);
        final user = await userRepository.getUserById(uid);
        if (user != null) {
          final updatedTimes = List<String>.from(user.notificationTimes);
          if (!updatedTimes.contains(timeString)) {
            updatedTimes.add(timeString);
            user.notificationTimes = updatedTimes;
            await userRepository.saveLocalUser(user);
            
            // Reschedule all notifications
            await notificationService.scheduleRecurringReminders(updatedTimes);
          }
        }
      } catch (e) {
        debugPrint('Failed to update notification: $e');
      }
    }

    if (mounted) {
      FeedbackMessenger.showSuccessToast(
        context,
        '習慣を更新しました！',
      );
      context.pop();
    }
  }

  Future<void> _deleteQuest() async {
    if (_originalQuest == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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

    if (shouldDelete == true) {
      await ref
          .read(contactLinkRepositoryProvider)
          .removeLink(_originalQuest!.id);
      await ref.read(questRepositoryProvider).deleteQuest(_originalQuest!.id);

      if (mounted) {
        FeedbackMessenger.showSuccessToast(
          context,
          '習慣を削除しました',
        );
        context.pop();
      }
    }
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
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final shouldLeave = await _confirmDiscardChanges();
        if (shouldLeave && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: tokens.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Header(
                    onBack: _handleBackRequest,
                    onDelete: _deleteQuest,
                  ),
                  SizedBox(height: tokens.spacing(4)),
                  _StepIndicator(
                    currentStep: _currentStep,
                    totalSteps: _stepTitles.length,
                    titles: _stepTitles,
                  ),
                  SizedBox(height: tokens.spacing(4)),
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
                  SizedBox(height: tokens.spacing(4)),
                  _StepperActions(
                    currentStep: _currentStep,
                    totalSteps: _stepTitles.length,
                    onPrevious: _currentStep > 0
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
            SizedBox(height: tokens.spacing(6)),
            _IconSelector(
              selectedIconKey: _selectedIconKey,
              onIconSelected: (String iconKey) {
                setState(() {
                  _selectedIconKey = iconKey;
                });
              },
            ),
            SizedBox(height: tokens.spacing(6)),
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
            SizedBox(height: tokens.spacing(6)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ReminderSettings(
              isReminderOn: _isReminderOn,
              reminderTime: _reminderTime,
              onReminderToggled: (bool isOn) {
                setState(() {
                  _isReminderOn = isOn;
                });
              },
              onTimeChanged: (TimeOfDay time) {
                setState(() {
                  _reminderTime = time;
                });
              },
            ),
          ],
        ),
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onBack,
    required this.onDelete,
  });

  final VoidCallback onBack;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        SizedBox(width: tokens.spacing(2)),
        Expanded(
          child: Text(
            '習慣を編集',
            style: tokens.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          style: IconButton.styleFrom(
            foregroundColor: tokens.accentError,
          ),
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
                borderRadius: tokens.cornerSmall(),
              ),
            ),
          ),
          if (i < totalSteps - 1) SizedBox(width: tokens.spacing(2)),
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
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing(4)),
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
          SizedBox(width: tokens.spacing(3)),
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
        Text('習慣名', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing(2)),
        TextFormField(
          controller: controller,
          validator: (String? value) =>
              value?.trim().isEmpty == true ? '習慣名を入力してください' : null,
          decoration: InputDecoration(
            hintText: '例: 朝のランニング',
            border: OutlineInputBorder(borderRadius: tokens.cornerLarge()),
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
          style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing(2)),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: '例：https://line.me/R/xxxxx',
            border: OutlineInputBorder(borderRadius: tokens.cornerLarge()),
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
    final List<String> iconKeys = ['spa', 'fitness_center', 'book', 'music_note', 'palette'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('アイコン', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing(2)),
        Wrap(
          spacing: tokens.spacing(2),
          children: iconKeys.map((iconKey) {
            final isSelected = iconKey == selectedIconKey;
            return GestureDetector(
              onTap: () => onIconSelected(iconKey),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? tokens.brandPrimary : tokens.surface,
                  border: Border.all(color: tokens.border),
                  borderRadius: tokens.cornerMedium(),
                ),
                child: Icon(
                  iconDataForKey(iconKey),
                  color: isSelected ? Colors.white : tokens.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
        Text('目標値', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing(2)),
        TextFormField(
          controller: goalValueController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '10',
            suffixText: '分',
            border: OutlineInputBorder(borderRadius: tokens.cornerLarge()),
          ),
        ),
      ],
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.selectedDays,
    required this.onDaysChanged,
  });

  final Set<int> selectedDays;
  final ValueChanged<Set<int>> onDaysChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const List<String> days = <String>['月', '火', '水', '木', '金', '土', '日'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('実行する曜日', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing(2)),
        Wrap(
          spacing: tokens.spacing(2),
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
                  borderRadius: tokens.cornerMedium(),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: tokens.bodyMedium.copyWith(
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
    required this.isReminderOn,
    required this.reminderTime,
    required this.onReminderToggled,
    required this.onTimeChanged,
  });

  final bool isReminderOn;
  final TimeOfDay reminderTime;
  final ValueChanged<bool> onReminderToggled;
  final ValueChanged<TimeOfDay> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('リマインダー', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing(2)),
        SwitchListTile(
          title: const Text('リマインダーを有効にする'),
          value: isReminderOn,
          onChanged: onReminderToggled,
        ),
        if (isReminderOn) ...[
          SizedBox(height: tokens.spacing(2)),
          ListTile(
            title: const Text('通知時刻'),
            subtitle: Text('${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: reminderTime,
              );
              if (time != null) {
                onTimeChanged(time);
              }
            },
          ),
        ],
      ],
    );
  }
}