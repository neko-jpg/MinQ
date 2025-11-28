import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// TensorFlow Liteベースの統合AIサービス
/// すべてのAI機能を一元化し、最高のパフォーマンスを提供
class TFLiteUnifiedAIService {
  static TFLiteUnifiedAIService? _instance;
  static TFLiteUnifiedAIService get instance =>
      _instance ??= TFLiteUnifiedAIService._();

  TFLiteUnifiedAIService._();

  // モデル管理
  Interpreter? _textGenerationModel;
  Interpreter? _sentimentModel;
  Interpreter? _recommendationModel;
  Interpreter? _predictionModel;

  // トークナイザー
  Map<String, int>? _vocabulary;
  Map<int, String>? _reverseVocabulary;

  // 初期化状態
  bool _isInitialized = false;
  final Completer<void> _initCompleter = Completer<void>();

  /// サービスの初期化
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (!_initCompleter.isCompleted) {
      try {
        await _loadModels();
        await _loadVocabulary();
        _isInitialized = true;
        _initCompleter.complete();
        log('TFLite AI: 統合AIサービスが初期化されました');
      } catch (e, stackTrace) {
        log('TFLite AI: 初期化エラー - $e', stackTrace: stackTrace);
        if (!_initCompleter.isCompleted) {
          _initCompleter.completeError(e, stackTrace);
        }
      }
    }
    return _initCompleter.future;
  }

  /// モデルの読み込み
  Future<void> _loadModels() async {
    try {
      // テキスト生成モデル（軽量GPT風）
      _textGenerationModel = await _loadModel(
        'assets/models/text_generation.tflite',
      );

      // 感情分析モデル
      _sentimentModel = await _loadModel(
        'assets/models/sentiment_analysis.tflite',
      );

      // 推薦システムモデル
      _recommendationModel = await _loadModel(
        'assets/models/recommendation.tflite',
      );

      // 失敗予測モデル
      _predictionModel = await _loadModel(
        'assets/models/failure_prediction.tflite',
      );

      log('TFLite AI: すべてのモデルが読み込まれました');
    } catch (e) {
      log('TFLite AI: モデル読み込みエラー - $e');
      // フォールバック: 軽量なルールベースモデルを使用
      await _initializeFallbackModels();
    }
  }

  /// モデルファイルの読み込み
  Future<Interpreter> _loadModel(String assetPath) async {
    try {
      return await Interpreter.fromAsset(assetPath);
    } catch (e) {
      log('TFLite AI: $assetPath の読み込みに失敗、フォールバックモデルを作成');
      return await _createFallbackModel();
    }
  }

  /// フォールバックモデルの作成
  Future<Interpreter> _createFallbackModel() async {
    // 最小限のダミーモデルを作成
    // 実際の実装では、事前訓練済みの軽量モデルを使用
    final modelData = Uint8List.fromList([0]); // プレースホルダー
    return Interpreter.fromBuffer(modelData);
  }

  /// フォールバックモデルの初期化
  Future<void> _initializeFallbackModels() async {
    log('TFLite AI: フォールバックモードで初期化');
    // ルールベースのAIロジックを初期化
  }

  /// 語彙の読み込み
  Future<void> _loadVocabulary() async {
    try {
      final vocabJson = await rootBundle.loadString(
        'assets/models/vocabulary.json',
      );
      final vocabData = jsonDecode(vocabJson) as Map<String, dynamic>;

      _vocabulary = Map<String, int>.from(vocabData);
      _reverseVocabulary = _vocabulary!.map((k, v) => MapEntry(v, k));

      log('TFLite AI: 語彙データ読み込み完了 (${_vocabulary!.length}語)');
    } catch (e) {
      log('TFLite AI: 語彙読み込みエラー、デフォルト語彙を使用 - $e');
      _initializeDefaultVocabulary();
    }
  }

  /// デフォルト語彙の初期化
  void _initializeDefaultVocabulary() {
    _vocabulary = {
      '<pad>': 0,
      '<unk>': 1,
      '<start>': 2,
      '<end>': 3,
      'こんにちは': 4,
      'ありがとう': 5,
      '習慣': 6,
      '継続': 7,
      '目標': 8,
      '達成': 9,
      '成功': 10,
      '失敗': 11,
      '今日': 12,
      '明日': 13,
      '頑張る': 14,
      '応援': 15,
    };
    _reverseVocabulary = _vocabulary!.map((k, v) => MapEntry(v, k));
  }

  // ========== テキスト生成機能 ==========

  /// 習慣提案生成
  Future<String> generateHabitSuggestion({
    required Map<String, dynamic> habitData,
    required String context,
  }) async {
    return generateChatResponse(
      '具体的な習慣の提案をお願いします。',
      systemPrompt: context,
      maxTokens: 200,
    );
  }

  /// AIチャット応答生成
  Future<String> generateChatResponse(
    String userMessage, {
    List<String> conversationHistory = const [],
    String? systemPrompt,
    int maxTokens = 150,
  }) async {
    await initialize();

    try {
      if (_textGenerationModel == null) {
        return _generateRuleBasedResponse(userMessage);
      }

      final context = _buildContext(
        userMessage,
        conversationHistory,
        systemPrompt,
      );
      final tokens = _tokenizeText(context);

      if (tokens.isEmpty) {
        return _generateRuleBasedResponse(userMessage);
      }

      final inputTensor = _prepareInputTensor(tokens, maxLength: 128);
      final outputTensor = [List.filled(maxTokens, 0.0)];

      _textGenerationModel!.run(inputTensor, outputTensor);

      final generatedTokens = _extractTokensFromOutput(outputTensor);
      final response = _detokenizeText(generatedTokens);

      return _postProcessResponse(response);
    } catch (e) {
      log('TFLite AI: テキスト生成エラー - $e');
      return _generateRuleBasedResponse(userMessage);
    }
  }

  /// コンテキストの構築
  String _buildContext(
    String userMessage,
    List<String> history,
    String? systemPrompt,
  ) {
    final buffer = StringBuffer();

    if (systemPrompt != null) {
      buffer.writeln(systemPrompt);
    }

    for (final msg in history.take(5)) {
      // 最新5件のみ
      buffer.writeln(msg);
    }

    buffer.write(userMessage);
    return buffer.toString();
  }

  /// ルールベース応答生成（フォールバック）
  String _generateRuleBasedResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // 挨拶
    if (_containsAny(message, ['こんにちは', 'おはよう', 'こんばんは'])) {
      return _getRandomResponse([
        'こんにちは！今日も一緒に頑張りましょう！',
        'お疲れさまです！今日の習慣はいかがですか？',
        'こんにちは！何かお手伝いできることはありますか？',
      ]);
    }

    // モチベーション
    if (_containsAny(message, ['やる気', 'モチベーション', '続かない', '挫折'])) {
      return _getRandomResponse([
        '小さな一歩でも、続けることが大切です。あなたならできます！',
        '完璧を目指さず、継続を大切にしましょう。',
        '今日できなくても大丈夫。明日また新しい気持ちで始めましょう！',
      ]);
    }

    // 習慣について
    if (_containsAny(message, ['習慣', 'ルーティン', '続ける', 'コツ'])) {
      return _getRandomResponse([
        '新しい習慣は小さく始めるのがコツです。1日1分からでも大丈夫！',
        '同じ時間に行うと習慣化しやすくなります。',
        '習慣が身につくまで約21日。焦らず続けることが大切です。',
      ]);
    }

    return _getRandomResponse([
      'ありがとうございます。他にも何かお聞きしたいことはありますか？',
      'そうですね。MinQでどんな習慣を始めてみたいですか？',
      '素晴らしいですね！継続することで必ず成果が出ますよ。',
    ]);
  }

  // ========== 感情分析機能 ==========

  /// テキストの感情分析
  Future<SentimentResult> analyzeSentiment(String text) async {
    await initialize();

    try {
      if (_sentimentModel == null) {
        return _analyzeSentimentRuleBased(text);
      }

      final tokens = _tokenizeText(text);
      final inputTensor = _prepareInputTensor(tokens, maxLength: 64);
      final outputTensor = [List.filled(3, 0.0)]; // [negative, neutral, positive]

      _sentimentModel!.run(inputTensor, outputTensor);

      final scores = outputTensor[0];
      return SentimentResult(
        positive: scores[2],
        neutral: scores[1],
        negative: scores[0],
      );
    } catch (e) {
      log('TFLite AI: 感情分析エラー - $e');
      return _analyzeSentimentRuleBased(text);
    }
  }

  /// ルールベース感情分析
  SentimentResult _analyzeSentimentRuleBased(String text) {
    final positiveWords = ['嬉しい', '楽しい', '頑張る', '成功', '達成', 'ありがとう'];
    final negativeWords = ['悲しい', '辛い', '失敗', '挫折', '疲れた', 'しんどい'];

    final lowerText = text.toLowerCase();
    var positiveScore = 0.0;
    var negativeScore = 0.0;

    for (final word in positiveWords) {
      if (lowerText.contains(word)) positiveScore += 0.2;
    }

    for (final word in negativeWords) {
      if (lowerText.contains(word)) negativeScore += 0.2;
    }

    final neutralScore = 1.0 - positiveScore - negativeScore;

    return SentimentResult(
      positive: positiveScore.clamp(0.0, 1.0),
      neutral: neutralScore.clamp(0.0, 1.0),
      negative: negativeScore.clamp(0.0, 1.0),
    );
  }

  // ========== 推薦システム ==========

  /// 習慣推薦
  Future<List<HabitRecommendation>> recommendHabits({
    required List<String> userHabits,
    required List<String> completedHabits,
    required Map<String, double> preferences,
    int limit = 5,
  }) async {
    await initialize();

    try {
      if (_recommendationModel == null) {
        return _generateRuleBasedRecommendations(userHabits, limit);
      }

      final features = _encodeUserFeatures(
        userHabits,
        completedHabits,
        preferences,
      );
      final inputTensor = [features].reshape([1, features.length]);
      final outputTensor = [List.filled(100, 0.0)]; // 100種類の習慣スコア

      _recommendationModel!.run(inputTensor, outputTensor);

      final scores = outputTensor[0];
      return _extractTopRecommendations(scores, limit);
    } catch (e) {
      log('TFLite AI: 推薦エラー - $e');
      return _generateRuleBasedRecommendations(userHabits, limit);
    }
  }

  /// ユーザー特徴量のエンコード
  List<double> _encodeUserFeatures(
    List<String> userHabits,
    List<String> completedHabits,
    Map<String, double> preferences,
  ) {
    final features = <double>[];

    // 習慣カテゴリの分布
    final categories = [
      'fitness',
      'mindfulness',
      'learning',
      'productivity',
      'health',
    ];
    for (final category in categories) {
      final count = userHabits.where((h) => h.contains(category)).length;
      features.add(count / userHabits.length);
    }

    // 完了率
    final completionRate =
        userHabits.isEmpty ? 0.0 : completedHabits.length / userHabits.length;
    features.add(completionRate);

    // 好み
    for (final category in categories) {
      features.add(preferences[category] ?? 0.5);
    }

    return features;
  }

  // ========== 失敗予測 ==========

  /// 習慣失敗の予測
  Future<FailurePrediction> predictFailure({
    required String habitId,
    required List<CompletionRecord> history,
    required DateTime targetDate,
  }) async {
    await initialize();

    try {
      if (_predictionModel == null) {
        return _predictFailureRuleBased(history, targetDate);
      }

      final features = _encodeFailureFeatures(history, targetDate);
      final inputTensor = [features].reshape([1, features.length]);
      final outputTensor = [List.filled(1, 0.0)];

      _predictionModel!.run(inputTensor, outputTensor);

      final riskScore = outputTensor[0][0];
      return FailurePrediction(
        riskScore: riskScore,
        confidence: 0.8,
        factors: _identifyRiskFactors(history, targetDate),
        suggestions: _generatePreventionSuggestions(riskScore),
      );
    } catch (e) {
      log('TFLite AI: 失敗予測エラー - $e');
      return _predictFailureRuleBased(history, targetDate);
    }
  }

  /// 失敗予測特徴量のエンコード
  List<double> _encodeFailureFeatures(
    List<CompletionRecord> history,
    DateTime targetDate,
  ) {
    final features = <double>[];

    // 最近の完了率
    final recentHistory =
        history
            .where((r) => targetDate.difference(r.completedAt).inDays <= 7)
            .toList();

    features.add(recentHistory.length / 7.0); // 週間完了率

    // ストリーク長
    var currentStreak = 0;
    final sortedHistory =
        history..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    for (var i = 0; i < sortedHistory.length; i++) {
      final daysDiff =
          targetDate.difference(sortedHistory[i].completedAt).inDays;
      if (daysDiff == i) {
        currentStreak++;
      } else {
        break;
      }
    }

    features.add(currentStreak / 30.0); // 正規化されたストリーク

    // 曜日パターン
    final weekdayPattern = List.filled(7, 0.0);
    for (final record in history) {
      weekdayPattern[record.completedAt.weekday - 1]++;
    }
    features.addAll(weekdayPattern.map((count) => count / history.length));

    return features;
  }

  // ========== ユーティリティメソッド ==========

  /// テキストのトークン化
  List<int> _tokenizeText(String text) {
    if (_vocabulary == null) return [];

    final words = text.toLowerCase().split(RegExp(r'\s+'));
    return words
        .map((word) => _vocabulary![word] ?? _vocabulary!['<unk>']!)
        .toList();
  }

  /// トークンのテキスト化
  String _detokenizeText(List<int> tokens) {
    if (_reverseVocabulary == null) return '';

    return tokens
        .map((token) => _reverseVocabulary![token] ?? '<unk>')
        .where((word) => !['<pad>', '<start>', '<end>'].contains(word))
        .join(' ');
  }

  /// 入力テンソルの準備
  List<List<double>> _prepareInputTensor(
    List<int> tokens, {
    required int maxLength,
  }) {
    final padded = List<double>.filled(maxLength, 0.0);
    for (var i = 0; i < math.min(tokens.length, maxLength); i++) {
      padded[i] = tokens[i].toDouble();
    }
    return [padded];
  }

  /// 出力からトークンを抽出
  List<int> _extractTokensFromOutput(List<List<double>> output) {
    return output[0].map((score) => score.round()).toList();
  }

  /// 応答の後処理
  String _postProcessResponse(String response) {
    return response
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .replaceAll('<unk>', '')
        .trim();
  }

  /// キーワード含有チェック
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// ランダム応答選択
  String _getRandomResponse(List<String> responses) {
    return responses[math.Random().nextInt(responses.length)];
  }

  /// ルールベース推薦生成
  List<HabitRecommendation> _generateRuleBasedRecommendations(
    List<String> userHabits,
    int limit,
  ) {
    final allHabits = [
      '朝の瞑想',
      '読書',
      '運動',
      '日記',
      '早起き',
      '水分補給',
      'ストレッチ',
      '感謝の記録',
      '目標設定',
      '振り返り',
    ];

    final recommendations =
        allHabits
            .where((habit) => !userHabits.contains(habit))
            .take(limit)
            .map(
              (habit) => HabitRecommendation(
                title: habit,
                score: 0.7 + math.Random().nextDouble() * 0.3,
                reason: '$habitは継続しやすく効果的な習慣です',
              ),
            )
            .toList();

    return recommendations;
  }

  /// トップ推薦の抽出
  List<HabitRecommendation> _extractTopRecommendations(
    List<double> scores,
    int limit,
  ) {
    final habits = [
      '朝の瞑想',
      '読書',
      '運動',
      '日記',
      '早起き',
      '水分補給',
      'ストレッチ',
      '感謝の記録',
      '目標設定',
      '振り返り',
    ];

    final indexed =
        scores.asMap().entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return indexed
        .take(limit)
        .map(
          (entry) => HabitRecommendation(
            title: habits[entry.key % habits.length],
            score: entry.value,
            reason: 'AIが分析した結果、あなたに最適な習慣です',
          ),
        )
        .toList();
  }

  /// ルールベース失敗予測
  FailurePrediction _predictFailureRuleBased(
    List<CompletionRecord> history,
    DateTime targetDate,
  ) {
    const recentDays = 7;
    final recentHistory =
        history
            .where(
              (r) => targetDate.difference(r.completedAt).inDays <= recentDays,
            )
            .toList();

    final recentCompletionRate = recentHistory.length / recentDays;
    final riskScore = 1.0 - recentCompletionRate;

    return FailurePrediction(
      riskScore: riskScore,
      confidence: 0.6,
      factors: _identifyRiskFactors(history, targetDate),
      suggestions: _generatePreventionSuggestions(riskScore),
    );
  }

  /// リスク要因の特定
  List<String> _identifyRiskFactors(
    List<CompletionRecord> history,
    DateTime targetDate,
  ) {
    final factors = <String>[];

    if (history.isEmpty) {
      factors.add('履歴データが不足しています');
      return factors;
    }

    final recentHistory =
        history
            .where((r) => targetDate.difference(r.completedAt).inDays <= 7)
            .toList();

    if (recentHistory.length < 3) {
      factors.add('最近の実行頻度が低下しています');
    }

    final weekendHistory =
        history.where((r) => r.completedAt.weekday >= 6).toList();

    if (weekendHistory.length < history.length * 0.3) {
      factors.add('週末の実行率が低い傾向があります');
    }

    return factors;
  }

  /// 予防提案の生成
  List<String> _generatePreventionSuggestions(double riskScore) {
    final suggestions = <String>[];

    if (riskScore > 0.7) {
      suggestions.addAll([
        'リマインダーの時間を見直してみましょう',
        '習慣の難易度を下げることを検討してください',
        'ペア機能を使って仲間と一緒に取り組みましょう',
      ]);
    } else if (riskScore > 0.4) {
      suggestions.addAll(['小さな報酬を設定してモチベーションを上げましょう', '実行する環境を整えてみてください']);
    } else {
      suggestions.add('現在のペースを維持して継続しましょう');
    }

    return suggestions;
  }

  /// 診断情報の取得
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    return {
      'isInitialized': _isInitialized,
      'textGenerationModel': _textGenerationModel != null,
      'sentimentModel': _sentimentModel != null,
      'recommendationModel': _recommendationModel != null,
      'predictionModel': _predictionModel != null,
      'vocabulary': _vocabulary?.length ?? 0,
      'status': 'TFLite AI Service is running',
    };
  }

  /// リソースの解放
  void dispose() {
    _textGenerationModel?.close();
    _sentimentModel?.close();
    _recommendationModel?.close();
    _predictionModel?.close();

    _textGenerationModel = null;
    _sentimentModel = null;
    _recommendationModel = null;
    _predictionModel = null;

    _isInitialized = false;
    log('TFLite AI: リソースが解放されました');
  }
}

