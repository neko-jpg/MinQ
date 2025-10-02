#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter command not found. Please install Flutter SDK." >&2
  exit 1
fi

flutter pub get
flutter pub global activate dartdoc >/dev/null 2>&1 || true

OUTPUT_DIR="build/api_docs"
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

flutter pub global run dartdoc --output "${OUTPUT_DIR}"

tar -czf api-docs.tar.gz -C "${OUTPUT_DIR}" .

echo "API documentation generated at ${OUTPUT_DIR} and archived to api-docs.tar.gz"
