import yaml

def generate_fix_script():
    try:
        with open('pubspec.lock', 'r') as f:
            lock = yaml.safe_load(f)
    except FileNotFoundError:
        print("pubspec.lock not found!")
        return

    packages = lock.get('packages', {})

    with open('fix_deps.sh', 'w') as f:
        f.write("#!/bin/bash\n")
        for pkg, info in packages.items():
            version = info['version']
            # Escape dots in version for sed? No, replacement string doesn't need escape.
            # But we are replacing 'any'.
            # Pattern: leading whitespace, package name, colon, whitespace, 'any', end of line (optional comment?)
            # Simplified: just replace "  package: any" with "  package: ^version"
            # Note: ^version to allow minor updates, or just version to pin exactly?
            # User wants stability, so ^version is standard, but exact pinning is safer for "cleanup".
            # Let's use ^version as it's standard practice.

            # Use sed to replace lines.
            # We use a strict pattern to avoid partial matches.
            # ^  name: any$
            # But wait, there might be comments or trailing spaces.
            # So: ^  name: any

            cmd = f"sed -i 's/^  {pkg}: any/  {pkg}: ^{version}/' pubspec.yaml\n"
            f.write(cmd)

    print("Generated fix_deps.sh")

if __name__ == '__main__':
    generate_fix_script()
