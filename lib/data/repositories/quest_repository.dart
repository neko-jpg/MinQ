import 'package:isar/isar.dart';
import 'package:minq/domain/quest/quest.dart';

class QuestRepository {
  QuestRepository(this._isar);

  final Isar _isar;

  static const List<Map<String, dynamic>> _templateSeedData = [
    {
      'title': '英単語を3個音読する',
      'category': '学習',
      'minutes': 3,
      'iconKey': 'book',
    },
    {
      'title': '教科書を1ページ読む',
      'category': '学習',
      'minutes': 5,
      'iconKey': 'book',
    },
    {
      'title': 'ノートを10分見返す',
      'category': '学習',
      'minutes': 10,
      'iconKey': 'memo',
    },
    {
      'title': '授業のポイントを5分まとめる',
      'category': '学習',
      'minutes': 5,
      'iconKey': 'memo',
    },
    {
      'title': '過去問を1問解いてみる',
      'category': '学習',
      'minutes': 15,
      'iconKey': 'calculator',
    },
    {
      'title': '資格テキストを3分眺める',
      'category': '学習',
      'minutes': 3,
      'iconKey': 'certificate',
    },
    {
      'title': 'ニュース記事を1本読む',
      'category': '学習',
      'minutes': 10,
      'iconKey': 'news',
    },
    {
      'title': 'ポモドーロ学習25分',
      'category': '学習',
      'minutes': 25,
      'iconKey': 'timer',
    },
    {
      'title': 'フラッシュカードを10枚復習',
      'category': '学習',
      'minutes': 5,
      'iconKey': 'cards',
    },
    {
      'title': '英作文を1文書く',
      'category': '学習',
      'minutes': 5,
      'iconKey': 'translate',
    },
    {
      'title': 'スクワットを10回する',
      'category': '運動',
      'minutes': 3,
      'iconKey': 'dumbbell',
    },
    {
      'title': '腕立て伏せを5回する',
      'category': '運動',
      'minutes': 3,
      'iconKey': 'dumbbell',
    },
    {
      'title': '体幹プランク30秒×2セット',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'stretch',
    },
    {
      'title': '階段を上り下り1往復',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'stairs',
    },
    {
      'title': '肩と首をほぐすストレッチ',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'stretch',
    },
    {
      'title': 'ラジオ体操を1セット',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'walk',
    },
    {
      'title': 'ジャンピングジャックを20回',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'dumbbell',
    },
    {
      'title': '早歩きで10分歩く',
      'category': '運動',
      'minutes': 10,
      'iconKey': 'walk',
    },
    {
      'title': 'ストレッチポールで10分ほぐす',
      'category': '運動',
      'minutes': 10,
      'iconKey': 'stretch',
    },
    {
      'title': '寝る前ストレッチ5分',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'stretch',
    },
    {
      'title': '机の上を5分片付ける',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'clean',
    },
    {
      'title': '本棚を1段整頓する',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'clean',
    },
    {
      'title': '洗濯物をたたむ',
      'category': '片付け',
      'minutes': 10,
      'iconKey': 'laundry',
    },
    {
      'title': 'ゴミ箱を空にする',
      'category': '片付け',
      'minutes': 3,
      'iconKey': 'trash',
    },
    {
      'title': '玄関を掃き掃除する',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'clean',
    },
    {
      'title': '観葉植物に水をあげる',
      'category': '片付け',
      'minutes': 3,
      'iconKey': 'plant',
    },
    {
      'title': '不要なメモを5枚処分する',
      'category': '片付け',
      'minutes': 3,
      'iconKey': 'trash',
    },
    {
      'title': 'キッチンを5分拭き掃除する',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'clean',
    },
    {
      'title': '明日の持ち物を準備する',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'todo',
    },
    {
      'title': '郵便物を仕分けする',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'todo',
    },
    {
      'title': '起きたら水をコップ1杯飲む',
      'category': '生活',
      'minutes': 1,
      'iconKey': 'water',
    },
    {
      'title': '家計簿を3分更新する',
      'category': '生活',
      'minutes': 3,
      'iconKey': 'finance',
    },
    {
      'title': '今日の予定を3つ確認する',
      'category': '生活',
      'minutes': 3,
      'iconKey': 'todo',
    },
    {
      'title': '明日の服を準備する',
      'category': '生活',
      'minutes': 5,
      'iconKey': 'todo',
    },
    {
      'title': '料理の下ごしらえを10分する',
      'category': '生活',
      'minutes': 10,
      'iconKey': 'cook',
    },
    {
      'title': '部屋の換気を3分する',
      'category': '生活',
      'minutes': 3,
      'iconKey': 'breath',
    },
    {
      'title': '次のゴミの日を確認する',
      'category': '生活',
      'minutes': 3,
      'iconKey': 'trash',
    },
    {
      'title': '自炊メニューを考える',
      'category': '生活',
      'minutes': 5,
      'iconKey': 'cook',
    },
    {
      'title': '気分転換に散歩10分',
      'category': '生活',
      'minutes': 10,
      'iconKey': 'walk',
    },
    {
      'title': '就寝前に照明を落とす時間を作る',
      'category': '生活',
      'minutes': 5,
      'iconKey': 'moon',
    },
    {
      'title': '深呼吸を5回行う',
      'category': 'セルフケア',
      'minutes': 3,
      'iconKey': 'breath',
    },
    {
      'title': '1分瞑想をする',
      'category': 'セルフケア',
      'minutes': 1,
      'iconKey': 'mind',
    },
    {
      'title': '感謝を1つ書き出す',
      'category': 'セルフケア',
      'minutes': 3,
      'iconKey': 'smile',
    },
    {
      'title': '好きな音楽を5分聴く',
      'category': 'セルフケア',
      'minutes': 5,
      'iconKey': 'music',
    },
    {
      'title': '目を温めるホットタオル',
      'category': 'セルフケア',
      'minutes': 5,
      'iconKey': 'mind',
    },
    {
      'title': '足湯でリラックス5分',
      'category': 'セルフケア',
      'minutes': 5,
      'iconKey': 'water',
    },
    {
      'title': 'スクリーンを10分オフにする',
      'category': 'セルフケア',
      'minutes': 10,
      'iconKey': 'digital_detox',
    },
    {
      'title': '日記を3行書く',
      'category': 'セルフケア',
      'minutes': 5,
      'iconKey': 'journal',
    },
    {
      'title': '寝る前ストレッチ3分',
      'category': 'セルフケア',
      'minutes': 3,
      'iconKey': 'stretch',
    },
    {
      'title': 'セルフマッサージを3分する',
      'category': 'セルフケア',
      'minutes': 3,
      'iconKey': 'mind',
    },
  ];

