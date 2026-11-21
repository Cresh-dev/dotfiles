#!/usr/bin/env bash
# Bootstrap a Mac from this repo: Homebrew packages, Oh My Zsh + plugins,
# stow symlinks, mise runtimes. Safe to re-run; never overwrites files.
#
# Usage: ./install.sh [--dry-run]
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR
readonly MAC_PACKAGES=(zsh git vim starship ghostty aerospace mise cava tmux claude)
readonly OMZ_DIR="$HOME/.oh-my-zsh"
readonly OMZ_PLUGINS=(
  "fzf-tab https://github.com/Aloxaf/fzf-tab.git"
  "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git"
  "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

DRY_RUN=false

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# Print instead of executing when --dry-run is set.
run() {
  if [[ "$DRY_RUN" == true ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

parse_args() {
  case "${1:-}" in
    "") ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help) sed -n '2,6p' "$0"; exit 0 ;;
    *) die "unknown option: $1 (use --dry-run or --help)" ;;
  esac
}

check_prerequisites() {
  [[ "$(uname -s)" == "Darwin" ]] || die "this script is for macOS; Linux configs live in linux/"
  command -v brew >/dev/null || die "Homebrew missing: install it from https://brew.sh, then re-run"
  command -v git >/dev/null || die "git missing: run 'xcode-select --install'"
}

install_brew_packages() {
  log "Homebrew packages (Brewfile)"
  if brew bundle check --file="$DOTFILES_DIR/Brewfile" >/dev/null; then
    log "already satisfied"
  else
    run brew bundle install --file="$DOTFILES_DIR/Brewfile"
  fi
}

install_oh_my_zsh() {
  log "Oh My Zsh and plugins"
  # Clone instead of the official installer: the installer replaces ~/.zshrc.
  if [[ ! -d "$OMZ_DIR" ]]; then
    run git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
  fi
  local entry name url
  for entry in "${OMZ_PLUGINS[@]}"; do
    read -r name url <<<"$entry"
    if [[ ! -d "$OMZ_DIR/custom/plugins/$name" ]]; then
      run git clone --depth 1 "$url" "$OMZ_DIR/custom/plugins/$name"
    fi
  done
}

link_dotfiles() {
  log "Symlinks via stow: ${MAC_PACKAGES[*]}"
  cd "$DOTFILES_DIR"  # stow reads .stowrc from the current directory
  # Simulate first: stow refuses to overwrite real files, so report conflicts and stop.
  if ! stow --no --restow "${MAC_PACKAGES[@]}" 2>/dev/null; then
    stow --no --restow "${MAC_PACKAGES[@]}" 2>&1 | grep -i "conflict\|existing target" >&2 || true
    die "existing files block the symlinks: back them up, remove them and re-run"
  fi
  run stow --restow "${MAC_PACKAGES[@]}"
}

install_runtimes() {
  log "Language runtimes (mise)"
  run mise install
}

enable_git_hooks() {
  log "Git hooks for this repo (.githooks: secret scan before commit)"
  # Hooks in .git/hooks are not versioned; core.hooksPath points git at the tracked folder.
  run git -C "$DOTFILES_DIR" config core.hooksPath .githooks
}

check_git_identity() {
  if [[ ! -f "$HOME/.config/git/local" ]]; then
    log "Git identity not set. Create ~/.config/git/local (untracked) with:"
    printf '    [user]\n        name = <name>\n        email = <email>\n'
  fi
}

main() {
  parse_args "$@"
  check_prerequisites
  install_brew_packages
  install_oh_my_zsh
  link_dotfiles
  install_runtimes
  enable_git_hooks
  check_git_identity
  log "Done. Open a new terminal to load the shell config."
}

main "$@"
