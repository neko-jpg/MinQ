# CI文字化け検知システム (F011対応)
# ARBファイルの文字化けを検知してビルドを失敗させる

param(
    [string]$ArbDir = "lib/l10n"
)

Write-Host "🔍 Checking ARB files for mojibake (character corruption)..." -ForegroundColor Cyan

# 文字化け文字のパターン
$MojibakePatterns = @(
    "\\uFFFD",     # Unicode replacement character
    "\\x81",       # Invalid UTF-8 sequence
    "\\x80",       # Invalid UTF-8 sequence
    "\\xEF\\xBF\\xBD",  # UTF-8 replacement character
    "�",           # Replacement character
    "E,",          # Common mojibake pattern
    "E��",         # Common mojibake pattern
    "ぁE",          # Common mojibake pattern
    "めE"           # Common mojibake pattern
)

$FoundIssues = $false

if (-not (Test-Path $ArbDir)) {
    Write-Host "❌ ARB directory not found: $ArbDir" -ForegroundColor Red
    exit 1
}

# Check each ARB file
$ArbFiles = Get-ChildItem -Path $ArbDir -Filter "*.arb"

foreach ($ArbFile in $ArbFiles) {
    Write-Host "📄 Checking $($ArbFile.Name)..." -ForegroundColor Yellow
    
    $Content = Get-Content -Path $ArbFile.FullName -Raw -Encoding UTF8
    
    # Check for mojibake patterns
    foreach ($Pattern in $MojibakePatterns) {
        if ($Content -match [regex]::Escape($Pattern)) {
            Write-Host "❌ Found mojibake pattern '$Pattern' in $($ArbFile.Name)" -ForegroundColor Red
            $FoundIssues = $true
        }
    }
    
    # Check for invalid JSON
    try {
        $JsonContent = $Content | ConvertFrom-Json
    }
    catch {
        Write-Host "❌ Invalid JSON format in $($ArbFile.Name): $($_.Exception.Message)" -ForegroundColor Red
        $FoundIssues = $true
        continue
    }
    
    # Check for missing required keys
    $RequiredKeys = @("@@locale")
    foreach ($Key in $RequiredKeys) {
        if (-not $JsonContent.PSObject.Properties.Name -contains $Key) {
            Write-Host "⚠️  Missing required key '$Key' in $($ArbFile.Name)" -ForegroundColor Yellow
        }
    }
}

# Check for missing translations
Write-Host "🔍 Checking for missing translations..." -ForegroundColor Cyan
$ReferenceFile = Join-Path $ArbDir "app_en.arb"

if (Test-Path $ReferenceFile) {
    try {
        $ReferenceContent = Get-Content -Path $ReferenceFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $ReferenceKeys = $ReferenceContent.PSObject.Properties.Name | Where-Object { -not $_.StartsWith("@@") } | Sort-Object
        
        foreach ($ArbFile in $ArbFiles) {
            if ($ArbFile.FullName -eq $ReferenceFile) {
                continue
            }
            
            Write-Host "📄 Checking translations in $($ArbFile.Name)..." -ForegroundColor Yellow
            
            try {
                $FileContent = Get-Content -Path $ArbFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
                $FileKeys = $FileContent.PSObject.Properties.Name | Where-Object { -not $_.StartsWith("@@") } | Sort-Object
                
                # Find missing keys
                $MissingKeys = $ReferenceKeys | Where-Object { $_ -notin $FileKeys }
                if ($MissingKeys.Count -gt 0) {
                    Write-Host "❌ Missing translations in $($ArbFile.Name):" -ForegroundColor Red
                    $MissingKeys | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
                    $FoundIssues = $true
                }
                
                # Find extra keys
                $ExtraKeys = $FileKeys | Where-Object { $_ -notin $ReferenceKeys }
                if ($ExtraKeys.Count -gt 0) {
                    Write-Host "⚠️  Extra keys in $($ArbFile.Name):" -ForegroundColor Yellow
                    $ExtraKeys | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
                }
            }
            catch {
                Write-Host "❌ Failed to parse $($ArbFile.Name): $($_.Exception.Message)" -ForegroundColor Red
                $FoundIssues = $true
            }
        }
    }
    catch {
        Write-Host "❌ Failed to parse reference file ${ReferenceFile}: $($_.Exception.Message)" -ForegroundColor Red
        $FoundIssues = $true
    }
}

Write-Host ""
if ($FoundIssues) {
    Write-Host "❌ ARB validation failed! Please fix the issues above." -ForegroundColor Red
    Write-Host "💡 Tips:" -ForegroundColor Cyan
    Write-Host "  - Ensure all ARB files are UTF-8 encoded" -ForegroundColor White
    Write-Host "  - Remove any corrupted characters (mojibake)" -ForegroundColor White
    Write-Host "  - Validate JSON syntax" -ForegroundColor White
    Write-Host "  - Add missing translations" -ForegroundColor White
    Write-Host "  - Remove unused localization keys" -ForegroundColor White
    exit 1
}
else {
    Write-Host "✅ All ARB files passed validation!" -ForegroundColor Green
}