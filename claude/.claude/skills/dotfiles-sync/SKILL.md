---
name: dotfiles-sync
description: Sync ~/dotfiles with the current machine state (Brewfile, stow links, untracked configs), then commit.
disable-model-invocation: true
model: sonnet
---

Repo: `~/dotfiles` (public, GNU Stow, `.stowrc` = `--target=~ --no-folding`). Packages are listed in `MAC_PACKAGES` in `install.sh`.

1. `git -C ~/dotfiles status -sb`, then `git -C ~/dotfiles pull --ff-only`. Stop if the tree has unexpected changes you can't explain.
2. Brewfile: `brew bundle dump --force --no-npm --no-go --no-cargo --no-uv --file=$HOME/dotfiles/Brewfile`, then show `git -C ~/dotfiles diff --stat Brewfile` and the added/removed lines.
3. Stow health, from inside `~/dotfiles`: `stow -n -v --restow <packages>`. Report conflicts (a real file where a link should be) and broken links into `~/dotfiles`. Don't fix them without asking: the fix moves files.
4. Untracked configs: list `~/.config/*` and `~/.claude/{skills,rules}` entries not covered by a package. Only report them with a suggestion; tracking needs approval and a privacy check (the repo is public).
5. Commit what changed following the /commit rules (secret scan, Conventional Commits, no AI attribution). `git -C /Users/alessio/dotfiles add|commit` are pre-approved.
6. Ask before `git push`.

Reply in Italian: a short table of what changed, what was committed, and what needs the user's decision.
