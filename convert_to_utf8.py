import pathlib

# プロジェクトのパス
target_dir = pathlib.Path(r"パス名をここに入力")

# .dart ファイルを再帰的に探索
for file_path in target_dir.rglob("*.dart"):
    try:
        # Shift_JISで読み込む（文字化け防止のため errors="replace" をつける）
        text = file_path.read_text(encoding="shift_jis", errors="replace")
        # UTF-8で上書き保存
        file_path.write_text(text, encoding="utf-8")
        print(f"[OK] {file_path} を Shift_JIS → UTF-8 に変換しました")
    except Exception as e:
        print(f"[ERROR] {file_path}: {e}")
