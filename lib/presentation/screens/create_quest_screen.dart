
import 'package:flutter/material.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _goalValueController = TextEditingController(text: "10");

  String _selectedIconKey = 'spa';
  Color _selectedColor = Colors.blue;
  bool _isTimeGoal = true;
  final Set<int> _selectedDays = {0, 1, 2, 3, 6}; // Mon, Tue, Wed, Thu, Sun
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);
  bool _isReminderOn = true;

  @override
  void dispose() {
    _titleController.dispose();
    _goalValueController.dispose();
    super.dispose();
  }

  Future<void> _saveQuest() async {
    if (_formKey.currentState?.validate() ?? false) {
      final uid = ref.read(uidProvider);
      if (uid == null || uid.isEmpty) {
        FeedbackMessenger.showErrorSnackBar(
          context,
          'ユーザーがサインインしていません。',
        );
        return;
      }

      final newQuest = Quest()
        ..owner = uid
        ..title = _titleController.text
        ..category = '' // Category seems to be removed in the new design
        ..estimatedMinutes = _isTimeGoal ? (int.tryParse(_goalValueController.text) ?? 0) : 0
        ..iconKey = _selectedIconKey
        ..status = QuestStatus.active
        ..createdAt = DateTime.now();

      await ref.read(questRepositoryProvider).addQuest(newQuest);

      if (mounted) {
        FeedbackMessenger.showSuccessToast(
          context,
          '新しい習慣を作成しました！',
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _Header(),
              const SizedBox(height: 24),
              _HabitNameInput(controller: _titleController),
              const SizedBox(height: 24),
              _IconAndColorPicker(
                selectedIcon: _selectedIconKey,
                selectedColor: _selectedColor,
                onIconSelected: (icon) => setState(() => _selectedIconKey = icon),
                onColorSelected: (color) => setState(() => _selectedColor = color),
              ),
              const SizedBox(height: 24),
              _GoalSetter(
                isTimeGoal: _isTimeGoal,
                goalValueController: _goalValueController,
                onGoalTypeChanged: (isTime) => setState(() => _isTimeGoal = isTime),
              ),
              const SizedBox(height: 24),
              _FrequencyPicker(
                selectedDays: _selectedDays,
                onDaySelected: (dayIndex) {
                  setState(() {
                    if (_selectedDays.contains(dayIndex)) {
                      _selectedDays.remove(dayIndex);
                    } else {
                      _selectedDays.add(dayIndex);
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              _ReminderSetter(
                isReminderOn: _isReminderOn,
                reminderTime: _reminderTime,
                onToggle: (isOn) => setState(() => _isReminderOn = isOn),
                onTimeTap: () async {
                  final newTime = await showTimePicker(context: context, initialTime: _reminderTime);
                  if (newTime != null) {
                    setState(() => _reminderTime = newTime);
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveQuest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("習慣を作成する"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new)),
        Text(
          "新しい習慣を追加",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 48), // To balance the back button
      ],
    );
  }
}

class _HabitNameInput extends StatelessWidget {
  final TextEditingController controller;
  const _HabitNameInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("習慣の名前", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) => (value == null || value.isEmpty) ? '名前を入力してください' : null,
          decoration: InputDecoration(
            hintText: "例：毎朝瞑想する",
            prefixIcon: const Icon(Icons.edit),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconAndColorPicker extends StatelessWidget {
  final String selectedIcon;
  final Color selectedColor;
  final ValueChanged<String> onIconSelected;
  final ValueChanged<Color> onColorSelected;

  const _IconAndColorPicker({
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconSelected,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = MinqTheme.of(context);
    final List<Color> colors = [tokens.joyAccent, tokens.encouragement, tokens.serenity, tokens.warmth, tokens.brandPrimary];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("アイコンと色", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                final iconKey = await showDialog<String>(context: context, builder: (context) => const _IconPickerDialog());
                if (iconKey != null) {
                  onIconSelected(iconKey);
                }
              },
              child: Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: selectedColor, shape: BoxShape.circle),
                child: Icon(iconDataForKey(selectedIcon), color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: colors.map((color) => GestureDetector(
                  onTap: () => onColorSelected(color),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: color == selectedColor ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoalSetter extends StatelessWidget {
  final bool isTimeGoal;
  final TextEditingController goalValueController;
  final ValueChanged<bool> onGoalTypeChanged;

  const _GoalSetter({
    required this.isTimeGoal,
    required this.goalValueController,
    required this.onGoalTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("目標", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ToggleButtons(
                  isSelected: [isTimeGoal, !isTimeGoal],
                  onPressed: (index) => onGoalTypeChanged(index == 0),
                  borderRadius: BorderRadius.circular(30),
                  children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("時間")), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("回数"))],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: goalValueController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(isTimeGoal ? "分" : "回", style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FrequencyPicker extends StatelessWidget {
  final Set<int> selectedDays;
  final ValueChanged<int> onDaySelected;
  const _FrequencyPicker({required this.selectedDays, required this.onDaySelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final days = ["月", "火", "水", "木", "金", "土", "日"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("頻度", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isSelected = selectedDays.contains(index);
                return ChoiceChip(
                  label: Text(days[index]),
                  selected: isSelected,
                  onSelected: (selected) => onDaySelected(index),
                  showCheckmark: false,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                  shape: const CircleBorder(),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  selectedColor: colorScheme.primary,
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
  final bool isReminderOn;
  final TimeOfDay reminderTime;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTimeTap;

  const _ReminderSetter({
    required this.isReminderOn,
    required this.reminderTime,
    required this.onToggle,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("リマインダー", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onTimeTap,
                  child: Text(reminderTime.format(context), style: textTheme.titleLarge),
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

  List<IconData> allQuestIcons() {
    return [
      Icons.fitness_center,
      Icons.book,
      Icons.music_note,
      Icons.palette,
      Icons.code,
      Icons.camera_alt,
      Icons.restaurant,
      Icons.directions_run,
      Icons.school,
      Icons.work,
      Icons.favorite,
      Icons.star,
      Icons.lightbulb,
      Icons.rocket_launch,
      Icons.celebration,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final icons = allQuestIcons();
    return AlertDialog(
      title: const Text("アイコンを選択"),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            final iconData = icons[index];
            return InkWell(
              onTap: () => Navigator.of(context).pop(iconData.codePoint),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconData, size: 32),
                  const SizedBox(height: 8),
                  Text('Icon ${index + 1}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("キャンセル"),
        ),
      ],
    );
  }
}