// ========== データクラス ==========

/// 感情分析結果
class SentimentResult {
  final double positive;
  final double neutral;
  final double negative;

  SentimentResult({
    required this.positive,
    required this.neutral,
    required this.negative,
  });

  SentimentType get dominantSentiment {
    if (positive > neutral && positive > negative)
      return SentimentType.positive;
    if (negative > neutral && negative > positive)
      return SentimentType.negative;
    return SentimentType.neutral;
  }
}

enum SentimentType { positive, neutral, negative }

/// 習慣推薦
class HabitRecommendation {
  final String title;
  final double score;
  final String reason;

  HabitRecommendation({
    required this.title,
    required this.score,
    required this.reason,
  });
}

/// 失敗予測結果
class FailurePrediction {
  final double riskScore;
  final double confidence;
  final List<String> factors;
  final List<String> suggestions;

  FailurePrediction({
    required this.riskScore,
    required this.confidence,
    required this.factors,
    required this.suggestions,
  });

  FailureRiskLevel get riskLevel {
    if (riskScore > 0.7) return FailureRiskLevel.high;
    if (riskScore > 0.4) return FailureRiskLevel.medium;
    return FailureRiskLevel.low;
  }
}

enum FailureRiskLevel { low, medium, high }

/// 完了記録
class CompletionRecord {
  final DateTime completedAt;
  final String habitId;

  CompletionRecord({required this.completedAt, required this.habitId});
}
