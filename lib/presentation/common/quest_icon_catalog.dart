import 'package:flutter/material.dart';

class QuestIconDefinition {
  const QuestIconDefinition({
    required this.key,
    required this.icon,
    required this.label,
    this.suggestedCategories = const <String>[],
  });

  final String key;
  final IconData icon;
  final String label;
  final List<String> suggestedCategories;
}

const List<QuestIconDefinition> questIconCatalog = [
  QuestIconDefinition(
    key: 'book',
    icon: Icons.menu_book,
    label: '���ȏ��E�Q�l��',
    suggestedCategories: ['�w�K'],
  ),
  QuestIconDefinition(
    key: 'memo',
    icon: Icons.edit,
    label: '�m�[�g�܂Ƃ�',
    suggestedCategories: ['�w�K'],
  ),
  QuestIconDefinition(
    key: 'lightbulb',
    icon: Icons.lightbulb,
    label: '�A�C�f�A����',
    suggestedCategories: ['�w�K'],
  ),
  QuestIconDefinition(
    key: 'calculator',
    icon: Icons.calculate,
    label: '�v�Z�E���W',
    suggestedCategories: ['�w�K'],
  ),
  QuestIconDefinition(
    key: 'certificate',
    icon: Icons.workspace_premium,
    label: '���i�΍�',
    suggestedCategories: ['�w�K'],
  ),
  QuestIconDefinition(
    key: 'news',
    icon: Icons.article,
    label: '�j���[�X��ǂ�',
    suggestedCategories: ['�w�K'],
  ),
  QuestIconDefinition(
    key: 'timer',
    icon: Icons.timer,
    label: '�^�C�}�[�w�K',
    suggestedCategories: ['�w�K', '����'],
  ),
  QuestIconDefinition(
    key: 'cards',
    icon: Icons.style,
    label: '�ËL�J�[�h',
    suggestedCategories: ['�w�K'],
  ),
  QuestIconDefinition(
    key: 'translate',
    icon: Icons.language,
    label: '��w�E�p��',
    suggestedCategories: ['�w�K'],
  ),
  QuestIconDefinition(
    key: 'dumbbell',
    icon: Icons.fitness_center,
    label: '�؃g��',
    suggestedCategories: ['�^��'],
  ),
  QuestIconDefinition(
    key: 'stretch',
    icon: Icons.self_improvement,
    label: '�X�g���b�`',
    suggestedCategories: ['�^��', '�Z���t�P�A'],
  ),
  QuestIconDefinition(
    key: 'stairs',
    icon: Icons.stairs,
    label: '�K�i�`�������W',
    suggestedCategories: ['�^��'],
  ),
  QuestIconDefinition(
    key: 'walk',
    icon: Icons.directions_walk,
    label: '�E�H�[�L���O',
    suggestedCategories: ['�^��', '����'],
  ),
  QuestIconDefinition(
    key: 'breath',
    icon: Icons.air,
    label: '�ċz�g���[�j���O',
    suggestedCategories: ['�^��', '����', '�Z���t�P�A'],
  ),
  QuestIconDefinition(
    key: 'clean',
    icon: Icons.cleaning_services,
    label: '�|���E�N���[���A�b�v',
    suggestedCategories: ['�Еt��', '����'],
  ),
  QuestIconDefinition(
    key: 'laundry',
    icon: Icons.local_laundry_service,
    label: '����',
    suggestedCategories: ['�Еt��'],
  ),
  QuestIconDefinition(
    key: 'trash',
    icon: Icons.delete_sweep,
    label: '���ݏo��',
    suggestedCategories: ['�Еt��'],
  ),
  QuestIconDefinition(
    key: 'plant',
    icon: Icons.grass,
    label: '�A���̂����b',
    suggestedCategories: ['�Еt��', '����'],
  ),
  QuestIconDefinition(
    key: 'water',
    icon: Icons.water_drop,
    label: '�����⋋',
    suggestedCategories: ['����', '�Z���t�P�A'],
  ),
  QuestIconDefinition(
    key: 'todo',
    icon: Icons.check_circle_outline,
    label: '�^�X�N����',
    suggestedCategories: ['�Еt��', '����'],
  ),
  QuestIconDefinition(
    key: 'journal',
    icon: Icons.auto_stories,
    label: '���L�E���O',
    suggestedCategories: ['����', '�Z���t�P�A', '�w�K'],
  ),
  QuestIconDefinition(
    key: 'moon',
    icon: Icons.nightlight_round,
    label: '�i�C�g���[�e�B��',
    suggestedCategories: ['����', '�Z���t�P�A'],
  ),
  QuestIconDefinition(
    key: 'finance',
    icon: Icons.savings,
    label: '�ƌv��',
    suggestedCategories: ['����'],
  ),
  QuestIconDefinition(
    key: 'cook',
    icon: Icons.restaurant,
    label: '�����E����',
    suggestedCategories: ['����', '�Еt��'],
  ),
  QuestIconDefinition(
    key: 'mind',
    icon: Icons.spa,
    label: '�}�C���h�t���l�X',
    suggestedCategories: ['�Z���t�P�A'],
  ),
  QuestIconDefinition(
    key: 'digital_detox',
    icon: Icons.phonelink_erase,
    label: '�f�W�^���f�g�b�N�X',
    suggestedCategories: ['�Z���t�P�A'],
  ),
  QuestIconDefinition(
    key: 'smile',
    icon: Icons.sentiment_satisfied_alt,
    label: '���肪�Ƃ����O',
    suggestedCategories: ['�Z���t�P�A'],
  ),
  QuestIconDefinition(
    key: 'music',
    icon: Icons.music_note,
    label: '���y�^�C��',
    suggestedCategories: ['�Z���t�P�A'],
  ),
];

QuestIconDefinition? questIconByKey(String? key) {
  if (key == null || key.isEmpty) {
    return null;
  }
  for (final icon in questIconCatalog) {
    if (icon.key == key) {
      return icon;
    }
  }
  return null;
}

List<QuestIconDefinition> questIconsForCategory(String? category) {
  if (category == null || category.isEmpty) {
    return questIconCatalog;
  }
  final filtered = questIconCatalog.where(
    (icon) => icon.suggestedCategories.isEmpty ||
        icon.suggestedCategories.contains(category),
  );
  final result = filtered.toList();
  if (result.isEmpty) {
    return questIconCatalog;
  }
  return result;
}

IconData iconDataForKey(String? key, {IconData fallback = Icons.bolt}) {
  return questIconByKey(key)?.icon ?? fallback;
}

String? iconLabelForKey(String? key) {
  return questIconByKey(key)?.label;
}
