# fix_pubspec.py
# 目的:
# - pubspec.yaml を安全にバックアップ
# - Top-level の重複 'dependencies:' を除去し、最初の dependencies に統合
# - 最初の dependencies にある isar / isar_flutter_libs のバージョンを ^4.0.0-dev.14 に矯正
# - dev_dependencies を重複キーなく再構成し、以下を強制:
#     build_runner: ^2.4.13
#     isar_generator: ^4.0.0-dev.14
#     json_serializable: ^6.11.1
#   （flutter_test / integration_test のネストは保持）
# - それ以外はできる限り元の順序と内容を維持

import re
from pathlib import Path
import shutil

ROOT = Path(".")
SRC = ROOT / "pubspec.yaml"
BAK = ROOT / "pubspec.yaml.bak"

if not SRC.exists():
    raise SystemExit("pubspec.yaml が見つかりません。プロジェクト直下で実行してください。")

# バックアップ
shutil.copyfile(SRC, BAK)

text = SRC.read_text(encoding="utf-8", errors="strict")
lines = text.splitlines(keepends=True)

# ===== ヘルパ: トップレベルセクションに分割 =====
sections = []  # List[ (name(str)|None, [lines]) ]
current_name = None
current_buf = []

top_key_re = re.compile(r'^[A-Za-z_][\w-]*:\s*(#.*)?\r?\n?$')  # 先頭にインデント無し + key:

def flush():
    nonlocal_var = locals()
    if current_buf:
        sections.append((current_name, current_buf.copy()))

for ln in lines:
    if not ln.startswith((" ", "\t")) and top_key_re.match(ln):
        # 新しいトップレベルキー開始
        if current_buf:
            sections.append((current_name, current_buf.copy()))
            current_buf.clear()
        current_name = ln.split(":")[0].strip()
        current_buf.append(ln)
    else:
        current_buf.append(ln)

if current_buf:
    sections.append((current_name, current_buf.copy()))

# ===== dependencies の統合・矯正 =====
new_sections = []
dependencies_seen = False

def fix_dependencies_block(block_lines):
    # block_lines[0] は 'dependencies:\n' のはず
    out = []
    found_isar = False
    found_isar_libs = False
    for i, ln in enumerate(block_lines):
        if i == 0:
            out.append(ln)
            continue
        # isar: any → isar: ^4.0.0-dev.14
        if re.match(r'^\s+isar\s*:\s*', ln):
            out.append(re.sub(r':\s*.*$', ': ^4.0.0-dev.14\n', ln))
            found_isar = True
        # isar_flutter_libs: any → isar_flutter_libs: ^4.0.0-dev.14
        elif re.match(r'^\s+isar_flutter_libs\s*:\s*', ln):
            out.append(re.sub(r':\s*.*$', ': ^4.0.0-dev.14\n', ln))
            found_isar_libs = True
        else:
            out.append(ln)
    # もし dependencies に isar/isar_flutter_libs がなければ末尾に追加
    if not found_isar:
        out.append("  isar: ^4.0.0-dev.14\n")
    if not found_isar_libs:
        out.append("  isar_flutter_libs: ^4.0.0-dev.14\n")
    return out

for name, block in sections:
    if name == "dependencies":
        if not dependencies_seen:
            new_sections.append((name, fix_dependencies_block(block)))
            dependencies_seen = True
        else:
            # 2個目以降の dependencies は破棄（統合）
            continue
    else:
        new_sections.append((name, block))

sections = new_sections

# ===== dev_dependencies の重複キー解消＆バージョン矯正 =====
def rebuild_dev_deps(block_lines):
    # dev_dependencies ブロックを解析して「2スペースインデントのエントリ単位」に切り分ける
    # ネスト（例: flutter_test: / integration_test:）は配下行をそのまま保持
    entries = []  # List[(key, [lines])]
    i = 0
    # 先頭行は 'dev_dependencies:' のはず
    header = block_lines[0]
    i = 1

    def is_level2_key(s):
        return s.startswith("  ") and (not s.startswith("   ")) and re.match(r'^\s{2}[^\s#][^:]*:\s*(#.*)?\r?\n?$', s)

    while i < len(block_lines):
        ln = block_lines[i]
        if is_level2_key(ln):
            key = ln.strip().rstrip(":")
            sub = [ln]
            i += 1
            # 配下（3スペース以上の行 or 空行やコメント含む）を取り込む
            while i < len(block_lines):
                nxt = block_lines[i]
                if is_level2_key(nxt):
                    break
                # 次のトップレベル（インデント無し）までが dev_dependencies のはずなので
                sub.append(nxt)
                i += 1
            entries.append((key, sub))
        else:
            # dev_dependencies に直接ぶら下がるコメント/空行など（保持）
            entries.append((None, [ln]))
            i += 1

    # 既存エントリを辞書化（同じ key は最初の出現を優先、あとで上書き）
    order = []
    by_key = {}
    passthrough_chunks = []  # key=None の行をそのまま

    for k, chunk in entries:
        if k is None:
            passthrough_chunks.append(chunk)
        else:
            if k not in by_key:
                order.append(k)
            by_key[k] = chunk  # 後ろの定義で上書き（重複解消）

    # ここで望ましいバージョンを強制
    def make_scalar_line(k, v):
        return [f"  {k}: {v}\n"]

    # build_runner / isar_generator / json_serializable は強制値
    by_key["build_runner"] = make_scalar_line("build_runner", "^2.4.13")
    by_key["isar_generator"] = make_scalar_line("isar_generator", "^4.0.0-dev.14")
    by_key["json_serializable"] = make_scalar_line("json_serializable", "^6.11.1")

    # order に無ければ追加（新規キー）
    for k in ["build_runner", "isar_generator", "json_serializable"]:
        if k not in order:
            order.append(k)

    # flutter_test / integration_test がネスト持ちならそのまま残す
    # その他のキー（flutter_lints など）は既存 chunk を尊重

    # 出力再構築
    out = [header]
    # まず key を順序で吐く
    for k in order:
        out.extend(by_key[k])
    # 次に key=None の素行（コメント等）を最後にまとめて載せる
    for chunk in passthrough_chunks:
        out.extend(chunk)
    return out

final_sections = []
for name, block in sections:
    if name == "dev_dependencies":
        final_sections.append((name, rebuild_dev_deps(block)))
    else:
        final_sections.append((name, block))

# ===== 出力 =====
result = "".join("".join(block) for _, block in final_sections)
SRC.write_text(result, encoding="utf-8")

print("[OK] pubspec.yaml を修正しました。バックアップ: pubspec.yaml.bak")
print("    - dependencies: isar / isar_flutter_libs → ^4.0.0-dev.14")
print("    - dev_dependencies: build_runner / isar_generator / json_serializable を整合")
