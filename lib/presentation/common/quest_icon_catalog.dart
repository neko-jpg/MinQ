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
    label: '教科書・参考書',
    suggestedCategories: ['学習'],
  ),
  QuestIconDefinition(
    key: 'memo',
    icon: Icons.edit,
    label: 'ノートまとめ',
    suggestedCategories: ['学習'],
  ),
  QuestIconDefinition(
    key: 'lightbulb',
    icon: Icons.lightbulb,
    label: 'アイデア整理',
    suggestedCategories: ['学習'],
  ),
  QuestIconDefinition(
    key: 'calculator',
    icon: Icons.calculate,
    label: '計算・問題集',
    suggestedCategories: ['学習'],
  ),
  QuestIconDefinition(
    key: 'certificate',
    icon: Icons.workspace_premium,
    label: '資格対策',
    suggestedCategories: ['学習'],
  ),
  QuestIconDefinition(
    key: 'news',
    icon: Icons.article,
    label: 'ニュースを読む',
    suggestedCategories: ['学習'],
  ),
  QuestIconDefinition(
    key: 'timer',
    icon: Icons.timer,
    label: 'タイマー学習',
    suggestedCategories: ['学習', '生活'],
  ),
  QuestIconDefinition(
    key: 'cards',
    icon: Icons.style,
    label: '暗記カード',
    suggestedCategories: ['学習'],
  ),
  QuestIconDefinition(
    key: 'translate',
    icon: Icons.language,
    label: '語学・英語',
    suggestedCategories: ['学習'],
  ),
  QuestIconDefinition(
    key: 'dumbbell',
    icon: Icons.fitness_center,
    label: '筋トレ',
    suggestedCategories: ['運動'],
  ),
  QuestIconDefinition(
    key: 'stretch',
    icon: Icons.self_improvement,
    label: 'ストレッチ',
    suggestedCategories: ['運動', 'セルフケア'],
  ),
  QuestIconDefinition(
    key: 'stairs',
    icon: Icons.stairs,
    label: '階段チャレンジ',
    suggestedCategories: ['運動'],
  ),
  QuestIconDefinition(
    key: 'walk',
    icon: Icons.directions_walk,
    label: 'ウォーキング',
    suggestedCategories: ['運動', '生活'],
  ),
  QuestIconDefinition(
    key: 'breath',
    icon: Icons.air,
    label: '呼吸トレーニング',
    suggestedCategories: ['運動', '生活', 'セルフケア'],
  ),
  QuestIconDefinition(
    key: 'clean',
    icon: Icons.cleaning_services,
    label: '掃除・クリーンアップ',
    suggestedCategories: ['片付け', '生活'],
  ),
  QuestIconDefinition(
    key: 'laundry',
    icon: Icons.local_laundry_service,
    label: '洗濯',
    suggestedCategories: ['片付け'],
  ),
  QuestIconDefinition(
    key: 'trash',
    icon: Icons.delete_sweep,
    label: 'ごみ出し',
    suggestedCategories: ['片付け'],
  ),
  QuestIconDefinition(
    key: 'plant',
    icon: Icons.grass,
    label: '植物のお世話',
    suggestedCategories: ['片付け', '生活'],
  ),
  QuestIconDefinition(
    key: 'water',
    icon: Icons.water_drop,
    label: '水分補給',
    suggestedCategories: ['生活', 'セルフケア'],
  ),
  QuestIconDefinition(
    key: 'todo',
    icon: Icons.check_circle_outline,
    label: 'タスク整理',
    suggestedCategories: ['片付け', '生活'],
  ),
  QuestIconDefinition(
    key: 'journal',
    icon: Icons.auto_stories,
    label: '日記・ログ',
    suggestedCategories: ['生活', 'セルフケア', '学習'],
  ),
  QuestIconDefinition(
    key: 'moon',
    icon: Icons.nightlight_round,
    label: 'ナイトルーティン',
    suggestedCategories: ['生活', 'セルフケア'],
  ),
  QuestIconDefinition(
    key: 'finance',
    icon: Icons.savings,
    label: '家計簿',
    suggestedCategories: ['生活'],
  ),
  QuestIconDefinition(
    key: 'cook',
    icon: Icons.restaurant,
    label: '料理・自炊',
    suggestedCategories: ['生活', '片付け'],
  ),
  QuestIconDefinition(
    key: 'mind',
    icon: Icons.spa,
    label: 'マインドフルネス',
    suggestedCategories: ['セルフケア'],
  ),
  QuestIconDefinition(
    key: 'digital_detox',
    icon: Icons.phonelink_erase,
    label: 'デジタルデトックス',
    suggestedCategories: ['セルフケア'],
  ),
  QuestIconDefinition(
    key: 'smile',
    icon: Icons.sentiment_satisfied_alt,
    label: 'ありがとうログ',
    suggestedCategories: ['セルフケア'],
  ),
  QuestIconDefinition(
    key: 'music',
    icon: Icons.music_note,
    label: '音楽タイム',
    suggestedCategories: ['セルフケア'],
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
    (icon) =>
        icon.suggestedCategories.isEmpty ||
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
