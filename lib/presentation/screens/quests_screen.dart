import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/quest/quest.dart' as minq_quest;
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  bool _isLoading = true;
  String _selectedCategory = 'Featured'; // Use English keys for state

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
    final l10n = AppLocalizations.of(context)!;
    final categories = ['Featured', 'My Quests', 'All', 'Learning', 'Exercise', 'Tidying'];
    final templateQuests = ref.watch(templateQuestsProvider);
    final userQuests = ref.watch(userQuestsProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(l10n.questsTitle, style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Tooltip(
          message: l10n.back,
          child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        ),
        backgroundColor: tokens.background.withOpacity(0.8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: (templateQuests.isLoading || userQuests.isLoading)
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
                  flexibleSpace: _buildCategoryTabs(tokens, categories, l10n),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(tokens.spacing(4)),
                  sliver: _buildQuestList(tokens, templateQuests.value ?? [], userQuests.value ?? []),
                ),
              ],
            ),
      floatingActionButton: (templateQuests.isLoading || userQuests.isLoading) ? null : _buildFab(tokens, l10n),
    );
  }

  Widget _buildSearchBar(MinqTheme tokens, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: TextField(
        decoration: InputDecoration(
          hintText: l10n.questsSearchHint,
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

  Widget _buildCategoryTabs(MinqTheme tokens, List<String> categories, AppLocalizations l10n) {
    String getLocalizedCategory(String key) {
      switch (key) {
        case 'Featured': return l10n.questsCategoryFeatured;
        case 'My Quests': return l10n.questsCategoryMyQuests;
        case 'All': return l10n.questsCategoryAll;
        case 'Learning': return l10n.questsCategoryLearning;
        case 'Exercise': return l10n.questsCategoryExercise;
        case 'Tidying': return l10n.questsCategoryTidying;
        default: return key;
      }
    }

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
          final categoryKey = categories[index];
          final isSelected = categoryKey == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = categoryKey),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing(3)),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isSelected ? tokens.brandPrimary : Colors.transparent, width: 2.0)),
              ),
              child: Text(
                getLocalizedCategory(categoryKey),
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

  Widget _buildQuestList(MinqTheme tokens, List<minq_quest.Quest> templateQuests, List<minq_quest.Quest> userQuests) {
    List<minq_quest.Quest> questsToShow = [];
    if (_selectedCategory == 'All') {
      questsToShow = [...templateQuests, ...userQuests];
    } else if (_selectedCategory == 'My Quests') {
      questsToShow = userQuests;
    } else if (_selectedCategory == 'Featured') {
      questsToShow = templateQuests.take(4).toList(); // Simple featured logic
    } else {
      questsToShow = templateQuests.where((q) => q.category == _selectedCategory).toList();
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _QuestCard(quest: questsToShow[index]),
              ),
            ),
          );
        },
        childCount: questsToShow.length,
      ),
    );
  }

  Widget _buildFab(MinqTheme tokens, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/quests/create'),
      label: Text(l10n.questsFabLabel, style: tokens.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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

class _QuestCard extends StatelessWidget {
  const _QuestCard({required this.quest});

  final minq_quest.Quest quest;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
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
                Icon(iconDataForKey(quest.iconKey), color: tokens.brandPrimary, size: tokens.spacing(6)),
                SizedBox(width: tokens.spacing(3)),
                Expanded(
                  child: Text(
                    quest.title,
                    style: tokens.bodyLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            // We can add user count for template quests if needed
          ],
        ),
      ),
    );
  }
}