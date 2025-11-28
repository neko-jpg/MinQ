import os
import re

def fix_files(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            if not filename.endswith('.dart'):
                continue

            filepath = os.path.join(dirpath, filename)
            with open(filepath, 'r') as f:
                content = f.read()

            # Fix withOpacity -> withValues
            # Pattern: .withOpacity(value) -> .withValues(alpha: value)
            new_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)

            if content != new_content:
                print(f"Fixed withOpacity in {filepath}")
                with open(filepath, 'w') as f:
                    f.write(new_content)

if __name__ == '__main__':
    fix_files('lib')
