/// クエストテンプレート
class QuestTemplate {
  final String id;
  final String title;
  final String description;
  final QuestCategory category;
  final List<String> tags;
  final Duration estimatedDuration;
  final DifficultyLevel difficulty;
  final List<String> tips;
  final String? icon;

  const QuestTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.tags = const [],
    this.estimatedDuration = const Duration(minutes: 30),
    this.difficulty = DifficultyLevel.medium,
    this.tips = const [],
    this.icon,
  });
}

/// クエストカテゴリー
enum QuestCategory {
  health,
  fitness,
  learning,
  productivity,
  mindfulness,
  social,
  creative,
  financial,
  other,
}

extension QuestCategoryExtension on QuestCategory {
  String get displayName {
    switch (this) {
      case QuestCategory.health:
        return '健康';
      case QuestCategory.fitness:
        return 'フィットネス';
      case QuestCategory.learning:
        return '学習';
      case QuestCategory.productivity:
        return '生産性';
      case QuestCategory.mindfulness:
        return 'マインドフルネス';
      case QuestCategory.social:
        return '社交';
      case QuestCategory.creative:
        return 'クリエイティブ';
      case QuestCategory.financial:
        return '金融';
      case QuestCategory.other:
        return 'その他';
    }
  }

  String get icon {
    switch (this) {
      case QuestCategory.health:
        return '🏥';
      case QuestCategory.fitness:
        return '💪';
      case QuestCategory.learning:
        return '📚';
      case QuestCategory.productivity:
        return '⚡';
      case QuestCategory.mindfulness:
        return '🧘';
      case QuestCategory.social:
        return '👥';
      case QuestCategory.creative:
        return '🎨';
      case QuestCategory.financial:
        return '💰';
      case QuestCategory.other:
        return '📝';
    }
  }
}

/// 難易度レベル
enum DifficultyLevel { easy, medium, hard }

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return '簡単';
      case DifficultyLevel.medium:
        return '普通';
      case DifficultyLevel.hard:
        return '難しい';
    }
  }
}

/// クエストテンプレートリポジトリ
class QuestTemplateRepository {
  /// 全テンプレートを取得
  static List<QuestTemplate> getAllTemplates() {
    return [
      ..._healthTemplates,
      ..._fitnessTemplates,
      ..._learningTemplates,
      ..._productivityTemplates,
      ..._mindfulnessTemplates,
      ..._socialTemplates,
      ..._creativeTemplates,
      ..._financialTemplates,
    ];
  }

  /// カテゴリー別にテンプレートを取得
  static List<QuestTemplate> getTemplatesByCategory(QuestCategory category) {
    return getAllTemplates()
        .where((template) => template.category == category)
        .toList();
  }

  /// 人気のテンプレートを取得
  static List<QuestTemplate> getPopularTemplates() {
    return [
      _healthTemplates[0], // 水を飲む
      _fitnessTemplates[0], // 朝のストレッチ
      _learningTemplates[0], // 読書
      _productivityTemplates[0], // タスク整理
      _mindfulnessTemplates[0], // 瞑想
    ];
  }

  /// 初心者向けテンプレートを取得
  static List<QuestTemplate> getBeginnerTemplates() {
    return getAllTemplates()
        .where((template) => template.difficulty == DifficultyLevel.easy)
        .toList();
  }

  /// おすすめテンプレートを取得
  static List<QuestTemplate> getRecommendedTemplates({
    required List<QuestCategory> preferredCategories,
    required DifficultyLevel maxDifficulty,
  }) {
    return getAllTemplates()
        .where(
          (template) =>
              preferredCategories.contains(template.category) &&
              template.difficulty.index <= maxDifficulty.index,
        )
        .toList();
  }

  // 健康テンプレート
  static final List<QuestTemplate> _healthTemplates = [
    const QuestTemplate(
      id: 'health_water',
      title: '水を飲む',
      description: '1日8杯の水を飲む',
      category: QuestCategory.health,
      tags: ['水分補給', '健康'],
      estimatedDuration: Duration(minutes: 5),
      difficulty: DifficultyLevel.easy,
      tips: ['朝起きたらまず1杯', '食事の前に1杯', 'ボトルを持ち歩く'],
      icon: '💧',
    ),
    const QuestTemplate(
      id: 'health_sleep',
      title: '早く寝る',
      description: '23時までに就寝する',
      category: QuestCategory.health,
      tags: ['睡眠', '健康'],
      estimatedDuration: Duration(hours: 8),
      difficulty: DifficultyLevel.medium,
      tips: ['就寝1時間前にスマホを置く', '部屋を暗くする', 'リラックスする音楽を聴く'],
      icon: '😴',
    ),
    const QuestTemplate(
      id: 'health_vegetables',
      title: '野菜を食べる',
      description: '1日5種類の野菜を食べる',
      category: QuestCategory.health,
      tags: ['食事', '健康', '野菜'],
      estimatedDuration: Duration(minutes: 30),
      difficulty: DifficultyLevel.medium,
      tips: ['サラダから食べる', '色々な色の野菜を選ぶ', '作り置きを活用'],
      icon: '🥗',
    ),
  ];

