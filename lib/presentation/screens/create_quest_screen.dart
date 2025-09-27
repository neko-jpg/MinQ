import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
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
  String _selectedCategory = '学習';
  String _selectedIconKey = 'book';
  double _estimatedMinutes = 5;

  final _categories = const ['学習', '運動', '片付け', '生活', 'セルフケア'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveQuest() async {
    if (_formKey.currentState?.validate() ?? false) {
      final uid = ref.read(uidProvider);
      if (uid == null || uid.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not signed in.')),
        );
        return;
      }

      final newQuest = Quest()
        ..owner = uid
        ..title = _titleController.text
        ..category = _selectedCategory
        ..estimatedMinutes = _estimatedMinutes.round()
        ..iconKey = _selectedIconKey
        ..status = QuestStatus.active
        ..createdAt = DateTime.now();

      await ref.read(questRepositoryProvider).addQuest(newQuest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom quest created!')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final icons = questIconsForCategory(_selectedCategory);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Create Custom Quest', style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        backgroundColor: tokens.background.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(tokens.spacing(4)),
          children: [
            _buildSectionHeader(tokens, 'Quest Title'),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'e.g., Read one chapter'),
              validator: (value) => (value == null || value.isEmpty) ? 'Please enter a title' : null,
            ),
            SizedBox(height: tokens.spacing(6)),
            _buildSectionHeader(tokens, 'Category'),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedIconKey = questIconsForCategory(value).first.key;
                  });
                }
              },
            ),
            SizedBox(height: tokens.spacing(6)),
            _buildSectionHeader(tokens, 'Icon'),
            SizedBox(
              height: 240,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  final iconDef = icons[index];
                  final isSelected = iconDef.key == _selectedIconKey;
                  return InkWell(
                    onTap: () => setState(() => _selectedIconKey = iconDef.key),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.brandPrimary.withOpacity(0.2) : tokens.surface,
                        borderRadius: tokens.cornerLarge(),
                        border: Border.all(color: isSelected ? tokens.brandPrimary : tokens.border, width: isSelected ? 2 : 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(iconDef.icon, color: tokens.brandPrimary, size: 32),
                          SizedBox(height: tokens.spacing(2)),
                          Text(iconDef.label, style: tokens.labelSmall, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: tokens.spacing(6)),
            _buildSectionHeader(tokens, 'Estimated Time: ${_estimatedMinutes.round()} min'),
            Slider(
              value: _estimatedMinutes,
              min: 1,
              max: 60,
              divisions: 59,
              label: '${_estimatedMinutes.round()} min',
              onChanged: (value) => setState(() => _estimatedMinutes = value),
            ),
            SizedBox(height: tokens.spacing(8)),
            MinqPrimaryButton(label: 'Save Quest', onPressed: _saveQuest),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(MinqTheme tokens, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing(3)),
      child: Text(title, style: tokens.titleSmall.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
    );
  }
}
