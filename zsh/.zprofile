# Login shell: environment and PATH only. Interactive setup lives in .zshrc.

eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"
export MANPATH="$HOME/linux-man/man-pages-6.10:$MANPATH"
export EDITOR="vim"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
