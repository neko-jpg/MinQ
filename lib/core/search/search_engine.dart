import 'dart:async';
import 'dart:math' as math;

import 'package:minq/domain/challenges/challenge.dart';
import 'package:minq/domain/quest/quest.dart';

/// 検索可能なアイテムの基底クラス
abstract class SearchableItem {
  String get id;
  String get title;
  String get description;
  List<String> get tags;
  String get category;
  DateTime get createdAt;
  DateTime? get updatedAt;
  
  /// 検索用のキーワードを生成
  List<String> get searchKeywords => [
    title.toLowerCase(),
    description.toLowerCase(),
    category.toLowerCase(),
    ...tags.map((tag) => tag.toLowerCase()),
  ];
}

/// クエスト用の検索可能アイテム
class SearchableQuest implements SearchableItem {
  final Quest quest;
  
  SearchableQuest(this.quest);
  
  @override
  String get id => quest.id.toString();
  
  @override
  String get title => quest.title;
  
  @override
  String get description => quest.category; // Using category as description for now
  
  @override
  List<String> get tags => [
    if (quest.difficulty != null) quest.difficulty!,
    if (quest.location != null) quest.location!,
    quest.status.name,
  ];
  
  @override
  String get category => quest.category;
  
  @override
  DateTime get createdAt => quest.createdAt;
  
  @override
  DateTime? get updatedAt => null;
  
  @override
  List<String> get searchKeywords => [
    title.toLowerCase(),
    description.toLowerCase(),
    category.toLowerCase(),
    ...tags.map((tag) => tag.toLowerCase()),
  ];
}

/// チャレンジ用の検索可能アイテム
class SearchableChallenge implements SearchableItem {
  final Challenge challenge;
  
  SearchableChallenge(this.challenge);
  
  @override
  String get id => challenge.id;
  
  @override
  String get title => challenge.name;
  
  @override
  String get description => challenge.description;
  
  @override
  List<String> get tags => [challenge.type];
  
  @override
  String get category => challenge.type;
  
  @override
  DateTime get createdAt => challenge.startDate;
  
  @override
  DateTime? get updatedAt => null;
  
  @override
  List<String> get searchKeywords => [
    title.toLowerCase(),
    description.toLowerCase(),
    category.toLowerCase(),
    ...tags.map((tag) => tag.toLowerCase()),
  ];
}

/// 検索フィルター
class SearchFilter {
  final List<String> categories;
  final List<String> tags;
  final DateRange? dateRange;
  final String? difficulty;
  final String? location;
  final String? status;
  
  const SearchFilter({
    this.categories = const [],
    this.tags = const [],
    this.dateRange,
    this.difficulty,
    this.location,
    this.status,
  });
  
  SearchFilter copyWith({
    List<String>? categories,
    List<String>? tags,
    DateRange? dateRange,
    String? difficulty,
    String? location,
    String? status,
  }) {
    return SearchFilter(
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      dateRange: dateRange ?? this.dateRange,
      difficulty: difficulty ?? this.difficulty,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }
  
  bool get isEmpty => 
      categories.isEmpty &&
      tags.isEmpty &&
      dateRange == null &&
      difficulty == null &&
      location == null &&
      status == null;
}

/// 日付範囲
class DateRange {
  final DateTime start;
  final DateTime end;
  
  const DateRange({required this.start, required this.end});
}

/// 検索結果
class SearchResult<T extends SearchableItem> {
  final T item;
  final double relevanceScore;
  final List<String> matchedKeywords;
  
  const SearchResult({
    required this.item,
    required this.relevanceScore,
    required this.matchedKeywords,
  });
}

/// 検索ソート順
enum SearchSortOrder {
  relevance,
  dateCreated,
  dateUpdated,
  alphabetical,
}

/// 検索エンジン
class SearchEngine {
  final Map<String, SearchableItem> _index = {};
  final Map<String, Set<String>> _keywordIndex = {};
  final StreamController<List<SearchResult>> _resultsController = StreamController.broadcast();
  
  /// 検索結果のストリーム
  Stream<List<SearchResult>> get resultsStream => _resultsController.stream;
  
  /// アイテムをインデックスに追加
  void addToIndex(SearchableItem item) {
    _index[item.id] = item;
    
    // キーワードインデックスを更新
    for (final keyword in item.searchKeywords) {
      _keywordIndex.putIfAbsent(keyword, () => <String>{}).add(item.id);
    }
  }
  
  /// アイテムをインデックスから削除
  void removeFromIndex(String itemId) {
    final item = _index.remove(itemId);
    if (item == null) return;
    
    // キーワードインデックスから削除
    for (final keyword in item.searchKeywords) {
      _keywordIndex[keyword]?.remove(itemId);
      if (_keywordIndex[keyword]?.isEmpty == true) {
        _keywordIndex.remove(keyword);
      }
    }
  }
  
  /// インデックスをクリア
  void clearIndex() {
    _index.clear();
    _keywordIndex.clear();
  }
  
  /// 検索を実行
  Future<List<SearchResult>> search({
    required String query,
    SearchFilter? filter,
    SearchSortOrder sortOrder = SearchSortOrder.relevance,
    int limit = 50,
  }) async {
    if (query.isEmpty && (filter?.isEmpty ?? true)) {
      return [];
    }
    
    final results = <SearchResult>[];
    final queryWords = _tokenizeQuery(query);
    
    for (final item in _index.values) {
      // フィルターを適用
      if (filter != null && !_matchesFilter(item, filter)) {
        continue;
      }
      
      // クエリにマッチするかチェック
      final matchResult = _calculateRelevance(item, queryWords);
      if (matchResult.score > 0) {
        results.add(SearchResult(
          item: item,
          relevanceScore: matchResult.score,
          matchedKeywords: matchResult.matchedKeywords,
        ));
      }
    }
    
    // ソート
    _sortResults(results, sortOrder);
    
    // 制限を適用
    final limitedResults = results.take(limit).toList();
    
    // 結果をストリームに送信
    _resultsController.add(limitedResults);
    
    return limitedResults;
  }
  
