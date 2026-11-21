#!/usr/bin/env bash
# PostToolUse hook: lint a shell script right after Claude edits it.
# Exit 2 sends the findings back to Claude, so it fixes them in the same turn.
set -euo pipefail

# Missing tools must never block an edit: skip silently.
command -v jq >/dev/null || exit 0
command -v shellcheck >/dev/null || exit 0

file="$(jq -r '.tool_input.file_path // empty')"
case "$file" in
  *.sh | *.bash) ;;
  *) exit 0 ;;
esac
[[ -f "$file" ]] || exit 0

# warning and above: info/style notes (e.g. SC1091 unresolved source) would loop on noise
if ! output="$(shellcheck --severity=warning "$file" 2>&1)"; then
  printf 'shellcheck found issues in %s:\n%s\n' "$file" "$output" >&2
  exit 2
fi
