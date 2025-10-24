/// イベントシステム
/// 期間限定クエストやチャレンジを管理
class EventSystem {
  final List<Event> _events = [];

  EventSystem() {
    _initializeEvents();
  }

  void _initializeEvents() {
    // サンプルイベント
    _events.addAll([
      Event(
        id: 'new_year_2025',
        title: '新年チャレンジ',
        description: '新しい年を新しい習慣で始めよう！',
        icon: '🎊',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 31),
        type: EventType.challenge,
        rewards: [
          const EventReward(
            id: 'new_year_badge',
            title: '新年バッジ',
            description: '新年チャレンジ完了',
            icon: '🏆',
          ),
        ],
        requirements: const EventRequirements(minCompletions: 21, minStreak: 7),
      ),
      Event(
        id: 'spring_fitness',
        title: '春の運動習慣',
        description: '春に向けて体を動かそう',
        icon: '🌸',
        startDate: DateTime(2025, 3, 1),
        endDate: DateTime(2025, 3, 31),
        type: EventType.seasonal,
        category: 'health',
        rewards: [
          const EventReward(
            id: 'spring_badge',
            title: '春の運動バッジ',
            description: '春の運動習慣完了',
            icon: '🏃',
          ),
        ],
        requirements: const EventRequirements(
          minCompletions: 15,
          categoryRequired: 'health',
        ),
      ),
      Event(
        id: 'reading_week',
        title: '読書週間',
        description: '1週間毎日読書しよう',
        icon: '📚',
        startDate: DateTime(2025, 4, 23),
        endDate: DateTime(2025, 4, 29),
        type: EventType.weekly,
        category: 'learning',
        rewards: [
          const EventReward(
            id: 'reading_badge',
            title: '読書家バッジ',
            description: '読書週間完了',
            icon: '📖',
          ),
        ],
        requirements: const EventRequirements(
          minCompletions: 7,
          minStreak: 7,
          categoryRequired: 'learning',
        ),
      ),
    ]);
  }

  /// アクティブなイベントを取得
  List<Event> getActiveEvents() {
    final now = DateTime.now();
    return _events.where((event) {
      return now.isAfter(event.startDate) && now.isBefore(event.endDate);
    }).toList();
  }

  /// 今後のイベントを取得
  List<Event> getUpcomingEvents() {
    final now = DateTime.now();
    return _events.where((event) {
        return now.isBefore(event.startDate);
      }).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  /// 過去のイベントを取得
  List<Event> getPastEvents() {
    final now = DateTime.now();
    return _events.where((event) {
        return now.isAfter(event.endDate);
      }).toList()
      ..sort((a, b) => b.endDate.compareTo(a.endDate));
  }

  /// イベント進捗を計算
  EventProgress calculateProgress(Event event, List<DateTime> completions) {
    final eventCompletions =
        completions.where((completion) {
          return completion.isAfter(event.startDate) &&
              completion.isBefore(event.endDate);
        }).toList();

    final completionCount = eventCompletions.length;
    final currentStreak = _calculateEventStreak(eventCompletions, event);

    final isCompleted =
        completionCount >= event.requirements.minCompletions &&
        currentStreak >= event.requirements.minStreak;

    return EventProgress(
      eventId: event.id,
      completionCount: completionCount,
      currentStreak: currentStreak,
      isCompleted: isCompleted,
      progress: completionCount / event.requirements.minCompletions,
    );
  }

  int _calculateEventStreak(List<DateTime> completions, Event event) {
    if (completions.isEmpty) return 0;

    completions.sort((a, b) => b.compareTo(a));
    int streak = 1;
    DateTime lastDate = completions.first;

    for (int i = 1; i < completions.length; i++) {
      final diff = lastDate.difference(completions[i]).inDays;
      if (diff == 1) {
        streak++;
        lastDate = completions[i];
      } else {
        break;
      }
    }

    return streak;
  }
}

/// イベント
class Event {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime startDate;
  final DateTime endDate;
  final EventType type;
  final String? category;
  final List<EventReward> rewards;
  final EventRequirements requirements;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.category,
    required this.rewards,
    required this.requirements,
  });

  Duration get duration => endDate.difference(startDate);
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
}

/// イベントタイプ
enum EventType {
  challenge, // チャレンジ
  seasonal, // 季節イベント
  weekly, // 週次イベント
  special, // 特別イベント
}

/// イベント報酬
class EventReward {
  final String id;
  final String title;
  final String description;
  final String icon;

  const EventReward({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// イベント要件
class EventRequirements {
  final int minCompletions;
  final int minStreak;
  final String? categoryRequired;

  const EventRequirements({
    required this.minCompletions,
    this.minStreak = 0,
    this.categoryRequired,
  });
}

/// イベント進捗
class EventProgress {
  final String eventId;
  final int completionCount;
  final int currentStreak;
  final bool isCompleted;
  final double progress;

  const EventProgress({
    required this.eventId,
    required this.completionCount,
    required this.currentStreak,
    required this.isCompleted,
    required this.progress,
  });
}

/// イベントランキング
class EventRanking {
  final String eventId;
  final List<EventRankingEntry> entries;

  const EventRanking({required this.eventId, required this.entries});
}

/// ランキングエントリー
class EventRankingEntry {
  final String userId;
  final String username;
  final int completionCount;
  final int rank;

  const EventRankingEntry({
    required this.userId,
    required this.username,
    required this.completionCount,
    required this.rank,
  });
}
