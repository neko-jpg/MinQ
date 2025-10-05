# AGENTS.md (Flutter)

> 本リポジトリでAIエージェント（以下 Agent）が**Flutterコード**を変更・生成するときの**行動規範**と**品質ゲート**。

## 0) 最重要ルール

1. **`task.md`の厳守（スコープ逸脱禁止）**

   * 実装・変更は `task.md` の「目的 / スコープ / 非目標 / 受け入れ条件」に**完全一致**させる。
   * 曖昧さや矛盾がある場合は `ASSUMPTIONS.md` を新規作成し**前提を明文化**した上で、**最小差分**のみ実装。勝手な拡張は不可。
   * 大規模な付随変更は `NEXT_TASKS.md` に切り出す。

2. **提出前の品質ゲート通過は必須**

   * **自動テスト（unit / widget / integration）**がすべて**グリーン**であること。テストの厚みはピラミッドの推奨に従う（下層＝単体・ウィジェットを厚く、統合は要所）。 ([docs.flutter.dev][1])
   * **静的解析（`dart analyze`）**で**エラー・警告ゼロ**。必要に応じ `--fatal-infos` を使う。 ([dart.dev][2])
   * **フォーマット差分なし**（`dart format --set-exit-if-changed .`）。
   * 変更UIは**ゴールデンテスト**で主要状態を担保（差分が出たら意図をPRに明記）。`--update-goldens` 運用を徹底。 ([Flutter API Docs][3])

---

## 1) ワークフロー

1. **読解 & 計画**

   * `task.md` から**受け入れ条件(AC)**を抜き出し、`PLAN.md` に**手順・影響範囲・テスト観点**を箇条書き化（測定可能に）。 ([docs.flutter.dev][1])

2. **ブランチ/コミット**

   * ブランチ: `feat|fix|chore/<scope>-<topic>`。
   * コミットは小さく一目的。PRは**小さく**保ち、自己レビュー後に作成。

3. **実装ガイド（Flutter前提）**

   * 既存の設計/テーマ/アクセシビリティ規約に**準拠**。
   * **テスト先行**：ロジックは unit、UIは widget、E2Eは `integration_test` を使う。 ([docs.flutter.dev][4])
   * 画像・文言・生成物などは**差分が不安定にならない工夫**（フォント固定、テキストスケールをテストで指定）。 ([Flutter API Docs][3])

4. **ドキュメント**

   * 公開APIや挙動が変わるときは `README` / `docs/` / `CHANGELOG.md` を更新。
   * 破壊的変更は PR/CHANGELOG に**明記**。

---

## 2) ローカル検査コマンド（必ず順守）

```bash
# 依存取得
flutter pub get

# 整形（差分があれば失敗）
dart format --set-exit-if-changed .

# 静的解析（警告も失敗扱いにする場合）
dart analyze --fatal-infos

# 単体・ウィジェットテスト（+ カバレッジ）
flutter test --coverage

# ゴールデン更新（意図的な見た目変更時のみ実行）
flutter test --update-goldens

# 統合テスト（デバイス or エミュレータ必須）
flutter test integration_test -d <deviceId>
```

* テスト層の定義：

  * **Unit**＝純Dart（副作用をMock）。**Widget**＝`flutter_test` でUIと相互作用。**Integration**＝`integration_test` で実機/エミュ上の挙動検証。 ([docs.flutter.dev][1])
* カバレッジは `--coverage` で `coverage/lcov.info` を生成。必要に応じて `lcov` で**生成ファイルを除外**（`*.g.dart`, `*.freezed.dart` など）してHTML化。 ([GitHub][5])

---

## 3) ゴールデンテスト規約

* 主要画面/状態は**ゴールデンで固定**。
* 実装：`expectLater(..., matchesGoldenFile('goldens/<name>.png'))` を使用。フォント・アイコン差異を避けるため**フォントロードを固定**する。更新は `--update-goldens`。 ([Flutter API Docs][3])
* 代表デバイスの**画面サイズ**と**ダーク/ライト**の組を最低1セットずつ用意。
* 不要なアニメは `pumpAndSettle()` やテスト用フラグで**停止**。

---

## 4) リンティング/静的解析

* 既定は `flutter_lints` を採用：`analysis_options.yaml` に
  `include: package:flutter_lints/flutter.yaml`。 ([Dart packages][6])
* さらに厳しくする場合は `very_good_analysis` を利用：
  `include: package:very_good_analysis/analysis_options.yaml`。 ([Dart packages][7])
* 実行は `dart analyze`（必要に応じて `--fatal-infos`）。 ([dart.dev][2])
* メトリクス/アンチパターン検出に `dart_code_metrics` を追加して CI 失敗条件にして良い。 ([GitHub][8])

---

## 5) PR 作成チェックリスト（Pre-submit）

> すべて ✅ にならない限り **PRをReadyにしない**。（ただし、環境上実行できないコマンドは除く）

