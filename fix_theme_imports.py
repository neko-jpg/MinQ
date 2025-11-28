import os

def fix_imports():
    with open('analysis_final_2.txt', 'r') as f:
        issues = f.readlines()

    files_needing_import = set()

    for line in issues:
        if "Undefined class 'MinqTheme'" in line:
            parts = line.split(' • ')
            if len(parts) >= 3:
                filepath = parts[2].split(':')[0]
                files_needing_import.add(filepath)

    for filepath in files_needing_import:
        if not os.path.exists(filepath):
            continue

        with open(filepath, 'r') as f:
            content = f.read()

        if "package:minq/presentation/theme/minq_theme.dart" in content:
            continue

        # Add import
        lines = content.splitlines()
        last_import = -1
        for i, line in enumerate(lines):
            if line.startswith('import '):
                last_import = i

        if last_import != -1:
            lines.insert(last_import + 1, "import 'package:minq/presentation/theme/minq_theme.dart';")
        else:
            lines.insert(0, "import 'package:minq/presentation/theme/minq_theme.dart';")

        with open(filepath, 'w') as f:
            f.write('\n'.join(lines) + '\n')
        print(f"Added theme import to {filepath}")

if __name__ == '__main__':
    fix_imports()
