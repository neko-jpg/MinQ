import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/habit_dna/habit_archetype.dart';

// Predefined Archetypes
final _archetypes = {
  'the_planner': HabitArchetype(
    id: 'the_planner',
    name: 'The Planner',
    description: 'You thrive on structure and planning. Your habits are most successful when scheduled in advance.',
    strengths: ['Consistency', 'Forward-thinking', 'Organization'],
    challenges: ['Spontaneity', 'Adapting to unexpected changes'],
  ),
  'the_sprinter': HabitArchetype(
    id: 'the_sprinter',
    name: 'The Sprinter',
    description: 'You work best in short, intense bursts of energy. You are great at starting new things but may lose momentum.',
    strengths: ['High energy', 'Initiative', 'Enthusiasm'],
    challenges: ['Long-term consistency', 'Pacing yourself'],
  ),
  'the_marathoner': HabitArchetype(
    id: 'the_marathoner',
    name: 'The Marathoner',
    description: 'Slow and steady wins the race. You excel at building habits over the long term through consistent, daily effort.',
    strengths: ['Endurance', 'Patience', 'Reliability'],
    challenges: ['Getting started on new, big goals', 'Quick bursts of activity'],
  ),
  'the_explorer': HabitArchetype(
    id: 'the_explorer',
    name: 'The Explorer',
    description: 'You love variety and trying new things. You are motivated by novelty and may get bored with repetitive tasks.',
    strengths: ['Curiosity', 'Adaptability', 'Trying new things'],
    challenges: ['Sticking to a routine', 'Deepening a single skill'],
  ),
};

// Provider for the service
final habitDNAServiceProvider = Provider<HabitDNAService>((ref) {
  return HabitDNAService(FirebaseFirestore.instance);
});

class HabitDNAService {
  final FirebaseFirestore _firestore;

  HabitDNAService(this._firestore);

  /// Determines the user's habit archetype based on their behavior patterns.
  Future<HabitArchetype?> determineArchetype(String userId) async {
    print("Determining habit archetype for user $userId.");
    try {
      final questLogsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quest_logs')
          .limit(100)
          .get();

      if (questLogsSnapshot.docs.length < 10) {
        print("Not enough data to determine archetype.");
        return null; // Need at least 10 completed quests
      }

      final questLogs = questLogsSnapshot.docs.map((doc) => doc.data()).toList();

      // Metric 1: Time of Day Preference (Morning vs. Evening)
      double averageCompletionHour = questLogs
          .map((log) => (log['completedAt'] as Timestamp).toDate().hour)
          .reduce((a, b) => a + b) / questLogs.length;

      // Metric 2: Quest Variety (Planner vs. Explorer)
      final uniqueQuestNames = questLogs.map((log) => log['name'] as String).toSet();
      double varietyRatio = uniqueQuestNames.length / questLogs.length;

      // Simple classification logic
      if (averageCompletionHour < 14) { // Morning person
        return (varietyRatio > 0.7) ? _archetypes['the_explorer'] : _archetypes['the_planner'];
      } else { // Evening person
        return (varietyRatio > 0.5) ? _archetypes['the_sprinter'] : _archetypes['the_marathoner'];
      }
    } catch (e) {
      print("Error determining archetype: $e");
      return null;
    }
  }

  /// Provides personalized strategies based on the user's archetype.
  List<String> getArchetypeStrategies(HabitArchetype archetype) {
    final strategies = <String>[];
    strategies.add("You are The ${archetype.name}!");
    strategies.add("Strengths to leverage: ${archetype.strengths.join(', ')}.");
    strategies.add("Watch out for these challenges: ${archetype.challenges.join(', ')}.");

    // Add custom tips
    switch(archetype.id) {
      case 'the_planner':
        strategies.add("Tip: Set aside time each Sunday to plan your quests for the week.");
        break;
      case 'the_sprinter':
        strategies.add("Tip: Break down large goals into smaller, exciting challenges you can tackle in a day.");
        break;
      case 'the_marathoner':
         strategies.add("Tip: Don't be afraid of slow progress. Your consistency is your superpower.");
        break;
      case 'the_explorer':
        strategies.add("Tip: Rotate your habits every few weeks to keep things fresh and exciting.");
        break;
    }
    return strategies;
  }
}