  // フィットネステンプレート
  static final List<QuestTemplate> _fitnessTemplates = [
    const QuestTemplate(
      id: 'fitness_stretch',
      title: '朝のストレッチ',
      description: '起床後10分間ストレッチする',
      category: QuestCategory.fitness,
      tags: ['ストレッチ', '朝', '運動'],
      estimatedDuration: Duration(minutes: 10),
      difficulty: DifficultyLevel.easy,
      tips: ['ゆっくり呼吸しながら', '無理をしない', '毎日同じ時間に'],
      icon: '🤸',
    ),
    const QuestTemplate(
      id: 'fitness_walk',
      title: '散歩',
      description: '30分間散歩する',
      category: QuestCategory.fitness,
      tags: ['散歩', '運動', '有酸素'],
      estimatedDuration: Duration(minutes: 30),
      difficulty: DifficultyLevel.easy,
      tips: ['快適な靴を履く', '音楽やポッドキャストを聴く', '景色を楽しむ'],
      icon: '🚶',
    ),
    const QuestTemplate(
      id: 'fitness_workout',
      title: '筋トレ',
      description: '20分間筋トレする',
      category: QuestCategory.fitness,
      tags: ['筋トレ', '運動', '筋肉'],
      estimatedDuration: Duration(minutes: 20),
      difficulty: DifficultyLevel.medium,
      tips: ['ウォームアップを忘れずに', '正しいフォームで', '休息日も大切'],
      icon: '💪',
    ),
  ];

  // 学習テンプレート
  static final List<QuestTemplate> _learningTemplates = [
    const QuestTemplate(
      id: 'learning_reading',
      title: '読書',
      description: '30分間読書する',
      category: QuestCategory.learning,
      tags: ['読書', '学習', '本'],
      estimatedDuration: Duration(minutes: 30),
      difficulty: DifficultyLevel.easy,
      tips: ['静かな場所で', 'メモを取りながら', '毎日同じ時間に'],
      icon: '📚',
    ),
    const QuestTemplate(
      id: 'learning_language',
      title: '語学学習',
      description: '15分間外国語を勉強する',
      category: QuestCategory.learning,
      tags: ['語学', '学習', '言語'],
      estimatedDuration: Duration(minutes: 15),
      difficulty: DifficultyLevel.medium,
      tips: ['アプリを活用', '声に出して練習', '毎日続ける'],
      icon: '🌍',
    ),
    const QuestTemplate(
      id: 'learning_skill',
      title: 'スキル学習',
      description: '新しいスキルを30分学ぶ',
      category: QuestCategory.learning,
      tags: ['スキル', '学習', '成長'],
      estimatedDuration: Duration(minutes: 30),
      difficulty: DifficultyLevel.medium,
      tips: ['オンラインコースを活用', '実践しながら学ぶ', '進捗を記録'],
      icon: '🎓',
    ),
  ];

  // 生産性テンプレート
  static final List<QuestTemplate> _productivityTemplates = [
    const QuestTemplate(
      id: 'productivity_planning',
      title: 'タスク整理',
      description: '今日のタスクを整理する',
      category: QuestCategory.productivity,
      tags: ['タスク', '整理', '計画'],
      estimatedDuration: Duration(minutes: 10),
      difficulty: DifficultyLevel.easy,
      tips: ['優先順位をつける', '実現可能な量に', '朝一番に'],
      icon: '📝',
    ),
    const QuestTemplate(
      id: 'productivity_focus',
      title: '集中作業',
      description: 'ポモドーロテクニックで25分集中',
      category: QuestCategory.productivity,
      tags: ['集中', '作業', 'ポモドーロ'],
      estimatedDuration: Duration(minutes: 25),
      difficulty: DifficultyLevel.medium,
      tips: ['通知をオフに', 'タイマーを使う', '休憩も大切'],
      icon: '⏰',
    ),
    const QuestTemplate(
      id: 'productivity_review',
      title: '振り返り',
      description: '今日の振り返りをする',
      category: QuestCategory.productivity,
      tags: ['振り返り', '反省', '改善'],
      estimatedDuration: Duration(minutes: 10),
      difficulty: DifficultyLevel.easy,
      tips: ['良かった点を3つ', '改善点を1つ', '明日の目標を設定'],
      icon: '🔍',
    ),
  ];

