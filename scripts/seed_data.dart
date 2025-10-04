import 'dart:math';

/// 開発用データシードスクリプト
/// テスト用のダミーデータを生成
class DataSeeder {
  final Random _random = Random();

  /// ランダムなクエストを生成
  Map<String, dynamic> generateQuest({int? id}) {
    final titles = [
      '朝ランニング',
      '読書30分',
      '瞑想10分',
      '英語学習',
      '筋トレ',
      '日記を書く',
      '水を2L飲む',
      'ストレッチ',
      'プログラミング学習',
      '早起き',
    ];

    final categories = ['健康', '学習', '生産性', 'マインドフルネス'];
    final difficulties = ['easy', 'medium', 'hard'];
    final locations = ['home', 'gym', 'office', 'outdoor'];

    return {
      'id': id ?? _random.nextInt(10000),
      'title': titles[_random.nextInt(titles.length)],
      'category': categories[_random.nextInt(categories.length)],
      'estimatedMinutes': [5, 10, 15, 30, 60][_random.nextInt(5)],
      'difficulty': difficulties[_random.nextInt(difficulties.length)],
      'location': locations[_random.nextInt(locations.length)],
      'iconKey': 'spa',
      'status': 'active',
      'createdAt': DateTime.now().subtract(Duration(days: _random.nextInt(30))),
    };
  }

  /// ランダムなクエストログを生成
  Map<String, dynamic> generateQuestLog({
    required int questId,
    required String userId,
  }) {
    final now = DateTime.now();
    final daysAgo = _random.nextInt(30);
    final completedAt = now.subtract(Duration(days: daysAgo));

    return {
      'questId': questId,
      'userId': userId,
      'completedAt': completedAt,
      'note': _random.nextBool() ? 'よくできました！' : null,
    };
  }

  /// ランダムなユーザーを生成
  Map<String, dynamic> generateUser({String? uid}) {
    final firstNames = ['太郎', '花子', '健太', '美咲', '大輔', '愛', '翔太', '結衣'];
    final lastNames = ['田中', '佐藤', '鈴木', '高橋', '渡辺', '伊藤', '山本', '中村'];

    final firstName = firstNames[_random.nextInt(firstNames.length)];
    final lastName = lastNames[_random.nextInt(lastNames.length)];

    return {
      'uid': uid ?? 'user_${_random.nextInt(100000)}',
      'displayName': '$lastName$firstName',
      'email': '${firstName.toLowerCase()}@example.com',
      'createdAt': DateTime.now().subtract(Duration(days: _random.nextInt(365))),
      'currentStreak': _random.nextInt(30),
      'longestStreak': _random.nextInt(100),
      'notificationTimes': ['07:30', '21:00'],
      'privacy': 'private',
    };
  }

  /// ランダムなアチーブメント進捗を生成
  Map<String, dynamic> generateAchievementProgress({
    required String userId,
    required String achievementId,
  }) {
    const maxProgress = 100;
    final current = _random.nextInt(maxProgress);

    return {
      'userId': userId,
      'achievementId': achievementId,
      'current': current,
      'unlocked': current >= maxProgress,
      'unlockedAt': current >= maxProgress 
          ? DateTime.now().subtract(Duration(days: _random.nextInt(30)))
          : null,
    };
  }

  /// 複数のクエストを生成
  List<Map<String, dynamic>> generateQuests(int count) {
    return List.generate(count, (index) => generateQuest(id: index + 1));
  }

  /// 複数のクエストログを生成
  List<Map<String, dynamic>> generateQuestLogs({
    required int questId,
    required String userId,
    required int count,
  }) {
    return List.generate(
      count,
      (index) => generateQuestLog(questId: questId, userId: userId),
    );
  }

  /// 複数のユーザーを生成
  List<Map<String, dynamic>> generateUsers(int count) {
    return List.generate(count, (index) => generateUser());
  }

  /// 完全なテストデータセットを生成
  Map<String, dynamic> generateFullDataset({
    int questCount = 10,
    int userCount = 5,
    int logsPerQuest = 20,
  }) {
    final users = generateUsers(userCount);
    final quests = generateQuests(questCount);
    final logs = <Map<String, dynamic>>[];

    for (final quest in quests) {
      for (final user in users) {
        logs.addAll(generateQuestLogs(
          questId: quest['id'] as int,
          userId: user['uid'] as String,
          count: logsPerQuest,
        ),);
      }
    }

    return {
      'users': users,
      'quests': quests,
      'logs': logs,
      'metadata': {
        'generatedAt': DateTime.now().toIso8601String(),
        'userCount': userCount,
        'questCount': questCount,
        'logCount': logs.length,
      },
    };
  }
}

/// Fakerライクなユーティリティ
class Faker {
  static final Random _random = Random();

  /// ランダムな名前
  static String name() {
    final firstNames = ['太郎', '花子', '健太', '美咲', '大輔', '愛', '翔太', '結衣'];
    final lastNames = ['田中', '佐藤', '鈴木', '高橋', '渡辺', '伊藤', '山本', '中村'];
    return '${lastNames[_random.nextInt(lastNames.length)]}${firstNames[_random.nextInt(firstNames.length)]}';
  }

  /// ランダムなメールアドレス
  static String email() {
    final domains = ['example.com', 'test.com', 'demo.com'];
    final username = 'user${_random.nextInt(10000)}';
    return '$username@${domains[_random.nextInt(domains.length)]}';
  }

  /// ランダムな日付
  static DateTime date({int maxDaysAgo = 365}) {
    return DateTime.now().subtract(Duration(days: _random.nextInt(maxDaysAgo)));
  }

  /// ランダムな整数
  static int integer({int min = 0, int max = 100}) {
    return min + _random.nextInt(max - min);
  }

  /// ランダムなブール値
  static bool boolean() {
    return _random.nextBool();
  }

  /// ランダムな文字列
  static String text({int wordCount = 10}) {
    final words = [
      'これは', 'テスト', 'データ', 'です', 'ランダム', '生成',
      'サンプル', '開発', '用途', 'ダミー', '文字列', '日本語',
    ];
    final selectedWords = List.generate(
      wordCount,
      (_) => words[_random.nextInt(words.length)],
    );
    return selectedWords.join('');
  }
}

void main() {
  final seeder = DataSeeder();
  
  // サンプルデータ生成
  print('=== データシード開始 ===');
  
  final dataset = seeder.generateFullDataset(
    questCount: 5,
    userCount: 3,
    logsPerQuest: 10,
  );
  
  print('ユーザー数: ${dataset['users'].length}');
  print('クエスト数: ${dataset['quests'].length}');
  print('ログ数: ${dataset['logs'].length}');
  
  print('\n=== サンプルユーザー ===');
  for (final user in (dataset['users'] as List).take(2)) {
    print('${user['displayName']} (${user['email']})');
  }
  
  print('\n=== サンプルクエスト ===');
  for (final quest in (dataset['quests'] as List).take(3)) {
    print('${quest['title']} - ${quest['category']} (${quest['estimatedMinutes']}分)');
  }
  
  print('\n=== データシード完了 ===');
}
