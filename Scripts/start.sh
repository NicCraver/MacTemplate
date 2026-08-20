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

DERIVED="$ROOT/.build/DerivedData"
xcodebuild \
  -project "${NAME}.xcodeproj" \
  -scheme "${NAME}" \
  -configuration Debug \
  -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath "$DERIVED" \
  build

APP="$DERIVED/Build/Products/Debug/${NAME}.app"
if [[ ! -d "$APP" ]]; then
  echo "Build succeeded but app not found: $APP" >&2
  exit 1
fi

open "$APP"
