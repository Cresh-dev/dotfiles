# ── Oh My Zsh ────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""   # prompt is handled by Starship (see bottom)

# Completamenti extra (zsh-completions + quelli di brew)
fpath=(/opt/homebrew/share/zsh-completions /opt/homebrew/share/zsh/site-functions $fpath)

# Ordine importante: fzf-tab dopo compinit, syntax-highlighting per ultimo
plugins=(
  git
  fzf-tab
  zsh-autosuggestions
  web-search
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ── Cronologia ───────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY       # salva timestamp
setopt SHARE_HISTORY          # condivisa tra tab/finestre
setopt HIST_IGNORE_ALL_DUPS   # niente duplicati
setopt HIST_IGNORE_SPACE      # comandi con spazio iniziale non salvati
setopt HIST_REDUCE_BLANKS

# ── Comodità ─────────────────────────────────────────────
setopt AUTO_CD                # scrivi il nome di una cartella per entrarci
setopt INTERACTIVE_COMMENTS
bindkey '^[[A' history-search-backward   # ↑ cerca nella cronologia col prefisso digitato
bindkey '^[[B' history-search-forward    # ↓

# ── fzf (Ctrl-R cronologia, Ctrl-T file, Alt-C cartelle) ──
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border=rounded --info=inline"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {}'"
source <(fzf --zsh)

# fzf-tab: anteprime durante il completamento con Tab
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --icons --color=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

# ── zoxide: "z progetto" salta alla cartella più usata ────
eval "$(zoxide init zsh)"

# ── bat ──────────────────────────────────────────────────
export BAT_THEME="ansi"   # usa la palette del tema del terminale
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# ── Alias ────────────────────────────────────────────────
alias ls='eza -a --icons --group-directories-first'
alias ll='eza -al --icons --git --group-directories-first'
alias lt='eza -a --tree --level=2 --icons --ignore-glob=".git|node_modules"'
alias cat='bat --paging=never --style=plain'
alias lg='lazygit'
alias top='btop'
alias reload='exec zsh'
alias ..='cd ..'
alias ...='cd ../..'
alias path='echo $PATH | tr ":" "\n"'

# mkdir + cd in un colpo
mkcd() { mkdir -p "$1" && cd "$1"; }

# ── Versioni dei linguaggi (Node, Python, Ruby, Go, Java) ─
# Config globale in ~/.config/mise/config.toml
eval "$(mise activate zsh)"

# ── Override locali, non tracciati (repo pubblico) ───────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ── Prompt: deve restare per ultimo ──────────────────────
eval "$(starship init zsh)"
