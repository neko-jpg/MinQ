import os
import re

def fix_print(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            if not filename.endswith('.dart'):
                continue

            filepath = os.path.join(dirpath, filename)
            with open(filepath, 'r') as f:
                content = f.read()

            if 'print(' not in content:
                continue

            # Check if it's a real print call (e.g. not a string containing "print(")
            # Simple regex: word boundary 'print' followed by optional space and '('
            # We assume it's the function call.

            if not re.search(r'\bprint\s*\(', content):
                continue

            new_content = re.sub(r'\bprint\s*\(', 'debugPrint(', content)

            if new_content != content:
                # Check imports
                if "package:flutter/foundation.dart" not in new_content and \
                   "package:flutter/material.dart" not in new_content and \
                   "package:flutter/widgets.dart" not in new_content and \
                   "package:flutter/cupertino.dart" not in new_content:

                       lines = new_content.splitlines()
                       # Find last import to insert after, or first line
                       last_import_idx = -1
                       for i, line in enumerate(lines):
                           if line.startswith('import '):
                               last_import_idx = i

                       if last_import_idx != -1:
                           lines.insert(last_import_idx + 1, "import 'package:flutter/foundation.dart';")
                       else:
                           lines.insert(0, "import 'package:flutter/foundation.dart';")

                       new_content = '\n'.join(lines) + '\n'

                print(f"Fixed print in {filepath}")
                with open(filepath, 'w') as f:
                    f.write(new_content)

if __name__ == '__main__':
    fix_print('lib')
