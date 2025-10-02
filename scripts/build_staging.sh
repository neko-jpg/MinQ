#!/bin/bash

# Staging環境でビルド

echo "🔨 Building for Staging environment..."

flutter build apk \
  --dart-define=ENV=staging \
  --dart-define=DEBUG=false \
  --dart-define=ANALYTICS_ENABLED=true \
  --dart-define=CRASHLYTICS_ENABLED=true \
  --dart-define=LOG_LEVEL=info \
  --flavor staging \
  --target lib/main.dart

echo "✅ Staging build completed!"
