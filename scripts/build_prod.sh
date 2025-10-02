#!/bin/bash

# Production環境でビルド

echo "🔨 Building for Production environment..."

# Git情報を取得
GIT_COMMIT=$(git rev-parse --short HEAD)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

flutter build apk \
  --dart-define=ENV=production \
  --dart-define=DEBUG=false \
  --dart-define=ANALYTICS_ENABLED=true \
  --dart-define=CRASHLYTICS_ENABLED=true \
  --dart-define=LOG_LEVEL=warning \
  --dart-define=GIT_COMMIT=$GIT_COMMIT \
  --dart-define=GIT_BRANCH=$GIT_BRANCH \
  --dart-define=BUILD_DATE=$BUILD_DATE \
  --release \
  --flavor prod \
  --target lib/main.dart

echo "✅ Production build completed!"
echo "Git Commit: $GIT_COMMIT"
echo "Git Branch: $GIT_BRANCH"
echo "Build Date: $BUILD_DATE"
