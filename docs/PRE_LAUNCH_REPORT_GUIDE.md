# プレローンチレポート対応ガイド

このドキュメントは、Google Play Consoleのプレローンチレポート（Pre-launch Report）で発見される問題への対応方法をまとめたものです。

## プレローンチレポートとは

Google Playが提供する自動テストサービスで、アプリを実際のデバイスで自動的にテストし、以下の問題を検出します：

- クラッシュ
- パフォーマンス問題
- セキュリティ脆弱性
- アクセシビリティ問題
- 互換性問題

### テスト環境
- 複数のAndroidデバイス（様々なメーカー・画面サイズ）
- 複数のAndroid OSバージョン
- 自動操作（Robo Test）
- 約5-10分間のテスト

---

## よくある問題と対処法

### 1. クラッシュ（Crashes）

#### 問題: NullPointerException
```
java.lang.NullPointerException: Attempt to invoke virtual method on a null object reference
```

**原因**
- null チェックの不足
- 初期化前のアクセス

**対処法**
```dart
// 悪い例
final user = ref.read(userProvider);
print(user.name); // userがnullの場合クラッシュ

// 良い例
final user = ref.read(userProvider);
if (user != null) {
  print(user.name);
}

// さらに良い例（null safety）
final user = ref.read(userProvider);
print(user?.name ?? 'Unknown');
```

#### 問題: IndexOutOfBoundsException
```
java.lang.IndexOutOfBoundsException: Index: 0, Size: 0
```

**原因**
- 空のリストへのアクセス

**対処法**
```dart
// 悪い例
final quests = ref.read(questsProvider);
final firstQuest = quests[0]; // questsが空の場合クラッシュ

// 良い例
final quests = ref.read(questsProvider);
if (quests.isNotEmpty) {
  final firstQuest = quests[0];
}

// さらに良い例
final quests = ref.read(questsProvider);
final firstQuest = quests.firstOrNull;
```

#### 問題: IllegalStateException
```
java.lang.IllegalStateException: Cannot perform this action after onSaveInstanceState
```

**原因**
- アプリがバックグラウンドに移行した後のUI操作

**対処法**
```dart
// Widgetのmountedチェックを追加
if (mounted) {
  Navigator.push(context, ...);
}

// AsyncValueを使用
ref.listen(someProvider, (previous, next) {
  if (!mounted) return;
  next.whenData((data) {
    // UI操作
  });
});
```

---

### 2. ANR（Application Not Responding）

#### 問題: メインスレッドでの重い処理
```
ANR in com.example.minq
Reason: Input dispatching timed out
```

**原因**
- UIスレッドでの同期的な重い処理
- ネットワーク処理の待機
- 大量のデータ処理

**対処法**
```dart
// 悪い例
void loadData() {
  final data = heavyComputation(); // UIスレッドをブロック
  setState(() => _data = data);
}

// 良い例
Future<void> loadData() async {
  final data = await compute(heavyComputation, input); // 別スレッド
  if (mounted) {
    setState(() => _data = data);
  }
}

// Isolateを使用
import 'dart:isolate';

Future<List<Quest>> processQuests(List<Quest> quests) async {
  return await Isolate.run(() {
    // 重い処理
    return quests.where((q) => q.isCompleted).toList();
  });
}
```

---

### 3. メモリリーク（Memory Leaks）

#### 問題: メモリ使用量の増加
```
Memory usage: 512MB (Warning: High memory usage)
```

**原因**
- StreamSubscriptionの未解放
- Controllerの未dispose
- 大きな画像のキャッシュ

**対処法**
```dart
// StreamSubscriptionの適切な管理
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen((data) {
      // 処理
    });
  }

  @override
  void dispose() {
    _subscription?.cancel(); // 必ず解放
    super.dispose();
  }
}

// 画像のメモリ最適化
Image.network(
  imageUrl,
  cacheWidth: 400, // リサイズしてキャッシュ
  cacheHeight: 400,
)
```

---

### 4. パーミッション問題

#### 問題: 権限エラー
```
SecurityException: Permission denied
```

**原因**
- 必要な権限の未宣言
- ランタイム権限の未リクエスト

