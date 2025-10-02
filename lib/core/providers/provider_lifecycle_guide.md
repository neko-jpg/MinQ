# Riverpod Provider ライフサイクルガイド

## AutoDispose vs KeepAlive の使い分け

### AutoDispose（自動破棄）

**使用すべき場合:**
- 画面固有のデータ（画面を離れたら不要）
- 一時的なUI状態（フォーム入力、フィルタ状態など）
- メモリ使用量が大きいデータ
- リアルタイム更新が必要なデータ（Streamなど）

**例:**
```dart
// 画面固有のコントローラー
final questDetailControllerProvider = StateNotifierProvider.autoDispose<
    QuestDetailController, AsyncValue<Quest>>(
  (ref) => QuestDetailController(ref),
);

// フォーム状態
final formStateProvider = StateProvider.autoDispose<FormState>(
  (ref) => FormState.initial(),
);

// 検索クエリ
final searchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);
```

### KeepAlive（永続化）

**使用すべき場合:**
- アプリ全体で共有されるデータ
- 認証状態
- ユーザープロフィール
- 設定・環境変数
- キャッシュしたいデータ
- 初期化コストが高いサービス

**例:**
```dart
// 認証状態（アプリ全体で使用）
final authControllerProvider = StateNotifierProvider<
    AuthController, AsyncValue<User?>>(
  (ref) => AuthController(ref),
);

// ユーザープロフィール
final userProfileProvider = StreamProvider<UserProfile?>(
  (ref) {
    final authState = ref.watch(authControllerProvider);
    return authState.maybeWhen(
      data: (user) => user != null
          ? ref.read(userRepositoryProvider).watchUserProfile(user.uid)
          : Stream.value(null),
      orElse: () => Stream.value(null),
    );
  },
);

// アプリ設定
final appSettingsProvider = StateNotifierProvider<
    AppSettingsController, AppSettings>(
  (ref) => AppSettingsController(ref),
);
```

## ref.keepAlive() の使用

一時的にAutoDisposeを無効化したい場合:

```dart
final dataProvider = FutureProvider.autoDispose<Data>((ref) async {
  // データ取得後、5分間キャッシュ
  final link = ref.keepAlive();
  
  Timer(const Duration(minutes: 5), () {
    link.close();
  });
  
  return await fetchData();
});
```

## cacheTime の使用

一定時間キャッシュを保持:

```dart
final cachedDataProvider = FutureProvider.autoDispose<Data>((ref) async {
  // 30秒間キャッシュ
  ref.cacheFor(const Duration(seconds: 30));
  
  return await fetchData();
});

// 拡張メソッド
extension CacheForExtension on AutoDisposeRef<Object?> {
  void cacheFor(Duration duration) {
    final link = keepAlive();
    Timer(duration, link.close);
  }
}
```

## 依存関係の管理

### 循環依存の回避

```dart
// ❌ 悪い例: 循環依存
final providerA = Provider((ref) {
  final b = ref.watch(providerB);
  return 'A: $b';
});

final providerB = Provider((ref) {
  final a = ref.watch(providerA);
  return 'B: $a';
});

// ✅ 良い例: 共通の依存元を作る
final baseProvider = Provider((ref) => 'base');

final providerA = Provider((ref) {
  final base = ref.watch(baseProvider);
  return 'A: $base';
});

final providerB = Provider((ref) {
  final base = ref.watch(baseProvider);
  return 'B: $base';
});
```

### Family の使用

パラメータ付きProvider:

```dart
// AutoDisposeを使用（画面ごとに異なるID）
final questProvider = FutureProvider.autoDispose.family<Quest, String>(
  (ref, questId) async {
    return await ref.read(questRepositoryProvider).getQuest(questId);
  },
);

// 使用例
final quest = ref.watch(questProvider('quest-123'));
```

## メモリリーク対策

### StreamSubscriptionの適切な破棄

```dart
final streamProvider = StreamProvider.autoDispose<Data>((ref) {
  final controller = StreamController<Data>();
  
  // 破棄時にStreamを閉じる
  ref.onDispose(() {
    controller.close();
  });
  
  return controller.stream;
});
```

### Timerの適切な破棄

```dart
final timerProvider = Provider.autoDispose<void>((ref) {
  final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    // 定期処理
  });
  
  // 破棄時にTimerをキャンセル
  ref.onDispose(() {
    timer.cancel();
  });
});
```

### AnimationControllerの適切な破棄

```dart
final animationProvider = Provider.autoDispose<AnimationController>((ref) {
  final vsync = ref.watch(tickerProviderProvider);
  final controller = AnimationController(
    vsync: vsync,
    duration: const Duration(milliseconds: 300),
  );
  
  // 破棄時にAnimationControllerを破棄
  ref.onDispose(() {
    controller.dispose();
  });
  
  return controller;
});
```

## パフォーマンス最適化

### select の使用

必要な部分だけを監視:

```dart
// ❌ 悪い例: 全体を監視
final name = ref.watch(userProvider).name;

// ✅ 良い例: 必要な部分だけを監視
final name = ref.watch(userProvider.select((user) => user.name));
```

### listenManual の使用

副作用のみを実行:

```dart
@override
Widget build(BuildContext context) {
  // listenManualを使用してエラーをSnackBarで表示
  ref.listenManual(
    questControllerProvider,
    (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    },
  );
  
  return Scaffold(...);
}
```

## ベストプラクティス

1. **デフォルトはAutoDispose**: 迷ったらAutoDisposeを使用
2. **明示的なライフサイクル管理**: keepAlive()を使う場合は必ずclose()を呼ぶ
3. **メモリリークに注意**: onDispose()で適切にリソースを解放
4. **循環依存を避ける**: 依存関係を一方向に保つ
5. **selectで最適化**: 必要な部分だけを監視
6. **familyは慎重に**: パラメータが多いとキャッシュが肥大化
7. **テスト容易性**: Providerをオーバーライドできるように設計

## チェックリスト

- [ ] AutoDisposeとKeepAliveの使い分けが適切か
- [ ] StreamSubscription/Timer/AnimationControllerが適切に破棄されているか
- [ ] 循環依存がないか
- [ ] selectで最適化できる箇所はないか
- [ ] listenManualが適切に使用されているか
- [ ] familyのパラメータが適切か
- [ ] メモリリークの可能性はないか
- [ ] テストでProviderをオーバーライドできるか
