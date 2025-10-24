import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/mood/mood_tracking_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/mood_selector_widget.dart';

class MoodTrackingScreen extends ConsumerStatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  ConsumerState<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends ConsumerState<MoodTrackingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'ムード追跡',
          style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: tokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '記録'), Tab(text: 'グラフ'), Tab(text: '分析')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_MoodRecordTab(), _MoodGraphTab(), _MoodAnalysisTab()],
      ),
    );
  }
}

class _MoodRecordTab extends ConsumerStatefulWidget {
  const _MoodRecordTab();

  @override
  ConsumerState<_MoodRecordTab> createState() => _MoodRecordTabState();
}

class _MoodRecordTabState extends ConsumerState<_MoodRecordTab> {
  String _selectedMood = 'neutral';
  int _selectedRating = 3;
  bool _isLoading = false;

  final Map<String, MoodData> _moodOptions = {
    'very_happy': const MoodData(
      emoji: '😄',
      label: 'とても良い',
      color: Color(0xFF4CAF50),
      description: '最高の気分です！',
    ),
    'happy': const MoodData(
      emoji: '😊',
      label: '良い',
      color: Color(0xFF8BC34A),
      description: '気分が良いです',
    ),
    'neutral': const MoodData(
      emoji: '😐',
      label: '普通',
      color: Color(0xFFFF9800),
      description: '普通の気分です',
    ),
    'sad': const MoodData(
      emoji: '😔',
      label: '悪い',
      color: Color(0xFFFF5722),
      description: '少し落ち込んでいます',
    ),
    'very_sad': const MoodData(
      emoji: '😢',
      label: 'とても悪い',
      color: Color(0xFFF44336),
      description: 'とても落ち込んでいます',
    ),
  };

  Future<void> _recordMood() async {
    final uid = ref.read(uidProvider);
    if (uid == null) {
      FeedbackMessenger.showErrorSnackBar(context, 'ユーザーがサインインしていません');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(moodTrackingServiceProvider);
      await service.recordMood(
        userId: uid,
        mood: _selectedMood,
        rating: _selectedRating,
      );

      if (mounted) {
        FeedbackMessenger.showSuccessToast(context, '気分を記録しました！');
      }
    } catch (e) {
      if (mounted) {
        FeedbackMessenger.showErrorSnackBar(context, '気分の記録に失敗しました');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final selectedMoodData = _moodOptions[_selectedMood]!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 説明カード
          Card(
            elevation: 0,
            color: selectedMoodData.color.withAlpha((255 * 0.1).round()),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(tokens.radius.lg)),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                children: [
                  Text(
                    selectedMoodData.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                  SizedBox(height: tokens.spacing.sm),
                  Text(
                    '今の気分はいかがですか？',
                    style: tokens.typography.h4.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.spacing.sm),
                  Text(
                    '気分を記録することで、習慣との関係性を分析できます',
                    style: tokens.typography.body.copyWith(color: tokens.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: tokens.spacing.xl),

          // 気分選択
          Text(
            '気分を選択',
            style: tokens.typography.body.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          MoodSelectorWidget(
            moodOptions: _moodOptions,
            selectedMood: _selectedMood,
            onMoodSelected: (mood) {
              setState(() {
                _selectedMood = mood;
                // 気分に応じてデフォルトの評価を設定
                switch (mood) {
                  case 'very_happy':
                    _selectedRating = 5;
                    break;
                  case 'happy':
                    _selectedRating = 4;
                    break;
                  case 'neutral':
                    _selectedRating = 3;
                    break;
                  case 'sad':
                    _selectedRating = 2;
                    break;
                  case 'very_sad':
                    _selectedRating = 1;
                    break;
                }
              });
            },
          ),

          SizedBox(height: tokens.spacing.lg),

          // 評価スライダー
          Text(
            '詳細な評価 ($_selectedRating/5)',
            style: tokens.typography.body.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(tokens.radius.lg),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1',
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                      Text(
                        selectedMoodData.description,
                        style: tokens.typography.body.copyWith(
                          color: selectedMoodData.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '5',
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: selectedMoodData.color,
                      thumbColor: selectedMoodData.color,
                      overlayColor: selectedMoodData.color.withAlpha((255 * 0.2).round()),
                    ),
                    child: Slider(
                      value: _selectedRating.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (value) {
                        setState(() {
                          _selectedRating = value.round();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: tokens.spacing.xl),

          // 記録ボタン
          MinqPrimaryButton(
            label: '気分を記録する',
            icon: Icons.favorite,
            onPressed: _isLoading ? null : _recordMood,
            // TODO(Jules): isLoading is not a valid parameter. I should fix this later.
            // isLoading: _isLoading,
          ),

          SizedBox(height: tokens.spacing.lg),

          // 今日の記録履歴
          _TodayMoodHistory(),
        ],
      ),
    );
  }
}

class _MoodGraphTab extends ConsumerWidget {
  const _MoodGraphTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 期間選択
          Row(
            children: [
              Text(
                '表示期間',
                style: tokens.typography.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('7日')),
                  ButtonSegment(value: 30, label: Text('30日')),
                  ButtonSegment(value: 90, label: Text('90日')),
                ],
                selected: const {30},
                onSelectionChanged: (selection) {
                  // TODO: 期間変更処理
                },
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.lg),

          // 気分推移グラフ
          Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(tokens.radius.lg),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '気分の推移',
                    style: tokens.typography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.lg),
                  SizedBox(height: 200, child: _MoodLineChart()),
                ],
              ),
            ),
          ),

          SizedBox(height: tokens.spacing.lg),

          // 気分分布
          Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(tokens.radius.lg),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '気分の分布',
                    style: tokens.typography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.lg),
                  SizedBox(height: 200, child: _MoodPieChart()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodAnalysisTab extends ConsumerWidget {
  const _MoodAnalysisTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分析実行ボタン
          MinqPrimaryButton(
            label: '習慣との相関分析を実行',
            icon: Icons.analytics,
            onPressed: () => _runCorrelationAnalysis(context, ref),
          ),

          SizedBox(height: tokens.spacing.lg),

          // 相関分析結果
          Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(tokens.radius.lg),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights, color: tokens.brandPrimary),
                      SizedBox(width: tokens.spacing.sm),
                      Text(
                        '習慣との相関分析',
                        style: tokens.typography.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing.md),
                  _CorrelationInsights(),
                ],
              ),
            ),
          ),

          SizedBox(height: tokens.spacing.lg),

          // AIインサイト
          Card(
            elevation: 0,
            color: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radius.lg)),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: tokens.brandPrimary),
                      SizedBox(width: tokens.spacing.sm),
                      Text(
                        'AIインサイト',
                        style: tokens.typography.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing.md),
                  _AIInsights(),
                ],
              ),
            ),
          ),

          SizedBox(height: tokens.spacing.lg),

          // 改善提案
          Card(
            elevation: 0,
            color: tokens.encouragement.withAlpha((255 * 0.1).round()),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radius.lg)),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: tokens.encouragement),
                      SizedBox(width: tokens.spacing.sm),
                      Text(
                        '改善提案',
                        style: tokens.typography.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing.md),
                  _ImprovementSuggestions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runCorrelationAnalysis(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final uid = ref.read(uidProvider);
    if (uid == null) {
      FeedbackMessenger.showErrorSnackBar(context, 'ユーザーがサインインしていません');
      return;
    }

    try {
      final service = ref.read(moodTrackingServiceProvider);
      await service.analyzeMoodHabitCorrelation(uid);

      if (context.mounted) {
        FeedbackMessenger.showSuccessToast(context, '相関分析が完了しました！');
      }
    } catch (e) {
      if (context.mounted) {
        FeedbackMessenger.showErrorSnackBar(context, '分析に失敗しました');
      }
    }
  }
}

