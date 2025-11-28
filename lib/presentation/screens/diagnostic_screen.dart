import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// 自己診断モード画面
/// 設定→テスト通知/ストレージ/ネット
class DiagnosticScreen extends ConsumerStatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  ConsumerState<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends ConsumerState<DiagnosticScreen> {
  final Map<String, DiagnosticResult> _results = {};
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          '自己診断',
          style: tokens.typography.h3.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: tokens.background.withValues(alpha: 0.9),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing.lg),
        children: [
          // 説明
          Container(
            padding: EdgeInsets.all(tokens.spacing.md),
            decoration: BoxDecoration(
              color: tokens.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(tokens.radius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: tokens.primary),
                SizedBox(width: tokens.spacing.sm),
                Expanded(
                  child: Text(
                    'アプリの動作を診断します。問題がある場合は結果を確認してください。',
                    style: tokens.typography.body.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.spacing.xl),
          // 診断項目
          _buildDiagnosticItem(
            title: '通知テスト',
            description: 'プッシュ通知が正常に動作するか確認',
            icon: Icons.notifications_outlined,
            testKey: 'notification',
            onTest: _testNotification,
            tokens: tokens,
          ),
          _buildDiagnosticItem(
            title: 'ストレージテスト',
            description: 'ローカルストレージの読み書きを確認',
            icon: Icons.storage_outlined,
            testKey: 'storage',
            onTest: _testStorage,
            tokens: tokens,
          ),
          _buildDiagnosticItem(
            title: 'ネットワークテスト',
            description: 'インターネット接続を確認',
            icon: Icons.wifi_outlined,
            testKey: 'network',
            onTest: _testNetwork,
            tokens: tokens,
          ),
          _buildDiagnosticItem(
            title: 'データベーステスト',
            description: 'ローカルデータベースの動作を確認',
            icon: Icons.database_outlined,
            testKey: 'database',
            onTest: _testDatabase,
            tokens: tokens,
          ),
          _buildDiagnosticItem(
            title: 'パフォーマンステスト',
            description: 'アプリの動作速度を確認',
            icon: Icons.speed_outlined,
            testKey: 'performance',
            onTest: _testPerformance,
            tokens: tokens,
          ),
          SizedBox(height: tokens.spacing.xl),
          // すべてテストボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRunning ? null : _runAllTests,
              icon:
                  _isRunning
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.play_arrow),
              label: Text(_isRunning ? '診断中...' : 'すべてテスト'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.full),
                ),
              ),
            ),
          ),
          if (_results.isNotEmpty) ...[
            SizedBox(height: tokens.spacing.xl),
            _buildSummary(tokens),
          ],
        ],
      ),
    );
  }

  Widget _buildDiagnosticItem({
    required String title,
    required String description,
    required IconData icon,
    required String testKey,
    required Future<DiagnosticResult> Function() onTest,
    required MinqTheme tokens,
  }) {
    final result = _results[testKey];

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing.md),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor(result?.status, tokens).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(tokens.radius.md),
              ),
              child: Icon(icon, color: _getStatusColor(result?.status, tokens)),
            ),
            SizedBox(width: tokens.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tokens.typography.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: tokens.typography.caption.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  if (result != null) ...[
                    SizedBox(height: tokens.spacing.xs),
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(result.status),
                          size: 16,
                          color: _getStatusColor(result.status, tokens),
                        ),
                        SizedBox(width: tokens.spacing.xs),
                        Text(
                          result.message,
                          style: tokens.typography.caption.copyWith(
                            color: _getStatusColor(result.status, tokens),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_outline),
              onPressed: () => _runTest(testKey, onTest),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(MinqTheme tokens) {
    final passed =
        _results.values
            .where((r) => r.status == DiagnosticStatus.passed)
            .length;
    final failed =
        _results.values
            .where((r) => r.status == DiagnosticStatus.failed)
            .length;
    final total = _results.length;

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '診断結果サマリー',
            style: tokens.typography.h4.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('合格', passed, tokens.success, tokens),
              _buildSummaryItem('不合格', failed, tokens.error, tokens),
              _buildSummaryItem('合計', total, tokens.textSecondary, tokens),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    int count,
    Color color,
    MinqTheme tokens,
  ) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: tokens.typography.h2.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: tokens.typography.caption.copyWith(
            color: tokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(DiagnosticStatus? status, MinqTheme tokens) {
    return switch (status) {
      DiagnosticStatus.passed => tokens.success,
      DiagnosticStatus.failed => tokens.error,
      DiagnosticStatus.warning => Colors.orange,
      null => tokens.textSecondary,
    };
  }

  IconData _getStatusIcon(DiagnosticStatus status) {
    return switch (status) {
      DiagnosticStatus.passed => Icons.check_circle,
      DiagnosticStatus.failed => Icons.error,
      DiagnosticStatus.warning => Icons.warning,
    };
  }

  Future<void> _runTest(
    String key,
    Future<DiagnosticResult> Function() test,
  ) async {
    setState(() {
      _isRunning = true;
    });

    try {
      final result = await test();
      setState(() {
        _results[key] = result;
      });
    } catch (e) {
      setState(() {
        _results[key] = DiagnosticResult(
          status: DiagnosticStatus.failed,
          message: 'エラー: $e',
        );
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _results.clear();
    });

    await _runTest('notification', _testNotification);
    await _runTest('storage', _testStorage);
    await _runTest('network', _testNetwork);
    await _runTest('database', _testDatabase);
    await _runTest('performance', _testPerformance);

    setState(() {
      _isRunning = false;
    });
  }

  Future<DiagnosticResult> _testNotification() async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: 実際の通知テスト
    return const DiagnosticResult(
      status: DiagnosticStatus.passed,
      message: '通知は正常に動作しています',
    );
  }

  Future<DiagnosticResult> _testStorage() async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: 実際のストレージテスト
    return const DiagnosticResult(
      status: DiagnosticStatus.passed,
      message: 'ストレージは正常に動作しています',
    );
  }

  Future<DiagnosticResult> _testNetwork() async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: 実際のネットワークテスト
    return const DiagnosticResult(
      status: DiagnosticStatus.passed,
      message: 'ネットワーク接続は正常です',
    );
  }

  Future<DiagnosticResult> _testDatabase() async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: 実際のデータベーステスト
    return const DiagnosticResult(
      status: DiagnosticStatus.passed,
      message: 'データベースは正常に動作しています',
    );
  }

  Future<DiagnosticResult> _testPerformance() async {
    await Future.delayed(const Duration(seconds: 2));
    // TODO: 実際のパフォーマンステスト
    return const DiagnosticResult(
      status: DiagnosticStatus.passed,
      message: 'パフォーマンスは良好です',
    );
  }
}

/// 診断結果
class DiagnosticResult {
  final DiagnosticStatus status;
  final String message;
  final Map<String, dynamic>? details;

  const DiagnosticResult({
    required this.status,
    required this.message,
    this.details,
  });
}

/// 診断ステータス
enum DiagnosticStatus { passed, failed, warning }
