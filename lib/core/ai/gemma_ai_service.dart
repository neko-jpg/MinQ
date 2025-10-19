import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _huggingFaceTokenFromEnv = String.fromEnvironment(
  'HUGGINGFACE_TOKEN',
);

Future<String?>? _huggingFaceTokenFuture;

/// Hugging FaceのAPIトークンを取得する。
///
/// まず `--dart-define` で注入された値を確認し、存在しない場合のみ
/// `config.json` の内容を読み込む。読み込みは一度だけ行い、以降は
/// キャッシュされたFutureを共有する。
Future<String?> loadHuggingFaceToken() {
  _huggingFaceTokenFuture ??= _resolveHuggingFaceToken();
  return _huggingFaceTokenFuture!;
}

Future<String?> _resolveHuggingFaceToken() async {
  if (_huggingFaceTokenFromEnv.isNotEmpty) {
    return _huggingFaceTokenFromEnv;
  }

  try {
    final configString = await rootBundle.loadString('config.json');
    final config = jsonDecode(configString) as Map<String, dynamic>;
    final token = config['HUGGINGFACE_TOKEN'] as String?;
    if (token != null && token.isNotEmpty) {
      return token;
    }
  } catch (error, stackTrace) {
    log(
      'Failed to load Hugging Face token from config.json: $error',
      stackTrace: stackTrace,
    );
  }
  return null;
}

enum GemmaChatRole { system, user, assistant }

class GemmaChatMessage {
  const GemmaChatMessage({required this.role, required this.text});

  const GemmaChatMessage.system(String text)
    : this(role: GemmaChatRole.system, text: text);

  const GemmaChatMessage.user(String text)
    : this(role: GemmaChatRole.user, text: text);

  const GemmaChatMessage.assistant(String text)
    : this(role: GemmaChatRole.assistant, text: text);

  final GemmaChatRole role;
  final String text;

  bool get isUser => role == GemmaChatRole.user;
  bool get isAssistant => role == GemmaChatRole.assistant;
  bool get isSystem => role == GemmaChatRole.system;

  GemmaChatMessage trimmed() => GemmaChatMessage(role: role, text: text.trim());
}

const GemmaChatMessage _defaultSystemMessage = GemmaChatMessage.system(
  'You are MinQ\'s helpful AI concierge. Reply in the same language as the '
  'user. Keep answers encouraging, practical, and concise.',
);

final gemmaAIServiceProvider = FutureProvider<GemmaAIService>((ref) async {
  return GemmaAIService();
});

class GemmaAIService {
  GemmaAIService();

  static const String modelFileName = 'gemma3-270m-it-q8.task';
  static const String modelDownloadUrl =
      'https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/'
      'gemma3-270m-it-q8.task';
  static const String _fallbackMessage = 'AIサービスを利用できません。時間をおいて再度お試しください。';
  static final RegExp _specialTokenPattern = RegExp(
    r'<(pad|bos|eos|unk|unused\d*|mask|start_of_turn|end_of_turn)>|\[multimodal\]',
    caseSensitive: false,
  );
  static const List<PreferredBackend> _backendPriority = <PreferredBackend>[
    PreferredBackend.gpu,
    PreferredBackend.cpu,
  ];

  InferenceModel? _activeModel;
  bool _isInitialized = false;
  Completer<void>? _initializationCompleter;
  bool _hasAttemptedRecovery = false;

  static Future<bool> isModelInstalled() =>
      FlutterGemma.isModelInstalled(modelFileName);

  static Future<List<String>> listInstalledModels() =>
      FlutterGemma.listInstalledModels();

