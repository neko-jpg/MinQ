import os

def fix_unused_locals():
    with open('analysis_final.txt', 'r') as f:
        issues = f.readlines()

    file_fixes = {}

    for line in issues:
        if 'unused_local_variable' not in line:
            continue

        parts = line.split(' • ')
        if len(parts) < 4:
            continue

        location = parts[2]
        path_parts = location.split(':')
        filepath = path_parts[0]
        lineno = int(path_parts[1])

        if filepath not in file_fixes:
            file_fixes[filepath] = []
        file_fixes[filepath].append(lineno)

    for filepath, lines in file_fixes.items():
        if not os.path.exists(filepath):
            continue

        with open(filepath, 'r') as f:
            content_lines = f.readlines()

        lines.sort(reverse=True)
        for lineno in lines:
            idx = lineno - 1
            if idx < len(content_lines):
                original = content_lines[idx].rstrip()
                if '// ignore: unused_local_variable' not in original:
                    content_lines[idx] = f"{original} // ignore: unused_local_variable\n"

        with open(filepath, 'w') as f:
            f.writelines(content_lines)

        print(f"Suppressed unused variables in {filepath}")

if __name__ == '__main__':
    fix_unused_locals()
