# Deep Links セットアップ

## 概要
Android App LinksとiOS Universal Linksを設定して、Webリンクから直接アプリを開けるようにします。

## Android App Links

### 1. assetlinks.jsonの作成

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.example.minq",
    "sha256_cert_fingerprints": [
      "YOUR_SHA256_FINGERPRINT_HERE"
    ]
  }
}]
```

### 2. Webサーバーに配置
- URL: `https://minq.app/.well-known/assetlinks.json`
- Content-Type: `application/json`

### 3. AndroidManifest.xmlの設定

```xml
<activity
    android:name=".MainActivity"
    android:exported="true">
    
    <!-- Deep Link Intent Filter -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        
        <!-- Quest Detail -->
        <data
            android:scheme="https"
            android:host="minq.app"
            android:pathPrefix="/quest" />
        
        <!-- Pair Request -->
        <data
            android:scheme="https"
            android:host="minq.app"
            android:pathPrefix="/pair" />
        
        <!-- Share -->
        <data
            android:scheme="https"
            android:host="minq.app"
            android:pathPrefix="/share" />
    </intent-filter>
</activity>
```

### 4. SHA256フィンガープリントの取得

```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore
keytool -list -v -keystore /path/to/release.keystore -alias your_alias
```

## iOS Universal Links

### 1. apple-app-site-associationの作成

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.example.minq",
        "paths": [
          "/quest/*",
          "/pair/*",
          "/share/*"
        ]
      }
    ]
  }
}
```

### 2. Webサーバーに配置
- URL: `https://minq.app/.well-known/apple-app-site-association`
- Content-Type: `application/json`
- 署名不要（iOS 9以降）

### 3. Xcode設定

1. Signing & Capabilities > Associated Domains を追加
2. ドメインを追加: `applinks:minq.app`

### 4. Info.plistの設定

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.example.minq</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>minq</string>
        </array>
    </dict>
</array>
```

## Flutter実装

### 1. app_linksパッケージの使用

```dart
import 'package:app_links/app_links.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  
  Future<void> initialize() async {
    // 初回起動時のリンクを取得
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }
    
    // アプリ起動中のリンクを監視
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }
  
  void _handleDeepLink(Uri uri) {
    final path = uri.path;
    final params = uri.queryParameters;
    
    if (path.startsWith('/quest/')) {
      final questId = path.split('/').last;
      // クエスト詳細画面へ遷移
      navigateToQuestDetail(questId);
    } else if (path.startsWith('/pair/')) {
      final pairId = path.split('/').last;
      // ペアリクエスト画面へ遷移
      navigateToPairRequest(pairId);
    } else if (path.startsWith('/share/')) {
      final shareId = path.split('/').last;
      // 共有画面へ遷移
      navigateToShare(shareId);
    }
  }
}
```

## Webフォールバックページ

### 1. quest.htmlの作成

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MinQ - Quest</title>
    <meta property="og:title" content="Check out this quest on MinQ!">
    <meta property="og:description" content="Join me on my habit journey">
    <meta property="og:image" content="https://minq.app/images/og-image.png">
    <script>
        // アプリがインストールされていない場合はストアへリダイレクト
        setTimeout(() => {
            const userAgent = navigator.userAgent.toLowerCase();
            if (userAgent.includes('android')) {
                window.location.href = 'https://play.google.com/store/apps/details?id=com.example.minq';
            } else if (userAgent.includes('iphone') || userAgent.includes('ipad')) {
                window.location.href = 'https://apps.apple.com/app/minq/id123456789';
            }
        }, 2000);
    </script>
</head>
<body>
    <h1>Opening MinQ...</h1>
    <p>If the app doesn't open, please download it from the store.</p>
    <a href="https://play.google.com/store/apps/details?id=com.example.minq">Google Play</a>
    <a href="https://apps.apple.com/app/minq/id123456789">App Store</a>
</body>
</html>
```

## テスト方法

### Android
```bash
# コマンドラインでテスト
adb shell am start -W -a android.intent.action.VIEW -d "https://minq.app/quest/123"

# ブラウザでテスト
# Chrome で https://minq.app/quest/123 を開く
```

### iOS
```bash
# Xcodeのコンソールでテスト
xcrun simctl openurl booted "https://minq.app/quest/123"

# Safariでテスト
# Safari で https://minq.app/quest/123 を開く
```

## トラブルシューティング

### Androidで動作しない場合
1. assetlinks.jsonが正しく配置されているか確認
2. SHA256フィンガープリントが正しいか確認
3. `adb shell pm get-app-links com.example.minq` でステータス確認

### iOSで動作しない場合
1. apple-app-site-associationが正しく配置されているか確認
2. Associated Domainsが正しく設定されているか確認
3. デバイスの設定 > Safari > 詳細 > Webインスペクタで確認

## 注意事項
- HTTPSが必須です
- ドメインの所有権を証明する必要があります
- アプリがインストールされていない場合の対応を実装してください
- ディープリンクのパラメータを適切にバリデーションしてください
