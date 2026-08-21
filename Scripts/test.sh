#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen is required. Install: brew install xcodegen" >&2
  exit 1
fi

NAME="$(awk '/^name:/{print $2; exit}' project.yml)"
if [[ -z "$NAME" ]]; then
  echo "Could not read project name from project.yml" >&2
  exit 1
fi

xcodegen generate

ONLY_TESTING="${NAME}Tests"
if [[ "${1:-}" == "--ui" ]]; then
  ONLY_TESTING="${NAME}UITests"
fi

xcodebuild \
  -project "${NAME}.xcodeproj" \
  -scheme "${NAME}" \
  -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath "$ROOT/.build/DerivedData" \
  -only-testing:"${ONLY_TESTING}" \
  test
