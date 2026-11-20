---
name: commit
description: Commit changes following Alessio's git rules (Conventional Commits, one purpose per commit, secret scan, no AI attribution). Use when asked to commit.
argument-hint: "[optional hint for message or scope]"
---

Commit the current changes. A repo's own CLAUDE.md rules (e.g. ObsidianVault) override these.

1. Inspect: `git status -sb`, `git diff --stat`, staged vs unstaged. If on `main`/`master` of a code repo and the change is non-trivial, propose a branch first.
2. Group changes into single-purpose commits. If more than one group, show the plan (files → message) before committing.
3. Block sensitive content. Never stage `.env*` (except `.env.example`), `*.pem`, `*.key`, credentials, DB dumps, large binaries. Scan what will be committed:
   `git diff --cached | grep -nE 'BEGIN [A-Z ]*PRIVATE KEY|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_|sk-ant|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|xox[abpr]-|(password|secret|token|api[_-]?key)\s*[:=]\s*\S{8,}'`
   On a hit: stop, unstage, report file and line with the value masked.
4. Message: English, Conventional Commits (`feat|fix|docs|chore|refactor|test(scope)?: subject`), imperative, subject ≤ 72 chars, body explains *why* when not obvious.
   Never mention Claude/AI, no `Co-Authored-By`, no "Generated with" lines.
5. Stage explicit paths (no blind `git add -A`), commit, then show `git log --oneline -5`.
6. Do not push. Ask the user; push only after an explicit yes.

Reply in Italian with a short summary: commits created and anything left unstaged.
