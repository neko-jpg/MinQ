import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/quest/quest.dart' as minq_quest;
import 'package:minq/domain/recommendation/habit_ai_suggestion_service.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/routing/app_router.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

const String _categoryRecommended = 'recommended';
const String _categoryMine = 'mine';
const String _categoryLearning = 'learning';
const String _categoryRecent = 'recent';

const Duration _searchDebounceDuration = Duration(milliseconds: 250);
const List<String> _searchSuggestionKeywords = <String>[
  '瞑想',
  'ストレッチ',
  '朝活',
  '集中',
  '英単語',
];

const Set<String> _questSearchStopWords = <String>{
  'を',
  'に',
  'で',
  'と',
  'や',
  'へ',
  'の',
  'が',
  'は',
  'も',
  'する',
  'して',
  'した',
  'しよう',
  'しましょう',
  'ます',
  'ました',
  'ように',
};

class _Category {
  const _Category({required this.key, required this.label});

  final String key;
  final String label;
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  bool _isLoading = true;
  String _selectedCategory = _categoryRecommended;
  String _searchQuery = '';
  Timer? _searchDebounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchControllerChanged);
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _searchDebounce?.cancel();
      if (_searchQuery.isNotEmpty) {
        setState(() {
          _searchQuery = '';
        });
      }
      return;
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchQuery = trimmed;
      });
    });
  }

  void _applySuggestion(String suggestion) {
    _searchDebounce?.cancel();
    _searchController
      ..text = suggestion
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: suggestion.length),
      );
    setState(() {
      _searchQuery = suggestion.trim();
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    if (_searchController.text.isEmpty && _searchQuery.isEmpty) {
      return;
    }
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  List<minq_quest.Quest> _applySearchFilter(List<minq_quest.Quest> quests) {
    final normalized = _searchQuery.trim().toLowerCase();
    if (normalized.isEmpty) {
      return quests;
    }

    return quests
        .where((quest) => _questMatchesQuery(quest, normalized))
        .toList();
  }

  bool _questMatchesQuery(minq_quest.Quest quest, String normalizedQuery) {
    if (quest.title.toLowerCase().contains(normalizedQuery)) {
      return true;
    }

    for (final tag in _deriveQuestTags(quest)) {
      if (tag.toLowerCase().contains(normalizedQuery)) {
        return true;
      }
    }
    return false;
  }

  Iterable<String> _deriveQuestTags(minq_quest.Quest quest) {
    final tags = <String>{};
    tags.add(quest.category);
    tags.add('${quest.estimatedMinutes}分');
    final iconKey = quest.iconKey;
    if (iconKey != null && iconKey.isNotEmpty) {
      tags.add(iconKey);
    }
    tags.addAll(_tokenizeTitle(quest.title));
    return tags;
  }

  Iterable<String> _tokenizeTitle(String title) {
    const suffixes = <String>['する', 'した', 'して', 'しよう', 'しましょう'];
    final matches = RegExp(
      r'[A-Za-z0-9]+|[ぁ-んー]+|[ァ-ンー]+|[一-龥々〆ヵヶ]+',
      unicode: true,
    ).allMatches(title);
    final results = <String>{};

    for (final match in matches) {
      var token = match.group(0)!;
      if (token.isEmpty) {
        continue;
      }
      if (_questSearchStopWords.contains(token)) {
        continue;
      }
      results.add(token);

      for (final suffix in suffixes) {
        if (token.endsWith(suffix) && token.length > suffix.length) {
          final trimmed = token.substring(0, token.length - suffix.length);
          if (trimmed.isNotEmpty && !_questSearchStopWords.contains(trimmed)) {
            results.add(trimmed);
          }
        }
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final categories = <_Category>[
      _Category(key: _categoryRecommended, label: l10n.questsCategoryFeatured),
      _Category(key: _categoryMine, label: l10n.questsCategoryMyQuests),
      _Category(key: _categoryLearning, label: l10n.questsCategoryLearning),
      _Category(key: _categoryRecent, label: l10n.questsCategoryRecent),
    ];
    final templateQuests = ref.watch(templateQuestsProvider);
    final userQuests = ref.watch(userQuestsProvider);
    final aiSuggestions = ref.watch(habitAiSuggestionsProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          l10n.questsTitle,
          style: tokens.titleMedium.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Tooltip(
          message: l10n.back,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        backgroundColor: tokens.background.withOpacity(0.8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          (templateQuests.isLoading || userQuests.isLoading)
              ? _QuestsSkeleton(tokens: tokens)
              : CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(child: _buildSearchBar(tokens, l10n)),
                  SliverAppBar(
                    pinned: true,
                    toolbarHeight: 60,
                    backgroundColor: tokens.background.withOpacity(0.8),
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: _buildCategoryTabs(tokens, categories),
                  ),
                  if (_selectedCategory == _categoryRecommended)
                    ..._buildAiSuggestionSlivers(tokens, aiSuggestions),
                  SliverPadding(
                    padding: EdgeInsets.all(tokens.spacing(4)),
                    sliver: _buildQuestList(
                      tokens,
                      l10n,
                      templateQuests.value ?? [],
                      userQuests.value ?? [],
                    ),
                  ),
                ],
              ),
      floatingActionButton:
          (templateQuests.isLoading || userQuests.isLoading)
              ? null
              : _buildFab(tokens, l10n),
    );
  }

  Widget _buildSearchBar(MinqTheme tokens, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.questsSearchHint,
          prefixIcon: Icon(Icons.search, color: tokens.textMuted),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    tooltip: '検索をクリア',
                    onPressed: _clearSearch,
                    icon: Icon(Icons.clear, color: tokens.textMuted),
                  )
                  : null,
          filled: true,
          fillColor: tokens.surface,
          border: OutlineInputBorder(
            borderRadius: tokens.cornerFull(),
            borderSide: BorderSide(color: tokens.border.withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: tokens.cornerFull(),
            borderSide: BorderSide(color: tokens.border.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(MinqTheme tokens, List<_Category> categories) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.border, width: 1.0)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: tokens.spacing(4)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.key == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category.key),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing(3)),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        isSelected ? tokens.brandPrimary : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              child: Text(
                category.label,
                style:
                    isSelected
                        ? tokens.bodyMedium.copyWith(
                          color: tokens.brandPrimary,
                          fontWeight: FontWeight.bold,
                        )
                        : tokens.bodyMedium.copyWith(color: tokens.textMuted),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestList(
    MinqTheme tokens,
    AppLocalizations l10n,
    List<minq_quest.Quest> templateQuests,
    List<minq_quest.Quest> userQuests,
  ) {
    final bool isSearching = _searchQuery.trim().isNotEmpty;
    List<minq_quest.Quest> questsToShow;

    switch (_selectedCategory) {
      case _categoryMine:
        questsToShow = List<minq_quest.Quest>.from(userQuests);
        break;
      case _categoryLearning:
        const learningKey = 'learning';
        bool matchesLearning(String category) {
          final normalized = category.toLowerCase();
          return normalized == learningKey || category == '学習';
        }

        questsToShow =
            templateQuests.where((q) => matchesLearning(q.category)).toList();
        final userLearning =
            userQuests.where((q) => matchesLearning(q.category)).toList();
        questsToShow = [...questsToShow, ...userLearning];
        break;
      case _categoryRecent:
        questsToShow = [...userQuests]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (questsToShow.isEmpty) {
          questsToShow = [...templateQuests]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
        break;
      case _categoryRecommended:
      default:
        questsToShow = List<minq_quest.Quest>.from(templateQuests);
        break;
    }

    if (!isSearching && questsToShow.length > 6) {
      questsToShow = questsToShow.take(6).toList();
    }

    final filteredQuests = _applySearchFilter(questsToShow);

    if (filteredQuests.isEmpty) {
      final trimmedQuery = _searchQuery.trim();
      if (trimmedQuery.isNotEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.spacing(8)),
            child: _EmptySearchResults(
              query: trimmedQuery,
              onClear: _clearSearch,
              onSuggestionSelected: _applySuggestion,
            ),
          ),
        );
      }
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.spacing(8)),
          child: Center(
            child: Text(
              '該当するクエストが見つかりません',
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 375),
          columnCount: 2,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: _QuestCard(
                quest: filteredQuests[index],
                categoryLabel: _localizeCategoryLabel(
                  l10n,
                  filteredQuests[index].category,
                ),
                onTap:
                    () => context.push(
                      AppRoutes.questDetail.replaceFirst(
                        ':questId',
                        filteredQuests[index].id.toString(),
                      ),
                    ),
              ),
            ),
          ),
        );
      }, childCount: filteredQuests.length),
    );
  }

  List<Widget> _buildAiSuggestionSlivers(
    MinqTheme tokens,
    AsyncValue<List<HabitAiSuggestion>> suggestions,
  ) {
    return suggestions.when(
      data: (items) {
        if (items.isEmpty) {
          return const <Widget>[];
        }
        return <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing(4),
                vertical: tokens.spacing(3),
              ),
              child: _AiSuggestionSection(suggestions: items),
            ),
          ),
        ];
      },
      loading:
          () => <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing(4),
                  vertical: tokens.spacing(3),
                ),
                child: _AiSuggestionSkeleton(tokens: tokens),
              ),
            ),
          ],
      error:
          (error, _) => <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing(4),
                  vertical: tokens.spacing(3),
                ),
                child: _AiSuggestionError(tokens: tokens),
              ),
            ),
          ],
    );
  }

  Widget _buildFab(MinqTheme tokens, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/quests/create'),
      label: Text(
        l10n.questsFabLabel,
        style: tokens.bodyLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      icon: const Icon(Icons.add, color: Colors.white),
      backgroundColor: tokens.brandPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerFull()),
    );
  }
}

