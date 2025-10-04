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

class CreateQuestScreen extends ConsumerStatefulWidget {
  const CreateQuestScreen({super.key});

  @override
  ConsumerState<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends ConsumerState<CreateQuestScreen> {
  static const List<String> _stepTitles = <String>['基本惁E��', '目標と頻度', 'リマインダー'];
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
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;

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
    if (_isVoiceListening) {
      await speech.stop();
      if (mounted) setState(() => _isVoiceListening = false);
      return;
    }

    try {
      final available = await speech.ensureInitialized();
      if (!available) {
        if (mounted) {
          FeedbackMessenger.showErrorSnackBar(
            context,
            '音声入力を使用できませんでした。�Eイクの権限を確認してください、E,
          );
        }
        return;
      }
      if (mounted) setState(() => _isVoiceListening = true);
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
      if (mounted) {
        setState(() => _isVoiceListening = false);
        FeedbackMessenger.showErrorSnackBar(
          context,
          '音声入力�E開始に失敗しました、E,
        );
      }
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
      duration: _reduceMotion ? Duration.zero : const Duration(milliseconds: 260),
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
          title: const Text('変更を破棁E��ますか�E�E),
          content: const Text('入力した�E容は保存されません。画面を閉じてもよろしぁE��すか�E�E),
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
              child: const Text('破棁E��めE),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _handleBackRequest() async {
    final shouldLeave = await _confirmDiscardChanges();
    if (shouldLeave && mounted) {
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
      FeedbackMessenger.showErrorSnackBar(
        context,
        'ユーザーがサインインしてぁE��せん、E,
      );
      return;
    }

    final newQuest = Quest()
      ..owner = uid
      ..title = _titleController.text
      ..category = ''
      ..estimatedMinutes =
          _isTimeGoal ? (int.tryParse(_goalValueController.text) ?? 0) : 0
      ..iconKey = _selectedIconKey
      ..status = QuestStatus.active
      ..createdAt = DateTime.now();

    await ref.read(questRepositoryProvider).addQuest(newQuest);

    final contactLink = _contactLinkController.text.trim();
    final contactRepository = ref.read(contactLinkRepositoryProvider);
    if (contactLink.isNotEmpty) {
      await contactRepository.setLink(newQuest.id, contactLink);
    } else {
      await contactRepository.removeLink(newQuest.id);
    }

    // Schedule notifications if reminder is enabled
    if (_isReminderOn) {
      try {
        final notificationService = ref.read(notificationServiceProvider);
        final timeString = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';
        
        // Update user's notification times to include this quest's reminder
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
        debugPrint('Failed to schedule notification: $e');
        // Don't fail quest creation if notification scheduling fails
      }
    }

    if (mounted) {
      FeedbackMessenger.showSuccessToast(
        context,
        '新しい習�Eを作�Eしました�E�E,
      );
      context.pop();
    }
  }

  List<Widget> _buildStepPages(MinqTheme tokens) {
    return <Widget>[
      _StepPage(
        index: 0,
        label: 'スチE��チE: 基本惁E��',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _HabitNameInput(
              controller: _titleController,
              onVoiceInputTap: _toggleVoiceInput,
              isListening: _isVoiceListening,
            ),
            SizedBox(height: tokens.spacing(4)),
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
            SizedBox(height: tokens.spacing(4)),
            _ContactLinkInput(controller: _contactLinkController),
          ],
        ),
      ),
      _StepPage(
        index: 1,
        label: 'スチE��チE: 目標と頻度',
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
            SizedBox(height: tokens.spacing(4)),
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
        label: 'スチE��チE: リマインダー',
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
                  _Header(onBack: _handleBackRequest),
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
                    canSubmit: _canSubmit,
                    onBack: _currentStep == 0 ? null : () => _goToStep(_currentStep - 1),
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
          tooltip: '前�E画面に戻めE,
        ),
        Text(
          '新しい習�Eを追加',
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
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
          label: 'スチE��チE{currentStep + 1}/$totalSteps: ${titles[currentStep]}',
          child: Text(
            'スチE��チE{currentStep + 1} / $totalSteps',
            style: tokens.labelSmall.copyWith(color: tokens.textMuted),
          ),
        ),
        SizedBox(height: tokens.spacing(2)),
        Row(
          children: List<Widget>.generate(totalSteps, (int index) {
            final bool isActive = index <= currentStep;
            final Color indicatorColor =
                isActive ? tokens.brandPrimary : tokens.border.withValues(alpha: 0.6);
            final bool reduceMotion =
                MediaQuery.maybeOf(context)?.disableAnimations ?? false;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.spacing(1)),
                child: AnimatedContainer(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  height: tokens.spacing(2),
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: tokens.cornerLarge(),
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
          child: OutlinedButton(
            onPressed: onBack,
            child: const Text('戻めE),
          ),
        ),
        SizedBox(width: tokens.spacing(3)),
        Expanded(
          child: FilledButton(
            onPressed: isLastStep && !canSubmit ? null : () => onNext(),
            child: Text(isLastStep ? '習�Eを保存すめE : '次へ進む'),
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
        padding: EdgeInsets.only(bottom: tokens.spacing(4)),
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
          '習�Eの名前',
          style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing(2)),
        TextFormField(
          controller: controller,
          validator: (String? value) =>
              (value == null || value.trim().isEmpty) ? '名前を�E力してください' : null,
          decoration: InputDecoration(
            hintText: '例：毎朝瞑想する',
            prefixIcon: const Icon(Icons.edit),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: tokens.cornerXLarge(),
              borderSide: BorderSide.none,
            ),
            suffixIcon: onVoiceInputTap == null
                ? null
                : Tooltip(
                    message: isListening ? '音声入力を停止' : '音声入劁E,
                    child: Semantics(
                      button: true,
                      toggled: isListening,
                      label: '音声入劁E,
                      child: IconButton(
                        icon: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color:
                              isListening ? tokens.brandPrimary : tokens.textMuted,
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
          '連絡先リンク (任愁E',
          style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing(2)),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: '例：https://line.me/R/xxxxx',
            prefixIcon: const Icon(Icons.link),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: tokens.cornerXLarge(),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (String? value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return null;
            return _isValidUrl(trimmed) ? null : '正しいURLを�E力してください';
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
          style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing(2)),
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
                width: tokens.spacing(14),
                height: tokens.spacing(14),
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  boxShadow: tokens.shadowSoft,
                ),
                child: Icon(iconDataForKey(selectedIcon), color: Colors.white, size: tokens.spacing(8)),
              ),
            ),
            SizedBox(width: tokens.spacing(4)),
            Expanded(
              child: Wrap(
                spacing: tokens.spacing(3),
                runSpacing: tokens.spacing(2),
                children: colors
                    .map(
                      (Color color) => GestureDetector(
                        onTap: () => onColorSelected(color),
                        child: Semantics(
                          button: true,
                          selected: selectedColor == color,
                          label: '色めE{color == selectedColor ? '選択済み' : '選択すめE}',
                          child: Container(
                            width: tokens.spacing(7),
                            height: tokens.spacing(7),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: selectedColor == color
                                  ? Border.all(color: Colors.white, width: 2)
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
        Text('目標タイチE, style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing(2)),
        SegmentedButton<bool>(
          segments: const <ButtonSegment<bool>>[
            ButtonSegment<bool>(value: true, label: Text('時間で管琁E��めE)),
            ButtonSegment<bool>(value: false, label: Text('回数で管琁E��めE)),
          ],
          selected: <bool>{isTimeGoal},
          onSelectionChanged: (Set<bool> selection) {
            if (selection.isNotEmpty) {
              onGoalTypeChanged(selection.first);
            }
          },
        ),
        SizedBox(height: tokens.spacing(3)),
        Text('目標値', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing(2)),
        TextFormField(
          controller: goalValueController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: isTimeGoal ? '刁E : '囁E,
            border: OutlineInputBorder(borderRadius: tokens.cornerXLarge()),
          ),
        ),
      ],
    );
  }
}

class _FrequencyPicker extends StatelessWidget {
  const _FrequencyPicker({required this.selectedDays, required this.onDaySelected});

  final Set<int> selectedDays;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const List<String> days = <String>['朁E, '火', '水', '木', '釁E, '圁E, '日'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('頻度', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing(2)),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing(3)),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: tokens.spacing(3),
              runSpacing: tokens.spacing(2),
              children: List<Widget>.generate(days.length, (int index) {
                final bool isSelected = selectedDays.contains(index);
                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: '${days[index]}曜日めE{isSelected ? '解除' : '選抁E}',
                  child: ChoiceChip(
                    label: Text(days[index]),
                    selected: isSelected,
                    onSelected: (_) => onDaySelected(index),
                    showCheckmark: false,
                    shape: const CircleBorder(),
                    labelStyle: tokens.bodyMedium.copyWith(
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
        Text('リマインダー', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing(2)),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing(4),
              vertical: tokens.spacing(3),
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
                      style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
                    ),
                  ),
                ),
                Switch(
                  value: isReminderOn,
                  onChanged: onToggle,
                ),
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
      title: const Text('アイコンを選抁E),
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
          child: const Text('閉じめE),
        ),
      ],
    );
  }
}
