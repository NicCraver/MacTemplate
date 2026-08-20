#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ensure_chunui() {
  local sibling
  sibling="$(cd "$ROOT/.." && pwd)/ChunUI"
  if [[ -d "$sibling" ]]; then
    return 0
  fi
  local repo="${CHUNUI_REPO:-https://github.com/liseami/ChunUI.git}"
  echo "ChunUI not found at $sibling; cloning $repo" >&2
  git clone --depth 1 "$repo" "$sibling"
}

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen is required. Install: brew install xcodegen" >&2
  exit 1
fi

NAME="$(awk '/^name:/{print $2; exit}' project.yml)"
if [[ -z "$NAME" ]]; then
  echo "Could not read project name from project.yml" >&2
  exit 1
fi

ensure_chunui
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