  Future<String> generateText(
    String prompt, {
    int maxTokens = 250,
    List<GemmaChatMessage> history = const <GemmaChatMessage>[],
    String? systemPrompt,
    double temperature = 0.7,
    double topP = 0.85,
    int topK = 40,
  }) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) {
      return '';
    }

    final messages = <GemmaChatMessage>[
      if (systemPrompt != null && systemPrompt.trim().isNotEmpty)
        GemmaChatMessage.system(systemPrompt.trim()),
      ...history,
      GemmaChatMessage.user(trimmedPrompt),
    ];

    if (!messages.any((message) => message.isSystem)) {
      messages.insert(0, _defaultSystemMessage);
    }

    return generateChatCompletion(
      messages: messages,
      maxOutputTokens: maxTokens,
      temperature: temperature,
      topP: topP,
      topK: topK,
    );
  }

  Future<String> generateChatCompletion({
    required List<GemmaChatMessage> messages,
    int maxOutputTokens = 256,
    double temperature = 0.7,
    double topP = 0.85,
    int topK = 40,
  }) async {
    log('Gemma AI: Starting chat completion with ${messages.length} messages');
    
    final normalized =
        messages
            .map((message) => message.trimmed())
            .where((message) => message.text.isNotEmpty)
            .toList();

    if (normalized.isEmpty) {
      log('Gemma AI: No valid messages provided');
      return '';
    }

    if (!normalized.last.isUser) {
      throw ArgumentError('The final GemmaChatMessage must be a user message.');
    }

    log('Gemma AI: Processing ${normalized.length} normalized messages');
    for (int i = 0; i < normalized.length; i++) {
      final msg = normalized[i];
      log('Gemma AI: Message $i (${msg.role.name}): "${msg.text.substring(0, msg.text.length.clamp(0, 50))}..."');
    }

    try {
      await _ensureModelReady();
      log('Gemma AI: Model is ready');
    } catch (error, stackTrace) {
      log('Gemma AI: Failed to prepare model - $error', stackTrace: stackTrace);
      return _fallbackMessage;
    }

    final model = _activeModel;
    if (model == null) {
      log('Gemma AI: No active model available after init.');
      return _fallbackMessage;
    }

    final chat = await _createChat(
      model,
      temperature: temperature,
      topP: topP,
      topK: topK,
      maxOutputTokens: maxOutputTokens,
    );

    try {
      log('Gemma AI: Adding messages to chat');
      for (final message in normalized) {
        final formatted = _formatChatMessage(message);
        if (formatted == null) {
          log('Gemma AI: Skipped empty message');
          continue;
        }
        log('Gemma AI: Adding message: "${formatted.text.substring(0, formatted.text.length.clamp(0, 50))}..."');
        await chat.addQueryChunk(formatted);
      }

      log('Gemma AI: Starting response generation');
      final generated = await _collectResponse(
        chat,
        maxGeneratedTokens: maxOutputTokens,
      );

      if (generated == null || generated.isEmpty) {
        log('Gemma AI: No response collected');
        return _fallbackMessage;
      }

      log('Gemma AI: Raw response: "${generated.substring(0, generated.length.clamp(0, 100))}..."');
      final cleaned = _sanitizeModelText(generated);
      log('Gemma AI: Cleaned response: "${cleaned.substring(0, cleaned.length.clamp(0, 100))}..."');
      return cleaned.isNotEmpty ? cleaned : _fallbackMessage;
    } catch (error, stackTrace) {
      log('Gemma AI: Text generation failed - $error', stackTrace: stackTrace);
      return _fallbackMessage;
    } finally {
      await _closeChat(chat);
    }
  }

  Future<void> warmUp() => _ensureModelReady();

  Future<void> reset() async {}

  Future<void> ensureModelInstalled({
    bool force = false,
    void Function(int progress)? onProgress,
  }) => _installOrActivateModel(onProgress: onProgress, force: force);

  Future<void> _ensureModelReady() async {
    if (_activeModel != null && _isInitialized) {
      return;
    }

    final existingInitialization = _initializationCompleter;
    if (existingInitialization != null) {
      return existingInitialization.future;
    }

    final completer = Completer<void>();
    _initializationCompleter = completer;

    try {
      await _installOrActivateModel();
      _activeModel = await _createActiveModelInstance();
      _isInitialized = true;
      completer.complete();
      log('Gemma AI: Model ready for use');
    } catch (error, stackTrace) {
      log('Gemma AI: Failed to prepare model - $error');
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
      rethrow;
    } finally {
      if (identical(_initializationCompleter, completer)) {
        _initializationCompleter = null;
      }
    }
  }

  Future<void> _installOrActivateModel({
    void Function(int progress)? onProgress,
    bool force = false,
  }) async {
    log('Gemma AI: Ensuring model installation for $modelFileName...');

    final token = await loadHuggingFaceToken();
    int? lastReportedProgress;
    final alreadyInstalled = await FlutterGemma.isModelInstalled(modelFileName);

    if (force && alreadyInstalled) {
      log('Gemma AI: Forcing reinstall of $modelFileName');
      try {
        await FlutterGemma.uninstallModel(modelFileName);
        log('Gemma AI: Existing model metadata removed');
      } catch (error, stackTrace) {
        log(
          'Gemma AI: Failed to uninstall existing model - $error',
          stackTrace: stackTrace,
        );
      }
    }

    // Initialize FlutterGemma with token if available
    if (token != null && token.isNotEmpty) {
      FlutterGemma.initialize(
        huggingFaceToken: token,
        maxDownloadRetries: 10,
      );
    }

    try {
      await FlutterGemma.installModel(
            modelType: ModelType.gemmaIt,
            fileType: ModelFileType.task,
          )
          .fromNetwork(
            modelDownloadUrl,
            token: (token != null && token.isNotEmpty) ? token : null,
          )
          .withProgress((progress) {
            if (progress == lastReportedProgress) {
              return;
            }
            lastReportedProgress = progress;
            if (progress <= 5 || progress % 10 == 0 || progress == 100) {
              log('Gemma AI: Download progress: $progress%');
            }
            onProgress?.call(progress);
          })
          .install();
    } catch (error, stackTrace) {
      if (_isAccessDeniedError(error)) {
        const message =
            'Gemma AI: Hugging Face denied access (HTTP 403).\n'
            'Accept the model license at '
            'https://huggingface.co/litert-community/gemma-3-270m-it '
            'and ensure the token in config.json has read scope.';
        log(message);
        throw GemmaModelAccessException(message, stackTrace: stackTrace);
      }

      log(
        'Gemma AI: Model installation failed - $error',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<InferenceModel> _createActiveModelInstance({
    bool retryOnFailure = true,
  }) async {
    // モデルが正しくインストールされているかチェック
    final isInstalled = await FlutterGemma.isModelInstalled(modelFileName);
    if (!isInstalled) {
      throw StateError('Model $modelFileName is not installed');
    }

    for (final backend in _backendPriority) {
      try {
        log('Gemma AI: Trying ${backend.name.toUpperCase()} backend');
        final model = await FlutterGemma.getActiveModel(
          maxTokens: 2048, // トークン数を調整
          preferredBackend: backend,
        );
        log('Gemma AI: Successfully created model with ${backend.name.toUpperCase()} backend');
        
        // モデルの基本的な動作テスト
        try {
          final testChat = await model.createChat(
            temperature: 0.7,
            topP: 0.9,
            topK: 40,
            tokenBuffer: 128,
            modelType: ModelType.gemmaIt,
          );
          await testChat.session.close();
          log('Gemma AI: Model validation successful');
        } catch (testError) {
          log('Gemma AI: Model validation failed - $testError');
          continue;
        }
        
        return model;
      } on PlatformException catch (error) {
        log('Gemma AI: Backend ${backend.name} not available - $error');
      } on StateError catch (error) {
        log('Gemma AI: No active model registered - $error');
        if (retryOnFailure && !_hasAttemptedRecovery) {
          break; // リトライロジックに進む
        }
        rethrow;
      } catch (error) {
        log('Gemma AI: Unexpected error on ${backend.name} backend - $error');
      }
    }

    if (retryOnFailure && !_hasAttemptedRecovery) {
      _hasAttemptedRecovery = true;
      log(
        'Gemma AI: Model creation failed on all backends. '
        'Forcing reinstall and retrying...',
      );
      await _forceReinstallModel();
      return _createActiveModelInstance(retryOnFailure: false);
    }

    throw StateError('Failed to create Gemma model with any available backend');
  }

  Future<InferenceChat> _createChat(
    InferenceModel model, {
    required double temperature,
    required double topP,
    required int topK,
    required int maxOutputTokens,
  }) async {
    final tokenBuffer = _calculateTokenBuffer(maxOutputTokens);
    log(
      'Gemma AI: Creating chat (temp=$temperature, topP=$topP, '
      'topK=$topK, tokenBuffer=$tokenBuffer)',
    );
    
    try {
      final chat = await model.createChat(
        temperature: temperature.clamp(0.1, 1.0),
        topP: topP.clamp(0.1, 1.0),
        topK: topK.clamp(1, 100),
        tokenBuffer: tokenBuffer,
        modelType: ModelType.gemmaIt,
      );
      log('Gemma AI: Chat created successfully');
      return chat;
    } catch (error, stackTrace) {
      log('Gemma AI: Failed to create chat - $error', stackTrace: stackTrace);
      rethrow;
    }
  }

  Message? _formatChatMessage(GemmaChatMessage message) {
    final trimmed = message.text.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    // Gemma用のプロンプトフォーマット
    if (message.isSystem) {
      return Message.text(text: trimmed, isUser: true);
    }

    if (message.isUser) {
      return Message.text(text: trimmed, isUser: true);
    } else {
      return Message.text(text: trimmed, isUser: false);
    }
  }

  Future<String?> _collectResponse(
    InferenceChat chat, {
    required int maxGeneratedTokens,
  }) async {
    final buffer = StringBuffer();
    var sawValidToken = false;
    var tokenCount = 0;
    var consecutiveSpecialTokens = 0;
    final limit = maxGeneratedTokens > 0 ? maxGeneratedTokens : 256;
    const maxConsecutiveSpecialTokens = 10; // 連続する特殊トークンの上限

    try {
      await for (final response in chat.generateChatResponseAsync()) {
        switch (response) {
          case TextResponse(:final token):
            // 空のトークンをスキップ
            if (token.isEmpty) {
              continue;
            }
            
            // 特殊トークンをチェック
            if (_isSpecialToken(token)) {
              consecutiveSpecialTokens++;
              log('Gemma AI: Filtered special token: "$token"');
              
              // 連続する特殊トークンが多すぎる場合は生成を停止
              if (consecutiveSpecialTokens >= maxConsecutiveSpecialTokens) {
                log('Gemma AI: Too many consecutive special tokens, stopping generation');
                break;
              }
              continue;
            }
            
            // 有効なトークンをリセット
            consecutiveSpecialTokens = 0;
            
            // 有効なテキストトークンを追加
            buffer.write(token);
            sawValidToken = true;
            tokenCount += 1;
            
            if (tokenCount >= limit) {
              log('Gemma AI: Token limit reached ($limit)');
              break;
            }
            
          case ThinkingResponse():
            continue;
          case FunctionCallResponse(:final name):
            log('Gemma AI: Function call requested -> $name');
            return null;
        }
      }
    } catch (error, stackTrace) {
      log(
        'Gemma AI: Streaming response failed - $error',
        stackTrace: stackTrace,
      );
      return null;
    }

    final collected = buffer.toString().trim();
    if (!sawValidToken || collected.isEmpty) {
      log('Gemma AI: No valid tokens collected');
      return null;
    }
    
    log('Gemma AI: Collected response: "${collected.substring(0, collected.length.clamp(0, 100))}..."');
    return collected;
  }

  Future<void> _closeChat(InferenceChat chat) async {
    try {
      await chat.session.close();
    } catch (error) {
      log('Gemma AI: Failed to close chat session - $error');
    }
  }

  bool _isSpecialToken(String token) {
    if (token.isEmpty) {
      return false;
    }
    
    // 特殊トークンパターンをチェック
    if (_specialTokenPattern.hasMatch(token)) {
      return true;
    }
    
    // 角括弧で囲まれたトークン
    if (token.startsWith('[') && token.endsWith(']')) {
      return true;
    }
    
    // 山括弧で囲まれたトークン
    if (token.startsWith('<') && token.endsWith('>')) {
      return true;
    }
    
    // その他の特殊トークン
    final lowerToken = token.toLowerCase();
    return lowerToken == 'multimodal' || 
           lowerToken.startsWith('unused') ||
           lowerToken == 'pad' ||
           lowerToken == 'bos' ||
           lowerToken == 'eos' ||
           lowerToken == 'mask';
  }

  String _sanitizeModelText(String response) {
    // 特殊トークンを除去
    var withoutTokens = response.replaceAll(_specialTokenPattern, ' ');
    
    // 追加の特殊トークンパターンを除去
    withoutTokens = withoutTokens.replaceAll(RegExp(r'<[^>]*>'), ' ');
    withoutTokens = withoutTokens.replaceAll(RegExp(r'\[[^\]]*\]'), ' ');
    
    final cleaned = _postProcessResponse(withoutTokens);
    if (cleaned.isNotEmpty) {
      return cleaned;
    }
    
    final fallbackText = withoutTokens.trim();
    if (fallbackText.isNotEmpty) {
      return fallbackText;
    }
    
    log('Gemma AI: Response empty after sanitization');
    return '';
  }

  String _postProcessResponse(String response) {
    var cleaned = response.replaceAll(RegExp(r'<[^>]*>'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'`[^`]*`'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  int _calculateTokenBuffer(int maxOutputTokens) {
    final base = maxOutputTokens < 32 ? 32 : maxOutputTokens;
    final scaled = base * 2;
    if (scaled < 96) {
      return 96;
    }
    if (scaled > 512) {
      return 512;
    }
    return scaled;
  }

  Future<void> _forceReinstallModel() async {
    _activeModel = null;
    _isInitialized = false;

    await _installOrActivateModel(force: true);
  }

  bool _isAccessDeniedError(Object error) {
    final message = error.toString();
    if (message.isEmpty) {
      return false;
    }

    return message.contains('response code 403') &&
        message.contains('Access to model');
  }

  /// 診断情報を取得
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    final info = <String, dynamic>{
      'isInitialized': _isInitialized,
      'hasActiveModel': _activeModel != null,
      'hasAttemptedRecovery': _hasAttemptedRecovery,
      'modelFileName': modelFileName,
    };

    try {
      info['isModelInstalled'] = await FlutterGemma.isModelInstalled(modelFileName);
      info['installedModels'] = await FlutterGemma.listInstalledModels();
    } catch (error) {
      info['diagnosticError'] = error.toString();
    }

    return info;
  }

  /// モデルを強制的にリセット
  Future<void> forceReset() async {
    log('Gemma AI: Forcing complete reset');
    _activeModel = null;
    _isInitialized = false;
    _hasAttemptedRecovery = false;
    _initializationCompleter = null;
  }
}

class GemmaModelAccessException implements Exception {
  GemmaModelAccessException(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}
