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

   The script installs the Brewfile, Oh My Zsh with its plugins, links every package and installs the
   mise runtimes. It never overwrites existing files: on conflicts it stops and tells you which ones.
3. Create your git identity (see below) and open a new terminal.

## Private, untracked files

This repo is **public**. Anything personal stays in local files that are never committed:

- `~/.config/git/local` — git identity, included at the end of the git config:

  ```ini
  [user]
      name = <name>
      email = <email>
  ```

- `~/.zshrc.local` — machine-specific shell settings, sourced by `.zshrc` if present.

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
