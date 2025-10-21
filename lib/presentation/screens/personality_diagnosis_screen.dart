import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/ai/personality_diagnosis_service.dart';

/// AIパーソナリティ診断画面
class PersonalityDiagnosisScreen extends ConsumerStatefulWidget {
  const PersonalityDiagnosisScreen({super.key});

  @override
  ConsumerState<PersonalityDiagnosisScreen> createState() =>
      _PersonalityDiagnosisScreenState();
}

class _PersonalityDiagnosisScreenState
    extends ConsumerState<PersonalityDiagnosisScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PersonalityDiagnosisService _diagnosisService =
      PersonalityDiagnosisService.instance;

  PersonalityDiagnosis? _currentDiagnosis;
  bool _isAnalyzing = false;
  int _currentQuestionIndex = 0;
  final List<int> _answers = [];

  // サンプル質問（実際の実装では外部ファイルから読み込み）
  final List<DiagnosisQuestion> _questions = [
    DiagnosisQuestion(
      id: 1,
      text: '新しい習慣を始めるとき、どのようにアプローチしますか？',
      options: [
        '詳細な計画を立ててから始める',
        'とりあえず始めて調整していく',
        '他の人の成功例を参考にする',
        '小さく始めて徐々に拡大する',
      ],
    ),
    DiagnosisQuestion(
      id: 2,
      text: '習慣が続かないとき、どう感じますか？',
      options: ['自分を責めてしまう', '方法を変えて再挑戦する', '一時的に休んで再開する', '完璧でなくても続ける'],
    ),
    DiagnosisQuestion(
      id: 3,
      text: 'モチベーションの源泉は何ですか？',
      options: ['目標達成の喜び', '他人からの評価', '自己成長の実感', '習慣そのものの楽しさ'],
    ),
    DiagnosisQuestion(
      id: 4,
      text: '困難に直面したとき、どう対処しますか？',
      options: [
        '論理的に分析して解決策を探す',
        '直感に従って行動する',
        '他人に相談してアドバイスを求める',
        '一度距離を置いて冷静になる',
      ],
    ),
    DiagnosisQuestion(
      id: 5,
      text: '理想的な習慣継続環境は？',
      options: ['一人で集中できる環境', '仲間と一緒に取り組める環境', '競争要素がある環境', '自由度が高い環境'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentDiagnosis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentDiagnosis() async {
    try {
      // TODO: 実際のユーザーIDを取得
      final diagnosis = await _diagnosisService.getCurrentDiagnosis(
        'current_user_id',
      );
      setState(() => _currentDiagnosis = diagnosis);
    } catch (e) {
      // 診断結果がない場合は無視
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AIパーソナリティ診断'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '診断', icon: Icon(Icons.psychology)),
            Tab(text: '結果', icon: Icon(Icons.insights)),
            Tab(text: '分析', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiagnosisTab(),
          _buildResultTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildDiagnosisTab() {
    if (_isAnalyzing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AIが分析中...'),
            SizedBox(height: 8),
            Text(
              'あなたの行動パターンを詳しく分析しています',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_currentQuestionIndex >= _questions.length) {
      return _buildCompletionScreen();
    }

    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 進捗表示
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '質問 ${_currentQuestionIndex + 1}/${_questions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(Colors.blue),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 質問
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 選択肢
                  ...question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _selectAnswer(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(
                                      65 + index,
                                    ), // A, B, C, D
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const Spacer(),

          // ナビゲーションボタン
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousQuestion,
                    child: const Text('前の質問'),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 12),
              Expanded(
                flex: _currentQuestionIndex > 0 ? 1 : 2,
                child: ElevatedButton(
                  onPressed:
                      _answers.length > _currentQuestionIndex
                          ? _nextQuestion
                          : null,
                  child: Text(
                    _currentQuestionIndex == _questions.length - 1
                        ? '診断完了'
                        : '次の質問',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            '診断完了！',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'すべての質問にお答えいただき、ありがとうございます。\nAIがあなたの回答を分析して、パーソナリティタイプを診断します。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startAnalysis,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('AI分析を開始'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTab() {
    if (_currentDiagnosis == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '診断結果がありません',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('「診断」タブから診断を開始してください', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final archetype = _currentDiagnosis!.primaryArchetype;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // メインタイプ
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(archetype.emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    archetype.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    archetype.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '信頼度: ${(_currentDiagnosis!.confidence * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 特徴
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '特徴',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...archetype.traits
                      .map(
                        (trait) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(trait)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 推奨習慣
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'おすすめの習慣',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...archetype.recommendedHabits
                      .map(
                        (habit) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(habit)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 行動パターン分析
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '行動パターン分析',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildPatternChart(),
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
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share),
                  label: const Text('結果を共有'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _retakeDiagnosis,
                  icon: const Icon(Icons.refresh),
                  label: const Text('再診断'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternChart() {
    if (_currentDiagnosis == null) return const SizedBox();

    final patterns = _currentDiagnosis!.behaviorPatterns;

    return Column(
      children:
          patterns.entries.map((entry) {
            final label = _getPatternLabel(entry.key);
            final value = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label),
                      Text(
                        '${(value * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(
                      _getPatternColor(entry.key),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildAnalysisTab() {
    if (_currentDiagnosis == null) {
      return const Center(child: Text('診断結果がありません'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AI分析結果
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI分析結果',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(_currentDiagnosis!.aiInsights),
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
                  const Text(
                    '改善提案',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._currentDiagnosis!.recommendations.map(
                    (rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(rec)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 相性分析
          if (_currentDiagnosis!.compatibilityAnalysis.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '他タイプとの相性',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._currentDiagnosis!.compatibilityAnalysis.entries.map((
                      entry,
                    ) {
                      final archetype = entry.key;
                      final compatibility = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              archetype.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(archetype.name)),
                            _buildCompatibilityIndicator(compatibility),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityIndicator(double compatibility) {
    Color color;
    String text;

    if (compatibility >= 0.8) {
      color = Colors.green;
      text = '最高';
    } else if (compatibility >= 0.6) {
      color = Colors.blue;
      text = '良好';
    } else if (compatibility >= 0.4) {
      color = Colors.orange;
      text = '普通';
    } else {
      color = Colors.red;
      text = '注意';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      if (_answers.length > _currentQuestionIndex) {
        _answers[_currentQuestionIndex] = answerIndex;
      } else {
        _answers.add(answerIndex);
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  Future<void> _startAnalysis() async {
    setState(() => _isAnalyzing = true);

    try {
      // TODO: 実際のユーザーIDを取得
      final diagnosis = await _diagnosisService.performDiagnosis(
        'current_user_id',
        _answers,
      );

      setState(() {
        _currentDiagnosis = diagnosis;
        _isAnalyzing = false;
      });

      _tabController.animateTo(1);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('診断が完了しました！')));
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('診断に失敗しました: $e')));
      }
    }
  }

  void _shareResult() {
    if (_currentDiagnosis == null) return;

    // TODO: 結果の共有機能を実装
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('結果を共有しました')));
  }

  void _retakeDiagnosis() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
      _currentDiagnosis = null;
    });
    _tabController.animateTo(0);
  }

  String _getPatternLabel(String key) {
    switch (key) {
      case 'consistency':
        return '継続性';
      case 'flexibility':
        return '柔軟性';
      case 'motivation':
        return 'モチベーション';
      case 'social':
        return '社会性';
      case 'analytical':
        return '分析力';
      default:
        return key;
    }
  }

  Color _getPatternColor(String key) {
    switch (key) {
      case 'consistency':
        return Colors.blue;
      case 'flexibility':
        return Colors.green;
      case 'motivation':
        return Colors.orange;
      case 'social':
        return Colors.purple;
      case 'analytical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// 診断質問
class DiagnosisQuestion {
  final int id;
  final String text;
  final List<String> options;

  DiagnosisQuestion({
    required this.id,
    required this.text,
    required this.options,
  });
}
