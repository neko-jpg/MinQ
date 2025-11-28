# Gemma AI 特殊トークン問題修正レポート

## 問題の概要

Gemma AIモデルが意味のない特殊トークン（`<unused13>`, `<pad>`, `<bos>`, `[multimodal]`など）を大量に出力し、正常な会話ができない状態でした。

## 根本原因

1. **特殊トークンフィルタリングの不備**: 一部の特殊トークンが適切にフィルタリングされていない
2. **モデル初期化の問題**: モデルの状態検証が不十分
3. **プロンプトフォーマットの問題**: Gemmaモデル用の適切なフォーマットが使用されていない
4. **エラーハンドリングの不備**: 連続する特殊トークンに対する対処が不十分

## 実装した修正

### 1. 特殊トークンフィルタリングの強化

```dart
// 特殊トークンパターンを拡張
static final RegExp _specialTokenPattern = RegExp(
  r'<(pad|bos|eos|unk|unused\d*|mask|start_of_turn|end_of_turn)>|\[multimodal\]',
  caseSensitive: false,
);

// より包括的な特殊トークン検出
bool _isSpecialToken(String token) {
  if (token.isEmpty) return false;
  
  // 特殊トークンパターンをチェック
  if (_specialTokenPattern.hasMatch(token)) return true;
  
  // 角括弧・山括弧で囲まれたトークン
  if (token.startsWith('[') && token.endsWith(']')) return true;
  if (token.startsWith('<') && token.endsWith('>')) return true;
  
  // その他の特殊トークン
  final lowerToken = token.toLowerCase();
  return lowerToken == 'multimodal' || 
         lowerToken.startsWith('unused') ||
         lowerToken == 'pad' ||
         lowerToken == 'bos' ||
         lowerToken == 'eos' ||
         lowerToken == 'mask';
}
```

### 2. レスポンス収集の改善

```dart
Future<String?> _collectResponse(InferenceChat chat, {required int maxGeneratedTokens}) async {
  final buffer = StringBuffer();
  var sawValidToken = false;
  var tokenCount = 0;
  var consecutiveSpecialTokens = 0;
  const maxConsecutiveSpecialTokens = 10; // 連続する特殊トークンの上限

  try {
    await for (final response in chat.generateChatResponseAsync()) {
      switch (response) {
        case TextResponse(:final token):
          if (token.isEmpty) continue;
          
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
      }
    }
  } catch (error, stackTrace) {
    log('Gemma AI: Streaming response failed - $error', stackTrace: stackTrace);
    return null;
  }

  final collected = buffer.toString().trim();
  if (!sawValidToken || collected.isEmpty) {
    log('Gemma AI: No valid tokens collected');
    return null;
  }
  
  return collected;
}
```

### 3. テキストサニタイゼーションの強化

```dart
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
```

### 4. モデル初期化の改善

```dart
Future<InferenceModel> _createActiveModelInstance({bool retryOnFailure = true}) async {
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
    } catch (error) {
      log('Gemma AI: Backend ${backend.name} failed - $error');
    }
  }

  // リトライロジック
  if (retryOnFailure && !_hasAttemptedRecovery) {
    _hasAttemptedRecovery = true;
    await _forceReinstallModel();
    return _createActiveModelInstance(retryOnFailure: false);
  }

  throw StateError('Failed to create Gemma model with any available backend');
}
```

### 5. 診断機能の追加

AIコンシェルジュ画面に診断メニューを追加し、以下の情報を確認できるようにしました：

- モデルの初期化状態
- アクティブモデルの有無
- モデルファイルの情報
- インストール状況
- リカバリ試行状況
- エラー情報

### 6. 詳細ログの追加

問題の特定を容易にするため、以下のログを追加：

- メッセージ処理の詳細
- 特殊トークンのフィルタリング状況
- レスポンス生成の進行状況
- モデルの状態変化

## 期待される効果

1. **特殊トークンの除去**: 意味のないトークンが出力されなくなる
2. **安定した会話**: 正常な日本語での応答が可能になる
3. **エラー回復**: 問題が発生した場合の自動回復機能
4. **診断機能**: 問題発生時の原因特定が容易になる
5. **ログ改善**: デバッグ情報の充実

## テスト方法

1. アプリを起動してAIコンシェルジュ画面に移動
2. 「Hello, how are you?」などの簡単なメッセージを送信
3. 正常な日本語の応答が返ってくることを確認
4. メニューから「AI診断情報」を選択して状態を確認
5. 問題がある場合は「AIをリセット」を実行

## 注意事項

- 初回起動時はモデルのダウンロードに時間がかかる場合があります
- ネットワーク環境によってはHugging Faceへのアクセスが必要です
- デバイスの性能によってはレスポンス時間が変わる可能性があります

## 今後の改善点

1. モデルの軽量化検討
2. キャッシュ機能の実装
3. オフライン対応の強化
4. パフォーマンス最適化