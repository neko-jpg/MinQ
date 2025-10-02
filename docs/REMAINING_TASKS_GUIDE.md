# 残りタスク実装ガイド

## P2-8: ペア機能の高度化

### ペアスコアボード/軽量ランキング
```dart
class PairLeaderboardService {
  Future<List<PairRanking>> getWeeklyRanking() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('pairStats')
        .where('weekStart', isEqualTo: _getWeekStart())
        .orderBy('totalCompletions', descending: true)
        .limit(100)
        .get();
    
    return snapshot.docs.map((doc) => PairRanking.fromFirestore(doc)).toList();
  }
}
```

## P2-9: ユーザー体験の磨き込み

### Onboarding計測（ステップ別離脱）
```dart
class OnboardingAnalytics {
  void trackStep(int step, String action) {
    FirebaseAnalytics.instance.logEvent(
      name: 'onboarding_step',
      parameters: {
        'step': step,
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

### Bidi対応（RTL検証）
```dart
MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en', ''),
    Locale('ja', ''),
    Locale('ar', ''), // RTL
    Locale('he', ''), // RTL
  ],
  builder: (context, child) {
    return Directionality(
      textDirection: _getTextDirection(context),
      child: child!,
    );
  },
)
```

## P2-10: 端末対応とパフォーマンス

### ABI別分割/圧縮（Android App Bundle最適化）
```gradle
// android/app/build.gradle
android {
    bundle {
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}
```

### 未使用アセット/フォント削除
```bash
# 未使用アセットを検出
flutter pub run flutter_unused_files:main

# 未使用フォントを削除
# pubspec.yaml から不要なフォントを削除
```

### ベクター化（PNG→SVG）
```yaml
# pubspec.yaml
dependencies:
  flutter_svg: ^2.0.0

# 使用例
SvgPicture.asset('assets/icons/icon.svg')
```

### 背景Isolateで重処理
```dart
Future<List<Stats>> calculateStats(List<QuestLog> logs) async {
  return await compute(_calculateStatsInBackground, logs);
}

List<Stats> _calculateStatsInBackground(List<QuestLog> logs) {
  // 重い計算処理
  return stats;
}
```

## P2-11: 法務とリリース運用

### 利用規約/プライバシーポリシー整備
- `assets/legal/terms_of_service.md`
- `assets/legal/privacy_policy.md`
- アプリ内で表示する画面を作成

### データセーフティフォーム（Play Console）
1. Play Console > アプリのコンテンツ > データセーフティ
2. 収集するデータを申告
3. データの使用目的を説明
4. 第三者との共有について説明

### アカウント削除/データ削除導線
```dart
class AccountDeletionService {
  Future<void> deleteAccount(String userId) async {
    // 1. Firestoreのデータを削除
    await _deleteUserData(userId);
    
    // 2. Storageのデータを削除
    await _deleteUserStorage(userId);
    
    // 3. Authenticationを削除
    await FirebaseAuth.instance.currentUser?.delete();
  }
}
```

### 年齢配慮/ペア機能の年少者保護
```dart
class AgeVerificationService {
  Future<bool> verifyAge(DateTime birthDate) async {
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    return age >= 13; // COPPA準拠
  }
  
  Future<void> enableParentalControl(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'parentalControlEnabled': true,
      'pairFeatureDisabled': true,
    });
  }
}
```

### 追跡拒否トグル（Do Not Track）
```dart
class TrackingService {
  Future<void> setTrackingEnabled(bool enabled) async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('tracking_enabled', enabled);
    });
  }
}
```

### ストア素材作成
- スクリーンショット: 5-8枚（各言語）
- プロモーション動画: 30秒以内
- アイコン: 512x512px
- フィーチャーグラフィック: 1024x500px

### メタデータ多言語化/ASOキーワード
```
タイトル: MinQ - 3分で続く習慣化アプリ
短い説明: ペアで励まし合いながら習慣を継続
詳細説明: 
- 3分で記録できる簡単な習慣管理
- ペア機能で仲間と励まし合い
- 継続日数を可視化してモチベーション維持

