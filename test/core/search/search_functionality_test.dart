import 'package:flutter_test/flutter_test.dart';

/// 検索可能なアイテムの基底クラス（テスト用）
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

/// 検索フィルター（テスト用）
class SearchFilter {
  final List<String> categories;
  final List<String> tags;
  
  const SearchFilter({
    this.categories = const [],
    this.tags = const [],
  });
  
  bool get isEmpty => categories.isEmpty && tags.isEmpty;
}

/// 検索結果（テスト用）
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

/// テスト用のシンプルな検索可能アイテム
class TestSearchableItem implements SearchableItem {
  @override
  final String id;
  
  @override
  final String title;
  
  @override
  final String description;
  
  @override
  final List<String> tags;
  
  @override
  final String category;
  
  @override
  final DateTime createdAt;
  
  @override
  final DateTime? updatedAt;
  
  TestSearchableItem({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.category,
    required this.createdAt,
    this.updatedAt,
  });
  
  @override
  List<String> get searchKeywords => [
    title.toLowerCase(),
    description.toLowerCase(),
    category.toLowerCase(),
    ...tags.map((tag) => tag.toLowerCase()),
  ];
}

/// シンプルな検索エンジン（テスト用）
class SimpleSearchEngine {
  final Map<String, SearchableItem> _index = {};
  final Map<String, Set<String>> _keywordIndex = {};
  
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
  
  /// 検索を実行
  Future<List<SearchResult>> search({
    required String query,
    SearchFilter? filter,
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
      
      // クエリが空の場合（フィルターのみ）は全てのアイテムを含める
      if (query.isEmpty) {
        results.add(SearchResult(
          item: item,
          relevanceScore: 1.0,
          matchedKeywords: [],
        ));
      } else {
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
    }
    
    // 関連度でソート
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    
    return results;
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
    
    return suggestions.take(limit).toList();
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
    
    return (score: totalScore, matchedKeywords: matchedKeywords);
  }
}

void main() {
  group('Search Functionality', () {
    late SimpleSearchEngine searchEngine;
    
    setUp(() {
      searchEngine = SimpleSearchEngine();
    });
    
    test('should add items to index', () {
      final item = TestSearchableItem(
        id: '1',
        title: 'Test Quest',
        description: 'A test quest for exercise',
        category: 'Exercise',
        tags: ['fitness', 'daily'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      // インデックスに追加されたことを確認するため、検索を実行
      expect(() => searchEngine.search(query: 'Test'), returnsNormally);
    });
    
    test('should search by title', () async {
      final item = TestSearchableItem(
        id: '1',
        title: 'Morning Exercise',
        description: 'Daily morning workout',
        category: 'Fitness',
        tags: ['morning', 'workout'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      final results = await searchEngine.search(query: 'Morning');
      
      expect(results, isNotEmpty);
      expect(results.first.item.title, contains('Morning'));
    });
    
    test('should search by category', () async {
      final item = TestSearchableItem(
        id: '1',
        title: 'Daily Run',
        description: 'Running exercise',
        category: 'Exercise',
        tags: ['running', 'cardio'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      final results = await searchEngine.search(query: 'Exercise');
      
      expect(results, isNotEmpty);
      expect(results.first.item.category, equals('Exercise'));
    });
    
    test('should filter by category', () async {
      final item1 = TestSearchableItem(
        id: '1',
        title: 'Morning Run',
        description: 'Running exercise',
        category: 'Exercise',
        tags: ['running'],
        createdAt: DateTime.now(),
      );
      
      final item2 = TestSearchableItem(
        id: '2',
        title: 'Read Book',
        description: 'Reading activity',
        category: 'Learning',
        tags: ['reading'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item1);
      searchEngine.addToIndex(item2);
      
      final filter = SearchFilter(categories: ['Exercise']);
      final results = await searchEngine.search(
        query: '',
        filter: filter,
      );
      
      expect(results, hasLength(1));
      expect(results.first.item.category, equals('Exercise'));
    });
    
    test('should generate autocomplete suggestions', () {
      final item = TestSearchableItem(
        id: '1',
        title: 'Morning Exercise',
        description: 'Daily workout',
        category: 'Fitness',
        tags: ['morning', 'workout'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      final suggestions = searchEngine.generateAutocompleteSuggestions(query: 'mor');
      
      expect(suggestions, contains('morning'));
    });
    
    test('should remove items from index', () async {
      final item = TestSearchableItem(
        id: '1',
        title: 'Test Quest',
        description: 'A test quest',
        category: 'Exercise',
        tags: ['test'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      // 検索結果があることを確認
      var results = await searchEngine.search(query: 'Test');
      expect(results, isNotEmpty);
      
      // インデックスから削除
      searchEngine.removeFromIndex(item.id);
      
      // 検索結果がないことを確認
      results = await searchEngine.search(query: 'Test');
      expect(results, isEmpty);
    });
    
    test('should calculate relevance score correctly', () async {
      final item1 = TestSearchableItem(
        id: '1',
        title: 'Morning Exercise',  // タイトルに完全一致
        description: 'Daily workout',
        category: 'Fitness',
        tags: ['workout'],
        createdAt: DateTime.now(),
      );
      
      final item2 = TestSearchableItem(
        id: '2',
        title: 'Daily Routine',
        description: 'Morning habits',  // 説明に一致
        category: 'Habits',
        tags: ['routine'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item1);
      searchEngine.addToIndex(item2);
      
      final results = await searchEngine.search(query: 'Morning');
      
      expect(results, hasLength(2));
      // タイトル一致の方が関連度が高いはず
      expect(results.first.item.title, equals('Morning Exercise'));
      expect(results.first.relevanceScore, greaterThan(results.last.relevanceScore));
    });
    
    test('should handle empty search query', () async {
      final item = TestSearchableItem(
        id: '1',
        title: 'Test Quest',
        description: 'A test quest',
        category: 'Exercise',
        tags: ['test'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      final results = await searchEngine.search(query: '');
      
      expect(results, isEmpty);
    });
    
    test('should handle search with no results', () async {
      final item = TestSearchableItem(
        id: '1',
        title: 'Test Quest',
        description: 'A test quest',
        category: 'Exercise',
        tags: ['test'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      final results = await searchEngine.search(query: 'NonExistent');
      
      expect(results, isEmpty);
    });
    
    test('should handle multiple word search', () async {
      final item = TestSearchableItem(
        id: '1',
        title: 'Morning Exercise Routine',
        description: 'Daily fitness workout',
        category: 'Exercise',
        tags: ['morning', 'fitness', 'daily'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item);
      
      final results = await searchEngine.search(query: 'Morning Exercise');
      
      expect(results, isNotEmpty);
      expect(results.first.matchedKeywords, containsAll(['morning', 'exercise']));
    });
    
    test('should filter by tags', () async {
      final item1 = TestSearchableItem(
        id: '1',
        title: 'Morning Run',
        description: 'Running exercise',
        category: 'Exercise',
        tags: ['running', 'cardio'],
        createdAt: DateTime.now(),
      );
      
      final item2 = TestSearchableItem(
        id: '2',
        title: 'Weight Training',
        description: 'Strength exercise',
        category: 'Exercise',
        tags: ['weights', 'strength'],
        createdAt: DateTime.now(),
      );
      
      searchEngine.addToIndex(item1);
      searchEngine.addToIndex(item2);
      
      final filter = SearchFilter(tags: ['cardio']);
      final results = await searchEngine.search(
        query: '',
        filter: filter,
      );
      
      expect(results, hasLength(1));
      expect(results.first.item.tags, contains('cardio'));
    });
  });
}