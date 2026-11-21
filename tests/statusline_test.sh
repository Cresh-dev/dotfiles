#!/usr/bin/env bash
# Tests for claude/.claude/statusline.sh: feeds fake Claude Code JSON and
# checks the rendered line. Run: STATUSLINE_NO_RAM=1 bash tests/statusline_test.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SCRIPT="$ROOT/claude/.claude/statusline.sh"
export STATUSLINE_NO_RAM=1  # RAM changes every second: keep output deterministic

# Nerd Font glyphs as UTF-8 bytes: editors often drop Private Use Area chars
readonly I_DIR=$'\xef\x81\xbb'          # U+F07B  folder
readonly I_GIT=$'\xee\x82\xa0'          # U+E0A0  branch
readonly I_MODEL=$'\xf3\xb0\x9a\xa9'   # U+F06A9 robot
readonly I_RATE=$'\xf3\xb1\x90\x8b'    # U+F140B lightning

failures=0
# Explicit template: BSD mktemp ignores $TMPDIR without one
tmp="$(mktemp -d "${TMPDIR:-/tmp}/statusline-test.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

pass() { printf 'PASS %s\n' "$1"; }
fail() { printf 'FAIL %s: %s\n' "$1" "$2"; failures=$((failures + 1)); }

strip_ansi() { sed $'s/\e\\[[0-9;]*m//g'; }
render() { "$SCRIPT" <<<"$1"; }

expect_contains() {  # name haystack needle...
  local name="$1" out="$2"; shift 2
  local needle
  for needle in "$@"; do
    [[ "$out" == *"$needle"* ]] || { fail "$name" "expected '$needle' in '$out'"; return; }
  done
  pass "$name"
}

expect_absent() {  # name haystack needle...
  local name="$1" out="$2"; shift 2
  local needle
  for needle in "$@"; do
    [[ "$out" != *"$needle"* ]] || { fail "$name" "unexpected '$needle' in '$out'"; return; }
  done
  pass "$name"
}

git_q() { git -c user.name=t -c user.email=t@t -c commit.gpgsign=false "$@" >/dev/null 2>&1; }

# Repo with a modified tracked file -> dirty marker
repo="$tmp/myrepo"
mkdir -p "$repo"
git_q -C "$repo" init -b main
echo a >"$repo/f"
git_q -C "$repo" add f
git_q -C "$repo" commit -m init
echo b >"$repo/f"

full_json='{"workspace":{"current_dir":"'"$repo"'"},"model":{"display_name":"Opus 5.5"},"context_window":{"used_percentage":38.7},"rate_limits":{"five_hour":{"used_percentage":22.2}}}'
raw_full="$(render "$full_json")"
out="$(strip_ansi <<<"$raw_full")"
expect_contains full "$out" "$I_DIR myrepo" "$I_GIT main*" "$I_MODEL Opus 5.5" "▰▰▰▱▱▱▱▱ 38%" "$I_RATE 5h 22%"

out="$(render '{"workspace":{"current_dir":"'"$repo"'"},"model":{"display_name":"Opus 5.5"},"context_window":{"used_percentage":10}}' | strip_ansi)"
expect_absent no-rate "$out" "5h" "null"

plain="$tmp/plain"
mkdir -p "$plain"
out="$(render '{"workspace":{"current_dir":"'"$plain"'"},"model":{"display_name":"Opus 5.5"}}' | strip_ansi)"
expect_absent no-git "$out" "$I_GIT"

if out="$(render '{}' | strip_ansi)"; then
  expect_contains empty "$out" "0%"
else
  fail empty "non-zero exit"
fi

detached="$tmp/detached"
git_q clone "$repo" "$detached"
git_q -C "$detached" checkout --detach
sha="$(git -C "$detached" rev-parse --short HEAD)"
out="$(render '{"workspace":{"current_dir":"'"$detached"'"},"model":{"display_name":"Opus 5.5"}}' | strip_ansi)"
expect_contains detached "$out" "$sha"

expect_absent colors "$raw_full" "38;2;" "38;5;"

# Empty strings must not shift the other fields
if out="$(render '{"workspace":{"current_dir":""},"model":{"display_name":"Opus 5.5"},"context_window":{"used_percentage":40}}' 2>&1 | strip_ansi)"; then
  expect_contains empty-dir "$out" "$I_MODEL Opus 5.5" "▰▰▰▱▱▱▱▱ 40%"
else
  fail empty-dir "non-zero exit: $out"
fi
out="$(render '{"workspace":{"current_dir":"'"$plain"'"},"model":{"display_name":""},"context_window":{"used_percentage":40},"rate_limits":{"five_hour":{"used_percentage":10}}}' 2>&1 | strip_ansi)"
expect_contains empty-model "$out" "▰▰▰▱▱▱▱▱ 40%" "$I_RATE 5h 10%"

# Non-numeric percentages fall back instead of crashing or being evaluated by bash arithmetic
marker="$tmp/pwned"
# shellcheck disable=SC2016  # the $(...) must stay literal: it is the injection payload
out="$(render '{"model":{"display_name":"M"},"context_window":{"used_percentage":"BAR_CELLS[$(touch '"$marker"')]"},"rate_limits":{"five_hour":{"used_percentage":"abc"}}}' 2>&1 | strip_ansi)"
expect_contains bad-pct "$out" "0%"
expect_absent bad-pct-rate "$out" "5h" "error"
if [[ -e "$marker" ]]; then fail no-injection "arithmetic expansion ran a command"; else pass no-injection; fi
out="$(render '{"model":{"display_name":"M"},"context_window":{"used_percentage":5},"rate_limits":{"five_hour":{"used_percentage":1e-7}}}' 2>&1 | strip_ansi)"
expect_contains tiny-rate "$out" "5h 0%"

elapsed_ms="$(perl -MTime::HiRes=time -e '
  my $t = time; system(@ARGV) == 0 or exit 1; printf "%d", (time - $t) * 1000;
' bash -c "\"\$0\" <<<\"\$1\" >/dev/null" "$SCRIPT" "$full_json")"
if (( elapsed_ms < 100 )); then pass "speed (${elapsed_ms} ms)"; else fail speed "${elapsed_ms} ms >= 100 ms"; fi

(( failures == 0 )) || { printf '%d failed\n' "$failures"; exit 1; }
printf 'all passed\n'
