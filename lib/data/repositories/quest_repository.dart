import 'package:isar/isar.dart';
import 'package:minq/domain/quest/quest.dart';

class QuestRepository {
  QuestRepository(this._isar);

  final Isar _isar;

  static const List<Map<String, dynamic>> _templateSeedData = [
    {
      'title': 'quest_read_english_3min',
      'category': '学習',
      'minutes': 3,
      'iconKey': 'book',
    },
    {
      'title': 'quest_read_textbook_1page',
      'category': '学習',
      'minutes': 5,
      'iconKey': 'book',
    },
    {
      'title': 'quest_review_notes_10min',
      'category': '学習',
      'minutes': 10,
      'iconKey': 'memo',
    },
    {
      'title': 'quest_summarize_class_5min',
      'category': '学習',
      'minutes': 5,
      'iconKey': 'memo',
    },
    {
      'title': 'quest_solve_past_exam_1q',
      'category': '学習',
      'minutes': 15,
      'iconKey': 'calculator',
    },
    {
      'title': 'quest_view_cert_text_3min',
      'category': '学習',
      'minutes': 3,
      'iconKey': 'certificate',
    },
    {
      'title': 'quest_read_news_10min',
      'category': '学習',
      'minutes': 10,
      'iconKey': 'news',
    },
    {
      'title': 'quest_pomodoro_25min',
      'category': '学習',
      'minutes': 25,
      'iconKey': 'timer',
    },
    {
      'title': 'quest_review_flashcards_10',
      'category': '学習',
      'minutes': 5,
      'iconKey': 'cards',
    },
    {
      'title': 'quest_write_english_sentence',
      'category': '学習',
      'minutes': 5,
      'iconKey': 'translate',
    },
    {
      'title': 'quest_squat_10',
      'category': '運動',
      'minutes': 3,
      'iconKey': 'dumbbell',
    },
    {
      'title': 'quest_pushup_5',
      'category': '運動',
      'minutes': 3,
      'iconKey': 'dumbbell',
    },
    {
      'title': 'quest_plank_30s_2',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'stretch',
    },
    {
      'title': 'quest_stairs_round_trip',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'stairs',
    },
    {
      'title': 'quest_stretch_neck_shoulder',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'stretch',
    },
    {
      'title': 'quest_radio_calisthenics',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'walk',
    },
    {
      'title': 'quest_jumping_jacks_20',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'dumbbell',
    },
    {
      'title': 'quest_brisk_walk_10min',
      'category': '運動',
      'minutes': 10,
      'iconKey': 'walk',
    },
    {
      'title': 'quest_stretch_pole_10min',
      'category': '運動',
      'minutes': 10,
      'iconKey': 'stretch',
    },
    {
      'title': 'quest_stretch_before_bed_5min',
      'category': '運動',
      'minutes': 5,
      'iconKey': 'stretch',
    },
    {
      'title': 'quest_tidy_desk_5min',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'clean',
    },
    {
      'title': 'quest_organize_bookshelf_1shelf',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'clean',
    },
    {
      'title': 'quest_fold_laundry',
      'category': '片付け',
      'minutes': 10,
      'iconKey': 'laundry',
    },
    {
      'title': 'quest_empty_trash',
      'category': '片付け',
      'minutes': 3,
      'iconKey': 'trash',
    },
    {
      'title': 'quest_sweep_entrance',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'clean',
    },
    {
      'title': 'quest_water_plants',
      'category': '片付け',
      'minutes': 3,
      'iconKey': 'plant',
    },
    {
      'title': 'quest_discard_5_notes',
      'category': '片付け',
      'minutes': 3,
      'iconKey': 'trash',
    },
    {
      'title': 'quest_wipe_kitchen_5min',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'clean',
    },
    {
      'title': 'quest_prepare_tomorrow_items',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'todo',
    },
    {
      'title': 'quest_sort_mail',
      'category': '片付け',
      'minutes': 5,
      'iconKey': 'todo',
    },
    {
      'title': 'quest_drink_water_morning',
      'category': '生活',
      'minutes': 1,
      'iconKey': 'water',
    },
    {
      'title': 'quest_update_budget_3min',
      'category': '生活',
      'minutes': 3,
      'iconKey': 'finance',
    },
    {
      'title': 'quest_check_schedule_3',
      'category': '生活',
      'minutes': 3,
      'iconKey': 'todo',
    },
    {
      'title': 'quest_prepare_tomorrow_clothes',
      'category': '生活',
      'minutes': 5,
      'iconKey': 'todo',
    },
    {
      'title': 'quest_meal_prep_10min',
      'category': '生活',
      'minutes': 10,
      'iconKey': 'cook',
    },
    {
      'title': 'quest_ventilate_room_3min',
      'category': '生活',
      'minutes': 3,
      'iconKey': 'breath',
    },
    {
      'title': 'quest_check_garbage_day',
      'category': '生活',
      'minutes': 3,
      'iconKey': 'trash',
    },
    {
      'title': 'quest_plan_meal_menu',
      'category': '生活',
      'minutes': 5,
      'iconKey': 'cook',
    },
    {
      'title': 'quest_walk_refresh_10min',
      'category': '生活',
      'minutes': 10,
      'iconKey': 'walk',
    },
    {
      'title': 'quest_dim_lights_before_bed',
      'category': '生活',
      'minutes': 5,
      'iconKey': 'moon',
    },
    {
      'title': 'quest_deep_breath_5',
      'category': 'セルフケア',
      'minutes': 3,
      'iconKey': 'breath',
    },
    {
      'title': 'quest_meditate_1min',
      'category': 'セルフケア',
      'minutes': 1,
      'iconKey': 'mind',
    },
    {
      'title': 'quest_write_gratitude_1',
      'category': 'セルフケア',
      'minutes': 3,
      'iconKey': 'smile',
    },
    {
      'title': 'quest_listen_music_5min',
      'category': 'セルフケア',
      'minutes': 5,
      'iconKey': 'music',
    },
    {
      'title': 'quest_hot_towel_eyes',
      'category': 'セルフケア',
      'minutes': 5,
      'iconKey': 'mind',
    },
    {
      'title': 'quest_foot_bath_5min',
      'category': 'セルフケア',
      'minutes': 5,
      'iconKey': 'water',
    },
    {
      'title': 'quest_screen_off_10min',
      'category': 'セルフケア',
      'minutes': 10,
      'iconKey': 'digital_detox',
    },
    {
      'title': 'quest_journal_3_lines',
      'category': 'セルフケア',
      'minutes': 5,
      'iconKey': 'journal',
    },
    {
      'title': 'quest_stretch_before_bed_3min',
      'category': 'セルフケア',
      'minutes': 3,
      'iconKey': 'stretch',
    },
    {
      'title': 'quest_self_massage_3min',
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
        final quest =
            Quest()
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
