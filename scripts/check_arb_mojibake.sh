#!/bin/bash

# CI文字化け検知システム (F011対応)
# ARBファイルの文字化けを検知してビルドを失敗させる

set -e

echo "🔍 Checking ARB files for mojibake (character corruption)..."

# 文字化け文字のパターン
MOJIBAKE_PATTERNS=(
    "\\uFFFD"     # Unicode replacement character
    "\\x81"       # Invalid UTF-8 sequence
    "\\x80"       # Invalid UTF-8 sequence
    "\\xEF\\xBF\\xBD"  # UTF-8 replacement character
    "�"           # Replacement character
    "E,"          # Common mojibake pattern
    "E��"         # Common mojibake pattern
    "ぁE"          # Common mojibake pattern
    "めE"          # Common mojibake pattern
)

ARB_DIR="lib/l10n"
FOUND_ISSUES=false

if [ ! -d "$ARB_DIR" ]; then
    echo "❌ ARB directory not found: $ARB_DIR"
    exit 1
fi

# Check each ARB file
for arb_file in "$ARB_DIR"/*.arb; do
    if [ ! -f "$arb_file" ]; then
        continue
    fi
    
    echo "📄 Checking $(basename "$arb_file")..."
    
    # Check file encoding
    if ! file "$arb_file" | grep -q "UTF-8"; then
        echo "❌ File is not UTF-8 encoded: $arb_file"
        FOUND_ISSUES=true
    fi
    
    # Check for mojibake patterns
    for pattern in "${MOJIBAKE_PATTERNS[@]}"; do
        if grep -q "$pattern" "$arb_file"; then
            echo "❌ Found mojibake pattern '$pattern' in $arb_file"
            grep -n "$pattern" "$arb_file" | head -5
            FOUND_ISSUES=true
        fi
    done
    
    # Check for invalid JSON
    if ! python3 -m json.tool "$arb_file" > /dev/null 2>&1; then
        echo "❌ Invalid JSON format in $arb_file"
        FOUND_ISSUES=true
    fi
    
    # Check for missing required keys
    required_keys=("@@locale")
    for key in "${required_keys[@]}"; do
        if ! grep -q "\"$key\"" "$arb_file"; then
            echo "⚠️  Missing required key '$key' in $arb_file"
        fi
    done
    
    # Check for unused keys (keys not referenced in Dart code)
    echo "🔍 Checking for unused localization keys..."
    while IFS= read -r line; do
        if [[ $line =~ \"([^\"]+)\":[[:space:]]*\"[^\"]*\" ]]; then
            key="${BASH_REMATCH[1]}"
            # Skip metadata keys
            if [[ $key == @@* ]]; then
                continue
            fi
            
            # Check if key is used in Dart files
            if ! grep -r "AppLocalizations\.of(context)\.$key\|context\.l10n\.$key\|l10n\.$key" lib/ --include="*.dart" > /dev/null 2>&1; then
                echo "⚠️  Potentially unused key '$key' in $arb_file"
            fi
        fi
    done < "$arb_file"
done

# Check for missing translations
echo "🔍 Checking for missing translations..."
reference_file="$ARB_DIR/app_en.arb"
if [ -f "$reference_file" ]; then
    # Extract keys from reference file
    reference_keys=$(grep -o '"[^"]*"[[:space:]]*:' "$reference_file" | grep -v '"@@' | sed 's/"//g' | sed 's/[[:space:]]*://' | sort)
    
    for arb_file in "$ARB_DIR"/*.arb; do
        if [ "$arb_file" = "$reference_file" ]; then
            continue
        fi
        
        echo "📄 Checking translations in $(basename "$arb_file")..."
        file_keys=$(grep -o '"[^"]*"[[:space:]]*:' "$arb_file" | grep -v '"@@' | sed 's/"//g' | sed 's/[[:space:]]*://' | sort)
        
        # Find missing keys
        missing_keys=$(comm -23 <(echo "$reference_keys") <(echo "$file_keys"))
        if [ -n "$missing_keys" ]; then
            echo "❌ Missing translations in $(basename "$arb_file"):"
            echo "$missing_keys" | sed 's/^/  - /'
            FOUND_ISSUES=true
        fi
        
        # Find extra keys
        extra_keys=$(comm -13 <(echo "$reference_keys") <(echo "$file_keys"))
        if [ -n "$extra_keys" ]; then
            echo "⚠️  Extra keys in $(basename "$arb_file"):"
            echo "$extra_keys" | sed 's/^/  - /'
        fi
    done
fi

if [ "$FOUND_ISSUES" = true ]; then
    echo ""
    echo "❌ ARB validation failed! Please fix the issues above."
    echo "💡 Tips:"
    echo "  - Ensure all ARB files are UTF-8 encoded"
    echo "  - Remove any corrupted characters (mojibake)"
    echo "  - Validate JSON syntax"
    echo "  - Add missing translations"
    echo "  - Remove unused localization keys"
    exit 1
else
    echo ""
    echo "✅ All ARB files passed validation!"
fi