String _localizeCategoryLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'Learning':
      return l10n.questsCategoryLearning;
    case 'Exercise':
      return l10n.questsCategoryExercise;
    case 'Tidying':
      return l10n.questsCategoryTidying;
    case 'My Quests':
      return l10n.questsCategoryMyQuests;
    case 'Featured':
      return l10n.questsCategoryFeatured;
    default:
      return key;
  }
}

class _QuestsSkeleton extends StatelessWidget {
  const _QuestsSkeleton({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      children: <Widget>[
        MinqSkeleton(
          height: tokens.spacing(13),
          borderRadius: tokens.cornerFull(),
        ),
        SizedBox(height: tokens.spacing(4)),
        const MinqSkeletonLine(width: double.infinity, height: 48),
        SizedBox(height: tokens.spacing(6)),
        const MinqSkeletonLine(width: 150, height: 28),
        SizedBox(height: tokens.spacing(4)),
        const MinqSkeletonGrid(
          crossAxisCount: 2,
          itemCount: 4,
          itemAspectRatio: 1.5,
        ),
      ],
    );
  }
}

class _AiSuggestionHeader extends StatelessWidget {
  const _AiSuggestionHeader();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Text(
      'AIおすすめ',
      style: tokens.titleLarge.copyWith(
        color: tokens.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _AiSuggestionSection extends StatelessWidget {
  const _AiSuggestionSection({required this.suggestions});

  final List<HabitAiSuggestion> suggestions;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AiSuggestionHeader(),
        SizedBox(height: tokens.spacing(2)),
        SizedBox(
          height: tokens.spacing(28),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => SizedBox(width: tokens.spacing(3)),
            itemBuilder:
                (context, index) =>
                    _AiSuggestionCard(suggestion: suggestions[index]),
          ),
        ),
      ],
    );
  }
}

