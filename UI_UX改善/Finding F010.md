Finding F010 — UI文言のL10n欠落

Severity: P3

Area: Copy

Files: .arbファイル全般、複数のUIファイル

Symptom (現象): オフライン関連のメッセージやプログレッシブヒント、エラーメッセージなど多数の文言がハードコードされており、app_en.arbやapp_ja.arbに登録されていない。英語版で日本語がそのまま表示される箇所がある。

Likely Root Cause (推定原因): 開発初期フェーズで機能実装を優先し、翻訳ファイルへの反映が後手に回った。CIによるチェックも存在せず、漏れが発見されにくい状況となっている。

Concrete Fix (修正案):

すべてのユーザー向け文言を洗い出し、.arbファイルにキーを追加する。今回追加するキー例はmicrocopy/strings_ja_en.mdに記載している。

コードベースのハードコーディングを削除し、AppLocalizations.of(context)!.<key>で参照するように変更する。

CIに文字化け検知（\uFFFDや\x81等の不可視文字）と未使用キー検出を追加する。

Tests (テスト): テストLocalization_keys_present_in_arbで、すべての参照キーが.arbに存在することを検証する。日本語と英語の両言語でUIが期待通り表示されるか、ゴールデンテストでも確認する。

Impact/Effort/Confidence: I=3, E=1 day, C=5

Patch (≤30 lines, unified diff if possible):

具体的な実装は大量のコード修正を伴うため省略しますが、以下のようにハードコードされた文字列をAppLocalizationsに置き換えます。

// Before
Text('オフラインモード - 一部機能が制限されています');

// After
Text(AppLocalizations.of(context)!.offlineModeBanner);