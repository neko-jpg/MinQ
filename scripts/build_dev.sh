#!/bin/bash

# Development環境でビルド

echo "🔨 Building for Development environment..."

flutter build apk \
  --dart-define=ENV=development \
  --dart-define=DEBUG=true \
  --dart-define=ANALYTICS_ENABLED=false \
  --dart-define=CRASHLYTICS_ENABLED=false \
  --dart-define=LOG_LEVEL=debug \
  --dart-define=SHOW_DEBUG_MENU=true \
  --flavor dev \
  --target lib/main.dart

echo "✅ Development build completed!"
