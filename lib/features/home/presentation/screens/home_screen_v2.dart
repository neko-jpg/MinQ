import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _AiEncouragementCard extends StatelessWidget {
  const _AiEncouragementCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("今日も一日、あなたの挑戦を応援しています！"), // Placeholder text
      ),
    );
  }
}

class _StreakAndProgressSection extends StatelessWidget {
  const _StreakAndProgressSection();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text("🔥", style: TextStyle(fontSize: 24)),
            Text("12日", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("継続中"),
          ],
        ),
        Column(
          children: [
            Icon(Icons.check_circle_outline, size: 28, color: Colors.green),
            Text("3/5", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("今日のクエスト"),
          ],
        ),
      ],
    );
  }
}

class _TodaysQuestsSection extends StatelessWidget {
  const _TodaysQuestsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("今日のクエスト", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        // Placeholder for one-tap quest recording (Task 15.2)
        ListTile(
          leading: const Icon(Icons.directions_run),
          title: const Text("朝のランニング"),
          trailing: IconButton(
            icon: const Icon(Icons.check_box_outline_blank),
            onPressed: () { /* Implement one-tap completion */ },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.book),
          title: const Text("読書を15分する"),
          trailing: IconButton(
            icon: const Icon(Icons.check_box_outline_blank),
            onPressed: () { /* Implement one-tap completion */ },
          ),
        ),
      ],
    );
  }
}

class _ActiveChallengesSection extends StatelessWidget {
  const _ActiveChallengesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("挑戦中のチャレンジ", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(
            title: Text("7日間連続ストリーク"),
            subtitle: LinearProgressIndicator(value: 0.5), // Placeholder progress
          ),
        ),
      ],
    );
  }
}