  /// オートコンプリート候補を生成
  List<String> generateAutocompleteSuggestions({
    required String query,
    int limit = 10,
  }) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    final suggestions = <String>[];
    
    // キーワードインデックスから候補を検索
    for (final keyword in _keywordIndex.keys) {
      if (keyword.startsWith(lowerQuery) && keyword != lowerQuery) {
        suggestions.add(keyword);
      }
    }
    
    // 関連度でソート
    suggestions.sort((a, b) {
      final aScore = _calculateKeywordRelevance(a, lowerQuery);
      final bScore = _calculateKeywordRelevance(b, lowerQuery);
      return bScore.compareTo(aScore);
    });
    
    return suggestions.take(limit).toList();
  }
  
  /// 人気検索キーワードを取得
  List<String> getPopularKeywords({int limit = 10}) {
    final keywordCounts = <String, int>{};
    
    for (final entry in _keywordIndex.entries) {
      keywordCounts[entry.key] = entry.value.length;
    }
    
    final sortedKeywords = keywordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedKeywords
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// クエリをトークン化
  List<String> _tokenizeQuery(String query) {
    return query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }
  
  /// アイテムがフィルターにマッチするかチェック
  bool _matchesFilter(SearchableItem item, SearchFilter filter) {
    // カテゴリフィルター
    if (filter.categories.isNotEmpty && 
        !filter.categories.contains(item.category)) {
      return false;
    }
    
    // タグフィルター
    if (filter.tags.isNotEmpty) {
      final hasMatchingTag = filter.tags.any((tag) => 
          item.tags.any((itemTag) => 
              itemTag.toLowerCase().contains(tag.toLowerCase())));
      if (!hasMatchingTag) return false;
    }
    
    // 日付フィルター
    if (filter.dateRange != null) {
      final itemDate = item.updatedAt ?? item.createdAt;
      if (itemDate.isBefore(filter.dateRange!.start) ||
          itemDate.isAfter(filter.dateRange!.end)) {
        return false;
      }
    }
    
    // 難易度フィルター（クエスト用）
    if (filter.difficulty != null && item is SearchableQuest) {
      if (item.quest.difficulty != filter.difficulty) {
        return false;
      }
    }
    
    // 場所フィルター（クエスト用）
    if (filter.location != null && item is SearchableQuest) {
      if (item.quest.location != filter.location) {
        return false;
      }
    }
    
    // ステータスフィルター（クエスト用）
    if (filter.status != null && item is SearchableQuest) {
      if (item.quest.status.name != filter.status) {
        return false;
      }
    }
    
    return true;
  }
  
  /// 関連度を計算
  ({double score, List<String> matchedKeywords}) _calculateRelevance(
    SearchableItem item,
    List<String> queryWords,
  ) {
    if (queryWords.isEmpty) return (score: 0.0, matchedKeywords: <String>[]);
    
    double totalScore = 0.0;
    final matchedKeywords = <String>[];
    
    for (final queryWord in queryWords) {
      double wordScore = 0.0;
      
      // タイトルでの完全一致
      if (item.title.toLowerCase().contains(queryWord)) {
        wordScore += 10.0;
        matchedKeywords.add(queryWord);
      }
      
      // 説明での一致
      if (item.description.toLowerCase().contains(queryWord)) {
        wordScore += 5.0;
        if (!matchedKeywords.contains(queryWord)) {
          matchedKeywords.add(queryWord);
        }
      }
      
      // タグでの一致
      for (final tag in item.tags) {
        if (tag.toLowerCase().contains(queryWord)) {
          wordScore += 3.0;
          if (!matchedKeywords.contains(queryWord)) {
            matchedKeywords.add(queryWord);
          }
          break;
        }
      }
      
      // カテゴリでの一致
      if (item.category.toLowerCase().contains(queryWord)) {
        wordScore += 2.0;
        if (!matchedKeywords.contains(queryWord)) {
          matchedKeywords.add(queryWord);
        }
      }
      
      totalScore += wordScore;
    }
    
    // 新しいアイテムにボーナス
    final daysSinceCreation = DateTime.now().difference(item.createdAt).inDays;
    final recencyBonus = math.max(0, 1.0 - (daysSinceCreation / 30.0));
    totalScore += recencyBonus;
    
    return (score: totalScore, matchedKeywords: matchedKeywords);
  }
  
  /// キーワードの関連度を計算
  double _calculateKeywordRelevance(String keyword, String query) {
    if (keyword.startsWith(query)) {
      return 1.0 - (keyword.length - query.length) / keyword.length;
    }
    return 0.0;
  }
  
  /// 検索結果をソート
  void _sortResults(List<SearchResult> results, SearchSortOrder sortOrder) {
    switch (sortOrder) {
      case SearchSortOrder.relevance:
        results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
        break;
      case SearchSortOrder.dateCreated:
        results.sort((a, b) => b.item.createdAt.compareTo(a.item.createdAt));
        break;
      case SearchSortOrder.dateUpdated:
        results.sort((a, b) {
          final aDate = a.item.updatedAt ?? a.item.createdAt;
          final bDate = b.item.updatedAt ?? b.item.createdAt;
          return bDate.compareTo(aDate);
        });
        break;
      case SearchSortOrder.alphabetical:
        results.sort((a, b) => a.item.title.compareTo(b.item.title));
        break;
    }
  }
  
  void dispose() {
    _resultsController.close();
  }
}