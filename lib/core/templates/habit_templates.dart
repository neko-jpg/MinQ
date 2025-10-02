import '../templates/quest_templates.dart';

/// 習慣テンプレート集
/// ユーザーが簡単に習慣を始められるように、よくある習慣のテンプレートを提供
class HabitTemplates {
  const HabitTemplates._();

  /// すべてのテンプレート
  static List<HabitTemplate> get all => [
    ...healthTemplates,
    ...learningTemplates,
    ...productivityTemplates,
    ...mindfulnessTemplates,
    ...socialTemplates,
  ];

  /// 健康・運動系テンプレート
  static List<HabitTemplate> get healthTemplates => [
    HabitTemplate(
      id: 'morning_run',
      title: '朝ラン',
      description: '朝の新鮮な空気を吸いながら軽くランニング',
      category: HabitCategory.health,
      icon: '🏃',
      difficulty: HabitDifficulty.medium,
      estimatedMinutes: 30,
      suggestedTimes: ['06:30', '07:00'],
      tips: '無理せず、自分のペースで走りましょう',
    ),
    HabitTemplate(
      id: 'morning_stretch',
      title: '朝ストレッチ',
      description: '目覚めの体をほぐす軽いストレッチ',
      category: HabitCategory.health,
      icon: '🧘',
      difficulty: HabitDifficulty.easy,
      estimatedMinutes: 10,
      suggestedTimes: ['06:00', '07:00'],
      tips: '呼吸を意識しながらゆっくりと',
    ),
    HabitTemplate(
      id: 'water_intake',
      title: '水を飲む',
      description: '1日2リットルの水分補給',
      category: HabitCategory.health,
      icon: '💧',
      difficulty: HabitDifficulty.easy,
      estimatedMinutes: 1,
      suggestedTimes: ['08:00', '12:00', '18:00'],
      tips: 'こまめに水分補給することが大切です',
    ),
    HabitTemplate(
      id: 'workout',
      title: '筋トレ',
      description: '自宅やジムでの筋力トレーニング',
      category: HabitCategory.health,
      icon: '💪',
      difficulty: HabitDifficulty.hard,
      estimatedMinutes: 45,
      suggestedTimes: ['18:00', '19:00'],
      tips: 'フォームを意識して、怪我に注意',
    ),
    HabitTemplate(
      id: 'walk',
      title: '散歩',
      description: '気分転換に外を歩く',
      category: HabitCategory.health,
      icon: '🚶',
      difficulty: HabitDifficulty.easy,
      estimatedMinutes: 20,
      suggestedTimes: ['12:00', '17:00'],
      tips: '景色を楽しみながらリラックス',
    ),
  ];

  /// 学習系テンプレート
  static List<HabitTemplate> get learningTemplates => [
    HabitTemplate(
      id: 'reading',
      title: '読書',
      description: '本を読んで知識を深める',
      category: HabitCategory.learning,
      icon: '📚',
      difficulty: HabitDifficulty.easy,
      estimatedMinutes: 30,
      suggestedTimes: ['21:00', '22:00'],
      tips: '寝る前の読書は睡眠の質を高めます',
    ),
    HabitTemplate(
      id: 'english_study',
      title: '英語学習',
      description: '英単語や英会話の練習',
      category: HabitCategory.learning,
      icon: '🇬🇧',
      difficulty: HabitDifficulty.medium,
      estimatedMinutes: 20,
      suggestedTimes: ['07:00', '20:00'],
      tips: '毎日少しずつ続けることが大切',
    ),
    HabitTemplate(
      id: 'online_course',
      title: 'オンライン講座',
      description: 'UdemyやCourseraで新しいスキルを学ぶ',
      category: HabitCategory.learning,
      icon: '🎓',
      difficulty: HabitDifficulty.medium,
      estimatedMinutes: 30,
      suggestedTimes: ['20:00', '21:00'],
      tips: '1つのコースを最後まで完走しましょう',
    ),
    HabitTemplate(
      id: 'podcast',
      title: 'ポッドキャスト',
      description: '通勤中や家事中に学びのポッドキャストを聴く',
      category: HabitCategory.learning,
      icon: '🎧',
      difficulty: HabitDifficulty.easy,
      estimatedMinutes: 15,
      suggestedTimes: ['08:00', '18:00'],
      tips: '移動時間を有効活用',
    ),
  ];

