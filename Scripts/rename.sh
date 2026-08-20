#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <AppName> <bundle.id>" >&2
  echo "  AppName   Swift 标识符，例如 NotesShelf" >&2
  echo "  bundle.id 例如 com.you.notesshelf" >&2
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

NAME="$1"
BUNDLE="$2"

if [[ ! "$NAME" =~ ^[A-Za-z][A-Za-z0-9]*$ ]]; then
  echo "AppName must be a Swift type identifier (letters and digits, start with a letter)." >&2
  exit 1
fi

if [[ ! "$BUNDLE" =~ ^[A-Za-z0-9]+(\.[A-Za-z0-9-]+)+$ ]]; then
  echo "bundle id looks invalid." >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PREFIX="$(printf '%s' "$NAME" | perl -pe 's/^(.)/\L$1/')"

replace_in_tree() {
  local from="$1"
  local to="$2"
  local file
  while IFS= read -r file; do
    perl -i -pe "s/\Q${from}\E/${to}/g" "$file"
  done < <(find . \
    \( -path './.git' -o -path './skills/chunui' -o -path './DerivedData' -o -path './.build' -o -path './node_modules' \) -prune \
    -o -type f \( -name '*.swift' -o -name '*.yml' -o -name '*.yaml' -o -name '*.md' -o -name '*.sh' -o -name '*.json' \) -print)
}

replace_in_tree "macTemplate" "$PREFIX"
replace_in_tree "com.chunui.mac-template" "$BUNDLE"
replace_in_tree "MacTemplate" "$NAME"

if command -v xcodegen >/dev/null 2>&1; then
  xcodegen generate
  echo "Renamed to ${NAME} (${BUNDLE}). Preference prefix: ${PREFIX}. Open ${NAME}.xcodeproj"
else
  echo "Renamed to ${NAME} (${BUNDLE}). Preference prefix: ${PREFIX}. Run: xcodegen generate"
fi
