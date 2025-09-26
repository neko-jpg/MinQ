# CI/CD パイプライン

GitHub Actions を用いて以下の自動化を構築しました。

## ワークフロー構成

- `lint-test` ジョブ
  - Flutter 3.22 (stable) をセットアップ
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
- `quality-gates` ジョブ
  - `dart run tool/dep_guard.dart`
  - `dart run tool/tls_guard.dart`

`lint-test` が失敗した場合は `quality-gates` は実行されません。成果物アップロードやストア配信はリリースブランチで別途 Codemagic を使用します。

## Secrets / キャッシュ

- `FLUTTER_VERSION`: stable
- `CACHE_KEY`: `pubspec.lock` のハッシュで pub キャッシュを共有
- Firebase/証明書関連の Secrets は別途署名戦略に従い設定

Pull Request 作成時には自動でワークフローが走り、全ジョブが成功した場合のみマージ可能とします。
