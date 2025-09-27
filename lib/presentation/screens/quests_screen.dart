import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';

class _QuestTemplateData {
  const _QuestTemplateData({
    required this.icon,
    required this.title,
    this.userCount,
  });

  final IconData icon;
  final String title;
  final String? userCount;
}

const Map<String, List<_QuestTemplateData>> _templatesByCategory = {
  'Featured': <_QuestTemplateData>[
    _QuestTemplateData(icon: Icons.auto_stories, title: 'Read 1 page of a book', userCount: '12.3k users'),
    _QuestTemplateData(icon: Icons.fitness_center, title: 'Do 1 push-up', userCount: '11.8k users'),
    _QuestTemplateData(icon: Icons.self_improvement, title: 'Stretch for 1 minute', userCount: '9.7k users'),
    _QuestTemplateData(icon: Icons.bed, title: 'Make your bed', userCount: '8.2k users'),
  ],
  'Learning': <_QuestTemplateData>[
    _QuestTemplateData(icon: Icons.auto_stories, title: 'Read 1 page of a book'),
    _QuestTemplateData(icon: Icons.headphones, title: 'Listen to 1 minute of an audiobook'),
  ],
  'Exercise': <_QuestTemplateData>[
    _QuestTemplateData(icon: Icons.fitness_center, title: 'Do 1 push-up'),
    _QuestTemplateData(icon: Icons.directions_walk, title: 'Walk for 1 minute'),
  ],
};

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  bool _isLoading = true;
  String _selectedCategory = 'Featured';

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
    final categories = ['Featured', 'All', 'Learning', 'Exercise', 'Tidying'];

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Mini-Quests', style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        backgroundColor: tokens.background.withOpacity(0.8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? _QuestsSkeleton(tokens: tokens)
          : CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(child: _buildSearchBar(tokens)),
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 60,
                  backgroundColor: tokens.background.withOpacity(0.8),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: _buildCategoryTabs(tokens, categories),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(tokens.spacing(4)),
                  sliver: _buildQuestSections(tokens),
                ),
              ],
            ),
      floatingActionButton: _isLoading ? null : _buildFab(tokens),
    );
  }

  Widget _buildSearchBar(MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for templates...',
          prefixIcon: Icon(Icons.search, color: tokens.textMuted),
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

  Widget _buildCategoryTabs(MinqTheme tokens, List<String> categories) {
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
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing(3)),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isSelected ? tokens.brandPrimary : Colors.transparent, width: 2.0)),
              ),
              child: Text(
                category,
                style: isSelected
                    ? tokens.bodyMedium.copyWith(color: tokens.brandPrimary, fontWeight: FontWeight.bold)
                    : tokens.bodyMedium.copyWith(color: tokens.textMuted),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestSections(MinqTheme tokens) {
    return SliverList(
      delegate: SliverChildListDelegate(
        _templatesByCategory.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: tokens.spacing(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
                SizedBox(height: tokens.spacing(4)),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5, // Adjusted for new card layout
                  ),
                  itemCount: entry.value.length,
                  itemBuilder: (context, index) => AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: _QuestTemplateCard(data: entry.value[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFab(MinqTheme tokens) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/quests/create'),
      label: Text('Create Custom', style: tokens.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      icon: const Icon(Icons.add, color: Colors.white),
      backgroundColor: tokens.brandPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerFull()),
    );
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
        MinqSkeleton(height: tokens.spacing(13), borderRadius: tokens.cornerFull()),
        SizedBox(height: tokens.spacing(4)),
        const MinqSkeletonLine(width: double.infinity, height: 48),
        SizedBox(height: tokens.spacing(6)),
        const MinqSkeletonLine(width: 150, height: 28),
        SizedBox(height: tokens.spacing(4)),
        const MinqSkeletonGrid(crossAxisCount: 2, itemCount: 4, itemAspectRatio: 1.5),
      ],
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
      elevation: 1,
      shadowColor: tokens.background.withOpacity(0.1),
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(data.icon, color: tokens.brandPrimary, size: tokens.spacing(6)),
                SizedBox(width: tokens.spacing(3)),
                Expanded(
                  child: Text(
                    data.title,
                    style: tokens.bodyLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            if (data.userCount != null)
              Row(
                children: <Widget>[
                  Icon(Icons.group, color: tokens.textMuted, size: tokens.spacing(4)),
                  SizedBox(width: tokens.spacing(1)),
                  Text(data.userCount!, style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}