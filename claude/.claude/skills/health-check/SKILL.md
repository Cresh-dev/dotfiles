---
name: health-check
description: Read-only health report of this Mac's dev setup (updates, RAM, disk, caches, runtimes, dotfiles drift).
disable-model-invocation: true
model: sonnet
---

Read-only: run checks and report. Never install, upgrade, delete or commit anything.

Checks (skip any whose tool is missing and say so):
- macOS: `sw_vers -productVersion`; `softwareupdate -l` (may need to run outside the sandbox; if blocked, just say so).
- Homebrew: `brew outdated`, `brew doctor`, `brew bundle check --file=$HOME/dotfiles/Brewfile`.
- Runtimes: `mise outdated`, `mise doctor | head -40`.
- RAM (8 GB is the main constraint): `memory_pressure | tail -1`, top 8 processes by memory `ps -axo rss=,comm= -m | head -8` (convert KB to MB), `ollama ps` (loaded models), `orbctl status` and `docker ps` (running containers), `minikube status` if a cluster exists.
- Disk: `df -h /`, sizes of `~/Library/Caches`, `~/.npm`, `~/.cache`, `~/.Trash`, `~/.ollama/models` via `du -sh`.
- Dotfiles: `git -C ~/dotfiles status -sb` and whether the Brewfile is out of date.

Report in Italian as a table: area · state (✅ / ⚠️ / ❌) · detail · suggested action with the exact command. End with the top 3 actions by impact. Flag anything that risks the 8 GB RAM limit first.
