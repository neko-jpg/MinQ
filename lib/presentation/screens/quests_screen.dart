import 'package:flutter/material.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';

class _QuestTemplateData {
  const _QuestTemplateData({
    required this.icon,
    required this.title,
    required this.userCount,
  });

  final IconData icon;
  final String title;
  final String userCount;
}

const Map<String, List<_QuestTemplateData>> _templatesByCategory = {
  'Featured': <_QuestTemplateData>[
    _QuestTemplateData(
      icon: Icons.auto_stories,
      title: 'Read 1 page of a book',
      userCount: '12.3k users',
    ),
    _QuestTemplateData(
      icon: Icons.fitness_center,
      title: 'Do 1 push-up',
      userCount: '11.8k users',
    ),
    _QuestTemplateData(
      icon: Icons.self_improvement,
      title: 'Stretch for 1 minute',
      userCount: '9.7k users',
    ),
  ],
  'All': <_QuestTemplateData>[
    _QuestTemplateData(
      icon: Icons.auto_stories,
      title: 'Read 1 page of a book',
      userCount: '12.3k users',
    ),
    _QuestTemplateData(
      icon: Icons.fitness_center,
      title: 'Do 1 push-up',
      userCount: '11.8k users',
    ),
    _QuestTemplateData(
      icon: Icons.self_improvement,
      title: 'Stretch for 1 minute',
      userCount: '9.7k users',
    ),
    _QuestTemplateData(
      icon: Icons.bed,
      title: 'Make your bed',
      userCount: '8.2k users',
    ),
  ],
  'Learning': <_QuestTemplateData>[
    _QuestTemplateData(
      icon: Icons.library_books,
      title: 'Review flashcards',
      userCount: '5.1k users',
    ),
    _QuestTemplateData(
      icon: Icons.edit_note,
      title: 'Journal one insight',
      userCount: '3.8k users',
    ),
  ],
  'Exercise': <_QuestTemplateData>[
    _QuestTemplateData(
      icon: Icons.directions_walk,
      title: 'Walk 500 steps',
      userCount: '7.4k users',
    ),
    _QuestTemplateData(
      icon: Icons.self_improvement,
      title: '2-minute stretch',
      userCount: '4.6k users',
    ),
  ],
  'Tidying': <_QuestTemplateData>[],
};

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  static const List<String> _categories = <String>[
    'Featured',
    'All',
    'Learning',
    'Exercise',
    'Tidying',
  ];

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  bool _showHelpBanner = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        backgroundColor: tokens.background,
        appBar: AppBar(
          title: Text(
            'Quests',
            style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(tokens.spacing(12)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _isLoading
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing(5),
                        vertical: tokens.spacing(3),
                      ),
                      child: const MinqSkeletonLine(width: 220, height: 24),
                    )
                  : TabBar(
                      isScrollable: true,
                      indicatorColor: tokens.brandPrimary,
                      labelColor: tokens.brandPrimary,
                      unselectedLabelColor: tokens.textMuted,
                      labelStyle: tokens.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: tokens.bodySmall,
                      tabs: _categories
                          .map((String title) => Tab(text: title))
                          .toList(),
                    ),
            ),
          ),
        ),
        body: _isLoading
            ? _QuestsSkeleton(tokens: tokens)
            : Column(
                children: <Widget>[
                  if (_showHelpBanner)
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.all(tokens.spacing(5)),
                      color: tokens.brandPrimary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: tokens.cornerLarge()),
                      child: ListTile(
                        leading:
                            Icon(Icons.info_outline, color: tokens.brandPrimary),
                        title: Text(
                          'ここから新しいQuestを追加したり、既存のQuestを編集したりできます。',
                          style: tokens.bodySmall
                              .copyWith(color: tokens.textPrimary),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.close, color: tokens.textPrimary),
                          onPressed: () =>
                              setState(() => _showHelpBanner = false),
                        ),
                      ),
                    ),
                  Expanded(
                    child: TabBarView(
                      children:
                          QuestsScreen._categories.map((String category) {
                        final templates =
                            _templatesByCategory[category] ??
                                const <_QuestTemplateData>[];
                        return _QuestCategoryList(
                          category: category,
                          templates: templates,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
        floatingActionButton: _isLoading
            ? null
            : FloatingActionButton.extended(
                onPressed: () {},
                label: Text(
                  'Create Custom',
                  style: tokens.bodyMedium.copyWith(
                    color: tokens.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: Icon(Icons.add, color: tokens.surface),
                backgroundColor: tokens.brandPrimary,
              ),
      ),
    );
  }
}

class _QuestsSkeleton extends StatelessWidget {
  const _QuestsSkeleton({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(tokens.spacing(5)),
      children: <Widget>[
        MinqSkeleton(
          height: tokens.spacing(12),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(4)),
        const MinqSkeletonGrid(
          crossAxisCount: 2,
          itemCount: 4,
          itemAspectRatio: 1.2,
        ),
        SizedBox(height: tokens.spacing(5)),
        const MinqSkeletonLine(width: 200, height: 20),
        SizedBox(height: tokens.spacing(3)),
        const MinqSkeletonList(itemCount: 3, itemHeight: 82),
      ],
    );
  }
}

class _QuestCategoryList extends StatelessWidget {
  const _QuestCategoryList({required this.category, required this.templates});

  final String category;
  final List<_QuestTemplateData> templates;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasTemplates = templates.isNotEmpty;

    return ListView(
      padding: EdgeInsets.all(tokens.spacing(5)),
      children: <Widget>[
        _buildSearchBar(tokens),
        SizedBox(height: tokens.spacing(6)),
        if (!hasTemplates)
          MinqEmptyState(
            icon: Icons.search_off,
            title: '保存済みのQuestがありません',
            message: 'テンプレートを検索するか、自分だけのQuestを作成しましょう。',
            actionLabel: 'Questを作成',
            onAction:
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Custom quest creation coming soon.'),
                  ),
                ),
          ),
        if (hasTemplates)
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: templates.length,
            itemBuilder: (BuildContext context, int index) {
              final template = templates[index];
              return _QuestTemplateCard(data: template);
            },
          ),
      ],
    );
  }

  Widget _buildSearchBar(MinqTheme tokens) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for templates…',
        hintStyle: tokens.bodySmall.copyWith(color: tokens.textMuted),
        prefixIcon: Icon(Icons.search, color: tokens.textMuted),
        filled: true,
        fillColor: tokens.surface,
        border: OutlineInputBorder(
          borderRadius: tokens.cornerXLarge(),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: tokens.spacing(3)),
      ),
    );
  }
}

class _QuestTemplateCard extends StatelessWidget {
  const _QuestTemplateCard({required this.data});

  final _QuestTemplateData data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerMedium()),
      shadowColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  data.icon,
                  color: tokens.brandPrimary,
                  size: tokens.spacing(6),
                ),
                SizedBox(width: tokens.spacing(2)),
                Expanded(
                  child: Text(
                    data.title,
                    style: tokens.bodyMedium.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.group_outlined,
                  color: tokens.textMuted,
                  size: tokens.spacing(4),
                ),
                SizedBox(width: tokens.spacing(1)),
                Text(
                  data.userCount,
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
