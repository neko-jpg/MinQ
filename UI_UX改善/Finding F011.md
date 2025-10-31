Finding F011 — .arbの文字化け検知がない

Severity: P3

Area: Testing

Files: CI設定および.arbファイル

Symptom (現象): .arbファイルにUTF‑8以外の文字や欠損文字（\uFFFD、\x81など）が含まれていても、現在のCIでは検出されずにビルドが通過してしまう。そのためリリース後に文字化けが発覚するリスクがある。

Likely Root Cause (推定原因): L10nの検証工程がCIに組み込まれていない。.arbファイルは手動で編集されることが多く、誤ったエンコーディングが混入しやすい。

Concrete Fix (修正案): CIワークフローにカスタムスクリプトを追加し、.arbファイルを走査してUTF‑8であることを確認する。\uFFFDや\x81、制御文字が含まれている場合はビルドを失敗させる。DartスクリプトやGitHub Actionで簡単に実装可能。例として以下のようなチェックを行う：

#!/usr/bin/env bash
set -e
for f in lib/l10n/*.arb; do
  if grep -P '\\x81|\\uFFFD' "$f"; then
    echo "Mojibake detected in $f" >&2
    exit 1
  fi
done


Tests (テスト): CI上で文字化け文字を含んだ.arbをコミットした際にジョブが失敗するかを確認するテストCI fails on mojibake in arb filesを追加する。

Impact/Effort/Confidence: I=2, E=0.5 days, C=5

Patch (≤30 lines, unified diff if possible):

CI設定ファイルへの追加例：

jobs:
  build:
    steps:
      - name: Check for mojibake in arb files
        run: bash scripts/check_arb_mojibake.sh