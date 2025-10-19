import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tflite_unified_ai_service.dart';

/// リアルタイムAIコーチサービス
/// クエスト実行中にリアルタイムでコーチングを提供
class RealtimeCoachService {
  static RealtimeCoachService? _instance;
  static RealtimeCoachService get instance => _instance ??= RealtimeCoachService._();
  
  RealtimeCoachService._();

  final TFLiteUnifiedAIService _aiService = TFLiteUnifiedAIService.instance;
  final FlutterTts _tts = FlutterTts();
  
  Timer? _coachingTimer;
  Timer? _motivationTimer;
  Timer? _checkInTimer;
  
  bool _isActive = false;
  String? _currentQuestId;
  DateTime? _sessionStartTime;
  CoachingSettings _settings = const CoachingSettings();
  
  final StreamController<CoachingMessage> _messageController = 
      StreamController<CoachingMessage>.broadcast();
  
  Stream<CoachingMessage> get messageStream => _messageController.stream;

  /// コーチングセッションの開始
  Future<void> startCoaching({
    required String questId,
    required String questTitle,
    required Duration estimatedDuration,
    CoachingSettings? settings,
  }) async {
    if (_isActive) {
      await stopCoaching();
    }

    _currentQuestId = questId;
    _sessionStartTime = DateTime.now();
    _settings = settings ?? const CoachingSettings();
    _isActive = true;

    await _initializeTTS();
    await _aiService.initialize();

    // 開始メッセージ
    final startMessage = await _generateStartMessage(questTitle, estimatedDuration);
    await _sendCoachingMessage(startMessage, CoachingMessageType.start);

    // 定期的なコーチング開始
    _startPeriodicCoaching(estimatedDuration);
    
    log('RealtimeCoach: コーチングセッション開始 - $questTitle');
  }

  /// コーチングセッションの停止
  Future<void> stopCoaching() async {
    if (!_isActive) return;

    _coachingTimer?.cancel();
    _motivationTimer?.cancel();
    _checkInTimer?.cancel();
    
    // 終了メッセージ
    if (_sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!);
      final endMessage = await _generateEndMessage(duration);
      await _sendCoachingMessage(endMessage, CoachingMessageType.completion);
    }

    _isActive = false;
    _currentQuestId = null;
    _sessionStartTime = null;
    
