# Error Reduction Baseline

**Date**: 2025-10-04
**Total Issues**: 736

## Breakdown by Severity

- **Errors**: 291
- **Warnings**: 25  
- **Info**: 420

## Major Error Categories

### 1. Deprecated API Usage (High Volume)
- `withOpacity` → needs migration to `.withValues()` (~150+ instances)
- `onPopInvoked` → needs migration to `onPopInvokedWithResult`
- `RawKeyEvent` APIs → needs migration to `KeyEvent`
- Color properties (`.red`, `.green`, `.blue`) → needs migration to `.r`, `.g`, `.b`
- `Share.shareXFiles` → needs migration to `SharePlus.instance.share()`

### 2. Undefined References (High Priority)
- `MinqTheme` missing properties: `typography`, `primary`, `success`, `error`, `lg`, `md`, `sm`, `xs`, `xl`, `xxs`, `full`
- `Spacing` class undefined
- `FocusThemeData` class undefined
- `Icons.database_outlined` undefined
- `BuildContext.tokens` undefined
- `networkStatusProvider` undefined

### 3. Type Errors
- `Object` → `String` conversions in referral_service.dart
- `num` → `double` conversions in quest_recommendation_service.dart
- `ProofType` → `String` conversions in today_logs_screen.dart
- Nullable value safety issues

### 4. Dependency Issues
- `miinq_integrations` package doesn't exist
- `riverpod` not declared in dependencies
- `test` package import issues

### 5. BuildContext Async Gaps (~50+ instances)
- Missing `mounted` checks after async operations

### 6. Unused Code
- Unused local variables
- Unused fields
- Unused methods
- Dead code blocks

## Test Failures
- Compilation errors in test files
- Mock stub issues (MissingStubError)
- Type mismatches in tests

## Next Steps
Follow the phased approach in tasks.md to systematically reduce these issues to 0.