キーワード:
習慣, 習慣化, 継続, モチベーション, ペア, 目標達成, 自己改善
```

### 内部テスト/クローズドテスト/オープンβ運用
1. 内部テスト: 開発チーム（最大100人）
2. クローズドテスト: 限定ユーザー（最大1000人）
3. オープンβ: 一般公開前のテスト

### プレローンチレポート対応
- Play Console > リリース > プレローンチレポート
- クラッシュレポートを確認
- 互換性問題を修正

### バグ報告機能
```dart
class BugReportService {
  Future<void> submitBugReport({
    required String description,
    File? screenshot,
  }) async {
    final logs = await _collectLogs();
    final deviceInfo = await _getDeviceInfo();
    
    // Firestoreに保存
    await FirebaseFirestore.instance.collection('bugReports').add({
      'description': description,
      'logs': logs,
      'deviceInfo': deviceInfo,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    // スクリーンショットをアップロード
    if (screenshot != null) {
      await _uploadScreenshot(screenshot);
    }
  }
}
```

### インアプリFAQ/ヘルプ/問い合わせ
```dart
class HelpCenterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help Center')),
      body: ListView(
        children: [
          ListTile(
            title: Text('FAQ'),
            onTap: () => _openFAQ(),
          ),
          ListTile(
            title: Text('Contact Us'),
            onTap: () => _openContactForm(),
          ),
          ListTile(
            title: Text('Tutorial'),
            onTap: () => _openTutorial(),
          ),
        ],
      ),
    );
  }
}
```

### 稼働監視ダッシュボード
- Firebase Console > Analytics
- Crashlytics でクラッシュ監視
- Performance Monitoring でパフォーマンス監視

### Slack/メール通知
```typescript
// Cloud Functions
export const notifyCriticalError = functions.crashlytics
  .issue()
  .onNew(async (issue) => {
    const message = {
      text: `🚨 Critical Error: ${issue.issueTitle}`,
      attachments: [{
        color: 'danger',
        fields: [
          { title: 'App Version', value: issue.appVersion },
          { title: 'Affected Users', value: issue.impactedUsersCount },
        ],
      }],
    };
    
    await axios.post(SLACK_WEBHOOK_URL, message);
  });
```

### リモートフラグのキルスイッチ
```dart
class FeatureFlagService {
  Future<bool> isFeatureEnabled(String featureName) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    return remoteConfig.getBool('feature_$featureName');
  }
}
```

### 実験テンプレ
```dart
class ABTestService {
  Future<String> getVariant(String experimentName) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    return remoteConfig.getString('experiment_$experimentName');
  }
}
```

### 料金/権限のフェンス
```dart
class SubscriptionService {
  Future<bool> isPremiumUser(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    return doc.data()?['isPremium'] ?? false;
  }
  
  Future<void> checkFeatureAccess(String feature) async {
    if (!await isPremiumUser(currentUserId)) {
      throw PremiumRequiredException(feature);
    }
  }
}
```

### リファラ計測
```dart
class ReferralService {
  Future<void> trackReferral(String referralCode) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'referral_used',
      parameters: {'referral_code': referralCode},
    );
    
    await FirebaseFirestore.instance
        .collection('referrals')
        .doc(referralCode)
        .update({
      'usageCount': FieldValue.increment(1),
    });
  }
}
```

### 変更履歴/お知らせセンター
```dart
class AnnouncementService {
  Future<List<Announcement>> getAnnouncements() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('announcements')
        .where('publishedAt', isLessThanOrEqualTo: DateTime.now())
        .orderBy('publishedAt', descending: true)
        .limit(20)
        .get();
    
    return snapshot.docs
        .map((doc) => Announcement.fromFirestore(doc))
        .toList();
  }
}
```

### テックドキュメント整備
- `docs/ARCHITECTURE.md`: アーキテクチャ設計
- `docs/RUNBOOK.md`: 運用手順書
- `docs/API.md`: API仕様書
- `docs/DATABASE.md`: データベース設計

### デザインシステムガイド
- `docs/DESIGN_SYSTEM.md`: 既に作成済み
- Figmaでデザインシステムを管理

### TODO/DEBT棚卸しと優先度付け
```bash
# TODOコメントを検索
grep -r "TODO" lib/

# 技術的負債を管理
# GitHub Issues でラベル付け: tech-debt, priority-high, priority-medium, priority-low
```

### 依存パッケージのライセンス表記
```dart
// lib/presentation/screens/licenses_screen.dart
class LicensesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LicensePage(
      applicationName: 'MinQ',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 MinQ Team',
    );
  }
}
```

## P2-12: その他高度な機能・改善

### FCMトピック設計
```dart
class TopicService {
  Future<void> subscribeToTopics(String userId) async {
    await FirebaseMessaging.instance.subscribeToTopic('all_users');
    await FirebaseMessaging.instance.subscribeToTopic('news');
    await FirebaseMessaging.instance.subscribeToTopic('weekly_summary');
  }
}
```

### バックグラウンド同期の窓口
```dart
// Android: WorkManager
// iOS: Background Fetch

