import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:minq/core/ai/failure_prediction_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/achievement_animation.dart';

/// 習慣分析画面
/// AI予測と詳細な分析結果を表示
class HabitAnalysisScreen extends ConsumerStatefulWidget {
  final String habitId;
  final String habitName;

  const HabitAnalysisScreen({
    super.key,
    required this.habitId,
    required this.habitName,
  });

  @override
  ConsumerState<HabitAnalysisScreen> createState() => _HabitAnalysisScreenState();
}

class _HabitAnalysisScreenState extends ConsumerState<HabitAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FailurePredictionResult? _predictionResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalysis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalysis() async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    try {
      final service = ref.read(failurePredictionServiceProvider);
      final result = await service.predictFailureRisk(
        userId: uid,
        habitId: widget.habitId,
      );

      setState(() {
        _predictionResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.habitName}の分析',
          style: tokens.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: tokens.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'AI予測'),
            Tab(text: '詳細分析'),
            Tab(text: '改善提案'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _predictionResult == null
              ? _buildErrorState(tokens)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPredictionTab(tokens),
                    _buildAnalysisTab(tokens),
                    _buildSuggestionsTab(tokens),
                  ],
                ),
    );
  }

  Widget _buildErrorState(MinqTokens tokens) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: tokens.spacing(20),
            color: tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing(4)),
          Text(
            'データの読み込みに失敗しました',
            style: tokens.titleMedium.copyWith(
              color: tokens.textMuted,
            ),
          ),
          SizedBox(height: tokens.spacing(4)),
          ElevatedButton(
            onPressed: _loadAnalysis,
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionTab(MinqTokens tokens) {
    final result = _predictionResult!;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // リスクレベルカード
          _buildRiskLevelCard(tokens, result),
          
          SizedBox(height: tokens.spacing(6)),
          
          // 予測スコア表示
          _buildPredictionScoreCard(tokens, result),
          
          SizedBox(height: tokens.spacing(6)),
          
          // 成功率トレンド
          _buildSuccessRateCard(tokens, result.analysis),
          
          SizedBox(height: tokens.spacing(6)),
          
          // 次回予測
          _buildNextPredictionCard(tokens, result),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab(MinqTokens tokens) {
    final analysis = _predictionResult!.analysis;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 曜日別成功率
          _buildDayAnalysisCard(tokens, analysis),
          
          SizedBox(height: tokens.spacing(6)),
          
          // 時間帯別成功率
          _buildTimeAnalysisCard(tokens, analysis),
          
          SizedBox(height: tokens.spacing(6)),
          
          // 統計サマリー
          _buildStatsSummaryCard(tokens, analysis),
        ],
      ),
    );
  }

  Widget _buildSuggestionsTab(MinqTokens tokens) {
    final suggestions = _predictionResult!.suggestions;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI改善提案',
            style: tokens.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          if (suggestions.isEmpty)
            _buildNoSuggestionsState(tokens)
          else
            ...suggestions.map((suggestion) => 
              _buildSuggestionCard(tokens, suggestion)
            ).toList(),
        ],
      ),
    );
  }

  Widget _buildRiskLevelCard(MinqTokens tokens, FailurePredictionResult result) {
    final riskLevel = result.riskLevel;
    Color riskColor;
    IconData riskIcon;
    String riskText;
    String riskDescription;

    switch (riskLevel) {
      case FailureRiskLevel.high:
        riskColor = Colors.red;
        riskIcon = Icons.warning;
        riskText = '高リスク';
        riskDescription = '失敗の可能性が高いです。特別な注意が必要です。';
        break;
      case FailureRiskLevel.medium:
        riskColor = Colors.orange;
        riskIcon = Icons.info;
        riskText = '中リスク';
        riskDescription = '注意が必要です。対策を検討しましょう。';
        break;
      case FailureRiskLevel.low:
        riskColor = Colors.green;
        riskIcon = Icons.check_circle;
        riskText = '低リスク';
        riskDescription = '順調です。このまま継続しましょう。';
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing(6)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            riskColor.withOpacity(0.1),
            riskColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: tokens.cornerLarge(),
        border: Border.all(
          color: riskColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            riskIcon,
            size: tokens.spacing(16),
            color: riskColor,
          ),
          
          SizedBox(height: tokens.spacing(3)),
          
          Text(
            riskText,
            style: tokens.displaySmall.copyWith(
              color: riskColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(2)),
          
          Text(
            riskDescription,
            style: tokens.bodyLarge.copyWith(
              color: riskColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionScoreCard(MinqTokens tokens, FailurePredictionResult result) {
    final score = result.prediction.predictionScore;
    final percentage = (score * 100).toInt();
    
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '失敗予測スコア',
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$percentage%',
                      style: tokens.displayMedium.copyWith(
                        color: _getScoreColor(score),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(1)),
                    Text(
                      '失敗リスク',
                      style: tokens.bodyMedium.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(
                width: tokens.spacing(32),
                height: tokens.spacing(32),
                child: CircularProgressIndicator(
                  value: score,
                  strokeWidth: 8,
                  backgroundColor: tokens.border,
                  valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
                ),
              ),
            ],
          ),
          
          SizedBox(height: tokens.spacing(3)),
          
          LinearProgressIndicator(
            value: score,
            backgroundColor: tokens.border,
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateCard(MinqTokens tokens, analysis) {
    final successRate = (analysis.successRate * 100).toInt();
    
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '全体成功率',
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Colors.green,
                size: tokens.spacing(8),
              ),
              SizedBox(width: tokens.spacing(3)),
              Text(
                '$successRate%',
                style: tokens.displayMedium.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: tokens.spacing(3)),
          
          Text(
            '過去のデータに基づく成功率です',
            style: tokens.bodyMedium.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPredictionCard(MinqTokens tokens, FailurePredictionResult result) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dayName = _getDayDisplayName(tomorrow.weekday);
    
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: tokens.cornerLarge(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: tokens.brandPrimary,
                size: tokens.spacing(6),
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(
                '明日の予測',
                style: tokens.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: tokens.spacing(3)),
          
          Text(
            '$dayNameの成功予測を準備中...',
            style: tokens.bodyMedium.copyWith(
              color: tokens.textMuted,
            ),
          ),
          
          SizedBox(height: tokens.spacing(3)),
          
          ElevatedButton(
            onPressed: () {
              // 明日の予測を生成
              _generateTomorrowPrediction();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.brandPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('明日の予測を生成'),
          ),
        ],
      ),
    );
  }

  Widget _buildDayAnalysisCard(MinqTokens tokens, analysis) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '曜日別成功率',
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          SizedBox(
            height: tokens.spacing(60),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1.0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['月', '火', '水', '木', '金', '土', '日'];
                        return Text(
                          days[value.toInt()],
                          style: tokens.bodySmall,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value * 100).toInt()}%',
                          style: tokens.bodySmall,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildDayBarGroups(analysis.successByDay),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysisCard(MinqTokens tokens, analysis) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '時間帯別成功率',
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          ...analysis.successByTime.entries.map((entry) {
            final timeSlot = entry.key;
            final successRate = entry.value;
            final percentage = (successRate * 100).toInt();
            
            return Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing(3)),
              child: Row(
                children: [
                  SizedBox(
                    width: tokens.spacing(16),
                    child: Text(
                      _getTimeDisplayName(timeSlot),
                      style: tokens.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  Expanded(
                    child: LinearProgressIndicator(
                      value: successRate,
                      backgroundColor: tokens.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getSuccessRateColor(successRate),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: tokens.spacing(2)),
                  
                  Text(
                    '$percentage%',
                    style: tokens.bodyMedium.copyWith(
                      color: _getSuccessRateColor(successRate),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatsSummaryCard(MinqTokens tokens, analysis) {
    final bestDay = analysis.successByDay.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    final worstDay = analysis.successByDay.entries
        .reduce((a, b) => a.value < b.value ? a : b);
    
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '統計サマリー',
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: tokens.spacing(4)),
          
          _buildStatItem(
            tokens,
            '最も成功しやすい曜日',
            _getDayDisplayName(bestDay.key),
            '${(bestDay.value * 100).toInt()}%',
            Colors.green,
          ),
          
          _buildStatItem(
            tokens,
            '最も失敗しやすい曜日',
            _getDayDisplayName(worstDay.key),
            '${(worstDay.value * 100).toInt()}%',
            Colors.red,
          ),
          
          _buildStatItem(
            tokens,
            '最終更新',
            _formatDate(analysis.lastUpdated),
            '',
            tokens.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    MinqTokens tokens,
    String label,
    String value,
    String suffix,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing(2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: tokens.bodyMedium,
          ),
          Row(
            children: [
              Text(
                value,
                style: tokens.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (suffix.isNotEmpty) ...[
                SizedBox(width: tokens.spacing(1)),
                Text(
                  suffix,
                  style: tokens.bodySmall.copyWith(
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(MinqTokens tokens, FailureSuggestion suggestion) {
    Color priorityColor;
    IconData priorityIcon;
    
    switch (suggestion.priority) {
      case SuggestionPriority.high:
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case SuggestionPriority.medium:
        priorityColor = Colors.orange;
        priorityIcon = Icons.info;
        break;
      case SuggestionPriority.low:
        priorityColor = Colors.blue;
        priorityIcon = Icons.lightbulb_outline;
        break;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: tokens.spacing(3)),
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(
          color: priorityColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                priorityIcon,
                color: priorityColor,
                size: tokens.spacing(5),
              ),
              SizedBox(width: tokens.spacing(2)),
              Expanded(
                child: Text(
                  suggestion.title,
                  style: tokens.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: tokens.spacing(2)),
          
          Text(
            suggestion.description,
            style: tokens.bodyMedium.copyWith(
              color: tokens.textMuted,
            ),
          ),
          
          if (suggestion.actionable) ...[
            SizedBox(height: tokens.spacing(3)),
            ElevatedButton(
              onPressed: () {
                // 提案を実行
                _applySuggestion(suggestion);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: priorityColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('実行する'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoSuggestionsState(MinqTokens tokens) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing(8)),
      child: Column(
        children: [
          Icon(
            Icons.psychology,
            size: tokens.spacing(16),
            color: tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing(4)),
          Text(
            '現在、改善提案はありません',
            style: tokens.titleMedium.copyWith(
              color: tokens.textMuted,
            ),
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            'データが蓄積されると、AIがより良い提案を生成します',
            style: tokens.bodyMedium.copyWith(
              color: tokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildDayBarGroups(Map<String, double> successByDay) {
    const dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return dayOrder.asMap().entries.map((entry) {
      final index = entry.key;
      final dayName = entry.value;
      final successRate = successByDay[dayName] ?? 0.0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: successRate,
            color: _getSuccessRateColor(successRate),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  Color _getScoreColor(double score) {
    if (score >= 0.7) return Colors.red;
    if (score >= 0.4) return Colors.orange;
    return Colors.green;
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 0.7) return Colors.green;
    if (rate >= 0.4) return Colors.orange;
    return Colors.red;
  }

  String _getDayDisplayName(int weekday) {
    const days = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];
    return days[weekday - 1];
  }

  String _getDayDisplayName(String dayName) {
    const displayNames = {
      'Monday': '月曜日',
      'Tuesday': '火曜日',
      'Wednesday': '水曜日',
      'Thursday': '木曜日',
      'Friday': '金曜日',
      'Saturday': '土曜日',
      'Sunday': '日曜日',
    };
    return displayNames[dayName] ?? dayName;
  }

  String _getTimeDisplayName(String timeSlot) {
    const displayNames = {
      'Morning': '朝',
      'Afternoon': '午後',
      'Evening': '夕方',
      'Night': '夜',
    };
    return displayNames[timeSlot] ?? timeSlot;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _generateTomorrowPrediction() {
    // TODO: 明日の予測を生成
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('明日の予測を生成中...')),
    );
  }

  void _applySuggestion(FailureSuggestion suggestion) {
    // TODO: 提案を実行
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('「${suggestion.title}」を実行しました')),
    );
  }
}