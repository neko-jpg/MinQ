import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/settings/settings_search_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class SettingsSearchBar extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SettingsSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  ConsumerState<SettingsSearchBar> createState() => _SettingsSearchBarState();
}

class _SettingsSearchBarState extends ConsumerState<SettingsSearchBar> {
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions =
          widget.focusNode.hasFocus && widget.controller.text.isEmpty;
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      ref.read(settingsSearchServiceProvider).addToSearchHistory(query);
    }
    widget.focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  void _onSuggestionTapped(String suggestion) {
    widget.controller.text = suggestion;
    widget.onChanged(suggestion);
    _onSearchSubmitted(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);
    final searchHistory = ref.watch(searchHistoryProvider);

    return Column(
      children: [
        // Search Input
        Container(
          decoration: BoxDecoration(
            color: theme.surfaceAlt,
            borderRadius: theme.cornerMedium(),
            border: Border.all(
              color:
                  widget.focusNode.hasFocus ? theme.brandPrimary : theme.border,
              width: widget.focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            onChanged: (value) {
              widget.onChanged(value);
              setState(() {
                _showSuggestions = value.isEmpty && widget.focusNode.hasFocus;
              });
            },
            onSubmitted: _onSearchSubmitted,
            decoration: InputDecoration(
              hintText: '設定を検索...',
              hintStyle: theme.typography.bodyMedium.copyWith(
                color: theme.textMuted,
              ),
              prefixIcon: Icon(Icons.search, color: theme.textSecondary),
              suffixIcon:
                  widget.controller.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(Icons.clear, color: theme.textSecondary),
                        onPressed: widget.onClear,
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: theme.spacing.md,
                vertical: theme.spacing.md,
              ),
            ),
            style: theme.typography.bodyMedium.copyWith(
              color: theme.textPrimary,
            ),
          ),
        ),

        // Search Suggestions
        if (_showSuggestions) ...[
          SizedBox(height: theme.spacing.sm),
          _buildSuggestions(theme, searchHistory),
        ],
      ],
    );
  }

  Widget _buildSuggestions(
    MinqTheme theme,
    AsyncValue<List<String>> searchHistory,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: theme.cornerMedium(),
        border: Border.all(color: theme.border),
        boxShadow: theme.shadow.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search History
          searchHistory.when(
            data: (history) {
              if (history.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(theme.spacing.md),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 16,
                            color: theme.textSecondary,
                          ),
                          SizedBox(width: theme.spacing.sm),
                          Text(
                            '最近の検索',
                            style: theme.typography.bodySmall.copyWith(
                              color: theme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              ref
                                  .read(settingsSearchServiceProvider)
                                  .clearSearchHistory();
                            },
                            child: Text(
                              'クリア',
                              style: theme.typography.bodySmall.copyWith(
                                color: theme.brandPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...history
                        .take(3)
                        .map(
                          (query) => _buildSuggestionItem(
                            theme,
                            query,
                            Icons.history,
                            onTap: () => _onSuggestionTapped(query),
                            onRemove: () {
                              ref
                                  .read(settingsSearchServiceProvider)
                                  .removeFromSearchHistory(query);
                            },
                          ),
                        ),
                    if (history.isNotEmpty)
                      Divider(color: theme.border, height: 1),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Popular Suggestions
          Padding(
            padding: EdgeInsets.all(theme.spacing.md),
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 16, color: theme.textSecondary),
                SizedBox(width: theme.spacing.sm),
                Text(
                  '人気の検索',
                  style: theme.typography.bodySmall.copyWith(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...ref
              .read(settingsSearchServiceProvider)
              .getSearchSuggestions()
              .take(5)
              .map(
                (suggestion) => _buildSuggestionItem(
                  theme,
                  suggestion,
                  Icons.search,
                  onTap: () => _onSuggestionTapped(suggestion),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    MinqTheme theme,
    String text,
    IconData icon, {
    required VoidCallback onTap,
    VoidCallback? onRemove,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.textMuted),
            SizedBox(width: theme.spacing.md),
            Expanded(
              child: Text(
                text,
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.textPrimary,
                ),
              ),
            ),
            if (onRemove != null)
              InkWell(
                onTap: onRemove,
                child: Padding(
                  padding: EdgeInsets.all(theme.spacing.xs),
                  child: Icon(Icons.close, size: 16, color: theme.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