class BackgroundSyncService {
  Future<void> scheduleSync() async {
    // Workmanager.registerPeriodicTask(
    //   'sync_task',
    //   'syncData',
    //   frequency: Duration(hours: 1),
    // );
  }
}
```

### タイムゾーン異常/うるう年/月末処理の境界テスト
```dart
void main() {
  test('Leap year handling', () {
    final leapYear = DateTime(2024, 2, 29);
    expect(leapYear.day, 29);
  });
  
  test('Timezone handling', () {
    final utc = DateTime.utc(2025, 1, 1, 0, 0);
    final local = utc.toLocal();
    expect(local.timeZoneOffset, isNot(Duration.zero));
  });
}
```

### その他の実装項目
- DND中の通知延期ロジック
- 連続通知抑制（デバウンス/バッチ）
- 例外セーフガード
- ネットワーク断/機内モード時のデグレード表示
- CDN/HTTPキャッシュ戦略
- 入力サニタイズ
- Play Integrity API
- アプリ内時刻表現の一貫性
- ダークモード切替を即時反映
- アクセントカラー切替
- フォントサイズ変更UI
- プロフィールのニックネーム重複検証
- タスク/習慣のタグ機能
- クエストのアーカイブ機能
- クエストのリマインド複数設定
- クエストの優先度ラベル
- 達成画面のアニメーション追加
- Statsでの週単位・月単位切替
- Statsのグラフにツールチップ追加
- データエクスポートをPDF形式でも提供
- サーバーメンテナンス時のメッセージ画面
- オフラインモード時のUI表示改善
- 通知タップで直接「今日のクエスト一覧」へ遷移
- 機種変更時のデータ移行ガイド
- ストリーク途切れ時のリカバリー機能
- ペアの進捗比較画面
- ペア解消機能
- ペアリマインド通知
- サーバーレスポンス遅延時のリトライUI
- バージョンアップ時の変更点案内
- バージョン互換チェック
- ストア評価リクエスト導線
- SNSシェア時のOGP画像生成
- ユーザー削除時の二重確認
- 通知の曜日/祝日カスタム
- 習慣テンプレート集
- 習慣提案AI
- 習慣に「難易度」属性追加
- 習慣に「推定時間」属性追加
- 習慣の「場所」属性
- 習慣の「連絡先」リンク
- 音声入力でクエスト作成
- 習慣実行時のタイマー機能
- 習慣実行中のBGM
- ペア同士の軽いチャット
- 不正利用検出
- 利用時間制限（親子モード）
- デバイス通知音のカスタム
- アプリ内での「よくある質問」ヘルプセンター
- フィードバック投稿フォーム
- アプリ内アンケート
- バッジシステム
- アチーブメント一覧画面
- プロフィールに「獲得バッジ数」表示
- イベントモード
- チーム習慣
- イベントランキング

## 高度な実装項目

### ISO 27001/SOC 2準拠のセキュリティポリシー策定
- セキュリティ監査の実施
- データ暗号化の徹底
- アクセス制御の強化

### 差分バックアップ+暗号化ZIPのユーザー直接DL機能
```dart
class BackupService {
  Future<File> createEncryptedBackup(String userId) async {
    final data = await _collectUserData(userId);
    final json = jsonEncode(data);
    final encrypted = _encrypt(json);
    final zip = await _createZip(encrypted);
    return zip;
  }
}
```

### その他の高度な機能
- マルチリージョンFirestore
- CDNヘッダ最適化
- アプリ起動時プリロード戦略
- Chaos Testing
- Fuzz Testing
- ライブラリアップデート自動PR
- 開発用データシードスクリプト
- Monorepo化＋Melos/Very Good CLI導入
- Dart API docs → pub.dev公開自動生成
- タグ/検索バー搭載
- AIレコメンド
- パーソナライズPush
- ACR Cloud連携でBGM自動タグ付け
- スクリーンリーダー最適化
- カラーコントラスト自動検証CI
- 日本語漢字変換中のIME候補被りテスト
- 祝日API同期
- DST/うるう秒/閏年パスケース単体テスト
- オフライン完全モード
- PWAインストールバナー＆Add to Home Screen対応
- Mac/Winネイティブビルド
- Wear OS/Apple Watchクイックチェックアプリ
- HealthKit/Google Fit連携
- GPT-4o埋め込みチャットサポートBot
- アプリ内コミュニティ掲示板
- カスタムWebhook IFTTT/Zapier連携
- Carbon footprint計測
- グリーンダークモード
- 動画チュートリアル生成パイプライン
- Live Activity / Android Live Widget
- Stripe Billing Portal統合
- アプリ内投げ銭
- Referral Code deep link
- ユーザートークン制Rate Limiter
- 地理的位置連動通知
- 画像生成AIでSNS共有バナー自動作成
- 高齢者向けアクセシビリティ設定
- プログレッシブオンボーディング
- Feature flag kill-switch即時反映
- KPIダッシュボード自動Snapshot→Slack送信
- バックエンドコストアラート
- ユーザー行動ヒートマップ
- 自己診断モード
- 脆弱性SCA
- 法域別プライバシーコンプライアンス
- パブリックAPI公開
- OSS公開計画

## 注意事項
- すべてのタスクを一度に実装する必要はありません
- 優先度の高いものから順に実装してください
- 各機能の実装前にテストを書いてください
- ドキュメントを更新してください
