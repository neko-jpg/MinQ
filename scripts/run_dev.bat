@echo off
REM Development環境で実行（Windows用）

echo 🚀 Running in Development environment...

flutter run ^
  --dart-define=ENV=development ^
  --dart-define=DEBUG=true ^
  --dart-define=ANALYTICS_ENABLED=false ^
  --dart-define=CRASHLYTICS_ENABLED=false ^
  --dart-define=LOG_LEVEL=debug ^
  --dart-define=SHOW_DEBUG_MENU=true ^
  --flavor dev ^
  --target lib/main.dart

echo ✅ Development run completed!