    log('RealtimeCoach: コーチングセッション終了');
  }

  /// TTSの初期化
  Future<void> _initializeTTS() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.8);
      await _tts.setVolume(0.7);
      await _tts.setPitch(1.0);
    } catch (e) {
      log('RealtimeCoach: TTS初期化エラー - $e');
    }
  }

  /// 定期的なコーチングの開始
  void _startPeriodicCoaching(Duration estimatedDuration) {
    // 励ましメッセージ（設定された間隔で）
    _motivationTimer = Timer.periodic(_settings.motivationInterval, (timer) {
      _sendMotivationMessage();
    });

    // チェックインメッセージ（進捗確認）
    final checkInInterval = Duration(
      milliseconds: (estimatedDuration.inMilliseconds * 0.3).round(),
    );
    _checkInTimer = Timer.periodic(checkInInterval, (timer) {
      _sendCheckInMessage();
    });

    // 特定のタイミングでのコーチング
    _scheduleTimedMessages(estimatedDuration);
  }

  /// タイミング指定メッセージのスケジュール
  void _scheduleTimedMessages(Duration estimatedDuration) {
    // 25%地点
    Timer(Duration(milliseconds: (estimatedDuration.inMilliseconds * 0.25).round()), () {
      if (_isActive) _sendProgressMessage(0.25);
    });

    // 50%地点
    Timer(Duration(milliseconds: (estimatedDuration.inMilliseconds * 0.5).round()), () {
      if (_isActive) _sendProgressMessage(0.5);
    });

    // 75%地点
    Timer(Duration(milliseconds: (estimatedDuration.inMilliseconds * 0.75).round()), () {
      if (_isActive) _sendProgressMessage(0.75);
    });

    // 90%地点（ラストスパート）
    Timer(Duration(milliseconds: (estimatedDuration.inMilliseconds * 0.9).round()), () {
      if (_isActive) _sendFinalSpurtMessage();
    });
  }

  /// 開始メッセージの生成
  Future<String> _generateStartMessage(String questTitle, Duration duration) async {
    final templates = [
      '${questTitle}を始めましょう！予定時間は${_formatDuration(duration)}です。一緒に頑張りましょう！',
      'さあ、${questTitle}の時間です。${_formatDuration(duration)}間、集中して取り組みましょう。',
      '${questTitle}をスタートします。今日も素晴らしい時間にしましょう！',
    ];

    try {
      final aiMessage = await _aiService.generateChatResponse(
        '${questTitle}を${_formatDuration(duration)}間実行します。やる気が出る開始メッセージを生成してください。',
        systemPrompt: 'あなたは親しみやすいパーソナルコーチです。短く励ましのメッセージを作成してください。',
        maxTokens: 50,
      );
      
      if (aiMessage.isNotEmpty && aiMessage.length > 10) {
        return aiMessage;
      }
    } catch (e) {
      log('RealtimeCoach: AI開始メッセージ生成エラー - $e');
    }

    return templates[math.Random().nextInt(templates.length)];
  }

  /// 終了メッセージの生成
  Future<String> _generateEndMessage(Duration actualDuration) async {
    final templates = [
      'お疲れさまでした！${_formatDuration(actualDuration)}間、よく頑張りました。',
      '素晴らしい！今日も目標を達成しましたね。継続は力なりです。',
      'ミッション完了です！今日の努力が明日の成果につながります。',
    ];

    try {
      final aiMessage = await _aiService.generateChatResponse(
        '${_formatDuration(actualDuration)}間の習慣を完了しました。達成感のある終了メッセージを生成してください。',
        systemPrompt: 'あなたは親しみやすいパーソナルコーチです。達成を祝う短いメッセージを作成してください。',
        maxTokens: 50,
      );
      
      if (aiMessage.isNotEmpty && aiMessage.length > 10) {
        return aiMessage;
      }
    } catch (e) {
      log('RealtimeCoach: AI終了メッセージ生成エラー - $e');
    }

    return templates[math.Random().nextInt(templates.length)];
  }

  /// モチベーションメッセージの送信
  Future<void> _sendMotivationMessage() async {
    if (!_isActive) return;

    final templates = [
      'いい調子です！その調子で続けましょう。',
      '集中できていますね。素晴らしいです！',
      '今の頑張りが未来の自分を作ります。',
      'あなたならできます。信じて続けましょう。',
      '小さな一歩も大きな進歩です。',
    ];

    try {
      final currentTime = DateTime.now();
      final elapsed = currentTime.difference(_sessionStartTime!);
      
      final aiMessage = await _aiService.generateChatResponse(
        '習慣実行中です。${_formatDuration(elapsed)}経過しました。短い励ましのメッセージをください。',
        systemPrompt: 'あなたは親しみやすいパーソナルコーチです。継続を励ます短いメッセージを作成してください。',
        maxTokens: 30,
      );
      
      final message = (aiMessage.isNotEmpty && aiMessage.length > 5) 
          ? aiMessage 
          : templates[math.Random().nextInt(templates.length)];
      
      await _sendCoachingMessage(message, CoachingMessageType.motivation);
    } catch (e) {
      log('RealtimeCoach: モチベーションメッセージエラー - $e');
      final message = templates[math.Random().nextInt(templates.length)];
      await _sendCoachingMessage(message, CoachingMessageType.motivation);
    }
  }

  /// チェックインメッセージの送信
  Future<void> _sendCheckInMessage() async {
    if (!_isActive) return;

    final templates = [
      '調子はいかがですか？順調に進んでいますか？',
      '今の気分はどうですか？無理せず続けましょう。',
      '疲れていませんか？自分のペースで大丈夫です。',
    ];

    final message = templates[math.Random().nextInt(templates.length)];
    await _sendCoachingMessage(message, CoachingMessageType.checkIn);
  }

  /// 進捗メッセージの送信
  Future<void> _sendProgressMessage(double progress) async {
    if (!_isActive) return;

    final percentage = (progress * 100).round();
    final templates = [
      '${percentage}%完了です！順調に進んでいますね。',
      'もう${percentage}%も進みました。素晴らしいペースです！',
      '${percentage}%地点を通過しました。この調子で続けましょう。',
    ];

    final message = templates[math.Random().nextInt(templates.length)];
    await _sendCoachingMessage(message, CoachingMessageType.progress);
  }

  /// ラストスパートメッセージの送信
  Future<void> _sendFinalSpurtMessage() async {
    if (!_isActive) return;

    final templates = [
      'ラストスパートです！もう少しで完了ですよ。',
      'あと少し！最後まで頑張りましょう。',
      'ゴールが見えてきました。最後まで集中です！',
    ];

    final message = templates[math.Random().nextInt(templates.length)];
    await _sendCoachingMessage(message, CoachingMessageType.finalSpurt);
  }

  /// コーチングメッセージの送信
  Future<void> _sendCoachingMessage(String message, CoachingMessageType type) async {
    final coachingMessage = CoachingMessage(
      message: message,
      type: type,
      timestamp: DateTime.now(),
      questId: _currentQuestId!,
    );

    _messageController.add(coachingMessage);

    // 音声出力（設定で有効な場合）
    if (_settings.enableVoice && type != CoachingMessageType.checkIn) {
      try {
        await _tts.speak(message);
      } catch (e) {
        log('RealtimeCoach: TTS再生エラー - $e');
      }
    }

    // 触覚フィードバック（設定で有効な場合）
    if (_settings.enableHaptics) {
      try {
        await HapticFeedback.lightImpact();
      } catch (e) {
        log('RealtimeCoach: 触覚フィードバックエラー - $e');
      }
    }
  }

  /// 時間のフォーマット
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}時間${duration.inMinutes.remainder(60)}分';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  /// 緊急介入（失敗予測時）
  Future<void> triggerEmergencyIntervention(String reason) async {
    if (!_isActive) return;

    final interventionMessages = [
      '少し休憩しませんか？無理は禁物です。',
      '今日は調子が悪そうですね。短時間でも大丈夫ですよ。',
      '完璧を目指さず、今できることから始めましょう。',
      '一度深呼吸して、リラックスしましょう。',
    ];

    try {
      final aiMessage = await _aiService.generateChatResponse(
        '習慣実行中にユーザーが困難を感じています。理由: $reason。励ましと具体的なアドバイスをください。',
        systemPrompt: 'あなたは共感的なパーソナルコーチです。ユーザーを励まし、実践的なアドバイスを提供してください。',
        maxTokens: 80,
      );
      
      final message = (aiMessage.isNotEmpty && aiMessage.length > 10) 
          ? aiMessage 
          : interventionMessages[math.Random().nextInt(interventionMessages.length)];
      
      await _sendCoachingMessage(message, CoachingMessageType.intervention);
    } catch (e) {
      log('RealtimeCoach: 緊急介入メッセージエラー - $e');
      final message = interventionMessages[math.Random().nextInt(interventionMessages.length)];
      await _sendCoachingMessage(message, CoachingMessageType.intervention);
    }
  }

  /// 設定の更新
  void updateSettings(CoachingSettings settings) {
    _settings = settings;
    
    // タイマーの再設定
    if (_isActive) {
      _motivationTimer?.cancel();
      _motivationTimer = Timer.periodic(settings.motivationInterval, (timer) {
        _sendMotivationMessage();
      });
    }
  }

  /// リソースの解放
  void dispose() {
    _coachingTimer?.cancel();
    _motivationTimer?.cancel();
    _checkInTimer?.cancel();
    _messageController.close();
    _tts.stop();
    
    _isActive = false;
    _currentQuestId = null;
    _sessionStartTime = null;
  }
}