* [ ] **`task.md` のACを満たした**（`PLAN.md` と一致）。 ([docs.flutter.dev][1])
* [ ] **Unit/Widget/Integration** がグリーン。重要UIは**ゴールデン差分なし**。 ([docs.flutter.dev][1])
* [ ] **`dart format` 差分なし**、**`dart analyze`エラー/警告ゼロ**。 ([dart.dev][2])
* [ ] カバレッジ生成済み（必要なら `lcov` で生成ファイル除外＆HTML化）。 ([GitHub][5])
* [ ] ドキュメント/スクショ/リスク/検証手順を PR に記載。

---

## 6) GitHub Actions（参考ワークフロー）

> CIは**全プラットフォームで動作**する Flutter Action を利用。テスト・解析・カバレッジ・ゴールデンを自動化。

```yaml
name: ci
on:
  pull_request:
  push:
    branches: [ main ]

jobs:
  flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter --version
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: dart analyze --fatal-infos
      - run: flutter test --coverage
      # 生成ファイル除外とHTML化（lcov がある環境のみ）
      - run: |
          sudo apt-get update && sudo apt-get install -y lcov
          lcov --remove coverage/lcov.info 'lib/**.g.dart' 'lib/**.freezed.dart' -o coverage/new_lcov.info --ignore-errors unused
          genhtml coverage/new_lcov.info -o coverage/html
      # ゴールデン差分チェック（意図的変更時は別ジョブで --update-goldens を運用）
```

* Flutterセットアップとキャッシュは `subosito/flutter-action` を使用。 ([GitHub][9])

---

## 7) よく使うテスト雛形

* **Widget Test**：`testWidgets(...)`, `tester.pumpWidget(...)`, `find.text/byType`, `expect(...)`。 ([docs.flutter.dev][4])
* **Integration Test**：`integration_test/` 配下に `*_test.dart`、`flutter test integration_test -d <device>`。 ([docs.flutter.dev][10])
* **Golden**：`expectLater(finder, matchesGoldenFile(...))`、更新は `--update-goldens`。フォント差異に注意。 ([Flutter API Docs][3])

---

## 8) 失敗時のリカバリ

* CI失敗＝まず**最小再現**。テストの安定化（フォント/時差/アニメ停止）→再実行。
* スコープ超過が判明＝PRを**クローズ**し、`task.md` を分割して出直す。
* ゴールデン差分が意図的なら PR 説明に**理由とスクショ**を添付。

---

### 参考出典

* Flutter 公式：**テストの全体像（unit/widget/integration）**と方針。 ([docs.flutter.dev][1])
* Flutter 公式：**Widget テスト入門**（`flutter_test` の使い方）。 ([docs.flutter.dev][4])
* Flutter 公式：**Integration Test**（`integration_test` の設定と実行）。 ([docs.flutter.dev][10])
* Dart 公式：**`dart analyze`** の使い方と失敗条件。 ([dart.dev][2])
* Flutter 公式/パッケージ：**`flutter_lints`** の導入ガイド。 ([Dart packages][6])
* Very Good Ventures：**`very_good_analysis`**（厳しめLintセット）。 ([Dart packages][7])
* Flutter API：**`matchesGoldenFile` と `--update-goldens`**（フォント差異の注意点含む）。 ([Flutter API Docs][3])
* Flutter wiki：**Golden運用の基本**。 ([GitHub][11])
* GitHub Actions：**Flutter環境セットアップ action**。 ([GitHub][9])
* カバレッジ：`flutter test --coverage` と lcov を使った**生成ファイルの除外**。 ([GitHub][5])

---


[1]: https://docs.flutter.dev/testing/overview?utm_source=chatgpt.com "Testing Flutter apps | Flutter"
[2]: https://dart.dev/tools/dart-analyze?utm_source=chatgpt.com "dart analyze"
[3]: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html?utm_source=chatgpt.com "matchesGoldenFile function - flutter_test library - Dart API"
[4]: https://docs.flutter.dev/cookbook/testing/widget/introduction?utm_source=chatgpt.com "Introduction | Flutter"
[5]: https://github.com/flutter/flutter/wiki/Test-coverage-for-package%3Aflutter/89e1b0a20b1567472afaac552a41a180652400f1?utm_source=chatgpt.com "Test coverage for package:flutter · flutter/flutter Wiki · GitHub"
[6]: https://pub.dev/packages/flutter_lints?utm_source=chatgpt.com "flutter_lints | Dart package"
[7]: https://pub.dev/packages/very_good_analysis?utm_source=chatgpt.com "very_good_analysis | Dart package"
[8]: https://github.com/arlakay/dart_code_metrics?utm_source=chatgpt.com "GitHub - arlakay/dart_code_metrics: Flutter DCM"
[9]: https://github.com/subosito/flutter-action?utm_source=chatgpt.com "GitHub - subosito/flutter-action: Flutter environment for use in GitHub Actions. It works on Linux, Windows, and macOS."
[10]: https://docs.flutter.dev/testing/integration-tests?utm_source=chatgpt.com "Check app functionality with an integration test | Flutter"
[11]: https://github.com/flutter/flutter/wiki/Writing-a-golden-file-test-for-package%3Aflutter/859df8b66ca14c7a1cc428f1d4bc76aa5d4e75e5?utm_source=chatgpt.com "Writing a golden file test for package:flutter · flutter/flutter Wiki · GitHub"
