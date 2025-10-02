# Git Hooks

このディレクトリには、コミット前に自動実行されるGit Hooksが含まれています。

## セットアップ

```bash
# Windowsの場合
sh .githooks/setup.sh

# または手動でコピー
copy .githooks\pre-commit .git\hooks\pre-commit
```

## Pre-commit Hook

コミット前に以下のチェックを実行します:

1. **コードフォーマット**: `dart format`でコードスタイルをチェック
2. **静的解析**: `flutter analyze`でコードの問題を検出
3. **未使用ファイル**: 未使用のファイルを検出（警告のみ）
4. **テスト**: `flutter test`で全テストを実行

## フックをスキップする

緊急時やWIP（Work In Progress）コミットの場合、フックをスキップできます:

```bash
git commit --no-verify -m "WIP: 作業中"
```

## トラブルシューティング

### Windowsでフックが実行されない

Git BashまたはWSLを使用してください。

### フックの実行権限エラー

```bash
chmod +x .git/hooks/pre-commit
```

### フックを無効化したい

```bash
rm .git/hooks/pre-commit
```