  /// 生産性系テンプレート
  static List<HabitTemplate> get productivityTemplates => [
    HabitTemplate(
      id: 'morning_planning',
      title: '朝の計画',
      description: '今日のタスクと優先順位を整理',
      category: HabitCategory.productivity,
      icon: '📝',
      difficulty: HabitDifficulty.easy,
      estimatedMinutes: 10,
      suggestedTimes: ['07:00', '08:00'],
      tips: '3つの重要タスクに絞りましょう',
    ),
    HabitTemplate(
      id: 'email_check',
      title: 'メール整理',
      description: '受信トレイをゼロにする',
      category: HabitCategory.productivity,
      icon: '📧',
      difficulty: HabitDifficulty.medium,
      estimatedMinutes: 15,
      suggestedTimes: ['09:00', '17:00'],
      tips: '2分ルール：2分以内で終わることはすぐやる',
    ),
    HabitTemplate(
      id: 'deep_work',
      title: '集中作業',
      description: '邪魔されない環境で重要な仕事に集中',
      category: HabitCategory.productivity,
      icon: '🎯',
      difficulty: HabitDifficulty.hard,
      estimatedMinutes: 90,
      suggestedTimes: ['09:00', '14:00'],
      tips: '通知をオフにして完全に集中',
    ),
    HabitTemplate(
      id: 'evening_review',
      title: '夜の振り返り',
      description: '今日の成果と明日の準備',
      category: HabitCategory.productivity,
      icon: '🌙',
      difficulty: HabitDifficulty.easy,
      estimatedMinutes: 10,
      suggestedTimes: ['21:00', '22:00'],
      tips: '小さな成功も認めてあげましょう',
    ),
  ];

  /// マインドフルネス系テンプレート
  static List<HabitTemplate> get mindfulnessTemplates => [
    HabitTemplate(
      id: 'meditation',
      title: '瞑想',
      description: '心を落ち着けて呼吸に集中',
      category: HabitCategory.mindfulness,
      icon: '🧘‍♀️',
      difficulty: HabitDifficulty.medium,
      estimatedMinutes: 10,
      suggestedTimes: ['06:30', '21:00'],
      tips: '完璧を求めず、ただ呼吸を観察',
    ),
    HabitTemplate(
      id: 'journaling',
      title: '日記',
      description: '今日の出来事や感情を書き出す',
      category: HabitCategory.mindfulness,
      icon: '📔',
      difficulty: HabitDifficulty.easy,
      estimatedMinutes: 15,
      suggestedTimes: ['21:00', '22:00'],
      tips: '思いついたことを自由に書きましょう',
    ),
    HabitTemplate(
      id: 'gratitude',
      title: '感謝の記録',
      description: '今日感謝したことを3つ書く',
      category: HabitCategory.mindfulness,
      icon: '🙏',
      difficulty: HabitDifficulty.easy,
      estimatedMinutes: 5,
      suggestedTimes: ['21:00', '22:00'],
      tips: '小さなことにも感謝の気持ちを',
    ),
    HabitTemplate(
      id: 'digital_detox',
      title: 'デジタルデトックス',
      description: 'スマホを見ない時間を作る',
      category: HabitCategory.mindfulness,
      icon: '📵',
      difficulty: HabitDifficulty.hard,
      estimatedMinutes: 60,
      suggestedTimes: ['20:00', '21:00'],
      tips: '寝る1時間前からスマホを置きましょう',
    ),
  ];