**対処法**

**AndroidManifest.xml**
```xml
<!-- 必要な権限を宣言 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />

<!-- Android 13以降の通知権限 -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" 
                 android:minSdkVersion="33" />
```

**Dartコード**
```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      // 権限が付与された
    } else {
      // 権限が拒否された
      // ユーザーに説明を表示
    }
  }
}
```

---

### 5. ネットワークエラー

#### 問題: ネットワーク接続失敗
```
SocketException: Failed to connect
```

**原因**
- ネットワーク接続なし
- タイムアウト
- SSL証明書エラー

**対処法**
```dart
// タイムアウト設定
final response = await http.get(
  Uri.parse(url),
).timeout(
  const Duration(seconds: 10),
  onTimeout: () {
    throw TimeoutException('Request timed out');
  },
);

// リトライロジック
Future<T> retryRequest<T>(
  Future<T> Function() request, {
  int maxAttempts = 3,
}) async {
  int attempts = 0;
  while (attempts < maxAttempts) {
    try {
      return await request();
    } catch (e) {
      attempts++;
      if (attempts >= maxAttempts) rethrow;
      await Future.delayed(Duration(seconds: attempts * 2));
    }
  }
  throw Exception('Max retry attempts reached');
}

// ネットワーク状態チェック
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isConnected() async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}
```

---

### 6. 画面サイズ・解像度問題

#### 問題: レイアウトオーバーフロー
```
RenderFlex overflowed by 48 pixels on the right
```

**原因**
- 固定サイズの使用
- 画面サイズの考慮不足

**対処法**
```dart
// 悪い例
Container(
  width: 400, // 小さい画面でオーバーフロー
  child: Text('Long text...'),
)

// 良い例
Container(
  width: MediaQuery.of(context).size.width * 0.8,
  child: Text(
    'Long text...',
    overflow: TextOverflow.ellipsis,
  ),
)

// Flexibleを使用
Row(
  children: [
    Flexible(
      child: Text('Long text...'),
    ),
    Icon(Icons.arrow_forward),
  ],
)

// LayoutBuilderを使用
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    } else {
      return TabletLayout();
    }
  },
)
```

---

### 7. テキスト表示問題

#### 問題: テキストが切れる
```
Text overflow detected
```

**対処法**
```dart
// オーバーフロー処理
Text(
  'Very long text that might overflow',
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
)

// 自動サイズ調整
import 'package:auto_size_text/auto_size_text.dart';

AutoSizeText(
  'Text that will resize to fit',
  maxLines: 2,
  minFontSize: 12,
  maxFontSize: 20,
)

// スクロール可能に
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Text('Very long text'),
)
```

---

### 8. バックグラウンド処理問題

#### 問題: バックグラウンドでのクラッシュ
```
Background execution not allowed
```

**原因**
- Android 12以降のバックグラウンド制限

**対処法**
```dart
// WorkManagerを使用
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // バックグラウンド処理
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  
  // 定期タスクの登録
  Workmanager().registerPeriodicTask(
    'sync-task',
    'syncData',
    frequency: Duration(hours: 1),
  );
  
  runApp(MyApp());
}
```

---

### 9. データベース問題

#### 問題: Firestore接続エラー
```
FirebaseException: Failed to get document
```

**対処法**
```dart
// オフライン永続化を有効化
await FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

// エラーハンドリング
try {
  final doc = await FirebaseFirestore.instance
      .collection('quests')
      .doc(questId)
      .get();
  
  if (doc.exists) {
    return Quest.fromJson(doc.data()!);
  } else {
    throw NotFoundException('Quest not found');
  }
} on FirebaseException catch (e) {
  if (e.code == 'unavailable') {
    // オフライン時の処理
    return getCachedQuest(questId);
  }
  rethrow;
}
```

---

### 10. 日付・時刻問題

#### 問題: タイムゾーンエラー
```
DateTimeException: Invalid timezone
```

**対処法**
```dart
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// 初期化
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(MyApp());
}

// タイムゾーンを考慮した日付処理
final tokyo = tz.getLocation('Asia/Tokyo');
final now = tz.TZDateTime.now(tokyo);

// UTCで保存、ローカルで表示
final utcTime = DateTime.now().toUtc();
final localTime = utcTime.toLocal();
```

