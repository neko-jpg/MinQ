# 動画チュートリアル生成パイプライン

MinQ のオンボーディングや機能紹介用の動画チュートリアルを、Lottie アニメーションと音声合成用スクリプトに分解して出力するスクリプトを追加しました。外部サービスと連携して最終的な動画を組み立てる際のテンプレートとして利用できます。

## スクリプトの概要

```
dart tool/tutorial_pipeline/generate_tutorial.dart <input.json> [output_dir]
```

- `input.json` : チュートリアルの構成を定義する JSON ファイル。
- `output_dir` : 生成されたファイルを配置するディレクトリ。省略時は `build/tutorial/`。

### 入力 JSON 形式

```json
{
  "title": "MinQ 使い方入門",
  "steps": [
    {
      "title": "ホーム画面",
      "caption": "今日のミニクエストを3タップで確認できます。",
      "lottieSegment": "scenes/home_overview.json",
      "durationSeconds": 6
    }
  ]
}
```

- `title` : チュートリアル全体のタイトル（省略可）。
- `steps` : 各シーンの配列。`caption` は必須です。
- `lottieSegment` : 既存の Lottie アセットや After Effects から書き出したセグメント名。
- `durationSeconds` : 各シーンの再生時間。指定がない場合は 5 秒になります。

### 出力

スクリプトを実行すると以下の 3 ファイルを生成します。

| ファイル名 | 説明 |
|------------|------|
| `tutorial_storyboard.json` | Lottie 合成ツールに読み込ませるためのシーン定義。|
| `voiceover_script.txt` | TTS エンジンに渡すナレーション原稿。|
| `metadata.json` | ステップ数や推定尺などのメタ情報。|

生成されたファイルを Lottie エディタで読み込み、TTS の音声と合わせることで数分で新しいチュートリアルを更新できます。

## ワークフロー提案

1. `input.json` を Git で管理し、プロダクトチームがステップを更新。
2. CI 上でスクリプトを実行し、成果物をストレージへアップロード。
3. Lottie コンポーザーで `tutorial_storyboard.json` を取り込み、TTS 音声とミックス。
4. 完成した mp4 をアプリのオンボーディングやサポートページに配置。

この仕組みにより、仕様変更時でもコード修正なしでチュートリアルを差し替えられます。
