import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/storage/local_storage_service.dart';
import 'package:minq/domain/settings/settings_category.dart';

/// Service for searching settings and managing search history
class SettingsSearchService {
  final LocalStorageService _storage;

  static const String _searchHistoryKey = 'settings_search_history';
  static const int _maxHistoryItems = 10;

  SettingsSearchService(this._storage);

  /// Search settings items across all categories
  List<SettingsSearchResult> searchSettings(
    List<SettingsCategory> categories,
    String query,
  ) {
    if (query.isEmpty) return [];

    final results = <SettingsSearchResult>[];

    for (final category in categories) {
      for (final item in category.items) {
        if (item.matchesSearch(query)) {
          results.add(
            SettingsSearchResult(
              category: category,
              item: item,
              relevanceScore: _calculateRelevanceScore(item, query),
            ),
          );
        }
      }
    }

    // Sort by relevance score (higher is better)
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return results;
  }

  /// Calculate relevance score for search result
  double _calculateRelevanceScore(SettingsItem item, String query) {
    final lowerQuery = query.toLowerCase();
    double score = 0.0;

    // Exact title match gets highest score
    if (item.title.toLowerCase() == lowerQuery) {
      score += 100.0;
    }
    // Title starts with query gets high score
    else if (item.title.toLowerCase().startsWith(lowerQuery)) {
      score += 80.0;
    }
    // Title contains query gets medium score
    else if (item.title.toLowerCase().contains(lowerQuery)) {
      score += 60.0;
    }

    // Subtitle matches get lower scores
    if (item.subtitle?.toLowerCase().contains(lowerQuery) == true) {
      score += 30.0;
    }

    // Keyword matches get variable scores based on position
    for (int i = 0; i < item.searchKeywords.length; i++) {
      if (item.searchKeywords[i].toLowerCase().contains(lowerQuery)) {
        score += 20.0 - (i * 2.0); // Earlier keywords get higher scores
      }
    }

    return score;
  }

  /// Get search history
  Future<List<String>> getSearchHistory() async {
    final history = await _storage.getStringList(_searchHistoryKey);
    return history ?? [];
  }

  /// Add search query to history
  Future<void> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;

    final history = await getSearchHistory();

    // Remove if already exists
    history.remove(query);

    // Add to beginning
    history.insert(0, query);

    // Limit history size
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    await _storage.setStringList(_searchHistoryKey, history);
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    await _storage.remove(_searchHistoryKey);
  }

  /// Remove specific item from search history
  Future<void> removeFromSearchHistory(String query) async {
    final history = await getSearchHistory();
    history.remove(query);
    await _storage.setStringList(_searchHistoryKey, history);
  }

  /// Get popular search suggestions
  List<String> getSearchSuggestions() {
    return [
      'テーマ',
      '通知',
      'ダークモード',
      'アクセシビリティ',
      'プライバシー',
      'データ',
      'アカウント',
      'バックアップ',
      'エクスポート',
      'リセット',
    ];
  }
}

/// Search result containing category, item, and relevance score
class SettingsSearchResult {
  final SettingsCategory category;
  final SettingsItem item;
  final double relevanceScore;

  const SettingsSearchResult({
    required this.category,
    required this.item,
    required this.relevanceScore,
  });
}

final settingsSearchServiceProvider = Provider<SettingsSearchService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SettingsSearchService(storage);
});

/// Provider for search history
final searchHistoryProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(settingsSearchServiceProvider);
  return await service.getSearchHistory();
});
