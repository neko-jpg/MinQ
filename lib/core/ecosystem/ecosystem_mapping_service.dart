import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the service
final ecosystemMappingServiceProvider = Provider<EcosystemMappingService>((ref) {
  return EcosystemMappingService(FirebaseFirestore.instance);
});

class EcosystemMappingService {
  final FirebaseFirestore _firestore;

  EcosystemMappingService(this._firestore);

  /// Analyzes the correlations and interdependencies between a user's habits.
  Future<Map<String, dynamic>> analyzeEcosystem(String userId) async {
    print("Analyzing habit ecosystem for user $userId.");
    final questLogsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('quest_logs')
        .orderBy('completedAt', descending: true)
        .limit(500) // Use a reasonable limit for performance
        .get();

    if (questLogsSnapshot.docs.length < 20) {
      print("Not enough data to analyze ecosystem.");
      return {};
    }

    // Group completions by day
    final dailyCompletions = <DateTime, Set<String>>{};
    for (final doc in questLogsSnapshot.docs) {
      final data = doc.data();
      final date = (data['completedAt'] as Timestamp).toDate();
      final dayOnly = DateTime(date.year, date.month, date.day);
      final questName = data['name'] as String;

      dailyCompletions.putIfAbsent(dayOnly, () => {}).add(questName);
    }

    // Calculate co-occurrence
    final coOccurrenceMatrix = <String, Map<String, int>>{};
    final occurrenceCount = <String, int>{};

    for (final dayHabits in dailyCompletions.values) {
      for (final habit1 in dayHabits) {
        occurrenceCount[habit1] = (occurrenceCount[habit1] ?? 0) + 1;
        for (final habit2 in dayHabits) {
          if (habit1 == habit2) continue;
          final habit1Matrix = coOccurrenceMatrix.putIfAbsent(habit1, () => {});
          habit1Matrix[habit2] = (habit1Matrix[habit2] ?? 0) + 1;
        }
      }
    }

    // Store the results
    final ecosystemData = {
      'coOccurrenceMatrix': coOccurrenceMatrix,
      'occurrenceCount': occurrenceCount,
      'lastAnalyzed': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(userId).update({
      'habitEcosystem': ecosystemData
    });

    print("Ecosystem analysis complete for user $userId.");
    return ecosystemData;
  }

  /// Identifies the "keystone" habit that has the most positive impact on other habits.
  Future<String?> identifyKeystoneHabit(String userId) async {
    print("Identifying keystone habit for user $userId.");
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final ecosystem = userDoc.data()?['habitEcosystem'] as Map<String, dynamic>?;

    if (ecosystem == null || ecosystem['coOccurrenceMatrix'] == null) {
      await analyzeEcosystem(userId); // Analyze first if not present
      final updatedUserDoc = await _firestore.collection('users').doc(userId).get();
      final updatedEcosystem = updatedUserDoc.data()?['habitEcosystem'] as Map<String, dynamic>?;
      if(updatedEcosystem == null) return null;
      return _findKeystone(updatedEcosystem);
    }

    return _findKeystone(ecosystem);
  }

  String? _findKeystone(Map<String, dynamic> ecosystem) {
     final coOccurrenceMatrix = ecosystem['coOccurrenceMatrix'] as Map<String, dynamic>;
     if (coOccurrenceMatrix.isEmpty) return null;

     String? keystoneHabit;
     double maxInfluenceScore = 0;

     coOccurrenceMatrix.forEach((habit, connections) {
       double currentScore = (connections as Map<String, dynamic>).values.fold(0, (sum, val) => sum + (val as int));
       if (currentScore > maxInfluenceScore) {
         maxInfluenceScore = currentScore;
         keystoneHabit = habit;
       }
     });

     return keystoneHabit;
  }


  /// Suggests optimizations for the user's habit ecosystem.
  Future<List<String>> getOptimizationSuggestions(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final ecosystem = userDoc.data()?['habitEcosystem'] as Map<String, dynamic>?;

    if (ecosystem == null) {
      return ["Analyze your habits first to get suggestions."];
    }

    final coOccurrenceMatrix = ecosystem['coOccurrenceMatrix'] as Map<String, dynamic>;
    final occurrenceCount = ecosystem['occurrenceCount'] as Map<String, dynamic>;
    final suggestions = <String>[];

    coOccurrenceMatrix.forEach((habitA, connections) {
      (connections as Map<String, dynamic>).forEach((habitB, count) {
        final totalA = occurrenceCount[habitA] ?? 1;
        final probability = (count as int) / totalA;
        if (probability > 0.6) { // High correlation
          suggestions.add("Did you know? Completing '$habitA' increases your chances of also doing '$habitB'!");
        }
      });
    });

    if (suggestions.isEmpty) {
      return ["Keep building habits to find powerful connections!"];
    }

    return suggestions.take(3).toList(); // Return top 3 suggestions
  }
}