---

## プレローンチレポートの確認方法

### 1. Play Consoleにアクセス
1. Play Consoleにログイン
2. アプリを選択
3. 「リリース」→「テスト」→「内部テスト」
4. リリースを選択
5. 「プレローンチレポート」タブをクリック

### 2. レポートの見方

#### クラッシュ
- クラッシュ率
- スタックトレース
- 影響を受けたデバイス

#### パフォーマンス
- 起動時間
- フレームレート
- メモリ使用量
- バッテリー消費

#### セキュリティ
- 脆弱性の警告
- 安全でない通信

#### アクセシビリティ
- タップターゲットサイズ
- コントラスト比
- スクリーンリーダー対応

---

## 対応優先順位

### P0（即座に修正）
- [ ] クラッシュ（クラッシュ率 > 1%）
- [ ] データ損失
- [ ] セキュリティ脆弱性
- [ ] 主要機能の動作不良

### P1（リリース前に修正）
- [ ] ANR
- [ ] メモリリーク
- [ ] パフォーマンス問題（起動時間 > 5秒）
- [ ] 互換性問題（主要デバイス）

### P2（リリース後に修正可）
- [ ] マイナーなUI問題
- [ ] 特定デバイスのみの問題
- [ ] アクセシビリティの改善
- [ ] パフォーマンスの最適化

---

## テスト自動化

### ユニットテスト
```dart
// test/unit/quest_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Quest', () {
    test('should create quest with valid data', () {
      final quest = Quest(
        id: '1',
        title: 'Test Quest',
        createdAt: DateTime.now(),
      );
      
      expect(quest.id, '1');
      expect(quest.title, 'Test Quest');
    });
    
    test('should throw error with invalid data', () {
      expect(
        () => Quest(id: '', title: '', createdAt: DateTime.now()),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
```

### ウィジェットテスト
```dart
// test/widget/home_screen_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeScreen should display quests', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    
    // ローディング表示
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // データ読み込み完了を待つ
    await tester.pumpAndSettle();
    
    // クエストリスト表示
    expect(find.byType(QuestCard), findsWidgets);
  });
}
```

### インテグレーションテスト
```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete quest flow', (tester) async {
    await tester.pumpWidget(MyApp());
    
    // ログイン
    await tester.tap(find.text('Login with Google'));
    await tester.pumpAndSettle();
    
    // クエスト作成
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextField), 'Test Quest');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    
    // クエスト完了
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    
    // 確認
    expect(find.text('Quest completed!'), findsOneWidget);
  });
}
```

---

## CI/CDでの自動テスト

### GitHub Actions設定
```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

---

## チェックリスト

### リリース前確認
- [ ] すべてのユニットテストが通過
- [ ] すべてのウィジェットテストが通過
- [ ] インテグレーションテストが通過
- [ ] プレローンチレポートでクラッシュゼロ
- [ ] ANRゼロ
- [ ] メモリリークなし
- [ ] 起動時間 < 3秒
- [ ] 主要デバイスで動作確認
- [ ] Android 8.0以降で動作確認
- [ ] オフライン動作確認
- [ ] 画面回転対応確認
- [ ] アクセシビリティ確認

---

## トラブルシューティング

### プレローンチレポートが生成されない
- **原因**: テストトラックに公開していない
- **対処**: 内部テスト/クローズドテストに公開

### クラッシュが再現できない
- **原因**: 特定デバイス/OS固有の問題
- **対処**: Firebase Test Labで該当デバイスをテスト

### パフォーマンス問題が検出される
- **原因**: 重い処理、メモリリーク
- **対処**: Flutter DevToolsでプロファイリング

---

## 参考リソース

- [Google Play プレローンチレポート](https://support.google.com/googleplay/android-developer/answer/7002270)
- [Firebase Test Lab](https://firebase.google.com/docs/test-lab)
- [Flutter テストガイド](https://docs.flutter.dev/testing)
- [Android アプリの品質](https://developer.android.com/quality)

---

## 更新履歴

- 2025-10-02: 初版作成
