#!/usr/bin/env bash
set -euo pipefail

MIN_COVERAGE=${1:-75}

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter command not found. Please install Flutter before running coverage." >&2
  exit 127
fi

flutter test --coverage

dart run tool/check_coverage.dart --min "$MIN_COVERAGE"