class _AiSuggestionCard extends StatelessWidget {
  const _AiSuggestionCard({required this.suggestion});

  final HabitAiSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final template = suggestion.template;
    final icon = template.icon ?? Icons.star;
    final confidence = (suggestion.confidence * 100).clamp(0, 100).round();

    return Container(
      width: 240,
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon as IconData, size: 32, color: tokens.brandPrimary),
              SizedBox(width: tokens.spacing(2)),
              Expanded(
                child: Text(
                  template.title,
                  style: tokens.titleSmall.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing(1)),
          Text(
            '適合度: $confidence%',
            style: tokens.bodySmall.copyWith(
              color: tokens.brandPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            suggestion.rationale,
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: tokens.spacing(2)),
          ...suggestion.supportingFacts
              .take(2)
              .map(
                (fact) => Padding(
                  padding: EdgeInsets.only(bottom: tokens.spacing(1)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: tokens.bodySmall),
                      Expanded(
                        child: Text(
                          fact,
                          style: tokens.bodySmall.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _AiSuggestionSkeleton extends StatelessWidget {
  const _AiSuggestionSkeleton({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: tokens.spacing(3),
          width: tokens.spacing(16),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: tokens.cornerSmall(),
          ),
        ),
        SizedBox(height: tokens.spacing(3)),
        SizedBox(
          height: tokens.spacing(28),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder:
                (_, __) => MinqSkeleton(
                  width: 220,
                  height: tokens.spacing(28),
                  borderRadius: tokens.cornerLarge(),
                ),
            separatorBuilder: (_, __) => SizedBox(width: tokens.spacing(3)),
            itemCount: 3,
          ),
        ),
      ],
    );
  }
}

class _AiSuggestionError extends StatelessWidget {
  const _AiSuggestionError({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AiSuggestionHeader(),
        SizedBox(height: tokens.spacing(2)),
        Container(
          padding: EdgeInsets.all(tokens.spacing(4)),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: tokens.cornerLarge(),
            border: Border.all(color: tokens.border.withOpacity(0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, color: tokens.encouragement),
              SizedBox(width: tokens.spacing(2)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AIおすすめの取得に失敗しました。',
                      style: tokens.bodyMedium.copyWith(
                        color: tokens.encouragement,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(1)),
                    Text(
                      'ネットワークを確認し、時間をおいてから再度お試しください。',
                      style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.quest,
    required this.categoryLabel,
    required this.onTap,
  });

  final minq_quest.Quest quest;
  final String categoryLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      shadowColor: tokens.background.withOpacity(0.1),
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.cornerLarge(),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    iconDataForKey(quest.iconKey),
                    color: tokens.brandPrimary,
                    size: tokens.spacing(6),
                  ),
                  SizedBox(width: tokens.spacing(3)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.title,
                          style: tokens.bodyLarge.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        SizedBox(height: tokens.spacing(1)),
                        Text(
                          categoryLabel,
                          style: tokens.bodySmall.copyWith(
                            color: tokens.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearchResults extends StatelessWidget {
  const _EmptySearchResults({
    required this.query,
    required this.onClear,
    required this.onSuggestionSelected,
  });

  final String query;
  final VoidCallback onClear;
  final ValueChanged<String> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return MinqEmptyState(
      icon: Icons.search_off,
      title: '「$query」に一致するクエストはありません',
      message: '検索語を変えるか、AIおすすめを参考にしてみてください。',
      actionArea: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: tokens.spacing(2),
            runSpacing: tokens.spacing(2),
            children:
                _searchSuggestionKeywords
                    .map(
                      (keyword) => ActionChip(
                        label: Text(
                          keyword,
                          style: tokens.bodySmall.copyWith(
                            color: tokens.textPrimary,
                          ),
                        ),
                        onPressed: () => onSuggestionSelected(keyword),
                        backgroundColor: tokens.surface,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: tokens.border.withOpacity(0.6),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: tokens.spacing(3)),
          TextButton.icon(
            onPressed: onClear,
            icon: Icon(Icons.refresh, color: tokens.brandPrimary),
            label: Text(
              '検索条件をリセット',
              style: tokens.bodyMedium.copyWith(color: tokens.brandPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