  // マインドフルネステンプレート
  static final List<QuestTemplate> _mindfulnessTemplates = [
    const QuestTemplate(
      id: 'mindfulness_meditation',
      title: '瞑想',
      description: '10分間瞑想する',
      category: QuestCategory.mindfulness,
      tags: ['瞑想', 'マインドフルネス', 'リラックス'],
      estimatedDuration: Duration(minutes: 10),
      difficulty: DifficultyLevel.easy,
      tips: ['静かな場所で', '呼吸に集中', 'アプリを活用'],
      icon: '🧘',
    ),
    const QuestTemplate(
      id: 'mindfulness_gratitude',
      title: '感謝日記',
      description: '感謝したことを3つ書く',
      category: QuestCategory.mindfulness,
      tags: ['感謝', '日記', 'ポジティブ'],
      estimatedDuration: Duration(minutes: 5),
      difficulty: DifficultyLevel.easy,
      tips: ['小さなことでもOK', '具体的に書く', '寝る前に'],
      icon: '🙏',
    ),
    const QuestTemplate(
      id: 'mindfulness_breathing',
      title: '深呼吸',
      description: '5分間深呼吸する',
      category: QuestCategory.mindfulness,
      tags: ['呼吸', 'リラックス', 'ストレス解消'],
      estimatedDuration: Duration(minutes: 5),
      difficulty: DifficultyLevel.easy,
      tips: ['4秒吸って、7秒止めて、8秒吐く', 'リラックスした姿勢で', 'ストレスを感じたら'],
      icon: '🌬️',
    ),
  ];

  // 社交テンプレート
  static final List<QuestTemplate> _socialTemplates = [
    const QuestTemplate(
      id: 'social_call',
      title: '友人に連絡',
      description: '友人や家族に連絡する',
      category: QuestCategory.social,
      tags: ['連絡', '友人', '家族'],
      estimatedDuration: Duration(minutes: 15),
      difficulty: DifficultyLevel.easy,
      tips: ['久しぶりの人に', '近況を聞く', '感謝を伝える'],
      icon: '📞',
    ),
    const QuestTemplate(
      id: 'social_compliment',
      title: '誰かを褒める',
      description: '誰かに感謝や褒め言葉を伝える',
      category: QuestCategory.social,
      tags: ['褒める', '感謝', 'ポジティブ'],
      estimatedDuration: Duration(minutes: 5),
      difficulty: DifficultyLevel.easy,
      tips: ['具体的に', '心から', '小さなことでも'],
      icon: '👍',
    ),
  ];

  // クリエイティブテンプレート
  static final List<QuestTemplate> _creativeTemplates = [
    const QuestTemplate(
      id: 'creative_writing',
      title: '日記を書く',
      description: '今日の出来事を日記に書く',
      category: QuestCategory.creative,
      tags: ['日記', '書く', '記録'],
      estimatedDuration: Duration(minutes: 10),
      difficulty: DifficultyLevel.easy,
      tips: ['思ったことを自由に', '毎日続ける', '振り返りに活用'],
      icon: '✍️',
    ),
    const QuestTemplate(
      id: 'creative_drawing',
      title: '絵を描く',
      description: '15分間絵を描く',
      category: QuestCategory.creative,
      tags: ['絵', '描く', 'アート'],
      estimatedDuration: Duration(minutes: 15),
      difficulty: DifficultyLevel.medium,
      tips: ['上手い下手は気にしない', '楽しむことが大切', '毎日少しずつ'],
      icon: '🎨',
    ),
  ];

  // 金融テンプレート
  static final List<QuestTemplate> _financialTemplates = [
    const QuestTemplate(
      id: 'financial_budget',
      title: '家計簿をつける',
      description: '今日の支出を記録する',
      category: QuestCategory.financial,
      tags: ['家計簿', '支出', '記録'],
      estimatedDuration: Duration(minutes: 5),
      difficulty: DifficultyLevel.easy,
      tips: ['レシートを保管', 'アプリを活用', '毎日記録'],
      icon: '💰',
    ),
    const QuestTemplate(
      id: 'financial_saving',
      title: '貯金',
      description: '500円貯金する',
      category: QuestCategory.financial,
      tags: ['貯金', '節約', 'お金'],
      estimatedDuration: Duration(minutes: 1),
      difficulty: DifficultyLevel.easy,
      tips: ['小銭から始める', '自動積立を活用', '目標を設定'],
      icon: '🏦',
    ),
  ];
}

/// テンプレート推薦エンジン
class TemplateRecommendationEngine {
  /// ユーザーの履歴に基づいて推薦
  static List<QuestTemplate> recommend({
    required List<String> completedQuestIds,
    required List<QuestCategory> preferredCategories,
    int limit = 5,
  }) {
    final allTemplates = QuestTemplateRepository.getAllTemplates();
    final scored = <_ScoredTemplate>[];

    for (final template in allTemplates) {
      // 既に完了したクエストは除外
      if (completedQuestIds.contains(template.id)) continue;

      double score = 0.0;

      // カテゴリーマッチ
      if (preferredCategories.contains(template.category)) {
        score += 50.0;
      }

      // 難易度（簡単なものを優先）
      score += (3 - template.difficulty.index) * 10.0;

      // 推定時間（短いものを優先）
      if (template.estimatedDuration.inMinutes <= 15) {
        score += 20.0;
      } else if (template.estimatedDuration.inMinutes <= 30) {
        score += 10.0;
      }

      scored.add(_ScoredTemplate(template, score));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.take(limit).map((s) => s.template).toList();
  }
}

class _ScoredTemplate {
  final QuestTemplate template;
  final double score;

  _ScoredTemplate(this.template, this.score);
}
