# ビルドスクリプト

環境別にアプリをビルド・実行するためのスクリプト集です。

## 使い方

### Development環境

```bash
# Windows
scripts\run_dev.bat

# Mac/Linux
sh scripts/build_dev.sh
```

### Staging環境

```bash
sh scripts/build_staging.sh
```

### Production環境

```bash
sh scripts/build_prod.sh
```

## 環境変数

各環境で以下の変数が設定されます:

### Development
- `ENV=development`
- `DEBUG=true`
- `ANALYTICS_ENABLED=false`
- `CRASHLYTICS_ENABLED=false`
- `LOG_LEVEL=debug`
- `SHOW_DEBUG_MENU=true`

### Staging
- `ENV=staging`
- `DEBUG=false`
- `ANALYTICS_ENABLED=true`
- `CRASHLYTICS_ENABLED=true`
- `LOG_LEVEL=info`

### Production
- `ENV=production`
- `DEBUG=false`
- `ANALYTICS_ENABLED=true`
- `CRASHLYTICS_ENABLED=true`
- `LOG_LEVEL=warning`
- `GIT_COMMIT=<commit hash>`
- `GIT_BRANCH=<branch name>`
- `BUILD_DATE=<build timestamp>`

## カスタム変数

追加の環境変数を設定する場合:

```bash
flutter run \
  --dart-define=ENV=development \
  --dart-define=CUSTOM_VAR=value
```

コード内での使用:

```dart
const customVar = String.fromEnvironment('CUSTOM_VAR', defaultValue: '');
```

## Flavor設定

各環境でFlavorを使用する場合、以下のファイルを設定してください:

- `android/app/build.gradle`: Android Flavor設定
- `ios/Runner.xcodeproj`: iOS Scheme設定

## トラブルシューティング

### Windowsでスクリプトが実行できない

Git BashまたはWSLを使用してください。

### 実行権限エラー

```bash
chmod +x scripts/*.sh
```
