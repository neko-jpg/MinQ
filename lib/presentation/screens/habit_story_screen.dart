import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/ai/habit_story_generator.dart';
import 'package:minq/presentation/widgets/empty_state_widget.dart';

/// ハビットストーリー画面
class HabitStoryScreen extends ConsumerStatefulWidget {
  const HabitStoryScreen({super.key});

  @override
  ConsumerState<HabitStoryScreen> createState() => _HabitStoryScreenState();
}

class _HabitStoryScreenState extends ConsumerState<HabitStoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final HabitStoryGenerator _storyGenerator = HabitStoryGenerator.instance;

  List<HabitStory> _stories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStories() async {
    setState(() => _isLoading = true);

    try {
      // サンプルデータでストーリーを生成
      final sampleData = HabitProgressData(
        habitTitle: '朝の瞑想',
        category: 'mindfulness',
        currentStreak: 7,
        totalCompletions: 25,
        weeklyCompletionRate: 0.85,
        averageWeeklyMood: 4.2,
        todayMood: 4,
        activeHabits: 3,
        achievements: ['7日連続達成', '週間目標クリア'],
        startDate: DateTime.now().subtract(const Duration(days: 25)),
      );

      final stories = <HabitStory>[];

      // 複数のストーリータイプを生成
      for (final type in [
        StoryType.dailyAchievement,
        StoryType.streakMilestone,
        StoryType.weeklyProgress,
      ]) {
        try {
          final story = await _storyGenerator.generateStory(
            type: type,
            progressData: sampleData,
          );
          stories.add(story);
        } catch (e) {
          debugPrint('ストーリー生成エラー: $e');
        }
      }

      setState(() {
        _stories = stories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ストーリーの読み込みに失敗しました: $e')));
      }
    }
  }

  Future<void> _generateNewStory(StoryType type) async {
    setState(() => _isLoading = true);

    try {
      final sampleData = HabitProgressData(
        habitTitle: '読書習慣',
        category: 'learning',
        currentStreak: 14,
        totalCompletions: 42,
        weeklyCompletionRate: 0.92,
        averageWeeklyMood: 4.5,
        todayMood: 5,
        activeHabits: 4,
        achievements: ['2週間連続達成', '月間目標クリア', '新記録更新'],
        startDate: DateTime.now().subtract(const Duration(days: 42)),
      );

      final story = await _storyGenerator.generateStory(
        type: type,
        progressData: sampleData,
      );

      setState(() {
        _stories.insert(0, story);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('新しいストーリーを生成しました！')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ストーリー生成に失敗しました: $e')));
      }
    }
  }

  void _showStoryDetail(HabitStory story) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildStoryDetailSheet(story),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ハビットストーリー'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ギャラリー', icon: Icon(Icons.photo_library)),
            Tab(text: '作成', icon: Icon(Icons.add_circle_outline)),
            Tab(text: '設定', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGalleryTab(), _buildCreateTab(), _buildSettingsTab()],
      ),
    );
  }

  Widget _buildGalleryTab() {
    if (_isLoading && _stories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stories.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.auto_stories,
        title: 'ストーリーがありません',
        message: '「作成」タブから新しいストーリーを生成してみましょう',
        action: ElevatedButton(
          onPressed: () => _tabController.animateTo(1),
          child: const Text('作成する'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStories,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return _buildStoryCard(story);
        },
      ),
    );
  }

  Widget _buildStoryCard(HabitStory story) {
    return GestureDetector(
      onTap: () => _showStoryDetail(story),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.1).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 背景画像またはグラデーション
              if (story.imageFile != null)
                Positioned.fill(
                  child: Image.file(story.imageFile!, fit: BoxFit.cover),
                )
              else
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: story.visualElements.backgroundGradient,
                    ),
                  ),
                ),

              // オーバーレイ
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha((255 * 0.7).round()),
                      ],
                    ),
                  ),
                ),
              ),

              // コンテンツ
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      story.visualElements.iconEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      story.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(story.createdAt),
                      style: TextStyle(
                        color: Colors.white.withAlpha((255 * 0.8).round()),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // タイプバッジ
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((255 * 0.6).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStoryTypeLabel(story.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ストーリータイプを選択',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStoryTypeButton(
                    StoryType.dailyAchievement,
                    '今日の達成',
                    '今日完了した習慣の成果を祝福',
                    Icons.today,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildStoryTypeButton(
                    StoryType.streakMilestone,
                    'ストリーク記録',
                    '継続日数の節目を記念',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildStoryTypeButton(
                    StoryType.weeklyProgress,
                    '週次振り返り',
                    '1週間の進捗をまとめて表示',
                    Icons.calendar_view_week,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildStoryTypeButton(
                    StoryType.celebration,
                    'お祝い',
                    '特別な達成を盛大に祝福',
                    Icons.celebration,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (_isLoading)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('ストーリーを生成中...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoryTypeButton(
    StoryType type,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: _isLoading ? null : () => _generateNewStory(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('自動生成'),
                subtitle: const Text('マイルストーン達成時に自動でストーリーを作成'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: 設定の保存
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('通知'),
                subtitle: const Text('新しいストーリーが作成されたときに通知'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: 設定の保存
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('テーマ設定'),
                subtitle: const Text('ストーリーのデザインテーマを選択'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: テーマ設定画面
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('テキスト設定'),
                subtitle: const Text('フォントサイズや言語を設定'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: テキスト設定画面
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('ストレージ'),
                subtitle: const Text('保存されたストーリーの管理'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: ストレージ管理画面
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('エクスポート'),
                subtitle: const Text('ストーリーをデバイスに保存'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: エクスポート機能
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryDetailSheet(HabitStory story) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ハンドル
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ヘッダー
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        story.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // コンテンツ
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ストーリー画像
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((255 * 0.1).round()),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child:
                              story.imageFile != null
                                  ? Image.file(
                                    story.imageFile!,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    decoration: BoxDecoration(
                                      gradient:
                                          story
                                              .visualElements
                                              .backgroundGradient,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            story.visualElements.iconEmoji,
                                            style: const TextStyle(
                                              fontSize: 64,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            story.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            story.content,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ストーリー情報
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ストーリー情報',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'タイプ',
                                _getStoryTypeLabel(story.type),
                              ),
                              _buildInfoRow(
                                '作成日時',
                                _formatDateTime(story.createdAt),
                              ),
                              _buildInfoRow(
                                '習慣',
                                story.progressData.habitTitle,
                              ),
                              _buildInfoRow(
                                'カテゴリ',
                                story.progressData.category,
                              ),
                              _buildInfoRow(
                                '継続日数',
                                '${story.progressData.currentStreak}日',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // アクションボタン
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _shareStory(story),
                              icon: const Icon(Icons.share),
                              label: const Text('共有'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _downloadStory(story),
                              icon: const Icon(Icons.download),
                              label: const Text('保存'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareStory(HabitStory story) async {
    try {
      await _storyGenerator.shareStory(story);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ストーリーを共有しました')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('共有に失敗しました: $e')));
      }
    }
  }

  Future<void> _downloadStory(HabitStory story) async {
    try {
      // TODO: ギャラリーに保存する機能を実装
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ストーリーを保存しました')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
      }
    }
  }

  String _getStoryTypeLabel(StoryType type) {
    switch (type) {
      case StoryType.dailyAchievement:
        return '今日の達成';
      case StoryType.streakMilestone:
        return 'ストリーク';
      case StoryType.weeklyProgress:
        return '週次進捗';
      case StoryType.monthlyReflection:
        return '月次振り返り';
      case StoryType.yearlyJourney:
        return '年間軌跡';
      case StoryType.weeklySummary:
        return '週次サマリー';
      case StoryType.motivational:
        return 'モチベーション';
      case StoryType.celebration:
        return 'お祝い';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