// 補助ウィジェット
class _TodayMoodHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日の記録',
              style: tokens.typography.body.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: tokens.spacing.sm),
            // TODO: 実際のデータを表示
            Text(
              '記録がありません',
              style: tokens.typography.caption.copyWith(color: tokens.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: 実際のデータを使用
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 3),
              const FlSpot(1, 4),
              const FlSpot(2, 2),
              const FlSpot(3, 5),
              const FlSpot(4, 3),
              const FlSpot(5, 4),
              const FlSpot(6, 3),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class _MoodPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: 実際のデータを使用
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 30,
            title: '😄',
            color: Colors.green,
            radius: 60,
          ),
          PieChartSectionData(
            value: 25,
            title: '😊',
            color: Colors.lightGreen,
            radius: 60,
          ),
          PieChartSectionData(
            value: 20,
            title: '😐',
            color: Colors.orange,
            radius: 60,
          ),
          PieChartSectionData(
            value: 15,
            title: '😔',
            color: Colors.deepOrange,
            radius: 60,
          ),
          PieChartSectionData(
            value: 10,
            title: '😢',
            color: Colors.red,
            radius: 60,
          ),
        ],
      ),
    );
  }
}

class _CorrelationInsights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        const _InsightItem(
          icon: Icons.trending_up,
          title: '良い気分の日',
          description: '平均3.2個の習慣を完了',
          color: Colors.green,
        ),
        SizedBox(height: tokens.spacing.sm),
        const _InsightItem(
          icon: Icons.trending_down,
          title: '悪い気分の日',
          description: '平均1.8個の習慣を完了',
          color: Colors.red,
        ),
      ],
    );
  }
}

class _AIInsights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Text(
      'あなたの気分が良い日は、習慣の継続率が78%高くなる傾向があります。'
      '特に朝の瞑想を行った日は、一日を通して気分が安定しています。',
      style: tokens.typography.bodyMedium.copyWith(color: tokens.textPrimary),
    );
  }
}

class _ImprovementSuggestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        const _SuggestionItem(
          icon: Icons.wb_sunny,
          title: '朝のルーティン',
          description: '気分を上げる朝の習慣を追加してみましょう',
        ),
        SizedBox(height: tokens.spacing.sm),
        const _SuggestionItem(
          icon: Icons.self_improvement,
          title: 'マインドフルネス',
          description: '瞑想や深呼吸で心を整える時間を作りましょう',
        ),
      ],
    );
  }
}

class _InsightItem extends StatelessWidget {
  const _InsightItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(tokens.spacing.sm),
          decoration: BoxDecoration(
            color: color.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(tokens.radius.md),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: tokens.spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tokens.typography.body.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: tokens.typography.caption.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  const _SuggestionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(tokens.spacing.sm),
          decoration: BoxDecoration(
            color: tokens.encouragement.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(tokens.radius.md),
          ),
          child: Icon(icon, color: tokens.encouragement, size: 20),
        ),
        SizedBox(width: tokens.spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tokens.typography.body.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: tokens.typography.caption.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// データクラス
class MoodData {
  final String emoji;
  final String label;
  final Color color;
  final String description;

  const MoodData({
    required this.emoji,
    required this.label,
    required this.color,
    required this.description,
  });
}