  Future<List<Quest>> getAllQuests() async {
    return _isar.quests
        .filter()
        .deletedAtIsNull()
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<Quest>> getTemplateQuests() async {
    return _isar.quests
        .filter()
        .ownerEqualTo('template')
        .deletedAtIsNull()
        .findAll();
  }

  Future<List<Quest>> getQuestsForOwner(String owner) async {
    return _isar.quests
        .filter()
        .ownerEqualTo(owner)
        .deletedAtIsNull()
        .findAll();
  }

  Future<Quest?> getQuestById(int id) =>
      _isar.quests.filter().idEqualTo(id).deletedAtIsNull().findFirst();

  Future<void> addQuest(Quest quest) async {
    if (quest.estimatedMinutes <= 0) {
      quest.estimatedMinutes = 5;
    }
    quest.status = QuestStatus.active;
    await _isar.writeTxn(() async {
      await _isar.quests.put(quest);
    });
  }

  Future<void> updateQuest(Quest quest) async {
    if (quest.estimatedMinutes <= 0) {
      quest.estimatedMinutes = 5;
    }
    await _isar.writeTxn(() async {
      await _isar.quests.put(quest);
    });
  }

  Future<void> reorderQuests(List<Quest> quests) async {
    await _isar.writeTxn(() async {
      for (int i = 0; i < quests.length; i++) {
        // TODO: Add sortOrder field to Quest model
        // quests[i].sortOrder = i;
        await _isar.quests.put(quests[i]);
      }
    });
  }

  Future<void> deleteQuest(int id) async {
    await _isar.writeTxn(() async {
      final quest = await getQuestById(id);
      if (quest != null) {
        quest.deletedAt = DateTime.now();
        await _isar.quests.put(quest);
      }
    });
  }

  Future<void> pauseQuest(int id) async {
    await _isar.writeTxn(() async {
      final quest = await getQuestById(id);
      if (quest != null) {
        quest.status = QuestStatus.paused;
        await _isar.quests.put(quest);
      }
    });
  }

  Future<void> resumeQuest(int id) async {
    await _isar.writeTxn(() async {
      final quest = await getQuestById(id);
      if (quest != null) {
        quest.status = QuestStatus.active;
        await _isar.quests.put(quest);
      }
    });
  }

  Future<void> seedInitialQuests() async {
    final existingTemplates =
        await _isar.quests.filter().ownerEqualTo('template').findAll();
    final existingByTitle = {
      for (final quest in existingTemplates) quest.title: quest,
    };

    final updates = <Quest>[];
    final now = DateTime.now();

    for (final data in _templateSeedData) {
      final title = data['title'] as String;
      final category = data['category'] as String;
      final minutes = data['minutes'] as int;
      final iconKey = data['iconKey'] as String?;

      final current = existingByTitle[title];
      if (current != null) {
        var changed = false;
        if (current.category != category) {
          current.category = category;
          changed = true;
        }
        if (current.estimatedMinutes != minutes) {
          current.estimatedMinutes = minutes;
          changed = true;
        }
        if (current.iconKey != iconKey) {
          current.iconKey = iconKey;
          changed = true;
        }
        if (changed) {
          updates.add(current);
        }
      } else {
        final quest = Quest()
          ..owner = 'template'
          ..title = title
          ..category = category
          ..estimatedMinutes = minutes
          ..iconKey = iconKey
          ..status = QuestStatus.active
          ..createdAt = now;
        updates.add(quest);
      }
    }

    if (updates.isEmpty) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.quests.putAll(updates);
    });
  }
}
