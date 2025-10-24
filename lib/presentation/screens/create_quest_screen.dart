import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class CreateQuestScreen extends ConsumerStatefulWidget {
  const CreateQuestScreen({super.key});

  @override
  ConsumerState<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends ConsumerState<CreateQuestScreen> {
  static const List<String> _stepTitles = <String>['基本情報', '目標と頻度', 'リマインダー'];
  static const Set<int> _defaultSelectedDays = <int>{0, 1, 2, 3, 6};

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _goalValueController = TextEditingController(text: '10');
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
  bool _isVoiceListening = false;

  bool get _reduceMotion =>
      WidgetsBinding
          .instance
          .platformDispatcher
          .accessibilityFeatures
          .disableAnimations;

  bool get _isLastStep => _currentStep == _stepTitles.length - 1;

  bool get _hasUnsavedChanges {
    return _titleController.text.trim().isNotEmpty ||
        _selectedIconKey != 'spa' ||
        _selectedColor != _defaultColor ||
        _isTimeGoal != true ||
        !_setEquality.equals(_selectedDays, _defaultSelectedDays) ||
        _reminderTime != const TimeOfDay(hour: 7, minute: 0) ||
        _isReminderOn != true ||
        (_isTimeGoal && _goalValueController.text != '10') ||
        _contactLinkController.text.trim().isNotEmpty;
  }

  bool get _canSubmit => _titleController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _goalValueController.addListener(_onFormChanged);
    _contactLinkController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_onFormChanged)
      ..dispose();
    _goalValueController
      ..removeListener(_onFormChanged)
      ..dispose();
    _contactLinkController
      ..removeListener(_onFormChanged)
      ..dispose();
    final speech = ref.read(speechInputServiceProvider);
    if (speech.isListening) {
      speech.stop();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceInput() async {
    final speech = ref.read(speechInputServiceProvider);
    final currentContext = context;
    if (_isVoiceListening) {
      await speech.stop();
      if (mounted) setState(() => _isVoiceListening = false);
      return;
    }

    try {
      final available = await speech.ensureInitialized();
      if (!mounted) return;

      if (!available) {
        FeedbackMessenger.showErrorSnackBar(
          context,
          '音声入力を使用できませんでした。マイクの権限を確認してください。',
        );
        return;
      }
      setState(() => _isVoiceListening = true);
      await speech.startListening(
        onResult: (text) {
          if (!mounted) return;
          _titleController.text = text;
          _titleController.selection = TextSelection.fromPosition(
            TextPosition(offset: _titleController.text.length),
          );
        },
        onFinalResult: () {
          if (mounted) setState(() => _isVoiceListening = false);
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isVoiceListening = false);
      FeedbackMessenger.showErrorSnackBar(context, '音声入力の開始に失敗しました。');
    }
  }

  void _onFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _goToStep(int step) async {
    if (step < 0 || step >= _stepTitles.length) {
      return;
    }
    setState(() {
      _currentStep = step;
    });
    await _pageController.animateToPage(
      step,
      duration:
          _reduceMotion ? Duration.zero : const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final tokens = context.tokens;
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('変更を破棄しますか？'),
          content: const Text('入力した内容は保存されません。画面を閉じてもよろしいですか？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: tokens.brandPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('破棄する'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _handleBackRequest() async {
    final shouldLeave = await _confirmDiscardChanges();
    if (!mounted) return;
    if (shouldLeave) {
      context.pop();
    }
  }

  Future<void> _saveQuest() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      await _goToStep(0);
      return;
    }

    final uid = ref.read(uidProvider);
    if (uid == null || uid.isEmpty) {
      if (!mounted) return;
      FeedbackMessenger.showErrorSnackBar(context, 'ユーザーがサインインしていません。');
      return;
    }

    final newQuest =
        Quest()
          ..owner = uid
          ..title = _titleController.text
          ..category = ''
          ..estimatedMinutes =
              _isTimeGoal ? (int.tryParse(_goalValueController.text) ?? 0) : 0
          ..iconKey = _selectedIconKey
          ..status = QuestStatus.active
          ..createdAt = DateTime.now();

    await ref.read(questRepositoryProvider).addQuest(newQuest);
    if (!mounted) return;

    final contactLink = _contactLinkController.text.trim();
    final contactRepository = ref.read(contactLinkRepositoryProvider);
    if (contactLink.isNotEmpty) {
      await contactRepository.setLink(newQuest.id, contactLink);
    } else {
      await contactRepository.removeLink(newQuest.id);
    }
    if (!mounted) return;

    // Schedule notifications if reminder is enabled
    if (_isReminderOn) {
      try {
        final notificationService = ref.read(notificationServiceProvider);
        final timeString =
            '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';

        // Update user's notification times to include this quest's reminder
        final userRepository = ref.read(userRepositoryProvider);
        final user = await userRepository.getUserById(uid);
        if (user != null) {
          final updatedTimes = List<String>.from(user.notificationTimes);
          if (!updatedTimes.contains(timeString)) {
            updatedTimes.add(timeString);
            user.notificationTimes = updatedTimes;
            await userRepository.saveLocalUser(user);
            if (!mounted) return;

            // Reschedule all notifications
            await notificationService.scheduleRecurringReminders(updatedTimes);
          }
        }
      } catch (e) {
        debugPrint('Failed to schedule notification: $e');
        // Don't fail quest creation if notification scheduling fails
      }
    }

    if (!mounted) return;
    FeedbackMessenger.showSuccessToast(context, '新しい習慣を作成しました！');
    // クエスト詳細画面に遷移
    ref.read(navigationUseCaseProvider).goToQuestDetail(newQuest.id);
  }

  List<Widget> _buildStepPages(MinqTheme tokens) {
    return <Widget>[
      _StepPage(
        index: 0,
        label: 'ステップ1: 基本情報',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _HabitNameInput(
              controller: _titleController,
              onVoiceInputTap: _toggleVoiceInput,
              isListening: _isVoiceListening,
            ),
            SizedBox(height: tokens.spacing.lg),
            _IconAndColorPicker(
              selectedIcon: _selectedIconKey,
              selectedColor: _selectedColor,
              onIconSelected: (String icon) {
                setState(() => _selectedIconKey = icon);
              },
              onColorSelected: (Color color) {
                setState(() => _selectedColor = color);
              },
            ),
            SizedBox(height: tokens.spacing.lg),
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
            _GoalSetter(
              isTimeGoal: _isTimeGoal,
              goalValueController: _goalValueController,
              onGoalTypeChanged: (bool isTime) {
                setState(() => _isTimeGoal = isTime);
              },
            ),
            SizedBox(height: tokens.spacing.lg),
            _FrequencyPicker(
              selectedDays: _selectedDays,
              onDaySelected: (int dayIndex) {
                setState(() {
                  if (_selectedDays.contains(dayIndex)) {
                    _selectedDays.remove(dayIndex);
                  } else {
                    _selectedDays.add(dayIndex);
                  }
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
            _ReminderSetter(
              isReminderOn: _isReminderOn,
              reminderTime: _reminderTime,
              onToggle: (bool isOn) {
                setState(() => _isReminderOn = isOn);
              },
              onTimeTap: () async {
                final newTime = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                );
                if (newTime != null) {
                  setState(() => _reminderTime = newTime);
                }
              },
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final shouldPop = await _confirmDiscardChanges();
        if (!mounted) return;
        if (shouldPop) {
          context.pop();
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
                  _Header(onBack: _handleBackRequest),
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
                    canSubmit: _canSubmit,
                    onBack:
                        _currentStep == 0
                            ? null
                            : () => _goToStep(_currentStep - 1),
                    onNext: () async {
                      if (_isLastStep) {
                        await _saveQuest();
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
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
          tooltip: '前の画面に戻る',
        ),
        Text(
          '新しい習慣を追加',
          style: tokens.typography.h4.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          container: true,
          liveRegion: true,
          label: 'ステップ${currentStep + 1}/$totalSteps: ${titles[currentStep]}',
          child: Text(
            'ステップ${currentStep + 1} / $totalSteps',
            style: tokens.typography.caption.copyWith(color: tokens.textMuted),
          ),
        ),
        SizedBox(height: tokens.spacing.sm),
        Row(
          children: List<Widget>.generate(totalSteps, (int index) {
            final bool isActive = index <= currentStep;
            final Color indicatorColor =
                isActive ? tokens.brandPrimary : tokens.border.withAlpha((255 * 0.6).round());
            final bool reduceMotion =
                MediaQuery.maybeOf(context)?.disableAnimations ?? false;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.spacing.xs),
                child: AnimatedContainer(
                  duration:
                      reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                  height: tokens.spacing.sm,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
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

class _StepperActions extends StatelessWidget {
  const _StepperActions({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
    required this.canSubmit,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final Future<void> Function() onNext;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bool isLastStep = currentStep == totalSteps - 1;

    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton(onPressed: onBack, child: const Text('戻る')),
        ),
        SizedBox(width: tokens.spacing.md),
        Expanded(
          child: FilledButton(
            onPressed: isLastStep && !canSubmit ? null : () => onNext(),
            child: Text(isLastStep ? '習慣を保存する' : '次へ進む'),
          ),
        ),
      ],
    );
  }
}

class _StepPage extends StatelessWidget {
  const _StepPage({
    required this.child,
    required this.label,
    required this.index,
  });

  final Widget child;
  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      container: true,
      sortKey: OrdinalSortKey(index.toDouble()),
      label: label,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: tokens.spacing.lg),
        child: child,
      ),
    );
  }
}

class _HabitNameInput extends StatelessWidget {
  const _HabitNameInput({
    required this.controller,
    this.onVoiceInputTap,
    this.isListening = false,
  });

  final TextEditingController controller;
  final VoidCallback? onVoiceInputTap;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '習慣の名前',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        TextFormField(
          controller: controller,
          validator:
              (String? value) =>
                  (value == null || value.trim().isEmpty)
                      ? '名前を入力してください'
                      : null,
          decoration: InputDecoration(
            hintText: '例：毎朝瞑想する',
            prefixIcon: const Icon(Icons.edit),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius.xl),
              borderSide: BorderSide.none,
            ),
            suffixIcon:
                onVoiceInputTap == null
                    ? null
                    : Tooltip(
                      message: isListening ? '音声入力を停止' : '音声入力',
                      child: Semantics(
                        button: true,
                        toggled: isListening,
                        label: '音声入力',
                        child: IconButton(
                          icon: Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            color:
                                isListening
                                    ? tokens.brandPrimary
                                    : tokens.textMuted,
                          ),
                          onPressed: onVoiceInputTap,
                        ),
                      ),
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
      children: <Widget>[
        Text(
          '連絡先リンク (任意)',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: '例：https://line.me/R/xxxxx',
            prefixIcon: const Icon(Icons.link),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius.xl),
              borderSide: BorderSide.none,
            ),
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

class _IconAndColorPicker extends StatelessWidget {
  const _IconAndColorPicker({
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconSelected,
    required this.onColorSelected,
  });

  final String selectedIcon;
  final Color selectedColor;
  final ValueChanged<String> onIconSelected;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final List<Color> colors = <Color>[
      tokens.joyAccent,
      tokens.encouragement,
      tokens.serenity,
      tokens.warmth,
      tokens.brandPrimary,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'アイコンと色',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                final String? iconKey = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => const _IconPickerDialog(),
                );
                if (iconKey != null) {
                  onIconSelected(iconKey);
                }
              },
              child: Container(
                width: tokens.spacing.xxl,
                height: tokens.spacing.xxl,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  iconDataForKey(selectedIcon),
                  color: Colors.white,
                  size: tokens.spacing.xl,
                ),
              ),
            ),
            SizedBox(width: tokens.spacing.lg),
            Expanded(
              child: Wrap(
                spacing: tokens.spacing.md,
                runSpacing: tokens.spacing.sm,
                children:
                    colors
                        .map(
                          (Color color) => GestureDetector(
                            onTap: () => onColorSelected(color),
                            child: Semantics(
                              button: true,
                              selected: selectedColor == color,
                              label:
                                  '色を${color == selectedColor ? '選択済み' : '選択する'}',
                              child: Container(
                                width: tokens.spacing.lg,
                                height: tokens.spacing.lg,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border:
                                      selectedColor == color
                                          ? Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          )
                                          : null,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoalSetter extends StatelessWidget {
  const _GoalSetter({
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
      children: <Widget>[
        Text(
          '目標タイプ',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        SegmentedButton<bool>(
          segments: const <ButtonSegment<bool>>[
            ButtonSegment<bool>(value: true, label: Text('時間で管理する')),
            ButtonSegment<bool>(value: false, label: Text('回数で管理する')),
          ],
          selected: <bool>{isTimeGoal},
          onSelectionChanged: (Set<bool> selection) {
            if (selection.isNotEmpty) {
              onGoalTypeChanged(selection.first);
            }
          },
        ),
        SizedBox(height: tokens.spacing.md),
        Text('目標値', style: tokens.typography.body.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing.sm),
        TextFormField(
          controller: goalValueController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: isTimeGoal ? '分' : '回',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(tokens.radius.xl)),
          ),
        ),
      ],
    );
  }
}

class _FrequencyPicker extends StatelessWidget {
  const _FrequencyPicker({
    required this.selectedDays,
    required this.onDaySelected,
  });

  final Set<int> selectedDays;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const List<String> days = <String>['月', '火', '水', '木', '金', '土', '日'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('頻度', style: tokens.typography.body.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing.sm),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radius.xl)),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing.md),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: tokens.spacing.md,
              runSpacing: tokens.spacing.sm,
              children: List<Widget>.generate(days.length, (int index) {
                final bool isSelected = selectedDays.contains(index);
                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: '${days[index]}曜日を${isSelected ? '解除' : '選択'}',
                  child: ChoiceChip(
                    label: Text(days[index]),
                    selected: isSelected,
                    onSelected: (_) => onDaySelected(index),
                    showCheckmark: false,
                    shape: const CircleBorder(),
                    labelStyle: tokens.typography.body.copyWith(
                      color: isSelected ? Colors.white : tokens.textPrimary,
                    ),
                    selectedColor: tokens.brandPrimary,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderSetter extends StatelessWidget {
  const _ReminderSetter({
    required this.isReminderOn,
    required this.reminderTime,
    required this.onToggle,
    required this.onTimeTap,
  });

  final bool isReminderOn;
  final TimeOfDay reminderTime;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'リマインダー',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radius.xl)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.lg,
              vertical: tokens.spacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Semantics(
                  button: true,
                  label: 'リマインダー時刻を変更',
                  child: GestureDetector(
                    onTap: onTimeTap,
                    child: Text(
                      reminderTime.format(context),
                      style: tokens.typography.h5.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                ),
                Switch(value: isReminderOn, onChanged: onToggle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IconPickerDialog extends StatelessWidget {
  const _IconPickerDialog();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AlertDialog(
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
          itemBuilder: (BuildContext context, int index) {
            final definition = questIconCatalog[index];
            return Semantics(
              button: true,
              label: definition.label,
              child: IconButton(
                tooltip: definition.label,
                onPressed: () => Navigator.of(context).pop(definition.key),
                icon: Icon(definition.icon, color: tokens.textPrimary),
              ),
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
