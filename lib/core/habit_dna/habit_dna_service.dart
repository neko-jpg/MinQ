import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/repositories/quest_log_repository.dart';
import 'package:minq/domain/habit_dna/habit_archetype.dart';

// Predefined Archetypes
final _archetypes = {
  'the_planner': const HabitArchetype(
    id: 'the_planner',
    name: 'The Planner',
    description:
        'You thrive on structure and planning. Your habits are most successful when scheduled in advance.',
    strengths: ['Consistency', 'Forward-thinking', 'Organization'],
    challenges: ['Spontaneity', 'Adapting to unexpected changes'],
  ),
  'the_sprinter': const HabitArchetype(
    id: 'the_sprinter',
    name: 'The Sprinter',
    description:
        'You work best in short, intense bursts of energy. You are great at starting new things but may lose momentum.',
    strengths: ['High energy', 'Initiative', 'Enthusiasm'],
    challenges: ['Long-term consistency', 'Pacing yourself'],
  ),
  'the_marathoner': const HabitArchetype(
    id: 'the_marathoner',
    name: 'The Marathoner',
    description:
        'Slow and steady wins the race. You excel at building habits over the long term through consistent, daily effort.',
    strengths: ['Endurance', 'Patience', 'Reliability'],
    challenges: [
      'Getting started on new, big goals',
      'Quick bursts of activity',
    ],
  ),
  'the_explorer': const HabitArchetype(
    id: 'the_explorer',
    name: 'The Explorer',
    description:
        'You love variety and trying new things. You are motivated by novelty and may get bored with repetitive tasks.',
    strengths: ['Curiosity', 'Adaptability', 'Trying new things'],
    challenges: ['Sticking to a routine', 'Deepening a single skill'],
  ),
};

// Provider for the service
final habitDNAServiceProvider = Provider<HabitDNAService>((ref) {
  return HabitDNAService(ref.watch(questLogRepositoryProvider));
});

class HabitDNAService {
  final QuestLogRepository _logRepository;

  HabitDNAService(this._logRepository);

  /// Determines the user's habit archetype based on their behavior patterns.
  Future<HabitArchetype?> determineArchetype(String userId) async {
    try {
      // Use local repository instead of Firestore for speed and offline support
      final questLogs = await _logRepository.getLogsForUser(userId);

      // Analyze last 100 logs
      final recentLogs = questLogs.take(100).toList();

      if (recentLogs.length < 10) {
        return null; // Need at least 10 completed quests
      }

      // Metric 1: Time of Day Preference (Morning vs. Evening)
      // Using local time hour
      double averageCompletionHour =
          recentLogs
              .map((log) => log.ts.toLocal().hour)
              .reduce((a, b) => a + b) /
          recentLogs.length;

      // Metric 2: Quest Variety (Planner vs. Explorer)
      final uniqueQuestIds =
          recentLogs.map((log) => log.questId).toSet();
      double varietyRatio = uniqueQuestIds.length / recentLogs.length;

      // Simple classification logic
      if (averageCompletionHour < 14) {
        // Morning person
        return (varietyRatio > 0.7)
            ? _archetypes['the_explorer']
            : _archetypes['the_planner'];
      } else {
        // Evening person
        return (varietyRatio > 0.5)
            ? _archetypes['the_sprinter']
            : _archetypes['the_marathoner'];
      }
    } catch (e) {
      // Use AppLogger in real app, print for now as fallback if logger not available in scope
      // debugPrint('Error determining archetype: $e');
      return null;
    }
  }

  /// Provides personalized strategies based on the user's archetype.
  List<String> getArchetypeStrategies(HabitArchetype archetype) {
    final strategies = <String>[];
    strategies.add('You are The ${archetype.name}!');
    strategies.add("Strengths to leverage: ${archetype.strengths.join(', ')}.");
    strategies.add(
      "Watch out for these challenges: ${archetype.challenges.join(', ')}.",
    );

    // Add custom tips
    switch (archetype.id) {
      case 'the_planner':
        strategies.add(
          'Tip: Set aside time each Sunday to plan your quests for the week.',
        );
        break;
      case 'the_sprinter':
        strategies.add(
          'Tip: Break down large goals into smaller, exciting challenges you can tackle in a day.',
        );
        break;
      case 'the_marathoner':
        strategies.add(
          "Tip: Don't be afraid of slow progress. Your consistency is your superpower.",
        );
        break;
      case 'the_explorer':
        strategies.add(
          'Tip: Rotate your habits every few weeks to keep things fresh and exciting.',
        );
        break;
    }
    return strategies;
  }
}
