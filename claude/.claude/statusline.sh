#!/usr/bin/env bash
# Claude Code status line: folder, git branch (* if dirty), model, context bar.
# Claude Code pipes a JSON object on stdin and shows the first line we print.
set -euo pipefail

command -v jq >/dev/null || { echo "statusline: jq missing (ships with macOS 15+, or brew install jq)" >&2; exit 1; }

input="$(cat)"

dir="$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")"
model="$(jq -r '.model.display_name // "?"' <<<"$input")"
pct="$(jq -r '.context_window.used_percentage // 0' <<<"$input" | cut -d. -f1)"

readonly BLUE=$'\e[34m' GREY=$'\e[90m' YELLOW=$'\e[33m' RED=$'\e[31m' RESET=$'\e[0m'

branch=""
if [[ -n "$dir" ]] && git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch="$(git -C "$dir" branch --show-current 2>/dev/null || true)"
  # Tracked files only: scanning untracked files is slow in big repos
  if [[ -n "$(git -C "$dir" status --porcelain --untracked-files=no 2>/dev/null | head -1)" ]]; then
    branch="${branch}*"
  fi
fi

# 10-cell bar; turns yellow/red as auto-compact gets closer
filled=$(( pct / 10 ))
bar=""
for (( i = 0; i < 10; i++ )); do
  if (( i < filled )); then bar+="▓"; else bar+="░"; fi
done
color="$GREY"
if (( pct >= 80 )); then color="$RED"; elif (( pct >= 60 )); then color="$YELLOW"; fi

# RAM: 8 GB is the tightest limit on this Mac. sysctl is ~2 ms, memory_pressure ~1 s.
# Pressure level from the kernel: 1 normal, 2 warning, 4 critical (same as Activity Monitor).
ram=""
if ram_free="$(sysctl -n kern.memorystatus_level 2>/dev/null)"; then
  case "$(sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null)" in
    4) ram_color="$RED" ;;
    2) ram_color="$YELLOW" ;;
    *) ram_color="$GREY" ;;
  esac
  ram=" · ${ram_color}RAM ${ram_free}% libera${RESET}"
fi

printf '%s%s%s' "$BLUE" "${dir##*/}" "$RESET"
[[ -n "$branch" ]] && printf ' %s%s%s' "$GREY" "$branch" "$RESET"
printf ' · %s · %s%s %s%%%s%s\n' "$model" "$color" "$bar" "$pct" "$RESET" "$ram"
