import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/battle/battle_service.dart';
import 'package:minq/presentation/widgets/empty_state_widget.dart';

/// ハビットバトル画面
class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({super.key});

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final BattleService _battleService = BattleService.instance;

  List<Battle> _availableBattles = [];
  List<BattleRanking> _rankings = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: 実際のユーザーIDを取得
      await _battleService.initialize('current_user_id');

      final battles = await _battleService.searchAvailableBattles();
      final rankings = await _battleService.getGlobalRanking();

      setState(() {
        _availableBattles = battles;
        _rankings = rankings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('データの読み込みに失敗しました: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ハビットバトル'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'バトル', icon: Icon(Icons.sports_esports)),
            Tab(text: '作成', icon: Icon(Icons.add_circle_outline)),
            Tab(text: 'ランキング', icon: Icon(Icons.leaderboard)),
            Tab(text: '履歴', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBattleListTab(),
          _buildCreateBattleTab(),
          _buildRankingTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildBattleListTab() {
    if (_isLoading && _availableBattles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // フィルター
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'カテゴリ',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('すべて')),
                    DropdownMenuItem(value: 'fitness', child: Text('フィットネス')),
                    DropdownMenuItem(
                      value: 'mindfulness',
                      child: Text('マインドフルネス'),
                    ),
                    DropdownMenuItem(value: 'learning', child: Text('学習')),
                    DropdownMenuItem(value: 'productivity', child: Text('生産性')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                    _filterBattles();
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
            ],
          ),
        ),

        // バトルリスト
        Expanded(
          child:
              _availableBattles.isEmpty
                  ? EmptyStateWidget(
                    icon: Icons.sports_esports,
                    title: 'バトルがありません',
                    message: '新しいバトルを作成するか、しばらく待ってから再度確認してください',
                    action: ElevatedButton(
                      onPressed: () => _tabController.animateTo(1),
                      child: const Text('バトルを作成'),
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _availableBattles.length,
                      itemBuilder: (context, index) {
                        final battle = _availableBattles[index];
                        return _buildBattleCard(battle);
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildBattleCard(Battle battle) {
    final progress = battle.participants.length / battle.maxParticipants;
    final timeLeft = battle.duration;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showBattleDetail(battle),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        battle.category,
                      ).withAlpha((255 * 0.1).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(battle.category),
                      color: _getCategoryColor(battle.category),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          battle.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          battle.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha((255 * 0.1).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${battle.entryFee}P',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 説明
              Text(
                battle.description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 進捗と情報
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '参加者 ${battle.participants.length}/${battle.maxParticipants}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation(
                            _getCategoryColor(battle.category),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '期間: ${_formatDuration(timeLeft)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '賞金: ${battle.totalPrize}P',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // アクションボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _joinBattle(battle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCategoryColor(battle.category),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('参加する'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateBattleTab() {
    return SingleChildScrollView(
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
                    'バトルを作成',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // タイトル
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'バトルタイトル',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // カテゴリ
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'カテゴリ',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'fitness', child: Text('フィットネス')),
                      DropdownMenuItem(
                        value: 'mindfulness',
                        child: Text('マインドフルネス'),
                      ),
                      DropdownMenuItem(value: 'learning', child: Text('学習')),
                      DropdownMenuItem(
                        value: 'productivity',
                        child: Text('生産性'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),

                  // 期間
                  DropdownButtonFormField<Duration>(
                    decoration: const InputDecoration(
                      labelText: '期間',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: Duration(hours: 1),
                        child: Text('1時間'),
                      ),
                      DropdownMenuItem(
                        value: Duration(hours: 6),
                        child: Text('6時間'),
                      ),
                      DropdownMenuItem(
                        value: Duration(hours: 24),
                        child: Text('24時間'),
                      ),
                      DropdownMenuItem(
                        value: Duration(days: 7),
                        child: Text('1週間'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),

                  // 参加費
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '参加費（ポイント）',
                      border: OutlineInputBorder(),
                      suffixText: 'P',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // 説明
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '説明',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // 作成ボタン
                  ElevatedButton(
                    onPressed: _createBattle,
                    child: const Text('バトルを作成'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // クイック作成
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'クイック作成',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickCreateButton(
                    '朝活バトル',
                    '早起きして習慣を実行',
                    'fitness',
                    const Duration(hours: 6),
                    50,
                  ),
                  const SizedBox(height: 8),
                  _buildQuickCreateButton(
                    '瞑想バトル',
                    'マインドフルネス習慣',
                    'mindfulness',
                    const Duration(hours: 24),
                    30,
                  ),
                  const SizedBox(height: 8),
                  _buildQuickCreateButton(
                    '学習バトル',
                    '継続学習で成長',
                    'learning',
                    const Duration(days: 7),
                    100,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCreateButton(
    String title,
    String description,
    String category,
    Duration duration,
    int entryFee,
  ) {
    return InkWell(
      onTap:
          () => _createQuickBattle(
            title,
            description,
            category,
            duration,
            entryFee,
          ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              _getCategoryIcon(category),
              color: _getCategoryColor(category),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Text(
              '${entryFee}P',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingTab() {
    if (_isLoading && _rankings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rankings.length,
      itemBuilder: (context, index) {
        final ranking = _rankings[index];
        return _buildRankingCard(ranking);
      },
    );
  }

  Widget _buildRankingCard(BattleRanking ranking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(ranking.rank),
          child: Text(
            '${ranking.rank}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          ranking.username,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '勝率: ${(ranking.winRate * 100).toStringAsFixed(1)}% (${ranking.totalWins}/${ranking.totalBattles})',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${ranking.totalPoints}P',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const Text('総ポイント', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ValueListenableBuilder<List<BattleResult>>(
      valueListenable: _battleService.battleHistory,
      builder: (context, history, child) {
        if (history.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.history,
            title: 'バトル履歴がありません',
            message: 'バトルに参加すると履歴が表示されます',
            action: ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              child: const Text('バトルに参加'),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final result = history[index];
            return _buildHistoryCard(result);
          },
        );
      },
    );
  }

  Widget _buildHistoryCard(BattleResult result) {
    final isWinner =
        result.winner?.userId == 'current_user_id'; // TODO: 実際のユーザーID

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isWinner ? Icons.emoji_events : Icons.sports_esports,
                  color: isWinner ? Colors.amber : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatDate(result.completedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '参加者: ${result.participants.length}人 | 期間: ${_formatDuration(result.duration)}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            if (isWinner) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🏆 勝利！ 賞金: ${result.totalPrize}P',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBattleDetail(Battle battle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBattleDetailSheet(battle),
    );
  }

  Widget _buildBattleDetailSheet(Battle battle) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
                        battle.title,
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
                      // バトル情報
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'バトル情報',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow('カテゴリ', battle.category),
                              _buildInfoRow(
                                '期間',
                                _formatDuration(battle.duration),
                              ),
                              _buildInfoRow('参加費', '${battle.entryFee}P'),
                              _buildInfoRow('賞金総額', '${battle.totalPrize}P'),
                              _buildInfoRow(
                                '参加者',
                                '${battle.participants.length}/${battle.maxParticipants}',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 説明
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '説明',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(battle.description),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 参加ボタン
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _joinBattle(battle);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getCategoryColor(battle.category),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('参加する'),
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

  Future<void> _filterBattles() async {
    // TODO: カテゴリフィルターの実装
  }

  Future<void> _joinBattle(Battle battle) async {
    try {
      await _battleService.joinBattle(
        battle.id,
        'current_user_id',
      ); // TODO: 実際のユーザーID

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('バトルに参加しました！')));
      }

      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('参加に失敗しました: $e')));
      }
    }
  }

  Future<void> _createBattle() async {
    try {
      // TODO: フォームの値を取得して実際のバトルを作成
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('バトルを作成しました！')));
      }

      _tabController.animateTo(0);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('作成に失敗しました: $e')));
      }
    }
  }

  Future<void> _createQuickBattle(
    String title,
    String description,
    String category,
    Duration duration,
    int entryFee,
  ) async {
    try {
      await _battleService.createBattle(
        creatorId: 'current_user_id', // TODO: 実際のユーザーID
        habitCategory: category,
        duration: duration,
        entryFee: entryFee,
        title: title,
        description: description,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('「$title」を作成しました！')));
      }

      _tabController.animateTo(0);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('作成に失敗しました: $e')));
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'fitness':
        return Colors.red;
      case 'mindfulness':
        return Colors.blue;
      case 'learning':
        return Colors.purple;
      case 'productivity':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'fitness':
        return Icons.fitness_center;
      case 'mindfulness':
        return Icons.self_improvement;
      case 'learning':
        return Icons.school;
      case 'productivity':
        return Icons.work;
      default:
        return Icons.category;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}日';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}時間';
    } else {
      return '${duration.inMinutes}分';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
