import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// クエスト検索バー
class QuestSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(List<String>)? onTagsChanged;
  final List<String> availableTags;

  const QuestSearchBar({
    super.key,
    required this.onSearch,
    this.onTagsChanged,
    this.availableTags = const [],
  });

  @override
  State<QuestSearchBar> createState() => _QuestSearchBarState();
}

class _QuestSearchBarState extends State<QuestSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final Set<String> _selectedTags = {};
  bool _showFilters = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        // 検索バー
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.md,
            vertical: tokens.spacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'クエストを検索...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _controller.clear();
                                  widget.onSearch('');
                                },
                              )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radius.xl),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.md,
                      vertical: tokens.spacing.sm,
                    ),
                  ),
                  onChanged: widget.onSearch,
                ),
              ),
              if (widget.availableTags.isNotEmpty) ...[
                SizedBox(width: tokens.spacing.sm),
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                    color:
                        _selectedTags.isNotEmpty ? tokens.brandPrimary : null,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
        // タグフィルター
        if (_showFilters && widget.availableTags.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.md,
              vertical: tokens.spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'タグでフィルター',
                  style: tokens.typography.caption.copyWith(
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Wrap(
                  spacing: tokens.spacing.sm,
                  runSpacing: tokens.spacing.sm,
                  children:
                      widget.availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                            widget.onTagsChanged?.call(_selectedTags.toList());
                          },
                          backgroundColor: tokens.surface,
                          selectedColor: tokens.brandPrimary
                              .withAlpha((255 * 0.2).round()),
                          checkmarkColor: tokens.brandPrimary,
                        );
                      }).toList(),
                ),
                if (_selectedTags.isNotEmpty) ...[
                  SizedBox(height: tokens.spacing.sm),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedTags.clear();
                      });
                      widget.onTagsChanged?.call([]);
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('フィルターをクリア'),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// クエスト検索サービス
class QuestSearchService {
  /// クエストを検索
  List<T> searchQuests<T>({
    required List<T> quests,
    required String query,
    required String Function(T) getTitle,
    required String Function(T) getDescription,
    required List<String> Function(T) getTags,
  }) {
    if (query.isEmpty) {
      return quests;
    }

    final lowerQuery = query.toLowerCase();

    return quests.where((quest) {
      final title = getTitle(quest).toLowerCase();
      final description = getDescription(quest).toLowerCase();
      final tags = getTags(quest).map((t) => t.toLowerCase()).toList();

      return title.contains(lowerQuery) ||
          description.contains(lowerQuery) ||
          tags.any((tag) => tag.contains(lowerQuery));
    }).toList();
  }

  /// タグでフィルター
  List<T> filterByTags<T>({
    required List<T> quests,
    required List<String> selectedTags,
    required List<String> Function(T) getTags,
  }) {
    if (selectedTags.isEmpty) {
      return quests;
    }

    return quests.where((quest) {
      final questTags = getTags(quest);
      return selectedTags.every((tag) => questTags.contains(tag));
    }).toList();
  }

  /// 検索とフィルターを組み合わせ
  List<T> searchAndFilter<T>({
    required List<T> quests,
    required String query,
    required List<String> selectedTags,
    required String Function(T) getTitle,
    required String Function(T) getDescription,
    required List<String> Function(T) getTags,
  }) {
    var results = quests;

    // 検索
    if (query.isNotEmpty) {
      results = searchQuests(
        quests: results,
        query: query,
        getTitle: getTitle,
        getDescription: getDescription,
        getTags: getTags,
      );
    }

    // タグフィルター
    if (selectedTags.isNotEmpty) {
      results = filterByTags(
        quests: results,
        selectedTags: selectedTags,
        getTags: getTags,
      );
    }

    return results;
  }

  /// 検索候補を生成
  List<String> generateSuggestions({
    required List<String> titles,
    required String query,
    int maxSuggestions = 5,
  }) {
    if (query.isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase();
    final suggestions =
        titles
            .where((title) => title.toLowerCase().contains(lowerQuery))
            .take(maxSuggestions)
            .toList();

    return suggestions;
  }
}

/// 検索履歴管理
class SearchHistoryManager {
  final List<String> _history = [];
  static const int _maxHistorySize = 10;

  /// 検索履歴に追加
  void addToHistory(String query) {
    if (query.isEmpty) return;

    _history.remove(query); // 重複を削除
    _history.insert(0, query);

    if (_history.length > _maxHistorySize) {
      _history.removeLast();
    }
  }

  /// 検索履歴を取得
  List<String> getHistory() {
    return List.unmodifiable(_history);
  }

  /// 検索履歴をクリア
  void clearHistory() {
    _history.clear();
  }

  /// 検索履歴から削除
  void removeFromHistory(String query) {
    _history.remove(query);
  }
}

/// 検索結果ハイライト
class SearchHighlight extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;

  const SearchHighlight({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final tokens = Theme.of(context).extension<MinqTheme>()!;
    final defaultHighlightStyle =
        highlightStyle ??
        TextStyle(
          backgroundColor:
              tokens.brandPrimary.withAlpha((255 * 0.3).round()),
          fontWeight: FontWeight.bold,
        );

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: defaultHighlightStyle,
        ),
      );

      start = index + query.length;
    }

    return RichText(text: TextSpan(style: style, children: spans));
  }
}
