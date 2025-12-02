import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/challenges/challenge_service.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/core/gamification/reward_system.dart';
import 'package:minq/core/providers/core_providers.dart';

final gamificationEngineProvider = Provider<GamificationEngine>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final isar = ref.watch(isarProvider).value;
  return GamificationEngine(firestore, isar);
});

final rewardSystemProvider = Provider<RewardSystem>((ref) {
  final firestore = ref.watch(firestoreProvider);
  if (firestore == null) {
    throw StateError('Firestore is not available');
  }
  return RewardSystem(firestore);
});

final challengeServiceProvider = Provider<ChallengeService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  if (firestore == null) {
    throw StateError('Firestore is not available');
  }
  final gamificationEngine = ref.watch(gamificationEngineProvider);
  return ChallengeService(firestore, gamificationEngine);
});
