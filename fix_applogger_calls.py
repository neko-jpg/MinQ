import os
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    pattern = re.compile(r'AppLogger\(\)\.[a-z]+\s*\(')

    new_content = []
    last_pos = 0

    matches = list(pattern.finditer(content))

    if not matches:
        return

    for match in matches:
        # Append text before match
        new_content.append(content[last_pos:match.end()])

        # Scan forward to find closing paren
        depth = 1
        pos = match.end()
        while pos < len(content) and depth > 0:
            if content[pos] == '(':
                depth += 1
            elif content[pos] == ')':
                depth -= 1
            pos += 1

        if depth > 0:
            # Unbalanced parens (EOF reached), skip fix for this one or break
            new_content.append(content[match.end():pos])
            last_pos = pos
            continue

        # The args string is content[match.end():pos-1]
        args_str = content[match.end():pos-1]

        fixed_args = args_str
        fixed_args = re.sub(r',\s*error:\s*', ', ', fixed_args)
        fixed_args = re.sub(r',\s*stackTrace:\s*', ', ', fixed_args)

        new_content.append(fixed_args)
        new_content.append(')')

        last_pos = pos

    new_content.append(content[last_pos:])

    result = "".join(new_content)

    if result != content:
        print(f"Fixed {filepath}")
        with open(filepath, 'w') as f:
            f.write(result)

def main():
    for dirpath, _, filenames in os.walk('lib'):
        for f in filenames:
            if f.endswith('.dart'):
                fix_file(os.path.join(dirpath, f))

if __name__ == '__main__':
    main()
