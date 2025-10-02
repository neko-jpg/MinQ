# Flavor別Firebaseプロジェクト分離

## 概要
開発環境（dev）、ステージング環境（stg）、本番環境（prod）でFirebaseプロジェクトを分離します。

## 設定方法

### 1. Firebaseプロジェクトの準備
- dev: minq-dev
- stg: minq-staging  
- prod: minq-production

### 2. 各環境の設定ファイル

#### Android
- `android/app/src/dev/google-services.json`
- `android/app/src/stg/google-services.json`
- `android/app/src/prod/google-services.json`

#### iOS
- `ios/Runner/Dev/GoogleService-Info.plist`
- `ios/Runner/Stg/GoogleService-Info.plist`
- `ios/Runner/Prod/GoogleService-Info.plist`

### 3. ビルドコマンド

```bash
# Development
flutter build apk --flavor dev --dart-define=FLAVOR=dev
flutter build ios --flavor dev --dart-define=FLAVOR=dev

# Staging
flutter build apk --flavor stg --dart-define=FLAVOR=stg
flutter build ios --flavor stg --dart-define=FLAVOR=stg

# Production
flutter build apk --flavor prod --dart-define=FLAVOR=prod
flutter build ios --flavor prod --dart-define=FLAVOR=prod
```

### 4. 実行コマンド

```bash
# Development
flutter run --flavor dev --dart-define=FLAVOR=dev

# Staging
flutter run --flavor stg --dart-define=FLAVOR=stg

# Production
flutter run --flavor prod --dart-define=FLAVOR=prod
```

## 注意事項
- 各環境のFirebaseプロジェクトは別々に作成してください
- google-services.jsonとGoogleService-Info.plistは各環境ごとに配置してください
- アプリIDも環境ごとに変更してください（例：com.example.minq.dev）