  /// 社交・コミュニケーション系テンプレート
  static List<HabitTemplate> get socialTemplates => [
    HabitTemplate(
      id: 'family_time',
      title: '家族との時間',
      description: '家族と会話や食事を楽しむ',
      category: HabitCategory.social,
      icon: '👨‍👩‍👧‍👦',
      difficulty: HabitDifficulty.easy,
      estimatedMinutes: 30,
      suggestedTimes: ['18:00', '19:00'],
      tips: 'スマホを置いて、顔を見て話しましょう',
    ),
    HabitTemplate(
      id: 'friend_contact',
      title: '友人に連絡',
      description: '大切な人にメッセージや電話',
      category: HabitCategory.social,
      icon: '💬',
      difficulty: HabitDifficulty.easy,
      estimatedMinutes: 10,
      suggestedTimes: ['12:00', '20:00'],
      tips: '短いメッセージでも気持ちは伝わります',
    ),
    HabitTemplate(
      id: 'networking',
      title: 'ネットワーキング',
      description: '新しい人と出会い、つながりを作る',
      category: HabitCategory.social,
      icon: '🤝',
      difficulty: HabitDifficulty.medium,
      estimatedMinutes: 60,
      suggestedTimes: ['18:00', '19:00'],
      tips: '相手の話をよく聞くことが大切',
    ),
  ];

  /// カテゴリー別にテンプレートを取得
  static List<HabitTemplate> getByCategory(HabitCategory category) {
    return all.where((template) => template.category == category).toList();
  }

  /// 難易度別にテンプレートを取得
  static List<HabitTemplate> getByDifficulty(HabitDifficulty difficulty) {
    return all.where((template) => template.difficulty == difficulty).toList();
  }

  /// 推定時間別にテンプレートを取得
  static List<HabitTemplate> getByDuration(int maxMinutes) {
    return all.where((template) => template.estimatedMinutes <= maxMinutes).toList();
  }

  /// IDからテンプレートを取得
  static HabitTemplate? getById(String id) {
    try {
      return all.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// 習慣テンプレート
class HabitTemplate {
  final String id;
  final String title;
  final String description;
  final HabitCategory category;
  final String icon;
  final HabitDifficulty difficulty;
  final int estimatedMinutes;
  final List<String> suggestedTimes;
  final String tips;
  final String? location;

  const HabitTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.suggestedTimes,
    required this.tips,
    this.location,
  });

  /// QuestTemplateに変換
  QuestTemplate toQuestTemplate() {
    return QuestTemplate(
      title: title,
      description: description,
      icon: icon,
      category: _categoryToString(category),
      difficulty: _difficultyToString(difficulty),
      estimatedMinutes: estimatedMinutes,
      tips: [tips],
    );
  }

  String _categoryToString(HabitCategory category) {
    return switch (category) {
      HabitCategory.health => '健康',
      HabitCategory.learning => '学習',
      HabitCategory.productivity => '生産性',
      HabitCategory.mindfulness => 'マインドフルネス',
      HabitCategory.social => '社交',
    };
  }

  String _difficultyToString(HabitDifficulty difficulty) {
    return switch (difficulty) {
      HabitDifficulty.easy => '簡単',
      HabitDifficulty.medium => '普通',
      HabitDifficulty.hard => '難しい',
    };
  }
}

/// 習慣カテゴリー
enum HabitCategory {
  health,        // 健康・運動
  learning,      // 学習
  productivity,  // 生産性
  mindfulness,   // マインドフルネス
  social,        // 社交
}

/// 習慣の難易度
enum HabitDifficulty {
  easy,    // 簡単
  medium,  // 普通
  hard,    // 難しい
}

/// カテゴリーの表示名
extension HabitCategoryExtension on HabitCategory {
  String get displayName {
    return switch (this) {
      HabitCategory.health => '健康・運動',
      HabitCategory.learning => '学習',
      HabitCategory.productivity => '生産性',
      HabitCategory.mindfulness => 'マインドフルネス',
      HabitCategory.social => '社交',
    };
  }

  String get icon {
    return switch (this) {
      HabitCategory.health => '💪',
      HabitCategory.learning => '📚',
      HabitCategory.productivity => '🎯',
      HabitCategory.mindfulness => '🧘',
      HabitCategory.social => '👥',
    };
  }
}

/// 難易度の表示名
extension HabitDifficultyExtension on HabitDifficulty {
  String get displayName {
    return switch (this) {
      HabitDifficulty.easy => '簡単',
      HabitDifficulty.medium => '普通',
      HabitDifficulty.hard => '難しい',
    };
  }

  String get icon {
    return switch (this) {
      HabitDifficulty.easy => '⭐',
      HabitDifficulty.medium => '⭐⭐',
      HabitDifficulty.hard => '⭐⭐⭐',
    };
  }
}
