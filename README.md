# dotfiles

Personal configuration for macOS (Apple Silicon), managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level folder is a *stow package*: its contents mirror paths relative to `$HOME`.

| Package     | Links to                                  | What                                 |
|-------------|-------------------------------------------|--------------------------------------|
| `zsh`       | `~/.zshrc`, `~/.zprofile`                 | Oh My Zsh, fzf, zoxide, aliases      |
| `starship`  | `~/.config/starship.toml`                 | Prompt (Pure preset, single line)    |
| `git`       | `~/.config/git/config`, `~/.config/git/ignore` | Git config + global gitignore   |
| `vim`       | `~/.vimrc`                                | Vim                                  |
| `ghostty`   | `~/.config/ghostty/`                      | Terminal                             |
| `aerospace` | `~/.config/aerospace/aerospace.toml`      | Tiling window manager                |
| `mise`      | `~/.config/mise/config.toml`              | Global Node/Python/Ruby/Go/Java      |
| `cava`      | `~/.config/cava/`                         | Audio visualizer                     |
| `claude`    | `~/.claude/settings.json`, `statusline.sh`, `rules/`, `skills/`, `output-styles/` | Claude Code: permissions, Bash sandbox, status line, notifications, plugins, personal skills, look |

Claude Code look: theme `dark-ansi` (uses the terminal's 16 ANSI colors, so it follows Ghostty's theme),
Italian nerd `spinnerVerbs`, and the `Cresh` output style (`output-styles/cresh.md`: Italian, terse,
minimal "insight" blocks). The status line (`statusline.sh`) prints
`dir  branch* │ model │ ▰▰▱▱ ctx% │ 5h rate% │ RAM free%` with Nerd Font icons and ANSI colors only;
test it with `bash tests/statusline_test.sh`. Path-scoped rules in `rules/` cover Docker, Kubernetes,
GitHub Actions, Python, JS/TS and shell. After adding a file to the package, run `stow --restow claude`.
The `"<name>@synced": false` entries in `enabledPlugins` are intentional: plugins synced from claude.ai
load by default, and those entries switch them off.

Personal skills (`claude/.claude/skills/`): `/commit` (Conventional Commits + secret scan), `/dotfiles-sync`
(Brewfile, stow health, commit), `/new-project` (Python/Node scaffold), `/health-check` (read-only machine report).
All but `/commit` set `disable-model-invocation: true`, so they cost no context until invoked.

`~/.claude/CLAUDE.md` is intentionally not tracked: it holds personal context. The plugins listed in
`settings.json` come from the official marketplace (`claude plugin install <name>@claude-plugins-official`);
the LSP plugins need `pyright`, `typescript-language-server` and `typescript`, installed globally via mise.

Not stowed:

- `Brewfile`: every Homebrew formula, cask and VS Code extension (`brew bundle`).
- `linux/`: old Hyprland setup (hypr, waybar, rofi, mako, kitty, swappy, zsh), kept for reference.

## Install on a new Mac

1. Install [Homebrew](https://brew.sh) and the Xcode Command Line Tools (`xcode-select --install`).
2. Clone and preview, then run:

   ```sh
   git clone git@github.com:Cresh-dev/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./install.sh --dry-run   # shows what would happen
   ./install.sh
   ```

   The script installs the Brewfile, Oh My Zsh with its plugins, links every package, installs the
   mise runtimes and enables the repo's git hooks. It never overwrites existing files: on conflicts it
   stops and tells you which ones.
3. Create your git identity (see below) and open a new terminal.

## Private, untracked files

This repo is **public**. Anything personal stays in local files that are never committed:

- `~/.config/git/local` — git identity, included at the end of the git config:

  ```ini
  [user]
      name = <name>
      email = <email>
      # Optional: SSH commit signing (gpg.format = ssh is set in the shared config)
      signingkey = key::ssh-ed25519 AAAA... <comment>
  [commit]
      gpgsign = true
  [tag]
      gpgsign = true
  ```

- `~/.config/git/allowed_signers` — public keys trusted by `git log --show-signature`, one per line:
  `<email> namespaces="git" ssh-ed25519 AAAA...`. Add the same key on GitHub as a *Signing key*
  to get the "Verified" badge.

- `~/.zshrc.local` — machine-specific shell settings, sourced by `.zshrc` if present.

As a safety net, `.githooks/pre-commit` runs [gitleaks](https://github.com/gitleaks/gitleaks) on the
staged changes and refuses the commit if it finds a secret (or if gitleaks is missing).
`install.sh` enables it with `git config core.hooksPath .githooks`. Scan the whole history with
`gitleaks git --redact .`.

## Daily use

Run stow from the repo folder, so it picks up `.stowrc` (`--target=~ --no-folding`):

```sh
cd ~/dotfiles
stow ghostty         # link a package
stow -D ghostty      # unlink it
stow -R ghostty      # relink after adding/removing files
stow -n -v ghostty   # dry run
```

`--no-folding` makes stow link single files instead of whole folders, so files that apps create next to
your config (like `~/.config/git/local`) never end up inside this repo.

Keep the Brewfile in sync after installing or removing packages:

```sh
brew bundle dump --force --no-npm --no-go --no-cargo --no-uv --file=~/dotfiles/Brewfile
```
