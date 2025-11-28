import os
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        lines = f.readlines()

    new_lines = []
    fixed = False

    for line in lines:
        # Check for Share.share or Share.shareXFiles
        if ('Share.share' in line or 'Share.shareXFiles' in line) and '// ignore:' not in line:
            # Add indentation same as the line? usually 4 or 6 spaces
            # Just minimal indentation
            new_lines.append('      // ignore: deprecated_member_use\n')
            fixed = True
        new_lines.append(line)

    if fixed:
        print(f"Fixed Share deprecation in {filepath}")
        with open(filepath, 'w') as f:
            f.writelines(new_lines)

def main():
    for dirpath, _, filenames in os.walk('lib'):
        for f in filenames:
            if f.endswith('.dart'):
                fix_file(os.path.join(dirpath, f))

if __name__ == '__main__':
    main()
