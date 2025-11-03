import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/search/search_engine.dart';
import 'package:minq/core/search/search_service.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// 高度な検索バー
class AdvancedSearchBar extends ConsumerStatefulWidget {
  final String initialQuery;
  final SearchFilter? initialFilter;
  final Function(String query, SearchFilter? filter) onSearch;
  final VoidCallback? onClear;
  final bool showVoiceSearch;
  final bool showFilters;

  const AdvancedSearchBar({
    super.key,
    this.initialQuery = '',
    this.initialFilter,
    required this.onSearch,
    this.onClear,
    this.showVoiceSearch = true,
    this.showFilters = true,
  });

  @override
  ConsumerState<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends ConsumerState<AdvancedSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  SearchFilter _currentFilter = const SearchFilter();
  bool _showSuggestions = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _currentFilter = widget.initialFilter ?? const SearchFilter();

    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // メイン検索バー
        Container(
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(tokens.radius.xl),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? tokens.brandPrimary
                  : tokens.border,
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: [
              if (_focusNode.hasFocus)
                BoxShadow(
                  color: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
            ],
          ),
          child: Row(
            children: [
              // 検索アイコン
              Padding(
                padding: EdgeInsets.only(left: tokens.spacing.md),
                child: Icon(
                  Icons.search,
                  color: tokens.textSecondary,
                  size: 20,
                ),
              ),

              // 検索入力フィールド
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.md,
                      vertical: tokens.spacing.md,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _showSuggestions =
                          value.isNotEmpty && _focusNode.hasFocus;
                    });

                    // リアルタイム検索（デバウンス付き）
                    if (value.isNotEmpty) {
                      _performSearch(value, _currentFilter);
                    }
                  },
                  onSubmitted: (value) {
                    _performSearch(value, _currentFilter);
                    _focusNode.unfocus();
                  },
                ),
              ),

              // 音声検索ボタン
              if (widget.showVoiceSearch)
                IconButton(
                  icon: Icon(Icons.mic, color: tokens.textSecondary),
                  onPressed: _startVoiceSearch,
                ),

              // フィルターボタン
              if (widget.showFilters)
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                    color: !_currentFilter.isEmpty
                        ? tokens.brandPrimary
                        : tokens.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),

              // クリアボタン
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, color: tokens.textSecondary),
                  onPressed: () {
                    _controller.clear();
                    _currentFilter = const SearchFilter();
                    setState(() {
                      _showSuggestions = false;
                    });
                    widget.onClear?.call();
                  },
                ),
            ],
          ),
        ),

        // オートコンプリート候補
        if (_showSuggestions) _buildSuggestions(),

        // フィルター
        if (_showFilters) _buildFilters(),
      ],
    );
  }

  Widget _buildSuggestions() {
    final suggestions = ref.watch(
      autocompleteSuggestionsProvider(_controller.text),
    );

    return suggestions.when(
      data: (suggestions) {
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: EdgeInsets.only(top: MinqTheme.of(context).spacing.sm),
          decoration: BoxDecoration(
            color: MinqTheme.of(context).surface,
            borderRadius:
                BorderRadius.circular(MinqTheme.of(context).radius.lg),
            border: Border.all(color: MinqTheme.of(context).border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).round()),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: suggestions.map((suggestion) {
              return ListTile(
                dense: true,
                leading: Icon(
                  Icons.history,
                  color: MinqTheme.of(context).textSecondary,
                  size: 16,
                ),
                title: Text(
                  suggestion,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  _controller.text = suggestion;
                  _performSearch(suggestion, _currentFilter);
                  setState(() {
                    _showSuggestions = false;
                  });
                  _focusNode.unfocus();
                },
              );
            }).toList(),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildFilters() {
    final filterOptions = ref.watch(filterOptionsProvider);

    return filterOptions.when(
      data: (options) => Container(
        margin: EdgeInsets.only(top: MinqTheme.of(context).spacing.sm),
        padding: EdgeInsets.all(MinqTheme.of(context).spacing.md),
        decoration: BoxDecoration(
          color: MinqTheme.of(context).surface,
          borderRadius:
              BorderRadius.circular(MinqTheme.of(context).radius.lg),
          border: Border.all(color: MinqTheme.of(context).border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // フィルターヘッダー
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).filters,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (!_currentFilter.isEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentFilter = const SearchFilter();
                      });
                      _performSearch(_controller.text, _currentFilter);
                    },
                    child: Text(AppLocalizations.of(context).clearAll),
                  ),
              ],
            ),

            SizedBox(height: MinqTheme.of(context).spacing.sm),

            // カテゴリフィルター
            if (options.categories.isNotEmpty) ...[
              _buildFilterSection(
                title: AppLocalizations.of(context).category,
                options: options.categories,
                selectedValues: _currentFilter.categories,
                onChanged: (selected) {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(
                      categories: selected,
                    );
                  });
                  _performSearch(_controller.text, _currentFilter);
                },
              ),
              SizedBox(height: MinqTheme.of(context).spacing.md),
            ],

            // 難易度フィルター
            if (options.difficulties.isNotEmpty) ...[
              _buildSingleSelectFilter(
                title: AppLocalizations.of(context).difficulty,
                options: options.difficulties,
                selectedValue: _currentFilter.difficulty,
                onChanged: (selected) {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(
                      difficulty: selected,
                    );
                  });
                  _performSearch(_controller.text, _currentFilter);
                },
              ),
              SizedBox(height: MinqTheme.of(context).spacing.md),
            ],

            // 場所フィルター
            if (options.locations.isNotEmpty) ...[
              _buildSingleSelectFilter(
                title: AppLocalizations.of(context).location,
                options: options.locations,
                selectedValue: _currentFilter.location,
                onChanged: (selected) {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(
                      location: selected,
                    );
                  });
                  _performSearch(_controller.text, _currentFilter);
                },
              ),
              SizedBox(height: MinqTheme.of(context).spacing.md),
            ],

            // ステータスフィルター
            if (options.statuses.isNotEmpty) ...[
              _buildSingleSelectFilter(
                title: AppLocalizations.of(context).status,
                options: options.statuses,
                selectedValue: _currentFilter.status,
                onChanged: (selected) {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(
                      status: selected,
                    );
                  });
                  _performSearch(_controller.text, _currentFilter);
                },
              ),
            ],
          ],
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: MinqTheme.of(context).textSecondary,
              ),
        ),
        SizedBox(height: MinqTheme.of(context).spacing.sm),
        Wrap(
          spacing: MinqTheme.of(context).spacing.sm,
          runSpacing: MinqTheme.of(context).spacing.sm,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                final newSelected = List<String>.from(selectedValues);
                if (selected) {
                  newSelected.add(option);
                } else {
                  newSelected.remove(option);
                }
                onChanged(newSelected);
              },
              backgroundColor: MinqTheme.of(context).surface,
              selectedColor: MinqTheme.of(context)
                  .brandPrimary
                  .withAlpha((255 * 0.2).round()),
              checkmarkColor: MinqTheme.of(context).brandPrimary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSingleSelectFilter({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: MinqTheme.of(context).textSecondary,
              ),
        ),
        SizedBox(height: MinqTheme.of(context).spacing.sm),
        Wrap(
          spacing: MinqTheme.of(context).spacing.sm,
          runSpacing: MinqTheme.of(context).spacing.sm,
          children: [
            // 「すべて」オプション
            FilterChip(
              label: Text(AppLocalizations.of(context).all),
              selected: selectedValue == null,
              onSelected: (selected) {
                if (selected) onChanged(null);
              },
              backgroundColor: MinqTheme.of(context).surface,
              selectedColor: MinqTheme.of(context)
                  .brandPrimary
                  .withAlpha((255 * 0.2).round()),
              checkmarkColor: MinqTheme.of(context).brandPrimary,
            ),
            // 各オプション
            ...options.map((option) {
              final isSelected = selectedValue == option;
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  onChanged(selected ? option : null);
                },
                backgroundColor: MinqTheme.of(context).surface,
                selectedColor: MinqTheme.of(context)
                    .brandPrimary
                    .withAlpha((255 * 0.2).round()),
                checkmarkColor: MinqTheme.of(context).brandPrimary,
              );
            }),
          ],
        ),
      ],
    );
  }

  void _performSearch(String query, SearchFilter filter) {
    widget.onSearch(query, filter);
  }

  void _startVoiceSearch() {
    // TODO: 音声検索の実装
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).voiceSearchNotImplemented),
      ),
    );
  }
}
