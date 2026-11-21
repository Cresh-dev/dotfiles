#!/usr/bin/env bash
# Claude Code status line, minimal "rice" style:
#   <dir>  <branch>* │ <model> │ ▰▰▱▱ ctx% │ 5h rate% │ RAM free%
# Claude Code pipes a JSON object on stdin and shows the first line we print.
# Only ANSI colors 0-15, so the line follows the terminal theme (Ghostty: Apprentice).
set -euo pipefail

command -v jq >/dev/null || { echo "statusline: jq missing (ships with macOS 15+, or brew install jq)" >&2; exit 1; }

# Nerd Font glyphs as UTF-8 bytes: editors often drop Private Use Area chars,
# and \x escapes also work in macOS's bash 3.2 (\u needs bash 4.2+).
readonly I_DIR=$'\xef\x81\xbb'          # U+F07B  folder
readonly I_GIT=$'\xee\x82\xa0'          # U+E0A0  branch
readonly I_MODEL=$'\xf3\xb0\x9a\xa9'   # U+F06A9 robot
readonly I_RATE=$'\xf3\xb1\x90\x8b'    # U+F140B lightning
readonly I_RAM=$'\xf3\xb0\x8d\x9b'     # U+F035B memory chip

readonly BLUE=$'\e[34m' MAGENTA=$'\e[35m' YELLOW=$'\e[33m' RED=$'\e[31m' GREY=$'\e[90m' RESET=$'\e[0m'
readonly SEP=" ${GREY}│${RESET} "
readonly BAR_CELLS=8

# One jq call for every field (each call is a process spawn); "\t"-joined
# so empty fields survive (IFS=tab collapses runs, hence the "-" placeholder).
IFS=$'\t' read -r dir model ctx rate < <(
  jq -r '[
    (.workspace.current_dir // .cwd // "-"),
    (.model.display_name // "?"),
    (.context_window.used_percentage // 0),
    (.rate_limits.five_hour.used_percentage // "-")
  ] | map(tostring) | join("\t")'
)
[[ "$dir" == "-" ]] && dir=""
ctx="${ctx%%.*}"
rate="${rate%%.*}"

# Grey by default; yellow/red past the warning/critical thresholds.
level_color() {  # value warn crit
  if (( $1 >= $3 )); then printf '%s' "$RED"
  elif (( $1 >= $2 )); then printf '%s' "$YELLOW"
  else printf '%s' "$GREY"; fi
}

line=""
[[ -n "$dir" ]] && line+="${BLUE}${I_DIR} ${dir##*/}${RESET}"

if [[ -n "$dir" ]] && git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch="$(git -C "$dir" branch --show-current 2>/dev/null || true)"
  [[ -z "$branch" ]] && branch="$(git -C "$dir" rev-parse --short HEAD 2>/dev/null || true)"
  dirty=""
  # Tracked files only: scanning untracked files is slow in big repos
  if [[ -n "$(git -C "$dir" status --porcelain --untracked-files=no 2>/dev/null | head -1)" ]]; then
    dirty="${YELLOW}*"
  fi
  line+="  ${MAGENTA}${I_GIT} ${branch}${dirty}${RESET}"
fi

[[ -n "$line" ]] && line+="$SEP"
line+="${GREY}${I_MODEL} ${model}${RESET}"

filled=$(( ctx * BAR_CELLS / 100 ))
bar=""
for (( i = 0; i < BAR_CELLS; i++ )); do
  if (( i < filled )); then bar+="▰"; else bar+="▱"; fi
done
line+="${SEP}$(level_color "$ctx" 60 80)${bar} ${ctx}%${RESET}"

# Absent until the first API response, and only on Pro/Max subscriptions
if [[ "$rate" != "-" ]]; then
  line+="${SEP}$(level_color "$rate" 70 90)${I_RATE} 5h ${rate}%${RESET}"
fi

# RAM: 8 GB is the tightest limit on this Mac. sysctl is ~2 ms, memory_pressure ~1 s.
# Kernel pressure level: 1 normal, 2 warning, 4 critical (same as Activity Monitor).
if [[ "${STATUSLINE_NO_RAM:-0}" != 1 ]] && ram_free="$(sysctl -n kern.memorystatus_level 2>/dev/null)"; then
  case "$(sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null)" in
    4) ram_color="$RED" ;;
    2) ram_color="$YELLOW" ;;
    *) ram_color="$GREY" ;;
  esac
  line+="${SEP}${ram_color}${I_RAM} ${ram_free}%${RESET}"
fi

printf '%s\n' "$line"
