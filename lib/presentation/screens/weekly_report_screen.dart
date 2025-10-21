import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/weekly_report_service.dart';

/// 週次AI分析レポート画面
class WeeklyReportScreen extends ConsumerStatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  ConsumerState<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final WeeklyReportService _reportService = WeeklyReportService.instance;

  List<WeeklyReport> _reports = [];
  WeeklyReport? _currentReport;
  bool _isLoading = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      // TODO: 実際のユーザーIDを取得
      final reports = await _reportService.getReportHistory('current_user_id');
      final current = reports.isNotEmpty ? reports.first : null;

      setState(() {
        _reports = reports;
        _currentReport = current;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('レポートの読み込みに失敗しました: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('週次AI分析レポート'),
        actions: [
          IconButton(
            onPressed: _generateNewReport,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '今週', icon: Icon(Icons.insights)),
            Tab(text: '履歴', icon: Icon(Icons.history)),
            Tab(text: '設定', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentReportTab(),
          _buildHistoryTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildCurrentReportTab() {
    if (_isLoading && _currentReport == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AIが分析中...'),
            SizedBox(height: 8),
            Text(
              'あなたの習慣データを詳しく分析しています',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_currentReport == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '今週のレポートがありません',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'AIが自動で週次レポートを生成します',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateNewReport,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('レポートを生成'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ヘッダー
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${_formatWeekRange(_currentReport!.weekStart, _currentReport!.weekEnd)}の分析',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '生成日時: ${_formatDateTime(_currentReport!.generatedAt)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMetricCard(
                        '総合スコア',
                        '${(_currentReport!.overallScore * 100).toInt()}',
                        Icons.star,
                        Colors.amber,
                      ),
                      _buildMetricCard(
                        '完了率',
                        '${(_currentReport!.completionRate * 100).toInt()}%',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildMetricCard(
                        '継続日数',
                        '${_currentReport!.streakDays}日',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // AI分析結果
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'AI分析結果',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentReport!.aiAnalysis.predictions.aiPrediction,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // トレンド分析
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'トレンド分析',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(height: 200, child: _buildTrendChart()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 改善提案
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        '改善提案',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._currentReport!.recommendations.map(
                    (rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.arrow_right,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rec.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 成功率予測
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        '30日後成功率予測',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${(_currentReport!.successPrediction.nextWeekCompletionRate * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text(
                              '継続成功の可能性',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value:
                              _currentReport!
                                  .successPrediction
                                  .nextWeekCompletionRate,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.green,
                          ),
                        ),
                      ),
                    ],
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
                  onPressed: _shareReport,
                  icon: const Icon(Icons.share),
                  label: const Text('レポートを共有'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportReport,
                  icon: const Icon(Icons.download),
                  label: const Text('PDFで保存'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTrendChart() {
    // サンプルデータ（実際の実装では_currentReport!.trendDataを使用）
    final spots = List.generate(7, (index) {
      return FlSpot(
        index.toDouble(),
        0.5 + math.sin(index * 0.5) * 0.3 + math.Random().nextDouble() * 0.2,
      );
    });

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value * 100).toInt()}%',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = ['月', '火', '水', '木', '金', '土', '日'];
                if (value.toInt() < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
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
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: 1,
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoading && _reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reports.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'レポート履歴がありません',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '週次レポートが自動生成されると履歴に表示されます',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(WeeklyReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showReportDetail(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatWeekRange(report.weekStart, report.weekEnd),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(report.generatedAt),
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
                      color: _getScoreColor(
                        report.overallScore,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(report.overallScore * 100).toInt()}点',
                      style: TextStyle(
                        color: _getScoreColor(report.overallScore),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.aiAnalysis.predictions.aiPrediction,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.trending_up, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '成功率予測: ${(report.successPrediction.nextWeekCompletionRate * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '完了率: ${(report.completionRate * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
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
                subtitle: const Text('毎週月曜日に自動でレポートを生成'),
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
                subtitle: const Text('新しいレポートが生成されたときに通知'),
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
                leading: const Icon(Icons.schedule),
                title: const Text('生成タイミング'),
                subtitle: const Text('レポート生成の曜日と時刻を設定'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: タイミング設定画面
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('分析設定'),
                subtitle: const Text('分析に含める項目をカスタマイズ'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: 分析設定画面
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
                leading: const Icon(Icons.cloud_download),
                title: const Text('データエクスポート'),
                subtitle: const Text('すべてのレポートをPDFで一括保存'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _exportAllReports,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('履歴削除'),
                subtitle: const Text('古いレポートを削除してストレージを節約'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showDeleteDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showReportDetail(WeeklyReport report) {
    setState(() => _currentReport = report);
    _tabController.animateTo(0);
  }

  Future<void> _generateNewReport() async {
    setState(() => _isGenerating = true);

    try {
      // TODO: 実際のユーザーIDを取得
      final report = await _reportService.generateWeeklyReport(
        'current_user_id',
      );

      setState(() {
        _reports.insert(0, report);
        _currentReport = report;
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('新しいレポートを生成しました！')));
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('レポート生成に失敗しました: $e')));
      }
    }
  }

  void _shareReport() {
    if (_currentReport == null) return;

    // TODO: レポートの共有機能を実装
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('レポートを共有しました')));
  }

  void _exportReport() {
    if (_currentReport == null) return;

    // TODO: PDFエクスポート機能を実装
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PDFで保存しました')));
  }

  void _exportAllReports() {
    // TODO: 全レポートのエクスポート機能を実装
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('すべてのレポートをエクスポートしました')));
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('履歴削除'),
            content: const Text('古いレポートを削除しますか？この操作は取り消せません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: 履歴削除機能を実装
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('古いレポートを削除しました')),
                  );
                },
                child: const Text('削除'),
              ),
            ],
          ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.blue;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }

  String _formatWeekRange(DateTime start, DateTime end) {
    return '${start.month}/${start.day} - ${end.month}/${end.day}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
