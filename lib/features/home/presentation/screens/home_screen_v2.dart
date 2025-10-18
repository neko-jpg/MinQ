import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/gemma_ai_service.dart';
import 'package:minq/core/progress/progress_visualization_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/core/challenges/challenge_service.dart';

// A dummy user ID for now
const _userId = 'test_user';

// Data class for the progress section
class HomeProgressData {
  final int streak;
  final int completedQuests;
  final int totalQuests;
  HomeProgressData({required this.streak, required this.completedQuests, required this.totalQuests});
}

final homeProgressProvider = FutureProvider.autoDispose<HomeProgressData>((ref) async {
  final progressService = ref.watch(progressVisualizationServiceProvider);

  // Fetch streak
  final streak = await progressService.calculateStreak(_userId);

  // Fetch today's quests
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

  final questSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(_userId)
      .collection('quests')
      .where('createdAt', isGreaterThanOrEqualTo: startOfDay, isLessThanOrEqualTo: endOfDay)
      .get();

  final totalQuests = questSnapshot.docs.length;
  final completedQuests = questSnapshot.docs.where((doc) => doc.data()['completed'] == true).length;

  return HomeProgressData(streak: streak, completedQuests: completedQuests, totalQuests: totalQuests);
});


class HomeScreenV2 extends ConsumerWidget {
  const HomeScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MinQ"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () { /* Navigate to notifications */ },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          // Placeholder for AI Daily Encouragement (Task 15.1)
          _AiEncouragementCard(),
          SizedBox(height: 16),

          // Placeholder for Streak Counter & Progress (Task 15.1)
          _StreakAndProgressSection(),
          SizedBox(height: 24),

          // Placeholder for Today's Pending Quests (Task 15.1)
          _TodaysQuestsSection(),
          SizedBox(height: 24),

          // Placeholder for Active Challenges (Task 15.1)
          _ActiveChallengesSection(),
        ],
      ),
    );
  }
}

// Provider to generate a daily motivational quote
final dailyQuoteProvider = FutureProvider.autoDispose<String>((ref) async {
  final gemmaService = ref.watch(gemmaAIServiceProvider);
  // This prompt is an example. It could be more dynamic.
  return await gemmaService.generateText(
      "Write a short, uplifting, one-sentence motivational quote for someone starting their day.");
});

class _AiEncouragementCard extends ConsumerWidget {
  const _AiEncouragementCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(dailyQuoteProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: quoteAsync.when(
          data: (quote) => Text(quote, style: const TextStyle(fontStyle: FontStyle.italic)),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text("AIからのメッセージ取得に失敗: $err"),
        ),
      ),
    );
  }
}

class _StreakAndProgressSection extends ConsumerWidget {
  const _StreakAndProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(homeProgressProvider);
    return progressAsync.when(
      data: (data) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ProgressTile(
            icon: const Text("🔥", style: TextStyle(fontSize: 24)),
            value: "${data.streak}日",
            label: "継続中",
          ),
          _ProgressTile(
            icon: const Icon(Icons.check_circle_outline, size: 28, color: Colors.green),
            value: "${data.completedQuests}/${data.totalQuests}",
            label: "今日のクエスト",
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text("進捗の読込に失敗")),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({required this.icon, required this.value, required this.label});
  final Widget icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

final todaysQuestsProvider = StreamProvider.autoDispose<List<QueryDocumentSnapshot>>((ref) {
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(_userId)
      .collection('quests')
      .where('createdAt', isGreaterThanOrEqualTo: startOfDay, isLessThanOrEqualTo: endOfDay)
      .snapshots()
      .map((snapshot) => snapshot.docs);
});

final questCompletionProvider = Provider((ref) {
  return (String questId, String questName) async {
    final firestore = FirebaseFirestore.instance;
    final gamification = ref.read(gamificationEngineProvider);
    final challenges = ref.read(challengeServiceProvider);

    // 1. Mark quest as complete
    await firestore.collection('users').doc(_userId).collection('quests').doc(questId).update({'completed': true});

    // 2. Log completion
    await firestore.collection('users').doc(_userId).collection('quest_logs').add({
      'questId': questId,
      'name': questName,
      'completedAt': FieldValue.serverTimestamp(),
    });

    // 3. Award points
    await gamification.awardPoints(userId: _userId, basePoints: 10, reason: "Completed quest: $questName");

    // 4. Update challenges
    final dailyChallengeId = 'daily_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}';
    await challenges.updateProgress(userId: _userId, challengeId: dailyChallengeId, incrementBy: 1);

    // 5. Invalidate providers to refresh UI
    ref.invalidate(homeProgressProvider);
    ref.invalidate(todaysQuestsProvider);
  };
});


class _TodaysQuestsSection extends ConsumerWidget {
  const _TodaysQuestsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(todaysQuestsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("今日のクエスト", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        questsAsync.when(
          data: (docs) {
            if (docs.isEmpty) {
              return const Center(child: Text("今日のクエストはありません。"));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final bool isCompleted = data['completed'] ?? false;
                return ListTile(
                  leading: Icon(isCompleted ? Icons.check_circle : Icons.circle_outlined),
                  title: Text(data['name'], style: TextStyle(decoration: isCompleted ? TextDecoration.lineThrough : null)),
                  trailing: IconButton(
                    icon: Icon(isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
                    onPressed: isCompleted ? null : () {
                      ref.read(questCompletionProvider)(doc.id, data['name']);
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Center(child: Text("クエストの読込に失敗")),
        ),
      ],
    );
  }
}

final activeChallengesProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  final firestore = FirebaseFirestore.instance;
  final challengeProgressStream = firestore
      .collection('users')
      .doc(_userId)
      .collection('challenge_progress')
      .where('completed', isEqualTo: false)
      .snapshots();

  await for (var snapshot in challengeProgressStream) {
    final challengesData = <Map<String, dynamic>>[];
    for (var doc in snapshot.docs) {
      final progressData = doc.data();
      final challengeId = progressData['challengeId'];

      final challengeDoc = await firestore.collection('challenges').doc(challengeId).get();
      if (challengeDoc.exists) {
        challengesData.add({
          'challenge': challengeDoc.data(),
          'progress': progressData,
        });
      }
    }
    yield challengesData;
  }
});

class _ActiveChallengesSection extends ConsumerWidget {
  const _ActiveChallengesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(activeChallengesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("挑戦中のチャレンジ", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        challengesAsync.when(
          data: (challenges) {
            if (challenges.isEmpty) {
              return const Card(child: ListTile(title: Text("挑戦中のチャレンジはありません。")));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challengeData = challenges[index];
                final challenge = challengeData['challenge'];
                final progress = challengeData['progress'];
                final goal = challenge['goal'] as int;
                final current = progress['progress'] as int;
                final progressValue = (current / goal).clamp(0.0, 1.0);

                return Card(
                  child: ListTile(
                    title: Text(challenge['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        LinearProgressIndicator(value: progressValue),
                        const SizedBox(height: 4),
                        Text("$current / $goal"),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Center(child: Text("チャレンジの読込に失敗")),
        ),
      ],
    );
  }
}