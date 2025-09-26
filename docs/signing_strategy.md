# アプリ署名ポリシー

## Android Keystore

- Play Console で App Signing by Google Play を有効化
- 本番 keystore (`minq-release.jks`) は 1Password の「Mobile Signing」ボルトで管理
- バックアップ: 物理セーフ（耐火）に暗号化 USB を保管し、年 2 回整合性チェック
- CI ではエンコードした keystore を GitHub Actions の Encrypted Secrets（`ANDROID_KEYSTORE_BASE64`）として登録
- `gradle.properties` 用のパスワード (`ANDROID_KEY_ALIAS` / `ANDROID_KEY_PASSWORD` / `ANDROID_STORE_PASSWORD`) も Secrets 管理

## iOS 証明書

- Apple Developer アカウントの `App Store Connect` で Distribution/Development 証明書を発行
- `fastlane match` でリポジトリ管理（Private Git、アクセス権限はモバイルチームのみ）
- Provisioning Profile は CI 実行時に自動取得し、`MATCH_PASSWORD` を Secrets で管理

## 運用フロー

1. 鍵の更新は有効期限 90 日前にリマインダーを設定し、更新後は全メンバーに告知
2. 新メンバーの端末登録は Tech Lead 承認後、証明書配布リストに追加
3. 鍵／証明書の持ち出しを禁止し、PC 紛失時は直ちに Secrets ローテーションを行う

これらにより `task.md` の「署名: Android Keystore保管、iOS 証明書/プロビジョニング整備」を満たします。