/// コーチング設定
class CoachingSettings {
  final Duration motivationInterval;
  final bool enableVoice;
  final bool enableHaptics;
  final bool enableEmergencyIntervention;
  final double voiceSpeed;
  final double voiceVolume;

  const CoachingSettings({
    this.motivationInterval = const Duration(minutes: 5),
    this.enableVoice = true,
    this.enableHaptics = true,
    this.enableEmergencyIntervention = true,
    this.voiceSpeed = 0.8,
    this.voiceVolume = 0.7,
  });

  CoachingSettings copyWith({
    Duration? motivationInterval,
    bool? enableVoice,
    bool? enableHaptics,
    bool? enableEmergencyIntervention,
    double? voiceSpeed,
    double? voiceVolume,
  }) {
    return CoachingSettings(
      motivationInterval: motivationInterval ?? this.motivationInterval,
      enableVoice: enableVoice ?? this.enableVoice,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableEmergencyIntervention: enableEmergencyIntervention ?? this.enableEmergencyIntervention,
      voiceSpeed: voiceSpeed ?? this.voiceSpeed,
      voiceVolume: voiceVolume ?? this.voiceVolume,
    );
  }
}

/// コーチングメッセージ
class CoachingMessage {
  final String message;
  final CoachingMessageType type;
  final DateTime timestamp;
  final String questId;

  CoachingMessage({
    required this.message,
    required this.type,
    required this.timestamp,
    required this.questId,
  });
}

/// コーチングメッセージタイプ
enum CoachingMessageType {
  start,
  motivation,
  checkIn,
  progress,
  finalSpurt,
  completion,
  intervention,
}