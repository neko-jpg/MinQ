import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/gamification/services/league_system.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/gamification/league.dart';

/// Provide aggregated statistics for the league dashboard.
final leagueStatisticsProvider =
    FutureProvider<LeagueStatistics>((ref) async {
  final leagueSystem = ref.watch(leagueSystemProvider);
  return leagueSystem.getLeagueStatistics();
});

/// Provide rankings for a specific league tier.
final leagueRankingsProvider =
    FutureProvider.family<List<LeagueRanking>, String>((ref, leagueId) async {
  final leagueSystem = ref.watch(leagueSystemProvider);
  return leagueSystem.getLeagueRankings(leagueId);
});

/// Provide the local user record stored in Isar.
final currentLeagueUserProvider =
    FutureProvider<LocalUser?>((ref) async {
  final uid = ref.watch(uidProvider);
  if (uid == null) {
    return null;
  }

  final isar = await ref.watch(isarProvider.future);
  return isar.collection<LocalUser>().filter().uidEqualTo(uid).findFirst();
});
