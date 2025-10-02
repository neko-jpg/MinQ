# Firestore Security Rules Unit Tests

Firestoreセキュリティルールのユニットテストです。

## セットアップ

```bash
cd firestore_rules_test
npm install
```

## Firestore Emulatorの起動

```bash
firebase emulators:start --only firestore
```

## テストの実行

```bash
npm test
```

## ウォッチモード

```bash
npm run test:watch
```

## テストカバレッジ

以下のシナリオをテストしています:

### Users Collection
- ✅ ユーザーは自分のプロフィールを読み取れる
- ✅ ユーザーは他人のプロフィールを読み取れない
- ✅ ユーザーは自分のプロフィールを更新できる
- ✅ 未認証ユーザーはプロフィールを読み取れない

### Quests Collection
- ✅ ユーザーは自分のクエストを作成できる
- ✅ ユーザーは自分のクエストを読み取れる
- ✅ ユーザーは他人のクエストを読み取れない
- ✅ ユーザーは自分のクエストを更新できる
- ✅ ユーザーは自分のクエストを削除できる

### Quest Logs Collection
- ✅ ユーザーは自分のログを作成できる
- ✅ ユーザーは自分のログを読み取れる
- ✅ ユーザーは自分のログを削除できる

### Pairs Collection
- ✅ ペアメンバーはペア情報を読み取れる
- ✅ 非メンバーはペア情報を読み取れない

## トラブルシューティング

### Emulatorに接続できない

Firestore Emulatorが起動しているか確認してください:

```bash
firebase emulators:start --only firestore
```

### ポートが使用中

`firebase.json`でポートを変更してください:

```json
{
  "emulators": {
    "firestore": {
      "port": 8080
    }
  }
}
```
